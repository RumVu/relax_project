# Project Audit — May 2026

## Quy mô hiện tại

| Hạng mục | Số liệu |
|---|---:|
| Module backend (NestJS) | 34 |
| Bảng Postgres (Prisma) | 61 |
| HTTP endpoint | 161 |
| Backend unit test | 41 ✅ |
| Backend e2e test | 87 ✅ |
| Trang web (Next.js routes) | 21 |
| Web unit test (Vitest) | 25 |
| Web e2e test (Playwright) | 8 |
| TypeScript files | 304 |
| GitHub Actions | ✅ Lint + Web + Backend all green |

## Production topology (chốt)

```
┌──────────────────────────────────────────────┐
│  Frontend                                    │
│  https://relax-project-web-dashboard.vercel.app  │ ← Vercel (free, HTTPS, CI deploy)
└──────────────────────────────────────────────┘
                       │ HTTPS fetch
                       ▼
┌──────────────────────────────────────────────┐
│  Cloudflare tunnel                           │
│  https://<random>.trycloudflare.com          │ ← cloudflared quick tunnel (free)
└──────────────────────────────────────────────┘
                       │ HTTPS → HTTP
                       ▼
┌──────────────────────────────────────────────┐
│  Backend NestJS (Docker, máy a)              │
│  http://localhost:6823                       │
│  + Postgres + Redis (docker compose)         │
└──────────────────────────────────────────────┘
```

**Vì sao không deploy backend lên Vercel:** NestJS là long-running
process với Socket.IO + BullMQ + Prisma pool + Redis persistent
connection. Serverless function chết sau ~10s → 4 thứ này đều vỡ.
`relax-project-backend.vercel.app` đã bị **đá ra khỏi chiến lược** —
nên xoá khỏi Vercel dashboard cho đỡ nhầm lẫn.

## 1 lệnh để chạy production

```bash
make share-vercel
```

Lệnh này:
1. Khởi động backend + Postgres + Redis trong docker (profile `api`).
2. Set `CORS_ORIGINS` allow Vercel URL.
3. Chạy `cloudflared tunnel --url http://localhost:6823`.
4. In hướng dẫn set `NEXT_PUBLIC_API_URL` trên Vercel.

Sau đó vào Vercel dashboard:
- Settings → Environment Variables
- Set `NEXT_PUBLIC_API_URL` = URL `*.trycloudflare.com` vừa lấy
- Set `NEXT_PUBLIC_GOOGLE_CLIENT_ID` =
  `884741112800-aq6rsskn13eiv1r3f3e5qbttlj82skcs.apps.googleusercontent.com`
- Deployments → ⋯ → Redeploy

## Google Sign-In — Client ID dùng chung

| Vị trí | Key | Giá trị |
|---|---|---|
| Backend (`.env`) | `GOOGLE_CLIENT_ID` | `884741112800-…apps.googleusercontent.com` |
| Backend (`.env`) | `GOOGLE_CLIENT_SECRET` | secret của OAuth client mới |
| Frontend Vercel (env) | `NEXT_PUBLIC_GOOGLE_CLIENT_ID` | giống y |
| Docker compose | mặc định | đã hard-code Client ID public |

Flow hiện tại là **OAuth authorization code**:
- Web redirect qua Google bằng client mới.
- Google redirect về `/auth/google/callback`.
- Web gửi `authorizationCode` + `redirectUri` cho backend.
- Backend dùng `GOOGLE_CLIENT_SECRET` để đổi code lấy token rồi verify user.

Google Cloud OAuth client mới phải có:
- Authorized JavaScript origins:
  `https://relax-project-web-dashboard.vercel.app`
  và `http://localhost:3233` nếu test local.
- Authorized redirect URIs:
  `https://relax-project-web-dashboard.vercel.app/auth/google/callback`
  và `http://localhost:3233/auth/google/callback` nếu test local.

OAuth client cũ không còn được dùng trong project.
Sau khi rotate secret, cần cập nhật `GOOGLE_CLIENT_SECRET` trên backend env
rồi restart/redeploy backend.

## Authorized JavaScript origins (Google Cloud)

Đã cấu hình:
- `https://relax-project-web-dashboard.vercel.app` ✅
- `http://localhost:3233` ✅

Khi nào cần thêm: nếu đổi Vercel custom domain hoặc test trên LAN
HTTPS, vào Google Cloud Console → Credentials → Client → Authorized
JavaScript origins.

## Các flow khác (vẫn giữ)

| Flow | Lệnh | Khi nào dùng |
|---|---|---|
| **Production (chốt)** | `make share-vercel` | Demo public, soft launch |
| Local full-stack | `make up` | Dev offline, full stack ở local |
| LAN sharing | `make share` | Khách cùng wifi, không cần internet |
| Tunnel cả web | `make tunnel` | Demo web local qua trycloudflare |

## Vấn đề secondary

- **`apps/mobile/relax_app`** — Flutter scaffold chưa kết nối API
  thật. Cần re-think hoặc xoá nếu không tiếp.
- **`packages/{shared-types, shared-utils, ui-kit}`** — gần như rỗng.
  Type/DTO chia sẻ đang duplicate ở backend + web.
- **HTTPS dev** — không có. Geolocation/Notification cần HTTPS hoặc
  localhost → user trên LAN HTTP không xin được quyền. Đã thêm
  permissions panel giải thích nhưng vẫn là limitation.

## Khi nào nâng cấp lên cloud thật

Flow Vercel + tunnel chỉ phụ thuộc máy a bật. Nếu muốn backend tự
sống 24/7 không cần máy a:

| Option | Chi phí | Setup |
|---|---|---|
| **Railway** | ~$15-20/tháng | 10 phút, kết nối GitHub |
| **Fly.io** | $0-10/tháng | Docker-native, dùng Dockerfile có sẵn |
| **Cloudflare named tunnel** | Free | URL cố định, vẫn cần máy a bật |

Em sẽ giúp setup khi a muốn — chỉ cần nói "đi Railway"/"named tunnel".

## Checklist trước khi share Vercel URL cho người khác

- [x] `make share-vercel` chạy ngon, tunnel URL có sẵn
- [ ] Vercel env `NEXT_PUBLIC_API_URL` = tunnel URL → redeployed
- [x] Vercel env `NEXT_PUBLIC_GOOGLE_CLIENT_ID` set → redeployed
- [ ] **Rotate** Google Client Secret (đã lộ trong chat)
- [ ] **Xoá** `relax-project-backend.vercel.app` ở Vercel dashboard
- [x] CORS backend đã có Vercel URL trong allow-list
- [x] Authorized JavaScript origins của Google đã có Vercel URL
