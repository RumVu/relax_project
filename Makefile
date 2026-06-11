# Digital Cigarette Break — developer shortcuts.
# Usage: `make help` to list targets.

SHELL := /bin/bash

.DEFAULT_GOAL := help

# ---- Infrastructure ---------------------------------------------------------

.PHONY: infra-up
infra-up: ## Start Postgres + Redis only
	docker compose up -d postgres redis

.PHONY: infra-down
infra-down: ## Stop Postgres + Redis (keep volumes)
	docker compose stop postgres redis

.PHONY: infra-reset
infra-reset: ## Stop + remove volumes (DESTRUCTIVE)
	docker compose down -v

.PHONY: up
up: ## Start full stack (infra + backend + web) via compose profiles
	JWT_SECRET="$${JWT_SECRET:-$$(openssl rand -hex 32)}" docker compose --profile full up -d --build

.PHONY: down
down: ## Stop all compose services
	docker compose --profile full down

.PHONY: share
share: ## Build + start full stack bound to your LAN IP so anyone on wifi can hit IP:3233
	@set -e; \
	IP="$${SHARE_IP:-$$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || hostname -I 2>/dev/null | awk '{print $$1}')}"; \
	if [ -z "$$IP" ]; then \
	  echo "✗ Không tìm thấy LAN IP — set SHARE_IP=192.168.x.x make share"; \
	  exit 1; \
	fi; \
	echo "→ Dùng LAN IP: $$IP"; \
	export JWT_SECRET="$${JWT_SECRET:-$$(openssl rand -hex 24)}"; \
	export NEXT_PUBLIC_API_URL="http://$$IP:6823"; \
	export CORS_ORIGINS="http://localhost:3233,http://$$IP:3233,http://localhost:3000"; \
	docker compose --profile full up -d --build; \
	echo ""; \
	echo "════════════════════════════════════════════════════════════"; \
	echo "  🌍 Web dashboard:  http://$$IP:3233"; \
	echo "  🔌 Backend API:    http://$$IP:6823"; \
	echo "  📘 Swagger docs:   http://$$IP:6823/docs"; \
	echo ""; \
	echo "  Gửi link http://$$IP:3233 cho người dùng cùng wifi."; \
	echo "  Stop: make down"; \
	echo "════════════════════════════════════════════════════════════"

.PHONY: share-ip
share-ip: ## In LAN IP máy đang dùng (cho biết để gửi cho khách)
	@ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || hostname -I 2>/dev/null | awk '{print $$1}'

# Vercel frontend (production) + backend ở docker + Cloudflare tunnel.
# Dùng khi a muốn người ngoài internet vô frontend Vercel mà vẫn gọi
# được backend chạy trên máy a. Không tốn $, URL frontend cố định.
.PHONY: share-vercel
share-vercel: ## Backend docker + tunnel public; frontend = Vercel
	scripts/share-vercel.sh

.PHONY: doctor
doctor: ## Kiểm tra prerequisites (docker, cloudflared, ports)
	@echo "→ Docker:"; \
	if command -v docker >/dev/null 2>&1; then \
	  echo "  ✓ $$(docker --version)"; \
	  if docker info >/dev/null 2>&1; then echo "  ✓ daemon up"; \
	  else echo "  ✗ daemon DOWN — open -a Docker, đợi 30s"; fi; \
	else echo "  ✗ chưa cài"; fi; \
	echo "→ cloudflared:"; \
	if command -v cloudflared >/dev/null 2>&1; then \
	  echo "  ✓ $$(cloudflared --version 2>&1 | head -1)"; \
	else echo "  ✗ chưa cài (brew install cloudflared)"; fi; \
	echo "→ Port 6823 (backend):"; \
	if curl -sf http://localhost:6823/health >/dev/null 2>&1; then \
	  echo "  ✓ backend đã chạy + healthy"; \
	elif lsof -nP -iTCP:6823 -sTCP:LISTEN >/dev/null 2>&1; then \
	  echo "  ⚠ port chiếm bởi process KHÁC — chạy 'lsof -i :6823' để xem"; \
	else echo "  ✓ trống (share-vercel sẽ boot backend)"; fi; \
	echo "→ JWT_SECRET:"; \
	if [ -n "$$JWT_SECRET" ]; then echo "  ✓ set ($${#JWT_SECRET} chars)"; \
	else echo "  ℹ chưa set — share-vercel sẽ tự tạo"; fi

.PHONY: tunnel-url
tunnel-url: ## In URL tunnel hiện tại (từ .tunnel-url) — copy vào Vercel
	@if [ -f .tunnel-url ]; then \
	  echo "$$(cat .tunnel-url)"; \
	else \
	  echo "✗ Chưa có tunnel — chạy 'make share-vercel' trước"; exit 1; \
	fi

.PHONY: backend-stop
backend-stop: ## Stop backend docker stack (giữ data)
	docker compose --profile api down

# ---- Tailscale Funnel (URL cố định, auto-restart) --------------------------
# Sau setup 1 lần (xem docs/14-tailscale-funnel.md): URL không đổi giữa
# các restart. Phù hợp để Vercel env trỏ tới 1 lần xài mãi.

.PHONY: funnel
funnel: ## Backend + Tailscale Funnel (auto-load apps/backend/.env nếu có)
	@# Auto-source apps/backend/.env nếu tồn tại — để a không phải export
	@# TS_AUTHKEY, SUPABASE_*, JWT_SECRET mỗi lần reboot.
	@set -a; [ -f apps/backend/.env ] && . ./apps/backend/.env; set +a; \
	if [ -z "$$TS_AUTHKEY" ]; then \
	  echo "✗ Cần TS_AUTHKEY trong env hoặc apps/backend/.env"; \
	  echo "  Setup: https://login.tailscale.com/admin/settings/keys"; \
	  echo "  Doc:   docs/14-tailscale-funnel.md"; \
	  exit 1; \
	fi; \
	export JWT_SECRET="$${JWT_SECRET:-$$(openssl rand -hex 32)}"; \
	docker compose --profile api --profile funnel up -d --build

.PHONY: funnel-url
funnel-url: ## In URL công khai Tailscale Funnel hiện tại
	@if ! docker ps --format '{{.Names}}' | grep -q digital-cigarette-tailscale; then \
	  echo "✗ Tailscale container chưa chạy — make funnel trước"; exit 1; \
	fi
	@docker exec digital-cigarette-tailscale tailscale status --json 2>/dev/null \
	  | python3 -c "import json,sys; d=json.load(sys.stdin); print('https://' + d['Self']['DNSName'].rstrip('.'))"

.PHONY: funnel-status
funnel-status: ## Tailscale status + funnel routes
	@docker exec digital-cigarette-tailscale tailscale status
	@echo "---"
	@docker exec digital-cigarette-tailscale tailscale funnel status

.PHONY: funnel-down
funnel-down: ## Stop chỉ Tailscale container (backend vẫn chạy)
	docker compose --profile funnel stop tailscale

.PHONY: logs
logs: ## Tail logs for all running compose services
	docker compose logs -f --tail=200

# ---- Backend ---------------------------------------------------------------

.PHONY: backend-install
backend-install: ## Install backend deps
	npm --workspace apps/backend install

.PHONY: backend-dev
backend-dev: ## Run backend in watch mode
	npm run dev:backend

.PHONY: backend-build
backend-build: ## Build backend (nest build)
	npm run build:backend

.PHONY: backend-test
backend-test: ## Backend unit tests
	npm --workspace apps/backend run test

.PHONY: backend-test-e2e
backend-test-e2e: ## Backend e2e tests (needs Postgres + Redis up)
	npm --workspace apps/backend run test:e2e

.PHONY: prisma-migrate
prisma-migrate: ## Apply Prisma migrations
	npm run prisma:migrate:deploy

.PHONY: prisma-seed
prisma-seed: ## Seed catalog + demo data
	npm run prisma:seed

.PHONY: prisma-cleanup
prisma-cleanup: ## Wipe test-data only
	npm run prisma:cleanup-test-data

# ---- Database Backup & Version ----------------------------------------------

.PHONY: db-version
db-version: ## Show DB version, migration status & health
	scripts/db-version.sh

.PHONY: db-version-json
db-version-json: ## DB version as JSON (for CI/scripts)
	scripts/db-version.sh --json

.PHONY: db-backup
db-backup: ## Create timestamped DB backup (optional tag: make db-backup TAG=before-deploy)
	scripts/db-backup.sh $(TAG)

.PHONY: db-restore
db-restore: ## Restore DB from a backup (interactive picker or FILE=path)
	scripts/db-restore.sh $(FILE)

.PHONY: db-snapshot
db-snapshot: ## Schema snapshot (NAME required: make db-snapshot NAME=before-feature-x)
	scripts/db-snapshot.sh $(NAME)

.PHONY: db-snapshot-data
db-snapshot-data: ## Schema + data snapshot (NAME required)
	scripts/db-snapshot.sh $(NAME) --with-data

.PHONY: db-snapshot-list
db-snapshot-list: ## List all schema snapshots
	scripts/db-snapshot.sh --list

.PHONY: db-snapshot-diff
db-snapshot-diff: ## Diff two snapshots (A and B required: make db-snapshot-diff A=before B=after)
	scripts/db-snapshot.sh --diff $(A) $(B)

# ---- Web -------------------------------------------------------------------

.PHONY: web-install
web-install: ## Install web deps
	npm --workspace apps/web install

.PHONY: web-dev
web-dev: ## Run Next.js dev server
	npm run dev:web

.PHONY: web-build
web-build: ## Build Next.js
	npm run build:web

.PHONY: web-test-e2e
web-test-e2e: ## Run Playwright smoke (auto-starts the web server)
	npm --workspace apps/web run test:e2e

# ---- Cloudflare tunnel -----------------------------------------------------

.PHONY: tunnel
tunnel: ## Backend + web Cloudflare quick tunnels (services must be running)
	scripts/tunnel.sh

.PHONY: tunnel-backend
tunnel-backend: ## Backend-only Cloudflare tunnel
	scripts/tunnel.sh --backend

.PHONY: tunnel-web
tunnel-web: ## Web-only Cloudflare tunnel
	scripts/tunnel.sh --web

# ---- Quality ---------------------------------------------------------------

.PHONY: lint
lint: ## Lint backend + web
	-npm --workspace apps/backend run lint
	-npm --workspace apps/web run lint

.PHONY: test
test: backend-test ## Alias: backend unit tests

.PHONY: test-all
test-all: backend-test backend-test-e2e web-test-e2e ## Run every test suite

.PHONY: clean
clean: ## Remove build artefacts
	rm -rf apps/backend/dist apps/web/.next apps/web/test-results

# ---- Mobile (Flutter) ------------------------------------------------------

FLUTTER_DIR := apps/mobile/relax_app
# Use fvm if it is installed, otherwise fallback to flutter
FLUTTER_BIN := $(shell command -v fvm >/dev/null 2>&1 && echo "fvm flutter" || echo "flutter")

.PHONY: mobile-run
mobile-run: ## Run Flutter app (production API)
	cd $(FLUTTER_DIR) && $(FLUTTER_BIN) run

.PHONY: mobile-run-local
mobile-run-local: ## Run Flutter app targeting localhost backend
	cd $(FLUTTER_DIR) && $(FLUTTER_BIN) run --dart-define=API_BASE=http://localhost:6823/v1

.PHONY: mobile-run-lan
mobile-run-lan: ## Run Flutter app targeting LAN backend (auto-detect IP)
	@set -e; \
	IP="$${SHARE_IP:-$$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || hostname -I 2>/dev/null | awk '{print $$1}')}"; \
	if [ -z "$$IP" ]; then \
	  echo "✗ Không tìm thấy LAN IP — set SHARE_IP=192.168.x.x make mobile-run-lan"; \
	  exit 1; \
	fi; \
	echo "→ API: http://$$IP:6823/v1"; \
	cd $(FLUTTER_DIR) && $(FLUTTER_BIN) run --dart-define=API_BASE="http://$$IP:6823/v1"

.PHONY: mobile-test
mobile-test: ## Run Flutter unit & widget tests
	cd $(FLUTTER_DIR) && $(FLUTTER_BIN) test

.PHONY: mobile-analyze
mobile-analyze: ## Run Flutter static analysis
	cd $(FLUTTER_DIR) && $(FLUTTER_BIN) analyze

.PHONY: mobile-build-apk
mobile-build-apk: ## Build release APK (production API)
	cd $(FLUTTER_DIR) && $(FLUTTER_BIN) build apk --release

.PHONY: mobile-build-ios
mobile-build-ios: ## Build release iOS (production API)
	cd $(FLUTTER_DIR) && $(FLUTTER_BIN) build ios --release --no-codesign

# ---- Help ------------------------------------------------------------------

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage: make \033[36m<target>\033[0m\n\nTargets:\n"} \
	/^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
