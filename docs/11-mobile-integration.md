# Mobile / Client Integration Guide

Contract reference for any client (mobile app, web, third-party) connecting to
the Relax Before Stress Comes backend. Pair this with the live OpenAPI document
at `/docs-json` and the provider/runtime matrix in
`docs/10-operational-readiness.md`.

## Base URL and versioning

- Local backend: `http://localhost:6823`
- **All API routes are versioned under `/v1`**, e.g. `GET /v1/mood-checkins/me`.
- Unversioned infra/index routes (do not prefix these): `GET /`, `GET /api`,
  `GET /health`, `GET /ready`.
- OpenAPI JSON: `GET /docs-json` (unversioned; already publishes `/v1/...`
  paths). Generate a typed client from it.
- Swagger UI: `GET /docs`.

Future breaking changes should ship under a new prefix (`/v2`) so existing
mobile builds keep working against `/v1`.

## Authentication

JWT bearer auth. Send `Authorization: Bearer <accessToken>` on protected routes.

| Action | Endpoint |
| --- | --- |
| Register | `POST /v1/auth/register` |
| Login | `POST /v1/auth/login` |
| Refresh tokens | `POST /v1/auth/refresh` (body `{ refreshToken }`) |
| Logout | `POST /v1/auth/logout` |
| Current user | `GET /v1/auth/me` |
| Request password reset | `POST /v1/auth/password-reset/request` |
| Confirm password reset | `POST /v1/auth/password-reset/confirm` |
| Verify email | `POST /v1/auth/email/verify` |
| Resend verification | `POST /v1/auth/me/email-verification` |
| Export my data | `GET /v1/auth/me/export` |
| Delete my account | `DELETE /v1/auth/me` |

- Register/login return `{ accessToken, refreshToken, expiresAt, sessionId, user }`.
- Access token default lifetime is short (`JWT_EXPIRES_IN`, 15m by default);
  refresh proactively or on `401`.
- **Refresh-on-401 rule:** retry via `/v1/auth/refresh` when the error `code`
  is one of `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_UNAUTHORIZED`,
  `AUTH_REFRESH_TOKEN_INVALID` and a refresh token is stored. Persist the new
  tokens (refresh tokens are rotated). If refresh fails, clear the session and
  send the user to login.
- Email verification and password reset only return a `devToken` when
  `NODE_ENV=development`; production needs a configured email provider (see
  Required configuration).

## Response conventions

### Error envelope (all non-2xx)

```json
{
  "success": false,
  "statusCode": 400,
  "code": "VALIDATION_FAILED",
  "message": "Human readable message",
  "details": "optional validation/provider details",
  "path": "/v1/mood-checkins/me",
  "timestamp": "2026-05-27T00:00:00.000Z"
}
```

Branch on `code` (stable enum), not on `message`. Common codes include
`VALIDATION_FAILED`, `AUTH_*`, `*_NOT_FOUND`, `PAYMENT_NOT_PENDING`,
`PAYMENT_PLAN_MISMATCH`, `RATE_LIMIT_EXCEEDED`.

### Success responses

Success responses are returned raw (no `{ data: ... }` wrapper).

- **List collections** return a page:
  `{ items: T[], total, skip, limit, hasMore }`
  (users, journals, mood check-ins, reminders, notifications, and all seven
  catalogs: cozy-quotes, ambient-sounds, breathing-exercises, app-themes,
  onboarding-slides, companion-assets, companion-messages).
  Supported query params: `skip`, `limit` (1–100), plus `q`/`search` and
  domain filters (`isActive`, `role`, `status`, `mood`, …).
- **Bounded/lookup endpoints** return a bare array or single object
  (e.g. `GET /v1/mood-checkins/options`, `/random`, `/default`).

> Note: response bodies are not yet typed in the OpenAPI schema (request DTOs
> are). Generated clients will type request bodies but treat responses loosely
> until response DTOs are added — model the shapes above on the client side.

## Realtime (Socket.IO)

- Namespace: `ws://<host>/realtime` (**not** under `/v1`).
- Authenticate by passing the access token: `io(url, { auth: { token } })`
  (or an `Authorization: Bearer` header).
- Handshake events from the server: `realtime.ready` (authenticated and joined
  the user room) and `realtime.auth_failed` (refresh the token and reconnect).
- User-scoped events (emitted to the connected user only), use them to refresh
  the relevant screen:

| Event | Emitted when | Payload |
| --- | --- | --- |
| `mood.updated` | mood check-in created | `{ id, mood, createdAt }` |
| `journal.created` | journal created | `{ id, title, createdAt }` |
| `relax-session.updated` | relax session finished | `{ id, activityType, status, durationSeconds }` |
| `notification.created` | notification created | `{ id, title, type, createdAt }` |
| `companion.updated` | companion upsert/interaction/personalization | `{ id, mood, action }` |
| `analytics.updated` | (reserved) analytics recompute | TBD |

Multi-instance fan-out requires Redis (single-instance in-memory fallback
otherwise — see Required configuration).

## Push notifications

- Register the device token: `POST /v1/notifications/me/devices`
  `{ token, platform: IOS|ANDROID|WEB, provider?: FCM|APNS|EXPO, deviceId?, deviceName?, appVersion?, timezone?, enabled? }`
- List / remove: `GET /v1/notifications/me/devices`,
  `DELETE /v1/notifications/me/devices/:id`.
- A token already bound to another user is rejected (re-register after logout).
- Actual delivery requires server-side provider keys; check capability first
  via `GET /v1/notifications/providers`.

## Capability discovery

Check these before showing gated features, since providers are environment-gated:

- `GET /v1/notifications/providers` — FCM/APNs/Expo + email readiness.
- `GET /v1/billing/providers` — Stripe/App Store/Google Play readiness.
- `GET /health`, `GET /ready` — backend/database/storage liveness.

## Storage / uploads

User uploads (avatars, etc.) use signed URLs scoped to `user-uploads/{userId}/`:

1. `POST /v1/storage/signed-upload-url` to get an upload URL.
2. Upload the bytes directly to the returned URL.
3. `POST /v1/storage/files` to record metadata; list via
   `GET /v1/storage/me/files`; remove via `DELETE /v1/storage/files/:id`.

## Billing (upgrade flow)

1. `GET /v1/billing/plans` — plan catalog.
2. `POST /v1/billing/me/checkout-session` `{ planName }` — creates a PENDING payment.
3. When no external provider is configured (dev/manual), confirm to activate:
   `POST /v1/billing/me/payments/:id/confirm` `{ planName }` — flips the payment
   to COMPLETED and provisions an ACTIVE subscription. With a real provider, a
   webhook performs this step instead.
4. `GET /v1/billing/me` — current subscription + provider status.

## Required configuration for full functionality

These are environment/ops concerns (see `docs/10-operational-readiness.md`),
not code. They are disabled in the local `.env` today:

| Capability | Env keys | Without it |
| --- | --- | --- |
| Push delivery | `FCM_SERVER_KEY` / `APNS_*` / `EXPO_ACCESS_TOKEN` | device registers, no push sent |
| Email verify / reset | `EMAIL_PROVIDER` + provider key | dev-token only |
| Realtime fan-out + throttle store | `REDIS_URL`, `REDIS_ENABLED=true` | single-instance, in-memory |
| Billing provider | `STRIPE_SECRET_KEY` / store keys | manual confirm only |
| CORS (web/Flutter Web) | `CORS_ORIGINS` (prod domains) | non-allowed web origins blocked |

Native mobile clients are not subject to CORS; the web build is.
