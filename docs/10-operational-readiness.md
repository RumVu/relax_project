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
| Email verify/reset | `EMAIL_PROVIDER` plus one of `RESEND_API_KEY`, `SENDGRID_API_KEY`, `SMTP_URL` | `GET /notifications/providers` | Local/dev auth returns a `devToken`; production requires a provider. |
| FCM push | `FCM_SERVER_KEY` or `FIREBASE_SERVICE_ACCOUNT_JSON` | `GET /notifications/providers` | Push provider reports missing keys. |
| APNs push | `APNS_KEY_ID`, `APNS_TEAM_ID`, `APNS_BUNDLE_ID`, `APNS_PRIVATE_KEY` | `GET /notifications/providers` | Push provider reports missing keys. |
| Expo push | `EXPO_ACCESS_TOKEN` | `GET /notifications/providers` | Expo provider reports missing key. |
| Stripe billing | `STRIPE_SECRET_KEY` | `GET /billing/providers` | Billing provider reports missing key. |
| App Store billing | `APPLE_SHARED_SECRET`, `APP_STORE_CONNECT_API_KEY` | `GET /billing/providers` | Billing provider reports missing keys. |
| Google Play billing | `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | `GET /billing/providers` | Billing provider reports missing key. |
| Weekly stats job loop | `WEEKLY_STATS_JOB_ENABLED=true` | `GET /jobs/status` | Manual recalculation APIs still work; background loop stays off. |

## Canonical Data Ownership

Use this table when adding new APIs or DTOs.

| Product concept | Canonical tables/models | Notes |
| --- | --- | --- |
| Mood check-in and charts | `MoodCheckin`, `WeeklyMoodStat` | `rawScore`, `finalScore`, and `scoredAt` feed weekly analytics. |
| Mood streak shown in analytics | `MoodCheckin` derived stats, `WeeklyMoodStat.streakDays` | `UserProfile.currentStreak` and `UserProfile.longestStreak` are denormalized profile counters only. |
| Gamification streak ledger | `UserStreak` | Kept for badges/challenges/social contracts, not the main mood chart source. |
| Relax activity flow | `RelaxActivity`, `RelaxSession` | This is the primary Play/Finish flow used by the app. |
| Meditation-specific library/history | `MeditationGuide`, `MeditationSession` | Kept for imported meditation content and future dedicated meditation screens. |
| Typed platform audit events | `PlatformEvent` mapped to `events` | Use when backend emits known `EventType` events. |
| Raw/custom app events | `AppEvent` mapped to `app_events` | Use for flexible client/admin telemetry that is not yet a typed platform event. |
| Weather greeting | `UserPreference.latitude`, `longitude`, `timezone`, `locationName`, `weatherEnabled` | Backend cannot request device location by itself; client must send coordinates. |
| Storage assets | `StorageFile` plus Supabase bucket | Public or signed URLs are controlled by bucket/path policy. |

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
