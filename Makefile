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
	docker compose --profile full up -d --build

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
VERCEL_WEB_URL ?= https://relax-project-web-dashboard.vercel.app

.PHONY: share-vercel
share-vercel: ## Backend docker + tunnel public; frontend = Vercel
	@set -e; \
	export JWT_SECRET="$${JWT_SECRET:-$$(openssl rand -hex 24)}"; \
	export CORS_ORIGINS="$(VERCEL_WEB_URL),http://localhost:3000,http://localhost:3233"; \
	echo "→ Start backend (docker) với CORS cho $(VERCEL_WEB_URL)..."; \
	docker compose --profile api up -d --build; \
	echo "→ Đợi backend healthy..."; \
	for i in 1 2 3 4 5 6 7 8 9 10; do \
	  if curl -sf http://localhost:6823/health >/dev/null 2>&1; then echo "  ✓ backend ready"; break; fi; \
	  sleep 2; \
	done; \
	echo ""; \
	echo "→ Mở Cloudflare tunnel cho backend..."; \
	echo "  (URL backend sẽ in ra dưới — copy phần https://*.trycloudflare.com)"; \
	echo ""; \
	echo "════════════════════════════════════════════════════════════"; \
	echo "  Sau khi thấy URL backend:"; \
	echo "    1. Vercel → Project → Settings → Environment Variables"; \
	echo "    2. Set NEXT_PUBLIC_API_URL=<URL backend trycloudflare>"; \
	echo "    3. Redeploy Vercel (Deployments → ⋯ → Redeploy)"; \
	echo "    4. Frontend: $(VERCEL_WEB_URL)"; \
	echo ""; \
	echo "  Ctrl+C để stop tunnel. Backend docker vẫn chạy — dùng"; \
	echo "  \`make down\` để stop hẳn."; \
	echo "════════════════════════════════════════════════════════════"; \
	echo ""; \
	scripts/tunnel.sh --backend

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

# ---- Help ------------------------------------------------------------------

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage: make \033[36m<target>\033[0m\n\nTargets:\n"} \
	/^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
