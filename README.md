<p align="center">
  <img src="https://img.shields.io/badge/NestJS-E0234E?style=for-the-badge&logo=nestjs&logoColor=white" />
  <img src="https://img.shields.io/badge/Next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white" />
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" />
  <img src="https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white" />
  <img src="https://img.shields.io/badge/Prisma-2D3748?style=for-the-badge&logo=prisma&logoColor=white" />
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/Supabase-3FCF8E?style=for-the-badge&logo=supabase&logoColor=white" />
</p>

<h1 align="center">Relax Before Stress Comes</h1>

<p align="center">
  <strong>A mindful wellness platform that turns your break into a healing moment.</strong>
  <br />
  Mood tracking, guided breathing, ambient sounds, AI companion, journaling & more.
  <br /><br />
  <a href="#quick-start">Quick Start</a> &bull;
  <a href="#architecture">Architecture</a> &bull;
  <a href="#project-workflow">Workflow</a> &bull;
  <a href="#api-reference">API</a> &bull;
  <a href="#deployment">Deployment</a>
</p>

---

## Overview

**Relax Before Stress Comes** is a full-stack wellness monorepo with three main surfaces:

| Surface | Stack | Purpose |
|---------|-------|---------|
| **Mobile App** | Flutter / Dart | User-facing relaxation app (iOS + Android) |
| **Web Dashboard** | Next.js 15 / React | Admin panel, billing, analytics |
| **Backend API** | NestJS / Prisma / PostgreSQL | REST API v1, WebSocket realtime, background jobs |

All surfaces share code through an npm workspace monorepo with common packages.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Backend** | NestJS 11, TypeScript, Prisma ORM, BullMQ |
| **Database** | PostgreSQL 16 |
| **Cache / Queue** | Redis 7 |
| **Web** | Next.js 15, React, TailwindCSS, Zustand |
| **Mobile** | Flutter 3 (Dart), Provider |
| **AI** | Google Gemini API (companion insights) |
| **Storage** | Supabase (file uploads, audio assets) |
| **Payment** | SePay QR (Vietnam bank gateway) |
| **Auth** | JWT + Refresh token (HttpOnly cookie), Google Sign-In |
| **Realtime** | Socket.IO (WebSocket) |
| **Infra** | Docker Compose, Tailscale Funnel, Vercel |
| **CI/CD** | GitHub Actions (lint, test, build, e2e) |
| **Monitoring** | Sentry (error tracking), Pino (structured logs) |

---

## Monorepo Structure

```
digital-cigarette-break/
├── apps/
│   ├── backend/              # NestJS API (57 modules)
│   │   ├── src/
│   │   │   ├── auth/         # JWT + Google Sign-In
│   │   │   ├── users/        # User management
│   │   │   ├── mood-checkins/# Mood tracking + streaks
│   │   │   ├── journals/     # Daily journaling
│   │   │   ├── relax-activities/ # Relaxation catalog
│   │   │   ├── meditations/  # Guided meditations
│   │   │   ├── breathing-exercises/ # Breathing sessions
│   │   │   ├── sleep/        # Sleep content
│   │   │   ├── ambient-sounds/ # Lo-fi, piano, nature...
│   │   │   ├── user-companions/ # AI companion (Gemini)
│   │   │   ├── ai-insights/  # AI-powered mood insights
│   │   │   ├── billing/      # SePay payment integration
│   │   │   ├── quests/       # Gamification quests
│   │   │   ├── achievements/ # Achievement badges
│   │   │   ├── friends/      # Social connections
│   │   │   ├── feed/         # Activity feed
│   │   │   ├── weather/      # Weather-based greetings
│   │   │   ├── notifications/# Push notifications
│   │   │   ├── realtime/     # WebSocket events
│   │   │   ├── admin-dashboard/ # Admin analytics
│   │   │   └── ...           # 20+ more modules
│   │   ├── prisma/           # Schema, migrations, seed
│   │   └── test/             # E2E test suites
│   │
│   ├── web/                  # Next.js web dashboard
│   │   ├── app/
│   │   │   ├── auth/         # Login, Register, Google SSO
│   │   │   ├── dashboard/    # Mood, Journal, Weather, Analytics
│   │   │   ├── admin/        # Users, Sounds, Themes, Pricing...
│   │   │   └── billing/      # SePay checkout
│   │   ├── stores/           # Zustand state management
│   │   └── lib/              # API client, utilities
│   │
│   └── mobile/               # Flutter mobile app
│       └── relax_app/
│           └── lib/
│               ├── screens/  # 20+ screens
│               └── core/     # API client, auth, audio, theme
│
├── packages/
│   ├── shared-types/         # OpenAPI-generated TypeScript types
│   ├── shared-utils/         # Common utility functions
│   └── ui-kit/               # Shared UI components
│
├── docker/                   # Tailscale Funnel config
├── docs/                     # 14 design & ops documents
├── scripts/                  # Dev helper scripts
├── docker-compose.yml        # Local dev infrastructure
├── docker-compose.prod.yml   # Production deployment
└── Makefile                  # Developer shortcuts
```

---

<a id="architecture"></a>

## Architecture

```
                         ┌─────────────────────────────────────────────┐
                         │              CLIENTS                        │
                         │                                             │
                         │  ┌─────────────┐    ┌────────────────────┐  │
                         │  │  Mobile App │    │  Web Dashboard    │  │
                         │  │  (Flutter)  │    │  (Next.js)        │  │
                         │  │             │    │                    │  │
                         │  │  20+ screens│    │  /auth             │  │
                         │  │  Audio ctrl │    │  /dashboard        │  │
                         │  │  Push notif │    │  /admin            │  │
                         │  │  Offline    │    │  /billing          │  │
                         │  └──────┬──────┘    └────────┬───────────┘  │
                         │         │    REST /v1 + WS   │              │
                         └─────────┼────────────────────┼──────────────┘
                                   │                    │
                              ┌────▼────────────────────▼────┐
                              │      BACKEND (NestJS)        │
                              │                              │
                              │  ┌────────────────────────┐  │
                              │  │    Throttler Guard     │──┼──► Redis
                              │  │    (300 req/min/IP)    │  │    (rate-limit)
                              │  └───────────┬────────────┘  │
                              │              ▼               │
                              │  ┌────────────────────────┐  │
                              │  │     JWT Auth Guard     │  │
                              │  │  (access + refresh)    │  │
                              │  └───────────┬────────────┘  │
                              │              ▼               │
                              │  ┌────────────────────────┐  │
                              │  │    57 Feature Modules  │  │
                              │  │  ┌──────┐ ┌─────────┐  │  │
                              │  │  │Mood  │ │Companion│  │  │
                              │  │  │Check │ │AI Chat  │──┼──┼──► Gemini API
                              │  │  └──────┘ └─────────┘  │  │
                              │  │  ┌──────┐ ┌─────────┐  │  │
                              │  │  │Relax │ │ Billing │──┼──┼──► SePay
                              │  │  └──────┘ └─────────┘  │  │
                              │  │  ┌──────┐ ┌─────────┐  │  │
                              │  │  │Sleep │ │ Storage │──┼──┼──► Supabase
                              │  │  └──────┘ └─────────┘  │  │
                              │  └────────────────────────┘  │
                              │              │               │
                              │  ┌───────────▼────────────┐  │
                              │  │   Realtime (Socket.IO) │  │
                              │  │   BullMQ (async jobs)  │  │
                              │  └────────────────────────┘  │
                              └──────┬──────────────┬────────┘
                                     │              │
                              ┌──────▼──────┐ ┌─────▼──────┐
                              │ PostgreSQL  │ │   Redis    │
                              │  (Prisma)   │ │  (cache +  │
                              │  port 5555  │ │   queues)  │
                              └─────────────┘ └────────────┘
```

---

<a id="project-workflow"></a>

## Project Workflow

### User Journey

```
  ┌──────────┐     first time?      ┌─────────────────┐
  │  Splash  │ ──── yes ──────────► │   Onboarding    │
  │  (3 sec) │                      │   (4 slides)    │
  └────┬─────┘                      └────────┬────────┘
       │ no                                  │
       ▼                                     ▼
  ┌──────────────────────────────────────────────────┐
  │                  AUTH FLOW                        │
  │                                                   │
  │   ┌────────┐   ┌──────────┐   ┌───────────────┐  │
  │   │ Login  │   │ Register │   │ Google SSO    │  │
  │   └───┬────┘   └────┬─────┘   └──────┬────────┘  │
  │       └──────────────┴────────────────┘           │
  └────────────────────────┬──────────────────────────┘
                           │ JWT access + refresh cookie
                           ▼
  ┌──────────────────────────────────────────────────────────────┐
  │               APP SHELL (4-Tab Navigation)                   │
  │                                                              │
  │   ┌──────────┐ ┌──────────┐ ┌───────────┐ ┌──────────┐     │
  │   │   Home   │ │  Relax   │ │ Companion │ │ Settings │     │
  │   └────┬─────┘ └────┬─────┘ └─────┬─────┘ └────┬─────┘     │
  └────────┼─────────────┼─────────────┼────────────┼────────────┘
           │             │             │            │
           ▼             ▼             ▼            ▼
  ┌──────────────┐ ┌───────────┐ ┌──────────┐ ┌──────────────┐
  │ Daily Hub    │ │ Wellness  │ │ AI Chat  │ │ Account      │
  │              │ │ Activities│ │ (Gemini) │ │              │
  │  Weather     │ │           │ │          │ │  Profile     │
  │  Mood CTA    │ │  Relax    │ │ Companion│ │  Theme       │
  │  Cozy quote  │ │  Breathe  │ │ Messages │ │  Language    │
  │  Streaks     │ │  Meditate │ │ Assets   │ │  Notif prefs │
  │  Quests      │ │  Sleep    │ │          │ │  Sounds      │
  │  Affirmation │ │  Sounds   │ │          │ │  Billing     │
  └──────┬───────┘ └─────┬─────┘ └──────────┘ │  Devices     │
         │               │                     └──────────────┘
         ▼               ▼
  ┌──────────────────────────────────────────────────────┐
  │              DAILY WELLNESS LOOP                      │
  │                                                       │
  │   Mood Check-in ──► AI Insight (Gemini)               │
  │        │                                              │
  │        ▼                                              │
  │   Journal Entry (reflect on feelings)                 │
  │        │                                              │
  │        ▼                                              │
  │   Relax Activity ──► Session Tracking                 │
  │   (music / breathing / meditation / sleep)            │
  │        │                                              │
  │        ▼                                              │
  │   Progress: Streaks + Quests + Achievements           │
  │        │                                              │
  │        ▼                                              │
  │   Social: Feed ◄──► Friends                           │
  └───────────────────────────────────────────────────────┘
```

### Backend Request Pipeline

```
  Incoming HTTP Request
         │
         ▼
  ┌──────────────────┐
  │  Rate Limiter    │ ◄── Redis-backed (300/min per IP)
  │  (ThrottlerGuard)│
  └────────┬─────────┘
           ▼
  ┌──────────────────┐
  │  JWT Auth Guard  │ ◄── Access token verification
  │                  │     Refresh via HttpOnly cookie
  └────────┬─────────┘
           ▼
  ┌──────────────────┐
  │  Controller      │ ──► Admin routes: AuditInterceptor logs actions
  │  (route handler) │
  └────────┬─────────┘
           ▼
  ┌──────────────────┐     ┌──────────┐
  │  Service Layer   │────►│ Prisma   │──► PostgreSQL (data)
  │                  │     └──────────┘
  │                  │────► Redis (cache, rate-limit, sessions)
  │                  │────► Supabase (file storage, audio)
  │                  │────► Gemini API (AI companion insights)
  │                  │────► BullMQ (async jobs, emails, reminders)
  │                  │────► SePay (payment webhook)
  └────────┬─────────┘
           ▼
  ┌──────────────────┐
  │  Realtime Engine │ ──► Socket.IO push to connected clients
  │  (event emitter) │     (mood updates, payment confirmations,
  └──────────────────┘      session changes)
```

---

<a id="quick-start"></a>

## Quick Start

### Prerequisites

| Tool | Version |
|------|---------|
| Node.js | >= 20 |
| npm | >= 10 |
| Docker & Docker Compose | latest |
| Flutter *(mobile only)* | >= 3.11 |

### 1. Clone & Install

```bash
git clone https://github.com/RumVu/relax_project.git
cd relax_project
npm install
```

### 2. Environment Setup

```bash
cp .env.example .env
# Edit .env and set a real JWT_SECRET:
#   openssl rand -hex 32
```

### 3. Start Infrastructure

```bash
make infra-up          # PostgreSQL + Redis containers
```

### 4. Database Setup

```bash
make prisma-migrate    # Apply all migrations
make prisma-seed       # Seed catalog data (sounds, quotes, themes...)
```

### 5. Run

```bash
# Terminal 1 — Backend API
make backend-dev       # http://localhost:6823

# Terminal 2 — Web Dashboard
make web-dev           # http://localhost:3233

# Terminal 3 — Mobile App (optional)
make mobile-run-local  # Flutter app targeting localhost
```

### Verify Everything Works

| Service | URL |
|---------|-----|
| API Index | `http://localhost:6823` |
| Swagger UI | `http://localhost:6823/docs` |
| OpenAPI JSON | `http://localhost:6823/docs-json` |
| Web Dashboard | `http://localhost:3233` |
| Redis Health | `http://localhost:6823/redis/health?deep=true` |
| Queue Health | `http://localhost:6823/queues/health?deep=true` |
| Realtime Health | `http://localhost:6823/realtime/health` |
| Socket.IO | `ws://localhost:6823/realtime` |

---

## Make Targets

Run `make help` for a full list. Key shortcuts:

### Infrastructure

| Command | Description |
|---------|-------------|
| `make infra-up` | Start Postgres + Redis only |
| `make infra-down` | Stop Postgres + Redis (keep data) |
| `make infra-reset` | Stop + remove volumes (**destructive**) |
| `make up` | Full stack via Docker Compose |
| `make down` | Stop all services |
| `make logs` | Tail logs for all running services |

### Development

| Command | Description |
|---------|-------------|
| `make backend-dev` | Run NestJS in watch mode |
| `make web-dev` | Run Next.js dev server |
| `make mobile-run` | Run Flutter app (production API) |
| `make mobile-run-local` | Run Flutter app (localhost backend) |
| `make mobile-run-lan` | Run Flutter app (auto-detect LAN IP) |

### Database

| Command | Description |
|---------|-------------|
| `make prisma-migrate` | Apply Prisma migrations |
| `make prisma-seed` | Seed catalog + demo data |
| `make prisma-cleanup` | Wipe test data only |

### Testing

| Command | Description |
|---------|-------------|
| `make backend-test` | Backend unit tests (Jest) |
| `make backend-test-e2e` | Backend E2E tests (needs DB + Redis) |
| `make web-test-e2e` | Playwright smoke tests |
| `make mobile-test` | Flutter unit & widget tests |
| `make test-all` | Run every test suite |
| `make lint` | Lint backend + web |

### Sharing & Tunnels

| Command | Description |
|---------|-------------|
| `make share` | Full stack on LAN IP (anyone on WiFi can access) |
| `make funnel` | Backend + Tailscale Funnel (stable public URL) |
| `make tunnel` | Cloudflare quick tunnel (backend + web) |
| `make share-ip` | Print your current LAN IP |

---

<a id="api-reference"></a>

## API Reference

All endpoints are versioned under `/v1`. Authentication uses Bearer JWT tokens.

### Core Endpoints

| Module | Endpoints | Description |
|--------|-----------|-------------|
| **Auth** | `POST /v1/auth/register`, `login`, `refresh`, `google` | Registration, login, token refresh, Google SSO |
| **Users** | `GET /v1/users/me`, `PATCH`, `DELETE` | Profile management, account deletion |
| **Mood** | `POST /v1/mood-checkins`, `GET` (history) | Mood tracking with emoji + note |
| **Journal** | `POST /v1/journals`, `GET`, `PATCH`, `DELETE` | Daily journal entries |
| **Relax** | `GET /v1/relax-activities`, sessions CRUD | Relaxation activity catalog + user sessions |
| **Breathing** | `GET /v1/breathing-exercises` | Guided breathing patterns |
| **Meditations** | `GET /v1/meditations` | Meditation audio content |
| **Sleep** | `GET /v1/sleep` | Sleep sounds and stories |
| **Sounds** | `GET /v1/ambient-sounds` | Lo-fi, piano, nature, rain... |
| **Companion** | `POST /v1/user-companions/chat` | AI companion chat (Gemini) |
| **Weather** | `GET /v1/weather/current` | Location-based weather greeting |
| **Quests** | `GET /v1/quests`, `POST claim` | Gamification quest system |
| **Achievements** | `GET /v1/achievements` | Badge collection |
| **Friends** | `POST /v1/friends/request`, `accept` | Social connections |
| **Feed** | `GET /v1/feed` | Activity feed from friends |
| **Billing** | `POST /v1/billing/checkout` | SePay QR payment flow |
| **Notifications** | `GET /v1/notifications`, push registration | Push notifications + in-app |
| **Admin** | `GET /v1/admin/*` | Dashboard analytics, user management, content CRUD |

### Realtime Events (Socket.IO)

| Event | Direction | Description |
|-------|-----------|-------------|
| `mood:created` | Server -> Client | New mood check-in recorded |
| `session:updated` | Server -> Client | Relax session state change |
| `payment:confirmed` | Server -> Client | SePay payment confirmed |
| `notification:new` | Server -> Client | New notification pushed |

Full OpenAPI docs available at `/docs` when backend is running.

---

<a id="deployment"></a>

## Deployment

### Docker (Production)

```bash
# Copy and configure production environment
cp .env.production.example .env.production

# Build and run with production compose
docker compose -f docker-compose.prod.yml --profile full up -d --build
```

### Vercel (Web Dashboard)

The web dashboard deploys to Vercel. Set `NEXT_PUBLIC_API_URL` to your backend URL.

### Mobile

```bash
make mobile-build-apk    # Android release APK
make mobile-build-ios     # iOS release (no codesign)
```

### Production Migration Strategy

> **Important**: Set `RUN_MIGRATIONS_ON_START=false` in production to avoid race conditions with multiple container replicas.

Run migrations as a standalone CI/CD step:

```bash
npm --workspace apps/backend run prisma:migrate:deploy
```

---

## Testing & CI/CD

### Test Suites

```bash
# Backend unit tests
npm --workspace apps/backend run test

# Backend E2E (requires Postgres + Redis)
npm --workspace apps/backend run test:e2e

# Web unit tests (Vitest)
npm --workspace apps/web run test

# Web E2E (Playwright)
npm --workspace apps/web run test:e2e

# Flutter tests
cd apps/mobile/relax_app && flutter test
```

### GitHub Actions Pipelines

| Workflow | Trigger | What it does |
|----------|---------|-------------|
| `ci.yml` | Push to `main` / PRs | Full monorepo: lint, unit tests, build, Playwright E2E |
| `backend-ci.yml` | Changes in `apps/backend/` | Prisma validate, lint, unit + E2E tests |
| `web-ci.yml` | Changes in `apps/web/` | Lint + build validation |

---

## Security & Production Hardening

| Area | Implementation |
|------|----------------|
| **Auth tokens** | Short-lived JWT access token (client-side) + long-lived refresh token as `HttpOnly` cookie |
| **Rate limiting** | 300 req/min per IP via Redis-backed `ThrottlerGuard` (skipped in test env) |
| **CORS** | Configurable allowlist via `CORS_ORIGINS` env var |
| **Swagger** | Disabled in production by default (`SWAGGER_ENABLED=false`) or behind Basic Auth |
| **Admin audit** | All admin actions logged via `AdminAuditInterceptor` |
| **Input validation** | `class-validator` + `class-transformer` on all DTOs |
| **Error monitoring** | Sentry integration for both backend (`@sentry/nestjs`) and web (`@sentry/nextjs`) |
| **Structured logging** | Pino logger with request correlation IDs, sensitive fields redacted |
| **Cookie security** | `Secure=true` + `SameSite=None` for cross-domain HTTPS deployments |

---

## Documentation

Detailed design documents live in the `docs/` directory:

| Doc | Topic |
|-----|-------|
| `01-product-requirement.md` | Product requirements & vision |
| `02-system-architecture.md` | System architecture design |
| `03-database-design.md` | Database schema & relationships |
| `04-api-specification.md` | Full API contract specification |
| `05-ui-flow.md` | UI/UX flow documentation |
| `06-deployment-guide.md` | Deployment procedures |
| `07-roadmap.md` | Product roadmap |
| `08-storage-supabase.md` | Supabase storage setup |
| `09-user-auth-api.md` | Auth API detailed docs |
| `10-operational-readiness.md` | Backend operational readiness |
| `11-mobile-integration.md` | Client/mobile integration contract |
| `12-project-audit.md` | Project audit findings |
| `13-run-production.md` | Production run guide |
| `14-tailscale-funnel.md` | Tailscale Funnel setup |

---

## Default Local Ports

| Service | Port | Protocol |
|---------|------|----------|
| Backend API | `6823` | HTTP |
| Web Dashboard | `3233` | HTTP |
| PostgreSQL | `5555` | TCP |
| Redis | `6379` | TCP |
| Socket.IO | `6823/realtime` | WebSocket |

---

## Git Branch Strategy

```
main (production)
 │
 ├── feature/*          Feature branches
 ├── fix/*              Bug-fix and security-hardening branches
 └── hotfix/*           Urgent production hotfixes
```

---

## License

MIT — see [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with a lot of coffee and good vibes.
</p>
