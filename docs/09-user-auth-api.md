# User, Auth, Profile, Preference, and Session APIs

Base path: backend API root. **All routes are served under `/v1`** (e.g.
`POST /v1/auth/login`); infra routes `/`, `/api`, `/health`, `/ready` stay
unversioned. The tables below omit the `/v1` prefix for brevity.

## Current contract (read this first)

- **Auth response shape** (`/v1/auth/register`, `/login`, `/refresh`):
  `{ accessToken, refreshToken, expiresAt, sessionId, user }`. The `user`
  payload mirrors the safe `User` shape and includes nested `profile`,
  `preferences`, and a `subscriptions` summary on `/v1/auth/me`.
- **Refresh-on-401 rule**: retry via `POST /v1/auth/refresh` when the error
  `code` is `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_UNAUTHORIZED`,
  or `AUTH_REFRESH_TOKEN_INVALID`. Refresh tokens are rotated; persist the
  new pair every time.
- **`/v1/users`** (admin) is paginated and filterable: `?search=`, `?role=`,
  `?status=ACTIVE|INACTIVE`, `?emailVerified=`, `?skip=`, `?limit=`. The
  response is `{ items, total, skip, limit, hasMore }`.
- For the full client/mobile contract (realtime events, push, error envelope,
  pagination, capability discovery, env requirements) see
  `docs/11-mobile-integration.md`.

## Auth

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `POST` | `/auth/register` | Public | Create a local user, profile, preferences, access token, and refresh session. |
| `POST` | `/auth/login` | Public | Validate email/password, update `lastLoginAt`, and create a refresh session. |
| `POST` | `/auth/refresh` | Public | Rotate a valid refresh token and return a fresh token pair. |
| `POST` | `/auth/logout` | Public | Revoke one refresh token. |
| `GET` | `/auth/me` | Bearer token | Return the current safe user payload. |

Register body:

```json
{
  "email": "user@example.com",
  "password": "Secret123!x",
  "name": "Relax User"
}
```

Login body:

```json
{
  "email": "user@example.com",
  "password": "Secret123!x"
}
```

Auth responses include:

```json
{
  "accessToken": "...",
  "refreshToken": "...",
  "expiresAt": "2026-06-14T14:00:00.000Z",
  "user": {
    "id": "...",
    "email": "user@example.com",
    "profile": {},
    "preferences": {}
  }
}
```

The API never returns `password` in safe user responses. New passwords must be
at least 10 characters and include uppercase, lowercase, number, and special
character. Password inputs that create a new password are capped at 72
characters to avoid bcrypt truncation surprises.

## Users

All `/users` routes require `Bearer` auth with `ADMIN` role.

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/users` | List users with profile and preferences. |
| `GET` | `/users/:id` | Get one user. |
| `POST` | `/users` | Admin-create a user. |
| `PATCH` | `/users/:id` | Update user metadata, status, role, or password. |
| `DELETE` | `/users/:id` | Delete user and cascade related rows. |

## User Profiles

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/user-profiles/me/profile` | Bearer token | Get current user's profile. |
| `PATCH` | `/user-profiles/me/profile` | Bearer token | Upsert current user's profile. |
| `GET` | `/user-profiles/:userId` | `ADMIN` | Get any user's profile. |
| `PATCH` | `/user-profiles/:userId` | `ADMIN` | Upsert any user's profile. |

Profile body:

```json
{
  "displayName": "Relax User",
  "bio": "Small calm steps.",
  "birthday": "2000-01-01T00:00:00.000Z"
}
```

## User Preferences

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/user-preferences/me/preferences` | Bearer token | Get current user's preferences. |
| `PATCH` | `/user-preferences/me/preferences` | Bearer token | Upsert current user's preferences. |
| `GET` | `/user-preferences/:userId` | `ADMIN` | Get any user's preferences. |
| `PATCH` | `/user-preferences/:userId` | `ADMIN` | Upsert any user's preferences. |

Preference body:

```json
{
  "language": "vi",
  "timezone": "Asia/Ho_Chi_Minh",
  "themeMode": "SYSTEM",
  "themeId": null,
  "enableCompanionBubble": true,
  "bubbleIntervalSeconds": 30,
  "enableSound": true,
  "enableHaptics": true,
  "pushNotificationsEnabled": true,
  "emailNotificationsEnabled": false
}
```

`themeId` links to `AppTheme`. If the theme is deleted, Prisma sets this field to `null`.

## Sessions

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/sessions/me` | Bearer token | List current user's sessions. |
| `GET` | `/sessions` | `ADMIN` | List all sessions with user summary. |
| `GET` | `/sessions/user/:userId` | `ADMIN` | List a user's sessions. |
| `DELETE` | `/sessions/:id` | `ADMIN` | Revoke one session. |
| `DELETE` | `/sessions/user/:userId` | `ADMIN` | Revoke all sessions for one user. |

Session list responses intentionally omit `refreshToken`.

## Prisma Links

- `User.profile` is one-to-one with `UserProfile` and cascades on user delete.
- `User.preferences` is one-to-one with `UserPreference` and cascades on user delete.
- `User.sessions` is one-to-many with `Session` and cascades on user delete.
- `UserPreference.themeId` is optional and points to `AppTheme`.
- Register/admin user creation creates both profile and preferences so app clients can depend on those records existing.

## Error Codes

| Code | Meaning |
| --- | --- |
| `AUTH_INVALID_CREDENTIALS` | Login email/password is invalid. |
| `AUTH_INACTIVE_USER` | User exists but is inactive. |
| `AUTH_REFRESH_TOKEN_INVALID` | Refresh token is missing, expired, revoked, or user is inactive. |
| `AUTH_TOKEN_INVALID` | Bearer token is missing or invalid. |
| `AUTH_FORBIDDEN` | Authenticated user does not have the required role. |
| `USER_NOT_FOUND` | User id was not found. |
| `USER_EMAIL_ALREADY_EXISTS` | Email violates the unique user constraint. |
| `USER_PROFILE_NOT_FOUND` | Profile was not found for a valid user. |
| `USER_PREFERENCE_NOT_FOUND` | Preferences were not found for a valid user. |
| `SESSION_NOT_FOUND` | Session id was not found. |
