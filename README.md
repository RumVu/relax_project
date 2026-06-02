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
4. Apply backend migrations with `npm run prisma:migrate:deploy`. Production Docker can also run this automatically when `RUN_MIGRATIONS_ON_START=true`.
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

## Production hardening notes

- Refresh tokens are issued as `HttpOnly` cookies by the backend. The web app
  keeps the short-lived access token client-side, then calls `/v1/auth/refresh`
  with `credentials: include` so the refresh token is not persisted in
  `localStorage`.
- Swagger is not public by default in production. Use
  `SWAGGER_ENABLED=false`, or set `SWAGGER_PUBLIC=false` with
  `SWAGGER_BASIC_USER` and `SWAGGER_BASIC_PASSWORD`.
- Local `docker-compose.yml` remains developer-friendly. For deployment, use
  `docker-compose.prod.yml` with `.env.production`; Postgres and Redis are not
  exposed on host ports and secrets have no weak fallbacks.
- Keep `AUTH_REFRESH_COOKIE_SECURE=true` and
  `AUTH_REFRESH_COOKIE_SAME_SITE=none` when the web and API are on separate
  HTTPS domains.

Storage setup is documented in `docs/08-storage-supabase.md`.
User/auth APIs are documented in `docs/09-user-auth-api.md`.
Backend provider readiness, schema cleanup rules, and canonical data ownership
are documented in `docs/10-operational-readiness.md`.
Client/mobile integration contract (versioning, auth, realtime events, push,
error/pagination shapes) is documented in `docs/11-mobile-integration.md`.

## Workspace scripts

- `npm run dev:backend`: Chạy NestJS backend ở môi trường development.
- `npm run dev:web`: Chạy Next.js web dashboard ở môi trường development.
- `npm run build`: Build toàn bộ ứng dụng (web, backend, packages) phục vụ production.
- `npm run prisma:generate`: Tạo Prisma Client typescript types.
- `npm run prisma:migrate:deploy`: Chạy deploy database migrations.
- `npm run prisma:seed`: Nạp dữ liệu mẫu seed catalog.

## Production Migrations

Trong môi trường production, **khuyến nghị cấu hình `RUN_MIGRATIONS_ON_START=false`** (đã được set mặc định trong `.env.production.example` và `docker-compose.prod.yml`). 
Việc này nhằm tránh tình trạng nhiều bản sao (replicas) container cùng khởi chạy đồng thời và thực hiện migration song song, dẫn tới race condition trên database.
Thay vào đó, hãy chạy lệnh migration một lần duy nhất như một bước độc lập trong pipeline CI/CD hoặc chạy một release job riêng biệt trước khi start backend:
```bash
npm --workspace apps/backend run prisma:migrate:deploy
```

## Testing, CI/CD & Operations

### 1. Hướng dẫn chạy Tests
Dự án được tích hợp đầy đủ hệ thống test từ Unit Test tới E2E (End-to-End):

* **Backend (NestJS):**
  * Chạy Unit Tests (Jest):
    ```bash
    npm --workspace apps/backend run test
    ```
  * Chạy E2E Tests (Jest + DB + Redis):
    ```bash
    npm --workspace apps/backend run test:e2e
    ```

* **Frontend (Next.js):**
  * Chạy Unit Tests (Vitest):
    ```bash
    npm --workspace apps/web run test
    ```
  * Chạy E2E Tests (Playwright):
    ```bash
    npm --workspace apps/web run test:e2e
    ```

### 2. Luồng CI/CD (GitHub Actions)
Dự án cấu hình sẵn các quy trình CI tự động trong `.github/workflows/`:
- **`ci.yml`**: Chạy linting, unit tests, build validation và Playwright E2E smoke tests cho toàn bộ monorepo khi có push lên `main` hoặc PR.
- **`backend-ci.yml`**: Chạy tự động kiểm tra code backend, validate Prisma schema, linting, unit test và e2e test khi có thay đổi trong thư mục `apps/backend/`.
- **`web-ci.yml`**: Chạy tự động linting và build test cho Next.js khi thay đổi phần `apps/web/`.

### 3. Rate Limiting (Giới hạn lưu lượng)
Để bảo vệ API chống lại spam và DDoS, dự án tích hợp sẵn NestJS `ThrottlerModule` kết hợp lưu trữ phân tán bằng Redis (`RedisThrottlerStorage`).
- **Cấu hình mặc định:** Giới hạn **300 requests / 1 phút** trên mỗi IP (`ttl: 60s`, `limit: 300`).
- Nếu vượt quá giới hạn, server sẽ phản hồi HTTP `429 Too Many Requests`.
- Cơ chế rate limiting được bỏ qua (skipped) tự động khi chạy môi trường test (`NODE_ENV=test`).

### 4. Error Monitoring (Sentry)
Dự án hỗ trợ tích hợp Sentry để theo dõi và cảnh báo lỗi thời gian thực ở production:
- **Backend:** Cài đặt `@sentry/nestjs` và cấu hình DSN qua biến môi trường `SENTRY_DSN`.
- **Frontend (Next.js):** Sử dụng `@sentry/nextjs` để tự động catch lỗi Client-side và API routes. Cấu hình file `sentry.client.config.ts` và `sentry.server.config.ts`.
- Để kích hoạt, hãy điền `SENTRY_DSN` vào biến môi trường trên hosting server.

