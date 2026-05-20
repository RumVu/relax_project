# Backend Operational Readiness

This note locks the current backend operating contract so the project does not
drift between the active Prisma schema, old import scripts, and optional
external services.

## Runtime Source Of Truth

- Runtime database schema: `public`
- Archived reference schema: none in the live DB
- Local database: `digital_cigarette_break`
- Local backend port: `6823`
- Canonical Prisma migration: `20260519000000_initial_schema`

The old `legacy` schema was backed up locally and dropped from the live database.
Runtime databases should only carry the `public` schema plus PostgreSQL system
schemas. If the old snapshot is ever needed again, restore it into a temporary
database first.

## Optional Provider Matrix

These features are coded, documented, and visible through status endpoints, but
they stay disabled until real production secrets are provided.

| Area | Required env keys | Status endpoint | Current behavior without keys |
| --- | --- | --- | --- |
| JWT auth | `JWT_SECRET` at least 32 chars, optional `JWT_EXPIRES_IN`, `JWT_ISSUER`, `JWT_AUDIENCE` | Authenticated endpoints | Access token defaults to 15 minutes; refresh sessions store SHA-256 token hashes only. |
| HTTP security | `CORS_ORIGINS`, `TRUST_PROXY`, optional `SWAGGER_ENABLED`, `SWAGGER_PUBLIC`, `SWAGGER_BASIC_USER`, `SWAGGER_BASIC_PASSWORD` | `GET /health`, `/docs` when enabled | Helmet headers, explicit CORS, proxy-aware client IPs, and timing-safe Swagger basic auth are enabled; production Swagger is disabled unless explicitly enabled or protected. |
| Email verify/reset | `EMAIL_PROVIDER` plus one of `RESEND_API_KEY`, `SENDGRID_API_KEY`, `SMTP_URL` | `GET /notifications/providers` | Only `NODE_ENV=development` may return a `devToken`; production, preview, staging, and test should use a provider or inspect DB/test fixtures. |
| FCM push | `FCM_SERVER_KEY` or `FIREBASE_SERVICE_ACCOUNT_JSON` | `GET /notifications/providers` | Push provider reports missing keys. |
| APNs push | `APNS_KEY_ID`, `APNS_TEAM_ID`, `APNS_BUNDLE_ID`, `APNS_PRIVATE_KEY` | `GET /notifications/providers` | Push provider reports missing keys. |
| Expo push | `EXPO_ACCESS_TOKEN` | `GET /notifications/providers` | Expo provider reports missing key. |
| Stripe billing | `STRIPE_SECRET_KEY` | `GET /billing/providers` | Billing provider reports missing key. |
| App Store billing | `APPLE_SHARED_SECRET`, `APP_STORE_CONNECT_API_KEY` | `GET /billing/providers` | Billing provider reports missing keys. |
| Google Play billing | `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | `GET /billing/providers` | Billing provider reports missing key. |
| Redis infrastructure | `REDIS_URL`, optional `REDIS_KEY_PREFIX`, `REDIS_DEFAULT_TTL_SECONDS` | `GET /redis/health?deep=true` (`ADMIN`) | Cache helpers degrade gracefully if Redis is unavailable; throttling falls back to per-process in-memory buckets instead of failing open. |
| Weekly stats job loop | `WEEKLY_STATS_JOB_ENABLED=true`, optional `WEEKLY_STATS_JOB_BATCH_SIZE`, `WEEKLY_STATS_JOB_LOCK_TTL_SECONDS` | `GET /jobs/status` | Manual recalculation APIs still work; background loop stays off. Runs page through all active users by cursor and uses a Redis lock to avoid duplicate multi-instance runs. |
| BullMQ queues | `QUEUE_ENABLED`, `QUEUE_PREFIX`, `QUEUE_DEFAULT_ATTEMPTS`, `QUEUE_BACKOFF_DELAY_MS` | `GET /queues/health?deep=true` (`ADMIN`) | Queue endpoints report readiness; enqueue returns disabled status if `QUEUE_ENABLED=false`. |
| Weekly stats queue worker | `WEEKLY_STATS_QUEUE_WORKER_ENABLED=true`, optional `WEEKLY_STATS_QUEUE_WORKER_CONCURRENCY` | `GET /jobs/status` | Jobs can be enqueued now; worker only consumes when explicitly enabled. |
| Socket.IO realtime | `REDIS_URL` for adapter fan-out | `GET /realtime/health` (`ADMIN`) | JWT-authenticated namespace `/realtime`; CORS follows `CORS_ORIGINS`, tokens are accepted via `auth.token` or Authorization header only, and it falls back to in-memory adapter if Redis is unavailable. |

## Canonical Data Ownership

Use this table when adding new APIs or DTOs.

| Product concept | Canonical tables/models | Notes |
| --- | --- | --- |
| Mood check-in and charts | `MoodCheckin`, `WeeklyMoodStat` | `rawScore`, `finalScore`, and `scoredAt` feed weekly analytics and are server-owned, not client DTO fields. Local day/week grouping must calculate timezone offset per historical check-in date to handle DST. |
| Mood streak shown in analytics | `MoodCheckin` derived stats, `WeeklyMoodStat.streakDays` | `UserProfile.currentStreak` and `UserProfile.longestStreak` are denormalized profile counters only. |
| Gamification streak ledger | `UserStreak` | Kept for badges/challenges/social contracts, not the main mood chart source. |
| Relax activity flow | `RelaxActivity`, `RelaxSession` | This is the primary Play/Finish flow used by the app; start/end time and duration are server-owned. |
| Meditation-specific library/history | `MeditationGuide`, `MeditationSession` | Kept for imported meditation content and future dedicated meditation screens. |
| Typed platform audit events | `PlatformEvent` mapped to `events` | Use when backend emits known `EventType` events. |
| Raw/custom app events | `AppEvent` mapped to `app_events` | Use for flexible client/admin telemetry that is not yet a typed platform event. |
| Weather greeting | `UserPreference.latitude`, `longitude`, `timezone`, `locationName`, `weatherEnabled` | Backend cannot request device location by itself; client must send coordinates. |
| Storage assets | `StorageFile` plus Supabase bucket | User upload reads/writes are scoped to `user-uploads/{userId}/`; arbitrary catalog/admin paths require admin endpoints. Bucket public/private policy still must match production CDN strategy. |
| Realtime delivery | `RealtimeGateway`, `RealtimeService`, Socket.IO rooms | User events should target `user:{userId}`; admin/system fan-out can target `role:{role}` or global events. |
| Queue-backed work | `QueuesService`, `JobsService` | Keep HTTP contract stable; move heavy processors into workers only after queue payloads are stable. |
| Billing price source | `SubscriptionTier`, fallback plan catalog | Checkout/payment rows must price from server-side plan data, never from client DTO amount/currency. |
| Push device ownership | `PushDevice.token` | A token already bound to another user is rejected instead of being rebound. |

## Runtime Split Policy

Keep the backend as a modular monolith for now. Redis-backed queues and
Socket.IO Redis adapter are already in place so the app can scale horizontally
without splitting services immediately.

Recommended order:

1. Keep API, Prisma, auth, catalog, wellness flows, storage, weather, and billing
   in `apps/backend`.
2. Use `/realtime` Socket.IO for user-level events such as mood updates,
   notifications, companion changes, and analytics refresh.
3. Put long-running or retryable work behind BullMQ first, starting with
   `weekly-mood-stats`.
4. Only split a separate worker or microservice when the job volume, deploy
   cadence, or runtime isolation actually needs it.

## Reserved Future Contracts

These models are intentionally kept even when no current controller/service
writes to them yet. They are not accidental trash; they are future product
contracts for challenger, social, meditation, insight, and recommendation
workflows.

| Future area | Reserved models | Notes |
| --- | --- | --- |
| Challenger and gamification | `Achievement`, `UserAchievement`, `Badge`, `UserBadge`, `Challenge`, `UserChallenge`, `LeaderboardEntry`, `UserPoints`, `PointsTransaction`, `UserLevel`, `UserStreak` | Keep for badges, daily challenges, points, levels, ranks, and streak-ledger screens. |
| Social/community | `Friend`, `FeedEntry` | Keep for friend requests, activity feed, and future sharing/community screens. |
| Dedicated meditation | `MeditationGuide`, `MeditationSession` | Keep for a dedicated meditation library/history separate from generic relax sessions. |
| Insights and recommendations | `AnalyticsSnapshot`, `Insight`, `AIInsight`, `Recommendation`, `ContentRating` | Keep for materialized analytics, AI insight cards, recommendation history, and content feedback. |
| Event ledgers | `PlatformEvent`, `AppEvent` | Keep for typed backend audit events and flexible app telemetry. |

Do not remove these tables from `public` just because `rg "prisma.<model>"`
returns no current runtime usage. Move a model out only after the related
product area is explicitly cancelled.

## Old Scaffold Status

The old scaffold path `backend/digital-cigarette-break-backend` has been removed
from git. `apps/backend` is the only backend workspace to run and deploy.

## Verification Commands

```bash
npm run prisma:validate
npm run build
npm --workspace apps/backend test -- --runInBand
npm --workspace apps/backend run test:e2e -- --runInBand
```
