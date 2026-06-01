# Deploy `apps/web` to Vercel

The web app is a standard Next.js 16 app inside an npm-workspace
monorepo. Vercel auto-detects Next.js but needs a few knobs set
because the project root is a workspace, not the package root.

## 1. Import the repo

1. https://vercel.com/new → pick the GitHub repo (`relax_project`).
2. **Root Directory**: `apps/web` ← important, the workspace lives here.
3. **Framework Preset**: Next.js (auto).
4. **Build & Output Settings** (override):
   - Build Command: `next build`
   - Install Command: `cd ../.. && npm ci --workspace apps/web --include-workspace-root`
   - Output Directory: `.next` (default)
   - Node Version: 22 (Vercel's default 20 also works, but the repo
     CI runs on 22).

`vercel.json` in `apps/web` ships these defaults too — Vercel will
respect them.

## 2. Environment variables

In **Settings → Environment Variables**, add for **Production** (and
optionally **Preview**):

| Key | Value | Notes |
|---|---|---|
| `NEXT_PUBLIC_API_URL` | `https://<random>.trycloudflare.com` | Public URL của backend. Lấy từ `make share-vercel` (in ra URL Cloudflare tunnel). Phải có `https://`, **không** trailing slash. Required. |
| `NEXT_PUBLIC_GOOGLE_CLIENT_ID` | `884741112800-…apps.googleusercontent.com` | Bật nút "Sign in with Google". Trùng với `GOOGLE_CLIENT_ID` ở backend. Client ID là PUBLIC nên commit/share thoải mái. |
| `NEXT_PUBLIC_SUPABASE_URL` | `https://<ref>.supabase.co` | Optional. |
| `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | `sb_publishable_…` | Optional. |

> ⚠️ Every `NEXT_PUBLIC_*` is **inlined at build time**. After
> changing one of these you have to redeploy (Vercel re-builds
> automatically when env vars change in the dashboard).

### Backend API variables

Avatar upload, admin upload buttons, and Google OAuth code exchange run through
the backend API. The backend environment that `NEXT_PUBLIC_API_URL` points to
must have:

| Key | Notes |
|---|---|
| `GOOGLE_CLIENT_ID` | Same OAuth client ID as `NEXT_PUBLIC_GOOGLE_CLIENT_ID`. |
| `GOOGLE_CLIENT_SECRET` | OAuth client secret. Backend-only, never expose to web/mobile. |
| `GOOGLE_REDIRECT_URI` | `https://relax-project-web-dashboard.vercel.app/auth/google/callback`. Must match Google Cloud exactly. |
| `SUPABASE_URL` | Supabase project URL. |
| `SUPABASE_PUBLISHABLE_KEY` | Public anon/publishable key. |
| `SUPABASE_SECRET_KEY` | Service-role/secret key used only by backend uploads. |
| `SUPABASE_BUCKET` | Usually `public-assets`. |

If any of these are missing, the UI will show
`Supabase storage chưa sẵn sàng...` even for an ADMIN account because the
server cannot upload without its storage key.

## 3. Vercel Analytics

The app includes `@vercel/analytics/next` in `app/layout.tsx`. After the
next Vercel deployment and at least one real visit, Vercel Analytics should
start counting page views.

## 4. Google OAuth

Google login uses a backend-owned authorization-code redirect callback:

```
https://relax-project-web-dashboard.vercel.app/auth/google/callback
```

In Google Cloud Console → OAuth Client:

- Authorized JavaScript origins:
  `https://relax-project-web-dashboard.vercel.app`
- Authorized redirect URIs:
  `https://relax-project-web-dashboard.vercel.app/auth/google/callback`

The `/o/oauth2/v2/auth` URL shown in DevTools is Google's OAuth v2 endpoint,
not this app's `/v1` API version.

## 5. Custom domain (optional)

Add it under **Settings → Domains**. Update `NEXT_PUBLIC_API_URL` if
the backend domain depends on the web domain.

## 6. Backend CORS

Add the Vercel URL to the backend's `CORS_ORIGINS`:

```
CORS_ORIGINS=https://<your-vercel-url>.vercel.app,https://yourdomain.com
```

Production CORS uses the explicit allow-list only — there is no LAN /
trycloudflare auto-allow in `NODE_ENV=production`.

## 7. Deploy

Push to `main` → Vercel builds + deploys. The build runs the same
`next build` that CI uses, so anything green in GitHub Actions ships.

## 8. Troubleshooting

| Symptom | Fix |
|---|---|
| `Module not found: @/components/...` | Make sure **Root Directory** is `apps/web`, not the repo root. |
| Login works but dashboard data calls fail with CORS error | Add the Vercel URL to backend `CORS_ORIGINS`. |
| `Sign in with Google` button missing | Set `NEXT_PUBLIC_GOOGLE_CLIENT_ID` AND redeploy (env-only changes still need rebuild). |
| Google login returns `redirect_uri_mismatch` | Add `/auth/google/callback` to Google OAuth Authorized redirect URIs. |
| Upload says Supabase storage is not ready | Set the four backend `SUPABASE_*` variables on the API deployment/tunnel environment and restart it. |
| Geolocation / Notification not prompting on the live URL | Vercel ships HTTPS by default — should work. If still blocked, check the in-app **Settings → Quyền truy cập** panel for a precise reason. |
