# Project Audit — July 2026

## Current Scale

| Category | Count |
|---|---:|
| Backend modules (NestJS) | 55 |
| Postgres tables (Prisma) | 69 |
| HTTP endpoints | 181 |
| Backend unit tests | 8 |
| Backend e2e tests | 124 |
| Web pages (Next.js routes) | 42 |
| Web unit tests (Vitest) | 45 |
| Web e2e tests (Playwright) | 14 |
| Mobile screens (Flutter) | 30+ |
| TypeScript files | 521 |
| GitHub Actions | Lint + Web + Backend all green |

## Mobile App Status

The Flutter app (`apps/mobile/relax_app`) is **fully connected to the backend API** with 30+ screens implemented:

- Mood check-in with intensity, notes, tags, and triggers
- Journal with privacy toggle, favorites, and auto-prompts
- Breathing exercises and meditation sessions with timers
- Ambient sounds player with sound mixer (multi-audio playback)
- AI companion chat with mood-based messages and history
- Weather integration for mood correlation
- Billing and subscription tier management
- Weekly wellness report (auto-generated)
- Personal wellness plan
- Achievement and gamification system
- Trigger map for stress cause visualization
- Smart recommendations based on mood, history, and time
- Crisis safety layer with keyword detection, safe responses, and hotlines
- Trusted buddy check-in with SOS messaging
- Privacy vault (PIN lock, hide preview, private AI mode, data export)
- Demo story mode with guided walkthrough and 14-day seed data

### Offline Mode

Hive-based local cache with a sync queue. Changes persist offline and sync automatically when connectivity is restored.

### Push Notifications

Configured with `flutter_local_notifications`. Supports smart reminders for mood check-ins and wellness activities.

## Backend Systems

### Recommendation Engine (Active)

Smart recommendation engine that factors in current mood, activity history, time of day, and trigger patterns to suggest personalized activities.

### Feature Flags (Operational)

Predefined feature flag system with mobile remote config support. Flags control feature rollout across web and mobile.

### A/B Testing Framework (Ready)

Experiment management with variant assignment. Supports creating experiments, assigning users to variants, and tracking outcomes.

### Safety Layer (Implemented)

Crisis keyword detection with safe responses and emergency hotline information. Integrated with trusted buddy system for SOS alerts.

### Weekly Wellness Report

BullMQ scheduled job that generates weekly summaries of mood trends, activity effectiveness, and personalized insights.

## Shared Packages

### packages/shared-types

Comprehensive TypeScript type definitions covering all major API responses:

- Auth (AuthResponse, UserSummary)
- Mood (MoodCheckin, MoodType, TriggerType)
- Journal (JournalEntry)
- Relax sessions (RelaxSession, RelaxActivityType, RelaxSessionStatus)
- Recommendations (Recommendation, RecommendationResponse)
- Content ratings (ContentRating)
- Feature flags (FeatureFlag)
- Billing (BillingPlan)
- Notifications (AppNotification)
- Experiments (Experiment, ExperimentAssignment)
- Ops status (OpsStatus)
- Paginated responses (PaginatedResponse)

### packages/shared-utils, packages/ui-kit

Minimal — utility and UI component packages available for future shared logic.

## Production Topology

```
Frontend (Vercel)
  https://relax-project-web-dashboard.vercel.app
          |
          | HTTPS fetch
          v
Cloudflare Tunnel (free quick tunnel)
  https://<random>.trycloudflare.com
          |
          | HTTPS -> HTTP
          v
Backend NestJS (Docker, local machine)
  http://localhost:6823
  + Postgres + Redis (docker compose)
```

Backend runs as a long-running process with Socket.IO, BullMQ, Prisma connection pool, and Redis persistent connections. Serverless deployment is not viable for this architecture.

## Quick Commands

| Flow | Command | Use Case |
|---|---|---|
| Production | `make share-vercel` | Demo public, soft launch |
| Local full-stack | `make up` | Dev offline, full stack locally |
| LAN sharing | `make share` | Same wifi, no internet needed |
| Tunnel web | `make tunnel` | Demo local web via trycloudflare |

## Resolved Items (July 2026)

- [x] **Vitest dependency resolution** — `@testing-library/jest-dom` hoisted to root couldn't find `vitest` at `apps/web/node_modules`. Fixed by adding `jsdom` and `jest-dom` to root devDependencies and switching setup to explicit `expect.extend(matchers)`.
- [x] **Swagger circular dependency** — Response DTOs lacked `@ApiProperty()` decorators; Swagger CLI plugin auto-scanned all DTOs. Fixed by adding decorators and limiting `dtoFileNameSuffix` to input DTOs only.
- [x] **Backend Docker entry point** — `start-prod.cjs` referenced `dist/main.js` instead of `dist/src/main.js`. Fixed.
- [x] **CI failures (OTP flow)** — 87 e2e tests broke after OTP registration. Fixed with shared `registerAndVerify()` helper.
- [x] **Security hygiene** — `.env`, `key.properties`, `*.keystore`, `*-service-account*.json`, `relax-project-*.json` all properly gitignored.
- [x] **Vercel Analytics 404** — Expected dev-only behaviour; `@vercel/analytics` auto-disables outside Vercel. No fix needed.
- [x] **Mobile-web dashboard overflow** — `body { overflow-x: hidden }` + `min-w-0` on grid container already prevent horizontal scroll at 390px.

## Remaining Items

- **Production deployment (Phase 6)** — AWS ECS/Fargate, RDS, ElastiCache, S3+CloudFront, CI/CD pipeline. Requires dedicated planning.
- **HTTPS in dev** — Geolocation/Notification APIs need HTTPS or localhost. LAN users on HTTP cannot request browser permissions.
- **App store deployment** — iOS App Store and Google Play submission pending Phase 7.

## Checklist Before Sharing

- [x] `make share-vercel` runs, tunnel URL available
- [ ] Vercel env `NEXT_PUBLIC_API_URL` = tunnel URL, redeployed
- [x] Vercel env `NEXT_PUBLIC_GOOGLE_CLIENT_ID` set, redeployed
- [ ] Google Client Secret rotated (was exposed in chat)
- [ ] Remove `relax-project-backend.vercel.app` from Vercel dashboard
- [x] CORS backend has Vercel URL in allow-list
- [x] Google authorized JavaScript origins has Vercel URL
