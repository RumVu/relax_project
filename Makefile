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
