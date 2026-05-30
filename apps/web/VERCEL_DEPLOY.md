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
| `NEXT_PUBLIC_GOOGLE_CLIENT_ID` | `627379199532-…apps.googleusercontent.com` | Bật nút "Sign in with Google". Trùng với `GOOGLE_CLIENT_ID` ở backend. Client ID là PUBLIC nên commit/share thoải mái. |
| `NEXT_PUBLIC_SUPABASE_URL` | `https://<ref>.supabase.co` | Optional. |
| `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | `sb_publishable_…` | Optional. |

> ⚠️ Every `NEXT_PUBLIC_*` is **inlined at build time**. After
> changing one of these you have to redeploy (Vercel re-builds
> automatically when env vars change in the dashboard).

## 3. Custom domain (optional)

Add it under **Settings → Domains**. Update `NEXT_PUBLIC_API_URL` if
the backend domain depends on the web domain.

## 4. Backend CORS

Add the Vercel URL to the backend's `CORS_ORIGINS`:

```
CORS_ORIGINS=https://<your-vercel-url>.vercel.app,https://yourdomain.com
```

Production CORS uses the explicit allow-list only — there is no LAN /
trycloudflare auto-allow in `NODE_ENV=production`.

## 5. Deploy

Push to `main` → Vercel builds + deploys. The build runs the same
`next build` that CI uses, so anything green in GitHub Actions ships.

## 6. Troubleshooting

| Symptom | Fix |
|---|---|
| `Module not found: @/components/...` | Make sure **Root Directory** is `apps/web`, not the repo root. |
| Login works but dashboard data calls fail with CORS error | Add the Vercel URL to backend `CORS_ORIGINS`. |
| `Sign in with Google` button missing | Set `NEXT_PUBLIC_GOOGLE_CLIENT_ID` AND redeploy (env-only changes still need rebuild). |
| Geolocation / Notification not prompting on the live URL | Vercel ships HTTPS by default — should work. If still blocked, check the in-app **Settings → Quyền truy cập** panel for a precise reason. |
