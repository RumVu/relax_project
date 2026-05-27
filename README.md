# Digital Cigarette Break

Monorepo for the Digital Cigarette Break product suite.

## Structure

- `apps/backend`: NestJS API, Prisma, migrations, and seed scripts
- `apps/web`: Next.js dashboard and admin web application
- `apps/mobile`: mobile application workspace placeholder
- `packages/shared-types`: shared TypeScript types
- `packages/shared-utils`: shared utility helpers
- `packages/ui-kit`: shared UI primitives placeholder
- `docs`: product, architecture, database, API, UI, storage, deployment, and roadmap notes
- `docker`: local infrastructure assets
- `scripts`: repository-level developer scripts

## Quick start

1. Install dependencies in the apps you want to run.
2. Make sure `apps/backend/.env` exists with the local database values below.
3. Start infrastructure with `docker compose up -d`.
4. Apply backend migrations with `npm run prisma:migrate:deploy`.
5. Seed sample data with `npm run prisma:seed`.
6. Start backend with `npm run dev:backend`.

Default local backend:

- API index: `http://localhost:6823`
- Swagger UI: `http://localhost:6823/docs`
- OpenAPI JSON: `http://localhost:6823/docs-json`
- Database URL: `postgresql://postgres:123456@localhost:5555/digital_cigarette_break?schema=public`
- Redis URL: `redis://localhost:6379`
- Redis health: `http://localhost:6823/redis/health?deep=true` (`ADMIN`)
- Queue health: `http://localhost:6823/queues/health?deep=true` (`ADMIN`)
- Realtime health: `http://localhost:6823/realtime/health` (`ADMIN`)
- Socket.IO namespace: `ws://localhost:6823/realtime`

Storage setup is documented in `docs/08-storage-supabase.md`.
User/auth APIs are documented in `docs/09-user-auth-api.md`.
Backend provider readiness, schema cleanup rules, and canonical data ownership
are documented in `docs/10-operational-readiness.md`.
Client/mobile integration contract (versioning, auth, realtime events, push,
error/pagination shapes) is documented in `docs/11-mobile-integration.md`.

## Workspace scripts

- `npm run dev:backend`
- `npm run dev:web`
- `npm run build`
- `npm run prisma:generate`
- `npm run prisma:migrate:deploy`
- `npm run prisma:seed`
