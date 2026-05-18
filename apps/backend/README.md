# Digital Cigarette Break Backend

NestJS API for the Digital Cigarette Break app. This backend owns auth, users,
profiles, preferences, mood check-ins, journals, relax sessions, companion
personalization, analytics, weather, storage, notifications, billing stubs, and
catalog content.

## Local Setup

From the repository root:

```bash
docker compose up -d
npm --workspace apps/backend install
npm run prisma:migrate:deploy
npm run prisma:seed
npm run dev:backend
```

Create or update `apps/backend/.env` so the local database matches Docker
Compose:

```env
DATABASE_URL="postgresql://postgres:123456@localhost:5555/digital_cigarette_break?schema=public"
PORT="6823"
```

## Local URLs

- API index: `http://localhost:6823`
- API index alias: `http://localhost:6823/api`
- Health: `http://localhost:6823/health`
- Swagger UI: `http://localhost:6823/docs`
- OpenAPI JSON: `http://localhost:6823/docs-json`

## Useful Scripts

```bash
npm run dev
npm run build
npm run lint
npm test -- --runInBand
npm run test:e2e -- --runInBand
npm run prisma:validate
npm run prisma:migrate:deploy
npm run prisma:seed
```

`npm run dev` frees the configured backend port before starting Nest watch mode.
Use `PORT=xxxx npm run dev` only when intentionally testing another port.

## Provider Readiness

Optional production integrations are intentionally key-gated. Check these before
turning on mobile push, email delivery, billing, or background jobs:

- Notifications/email/push: `GET /notifications/providers`
- Billing: `GET /billing/providers`
- Weekly stats job: `GET /jobs/status`
- Manual weekly stats recalculation: `POST /jobs/weekly-mood-stats/run`

The full provider and schema ownership contract lives in
`../../docs/10-operational-readiness.md`.
