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
JWT_SECRET="<at least 32 random characters>"
JWT_EXPIRES_IN="15m"
JWT_ISSUER="digital-cigarette-break-api"
JWT_AUDIENCE="digital-cigarette-break-app"
CORS_ORIGINS="http://localhost:3000,http://localhost:5300,http://localhost:6823"
TRUST_PROXY="loopback"
REDIS_URL="redis://localhost:6379"
QUEUE_ENABLED="true"
QUEUE_PREFIX="dcb"
QUEUE_DEFAULT_ATTEMPTS="3"
QUEUE_BACKOFF_DELAY_MS="1000"
WEEKLY_STATS_QUEUE_WORKER_ENABLED="false"
WEEKLY_STATS_QUEUE_WORKER_CONCURRENCY="2"
```

## Local URLs

- API index: `http://localhost:6823`
- API index alias: `http://localhost:6823/api`
- Health: `http://localhost:6823/health`
- Redis health: `http://localhost:6823/redis/health?deep=true` (`ADMIN`)
- Queue health: `http://localhost:6823/queues/health?deep=true` (`ADMIN`)
- Realtime health: `http://localhost:6823/realtime/health` (`ADMIN`)
- Socket.IO namespace: `ws://localhost:6823/realtime`
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
- Redis cache/session foundation: `GET /redis/health?deep=true` (`ADMIN`)
- Queue foundation: `GET /queues/health?deep=true` (`ADMIN`)
- Socket.IO realtime foundation: `GET /realtime/health` (`ADMIN`)
- Weekly stats job: `GET /jobs/status`
- Manual weekly stats recalculation: `POST /jobs/weekly-mood-stats/run`
- Enqueue weekly stats recalculation: `POST /jobs/weekly-mood-stats/enqueue`

Realtime currently stays inside the same Nest backend. Clients connect to
namespace `/realtime` with JWT in `auth.token` or `Authorization: Bearer ...`.
Do not pass tokens in query strings because they are easy to leak into logs.
When Redis is available, Socket.IO uses Redis
adapter for multi-instance fan-out; when Redis is unavailable, it falls back to
in-memory mode and the health payload reports that clearly.

Queues use BullMQ on Redis. `POST /jobs/weekly-mood-stats/enqueue` can enqueue
weekly stat recalculation now. The in-process queue worker only runs when
`WEEKLY_STATS_QUEUE_WORKER_ENABLED=true`; this lets local dev stay predictable
while keeping the worker contract ready for production.

The full provider and schema ownership contract lives in
`../../docs/10-operational-readiness.md`.
