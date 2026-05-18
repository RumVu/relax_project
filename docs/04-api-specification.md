# API Specification

Backend Swagger UI is available at:

- Local UI: `http://localhost:6823/docs`
- OpenAPI JSON: `http://localhost:6823/docs-json`

The Swagger UI supports Bearer auth. Register or login through `/auth/register` or `/auth/login`, copy the returned `accessToken`, click **Authorize**, and paste it as the bearer token.

## Health

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/` | Public | API index with docs links and exposed module map. |
| `GET` | `/api` | Public | Alias of `/` for API discovery. |
| `GET` | `/health` | Public | App health, database config, and storage config status. |

## Auth

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `POST` | `/auth/register` | Public | Create user, profile, preferences, access token, and refresh session. |
| `POST` | `/auth/login` | Public | Login with email/password and create a refresh session. |
| `POST` | `/auth/refresh` | Public | Rotate refresh token and return a fresh token pair. |
| `POST` | `/auth/logout` | Public | Revoke one refresh token. |
| `GET` | `/auth/me` | Bearer token | Return current safe user payload. |

## Users

All `/users` routes require a Bearer token from a user with `ADMIN` role.

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/users` | `ADMIN` | List users with profile and preferences. |
| `GET` | `/users/:id` | `ADMIN` | Get one user by id. |
| `POST` | `/users` | `ADMIN` | Create one user. |
| `PATCH` | `/users/:id` | `ADMIN` | Update user metadata, role, status, or password. |
| `DELETE` | `/users/:id` | `ADMIN` | Delete user and cascade related rows. |

## User Profiles

When `birthday` is provided, the backend derives `zodiacSign` and `chineseZodiac` on the profile. The app can use these values for first-run personalization without asking the user to pick them manually.

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/user-profiles/me/profile` | Bearer token | Get current user's profile. |
| `PATCH` | `/user-profiles/me/profile` | Bearer token | Upsert current user's profile. |
| `GET` | `/user-profiles/:userId` | `ADMIN` | Get any user's profile. |
| `PATCH` | `/user-profiles/:userId` | `ADMIN` | Upsert any user's profile. |

## User Preferences

Preferences store the user's `timezone`, optional `latitude`, optional `longitude`, optional `locationName`, and `weatherEnabled`. Timezone-aware analytics prefer the saved timezone unless a request supplies a `timezone` or `timezoneOffsetMinutes` override.

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/user-preferences/me/preferences` | Bearer token | Get current user's preferences. |
| `PATCH` | `/user-preferences/me/preferences` | Bearer token | Upsert current user's preferences. |
| `GET` | `/user-preferences/:userId` | `ADMIN` | Get any user's preferences. |
| `PATCH` | `/user-preferences/:userId` | `ADMIN` | Upsert any user's preferences. |

## Sessions

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/sessions/me` | Bearer token | List current user's sessions. |
| `GET` | `/sessions` | `ADMIN` | List all sessions with user summary. |
| `GET` | `/sessions/user/:userId` | `ADMIN` | List sessions for one user. |
| `DELETE` | `/sessions/:id` | `ADMIN` | Revoke one session. |
| `DELETE` | `/sessions/user/:userId` | `ADMIN` | Revoke all sessions for one user. |

## Mood Check-ins

Mood values follow Prisma `MoodType`: `HAPPY`, `CALM`, `TIRED`, `SAD`, `ANXIOUS`, `STRESSED`, `EXCITED`, `NEUTRAL`, `LONELY`, `GRATEFUL`.

The mood home/onboarding screen should use:

- `GET /mood-checkins/options` for the selectable mood grid metadata: Vietnamese labels, icon keys, colors, companion line, and recommended action order.
- `GET /mood-checkins/me/dashboard` for current user screen data: greeting, latest mood, all options, distribution percentages, streak summary, and recommended actions.
- `GET /mood-checkins/me/analytics?period=week&timezoneOffsetMinutes=420` for setup/statistics charts: daily timeline, active days, positive/stress rates, previous-period comparison, deltas, streak, and insights.
- `GET /mood-checkins/me/recommendations?mood=STRESSED` to refresh the action cards after the user selects a mood.

Create payload:

```json
{
  "mood": "CALM",
  "intensity": 4,
  "rawScore": 80,
  "finalScore": 35,
  "scoredAt": "2026-05-15T06:15:00.000Z",
  "note": "Feeling lighter",
  "tags": ["relax", "finish"],
  "checkedAt": "2026-05-15T06:00:00.000Z"
}
```

Rules:

- `intensity` is optional, from `1` to `5`.
- `rawScore` and `finalScore` are optional stress scores from `0` to `100`; lower `finalScore` means the activity helped reduce stress.
- If score fields are omitted, backend derives them from mood. `scoredAt` defaults to check-in time.
- `note` is optional, max `120` characters.
- `tags` is optional, max `10` items.
- `checkedAt` is optional; when present it writes the check-in `createdAt`.
- Query filters support `mood`, `from`, `to`, `skip`, and `limit` (`1` to `100`).
- Analytics query supports `period=week|month|quarter|year|custom`, optional `from`, `to`, `compare`, and `timezoneOffsetMinutes`.
- Creating and deleting mood check-ins sync `UserProfile.totalMoodCheckins`, `currentStreak`, and `longestStreak`.

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/mood-checkins/options` | Public | List mood metadata for the onboarding/home mood grid. |
| `GET` | `/mood-checkins/me` | Bearer token | List current user's mood check-ins. |
| `GET` | `/mood-checkins/me/latest` | Bearer token | Get current user's latest mood check-in. |
| `GET` | `/mood-checkins/me/stats` | Bearer token | Get current user's total, average intensity, mood breakdown, latest check-in, and streaks. |
| `GET` | `/mood-checkins/me/weekly-stats` | Bearer token | Get materialized weekly mood stat rows. |
| `GET` | `/mood-checkins/me/analytics` | Bearer token | Get current user's daily mood analytics, trend timeline, comparison delta, and insights. |
| `GET` | `/mood-checkins/me/dashboard` | Bearer token | Get the full mood home dashboard payload. |
| `GET` | `/mood-checkins/me/recommendations` | Bearer token | Get action recommendations for `mood` query, defaulting to `NEUTRAL`. |
| `POST` | `/mood-checkins/me` | Bearer token | Create a mood check-in for current user. |
| `GET` | `/mood-checkins/:id` | Owner or `ADMIN` | Get one mood check-in. |
| `PATCH` | `/mood-checkins/:id` | Owner or `ADMIN` | Update mood, intensity, note, or tags. |
| `DELETE` | `/mood-checkins/:id` | Owner or `ADMIN` | Delete one mood check-in and resync profile stats. |
| `GET` | `/mood-checkins` | `ADMIN` | List all mood check-ins with user summary. |
| `GET` | `/mood-checkins/user/:userId` | `ADMIN` | List mood check-ins for one user. |
| `GET` | `/mood-checkins/user/:userId/stats` | `ADMIN` | Get mood stats for one user. |
| `GET` | `/mood-checkins/user/:userId/weekly-stats` | `ADMIN` | Get materialized weekly mood stat rows for one user. |
| `GET` | `/mood-checkins/user/:userId/analytics` | `ADMIN` | Get mood analytics for one user. |

Weekly stats are stored in Prisma `WeeklyMoodStat` with `weekStart`, `avgScore`, `stressReducePct`, `streakDays`, and `dominantMood`.

## Journals

Journals are linked to users and can optionally carry a mood, tags, privacy state, and favorite state. Creating/deleting journals syncs `UserProfile.totalJournalPosts`.

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/journals/me` | Bearer token | List current user's journals. |
| `GET` | `/journals/me/stats` | Bearer token | Get current user's journal totals, favorites, mood breakdown, and recent journals. |
| `POST` | `/journals/me` | Bearer token | Create current user's journal. |
| `GET` | `/journals/user/:userId` | `ADMIN` | List journals by user id. |
| `GET` | `/journals/:id` | Owner or `ADMIN` | Get one journal. |
| `PATCH` | `/journals/:id` | Owner or `ADMIN` | Update journal fields. |
| `DELETE` | `/journals/:id` | Owner or `ADMIN` | Delete journal and resync profile stats. |

## Relax Activities

The relax activity flow powers the "Khu thư giãn" screen, finish popup, and relax statistics dashboard. Sessions are stored in Prisma `RelaxSession` with typed activity/status fields, timing, mood before/after, relief score, note, and next-action metadata.

Activity types:

- `MUSIC`
- `PODCAST`
- `JOURNAL`
- `BREATHING`
- `MYSTERY`
- `MEDITATION`

Start payload:

```json
{
  "activityType": "MUSIC",
  "resourceId": "optional-catalog-id",
  "title": "Lo-fi Chill",
  "moodBefore": "STRESSED",
  "startedAt": "2026-05-15T12:00:00.000Z"
}
```

Finish payload:

```json
{
  "moodAfter": "CALM",
  "reliefLevel": 4,
  "note": "Nhẹ hơn nhiều",
  "durationSeconds": 1500
}
```

Rules:

- `reliefLevel` is optional, from `1` to `5`; backend maps it to `stressReliefPercent`.
- Finishing a session updates the `RelaxSession` row and, when `moodAfter` is present, creates a mood check-in tagged `relax-finish`, activity type, and session id.
- Stats query supports `period=week|month|quarter|year|custom`, optional `from`, `to`, `limit`, and `timezoneOffsetMinutes`.

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/relax-activities` | Public | List relax activity options and linked active resources. |
| `POST` | `/relax-activities/sessions/start` | Bearer token | Start a relax activity session. |
| `POST` | `/relax-activities/sessions/:id/finish` | Bearer token | Finish a session, produce post-check-in popup payload, and optionally create mood check-in. |
| `GET` | `/relax-activities/me/sessions` | Bearer token | List current user's finished relax sessions. |
| `GET` | `/relax-activities/me/stats` | Bearer token | Get streak, total relax time, favorite activities, recent moments, daily timeline, and relief summary. |

## Relax Sessions

`/relax-sessions` is an alias layer over the same relax activity event ledger. It exists so the frontend can talk to a session-focused API while `/relax-activities` remains the catalog/flow API.

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `POST` | `/relax-sessions/start` | Bearer token | Start current user's relax session. |
| `POST` | `/relax-sessions/:id/finish` | Bearer token | Finish current user's relax session. |
| `GET` | `/relax-sessions/me` | Bearer token | List current user's finished relax sessions. |
| `GET` | `/relax-sessions/me/stats` | Bearer token | Get current user's relax session stats. |

## User Companions

User companions connect the pet/cat UI to user state. Calling `GET /user-companions/me` auto-creates a default companion when the user does not have one yet.

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/user-companions/me` | Bearer token | Get or create current user's companion. |
| `PATCH` | `/user-companions/me` | Bearer token | Update companion name, asset, mood, action, level, affection, or energy. |
| `POST` | `/user-companions/me/interactions` | Bearer token | Record pet interaction and update affection/energy. |
| `GET` | `/user-companions/me/stats` | Bearer token | Get companion state and recent interactions. |

## Analytics

Analytics aggregates mood, journal, relax, and companion data into one backend payload for home/setup dashboards.

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/analytics/me/overview` | Bearer token | Get current user's mood analytics, journal stats, relax stats, companion stats, and summary cards. |

## Weather

Weather is used for the home greeting shown near the top of the mood screen. The backend calls Open-Meteo by coordinates, so no weather API key is required.

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/weather/current` | Public | Get current weather by `latitude`, `longitude`, and optional `timezone`. |
| `GET` | `/weather/me/current` | Bearer token | Get current weather using saved preferences; query coordinates override saved location. |

If location is missing or weather is disabled, the endpoint still returns a fallback greeting based on timezone so the UI can render safely.

## Storage

Storage is backed by Supabase bucket `public-assets`.

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/storage/health` | Public | Storage env/config status. Use `?deep=true` to test Supabase connectivity and bucket existence. |
| `GET` | `/redis/health` | Public | Redis config status. Use `?deep=true` to run a real Redis PING. |
| `POST` | `/storage/signed-upload-url` | Public | Create signed upload URL for a path. |
| `GET` | `/storage/signed-url` | Public | Create signed read URL for a path. |
| `GET` | `/storage/public-url` | Public | Get public URL for a path. |
| `GET` | `/storage/files` | Public | List registered file metadata. |
| `POST` | `/storage/files` | Public | Register file metadata in Prisma. |
| `DELETE` | `/storage/files/:id` | Public | Delete file metadata. |
| `DELETE` | `/storage/objects` | Public | Delete objects from Supabase storage. |

## Catalog APIs

| Group | Method | Path | Purpose |
| --- | --- | --- | --- |
| App Themes | `GET` | `/app-themes` | List themes. |
| App Themes | `GET` | `/app-themes/default` | Get default active theme. |
| App Themes | `POST` | `/app-themes` | Create theme. |
| App Themes | `PATCH` | `/app-themes/:id` | Update theme. |
| App Themes | `DELETE` | `/app-themes/:id` | Delete theme. |
| Onboarding Slides | `GET` | `/onboarding-slides` | List slides. |
| Onboarding Slides | `POST` | `/onboarding-slides` | Create slide. |
| Onboarding Slides | `PATCH` | `/onboarding-slides/:id` | Update slide. |
| Onboarding Slides | `DELETE` | `/onboarding-slides/:id` | Delete slide. |
| Companion Assets | `GET` | `/companion-assets` | List companion assets. |
| Companion Assets | `GET` | `/companion-assets/default` | Get default active companion asset. |
| Companion Assets | `POST` | `/companion-assets` | Create companion asset. |
| Companion Assets | `PATCH` | `/companion-assets/:id` | Update companion asset. |
| Companion Assets | `DELETE` | `/companion-assets/:id` | Delete companion asset. |
| Companion Messages | `GET` | `/companion-messages` | List companion messages. |
| Companion Messages | `GET` | `/companion-messages/random` | Get random active companion message. |
| Companion Messages | `POST` | `/companion-messages` | Create companion message. |
| Companion Messages | `PATCH` | `/companion-messages/:id` | Update companion message. |
| Companion Messages | `DELETE` | `/companion-messages/:id` | Delete companion message. |
| Ambient Sounds | `GET` | `/ambient-sounds` | List ambient sounds. |
| Ambient Sounds | `GET` | `/ambient-sounds/category/:category` | List ambient sounds by category. |
| Ambient Sounds | `POST` | `/ambient-sounds` | Create ambient sound. |
| Ambient Sounds | `PATCH` | `/ambient-sounds/:id` | Update ambient sound. |
| Ambient Sounds | `DELETE` | `/ambient-sounds/:id` | Delete ambient sound. |
| Breathing Exercises | `GET` | `/breathing-exercises` | List breathing exercises. |
| Breathing Exercises | `POST` | `/breathing-exercises` | Create breathing exercise. |
| Breathing Exercises | `PATCH` | `/breathing-exercises/:id` | Update breathing exercise. |
| Breathing Exercises | `DELETE` | `/breathing-exercises/:id` | Delete breathing exercise. |
| Cozy Quotes | `GET` | `/cozy-quotes` | List cozy quotes. |
| Cozy Quotes | `GET` | `/cozy-quotes/random` | Get random active quote. |
| Cozy Quotes | `GET` | `/cozy-quotes/mood/:mood` | List quotes by mood. |
| Cozy Quotes | `POST` | `/cozy-quotes` | Create quote. |
| Cozy Quotes | `PATCH` | `/cozy-quotes/:id` | Update quote. |
| Cozy Quotes | `DELETE` | `/cozy-quotes/:id` | Delete quote. |

## Common Error Shape

```json
{
  "success": false,
  "statusCode": 400,
  "code": "VALIDATION_FAILED",
  "message": "Validation failed",
  "details": ["mood must be one of the following values: HAPPY, CALM, ..."],
  "timestamp": "2026-05-15T00:00:00.000Z",
  "path": "/example"
}
```

Swagger injects the common error response schema into every endpoint with these status codes: `400`, `401`, `403`, `404`, `409`, and `500`.

| HTTP | Code | Meaning |
| --- | --- | --- |
| `400` | `VALIDATION_FAILED` | Request body/query/path validation failed or business validation failed. |
| `400` | `STORAGE_INVALID_PATH` | Storage path is missing, unsafe, or invalid. |
| `401` | `AUTH_UNAUTHORIZED` | Bearer token is missing. |
| `401` | `AUTH_TOKEN_INVALID` | Bearer token is invalid or expired. |
| `401` | `AUTH_INVALID_CREDENTIALS` | Login email/password is wrong. |
| `401` | `AUTH_REFRESH_TOKEN_INVALID` | Refresh token is missing, expired, revoked, or invalid. |
| `401` | `AUTH_INACTIVE_USER` | User exists but is inactive. |
| `403` | `AUTH_FORBIDDEN` | User is authenticated but does not own the resource or lacks role permission. |
| `404` | `ROUTE_NOT_FOUND` | URL does not match any route. |
| `404` | `USER_NOT_FOUND` | User id does not exist. |
| `404` | `USER_PROFILE_NOT_FOUND` | User profile does not exist. |
| `404` | `USER_PREFERENCE_NOT_FOUND` | User preferences do not exist. |
| `404` | `SESSION_NOT_FOUND` | Session id does not exist. |
| `404` | `MOOD_CHECKIN_NOT_FOUND` | Mood check-in id does not exist. |
| `404` | `JOURNAL_NOT_FOUND` | Journal id does not exist. |
| `404` | `USER_COMPANION_NOT_FOUND` | User companion does not exist. |
| `404` | `RELAX_SESSION_NOT_FOUND` | Relax session id does not exist or is not in the expected state. |
| `404` | `CATALOG_APP_THEME_NOT_FOUND` | App theme id does not exist. |
| `404` | `CATALOG_DEFAULT_APP_THEME_NOT_FOUND` | No active default app theme exists. |
| `404` | `CATALOG_ONBOARDING_SLIDE_NOT_FOUND` | Onboarding slide id does not exist. |
| `404` | `CATALOG_COMPANION_ASSET_NOT_FOUND` | Companion asset id does not exist. |
| `404` | `CATALOG_DEFAULT_COMPANION_ASSET_NOT_FOUND` | No active default companion asset exists. |
| `404` | `CATALOG_COMPANION_MESSAGE_NOT_FOUND` | Companion message id does not exist. |
| `404` | `CATALOG_ACTIVE_COMPANION_MESSAGE_NOT_FOUND` | No active companion message is available for random selection. |
| `404` | `CATALOG_AMBIENT_SOUND_NOT_FOUND` | Ambient sound id does not exist. |
| `404` | `CATALOG_BREATHING_EXERCISE_NOT_FOUND` | Breathing exercise id does not exist. |
| `404` | `CATALOG_COZY_QUOTE_NOT_FOUND` | Cozy quote id does not exist. |
| `404` | `CATALOG_ACTIVE_COZY_QUOTE_NOT_FOUND` | No active cozy quote is available for random selection. |
| `404` | `DATABASE_RECORD_NOT_FOUND` | Prisma update/delete could not find the target row. |
| `409` | `USER_EMAIL_ALREADY_EXISTS` | Email is already registered. |
| `409` | `DATABASE_UNIQUE_CONSTRAINT` | Database unique constraint failed. |
| `409` | `DATABASE_FOREIGN_KEY_CONSTRAINT` | Database foreign key constraint failed. |
| `500` | `INTERNAL_SERVER_ERROR` | Unexpected backend/database/provider failure. |
| `500` | `CONFIG_MISSING_REQUIRED_ENV` | Required environment variable is missing. |
| `500` | `STORAGE_NOT_CONFIGURED` | Supabase storage env is incomplete or invalid. |
| `500` | `STORAGE_OPERATION_FAILED` | Supabase storage operation failed. |
