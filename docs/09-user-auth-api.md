# User, Auth, Profile, Preference, and Session APIs

Base path: backend API root.

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
  "password": "secret123",
  "name": "Relax User"
}
```

Login body:

```json
{
  "email": "user@example.com",
  "password": "secret123"
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

The API never returns `password` in safe user responses.

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
