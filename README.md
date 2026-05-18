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
2. Copy backend env: `cp apps/backend/.env.example apps/backend/.env`.
3. Start infrastructure with `docker compose up -d`.
4. Apply backend migrations with `npm run prisma:migrate:deploy`.
5. Seed sample data with `npm run prisma:seed`.
6. Start backend with `npm run dev:backend`.

Default local backend:

- API index: `http://localhost:6823`
- Swagger UI: `http://localhost:6823/docs`
- OpenAPI JSON: `http://localhost:6823/docs-json`
- Database URL: `postgresql://postgres:123456@localhost:5555/digital_cigarette_break?schema=public`

Storage setup is documented in `docs/08-storage-supabase.md`.
User/auth APIs are documented in `docs/09-user-auth-api.md`.

## Workspace scripts

- `npm run dev:backend`
- `npm run dev:web`
- `npm run build`
- `npm run prisma:generate`
- `npm run prisma:migrate:deploy`
- `npm run prisma:seed`
