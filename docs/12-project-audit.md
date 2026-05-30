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

## Tech stack — chỗ nào ổn, chỗ nào kẹt

### ✅ Ổn — đã tốt cho production

- **Frontend (Next.js 16)** — static + SSR routes, build sạch, deploy
  Vercel xanh, đã có CSP/HSTS/CORS headers. Bundle ~430 KB.
- **CI** — full pipeline: lint, Web build + Playwright, Backend unit +
  e2e với Postgres+Redis services. Push → 3-5 phút có kết quả.
- **Test coverage** — 161 test (backend 128 + web 33) — đủ để refactor
  không sợ vỡ.
- **Local dev (Docker)** — `make share` 1 lệnh ra LAN URL. Build
  cache, không cần `npm install` ở host.

### ⚠️ Architectural blocker — Backend KHÔNG fit Vercel

NestJS backend của a là **long-running Node process** với 4 thành phần
không tương thích serverless:

| Thành phần | Vấn đề trên Vercel |
|---|---|
| **Socket.IO realtime** (`@nestjs/platform-socket.io` + `@socket.io/redis-adapter`) | Cần connection sống lâu, Vercel cold-start mỗi request → notification "thiết bị mới" + dashboard live update đứt |
| **BullMQ workers** (`bullmq`) | Workers cần process chạy 24/7 process queue, serverless function chỉ sống ~10s |
| **Prisma connection pool** | Mỗi cold-start tạo pool mới → connection exhaustion ở Postgres free tier |
| **Redis client** (`ioredis`) | Persistent connection bị reset mỗi invocation |

Đây là lý do `relax-project-backend.vercel.app` Error Rate 100% —
không phải bug code, là kiến trúc không khớp.

### 🟡 Vấn đề secondary

- **`apps/mobile/relax_app`** — Flutter scaffold chưa kết nối API thật.
  Vẫn là Hello World counter. Cần re-think hoặc xoá nếu không tiếp.
- **`packages/{shared-types, shared-utils, ui-kit}`** — gần như rỗng.
  Type/DTO chia sẻ đang duplicate ở backend + web.
- **HTTPS dev** — không có. Geolocation/Notification cần HTTPS hoặc
  localhost → user trên LAN HTTP không xin được quyền. Đã thêm
  permissions panel giải thích nhưng vẫn là limitation.
- **`GOOGLE_CLIENT_SECRET`** — đã lộ trong chat. Cần rotate.

## Lựa chọn deploy production

### Option A — Railway (đề xuất nếu muốn full deploy)

| Hạng mục | Railway |
|---|---|
| Backend NestJS | ✅ Long-running container, Socket.IO + BullMQ chạy ngon |
| Postgres | ✅ Bundled add-on $5/mo |
| Redis | ✅ Bundled add-on $5/mo |
| Free tier | $5 credit trial, ~500h container |
| Setup | 10 phút: kết nối GitHub → chọn `apps/backend` → set env |
| HTTPS | ✅ tự cấp |
| Realtime | ✅ Socket.IO + BullMQ + Prisma đều OK |

Chi phí thật: **~$15-20/tháng** (backend container + Postgres + Redis).

### Option B — Fly.io

| Hạng mục | Fly.io |
|---|---|
| Backend | ✅ Docker-native, dùng nguyên Dockerfile có sẵn |
| Postgres | ✅ Fly Postgres free tier (256MB) |
| Redis | ⚠️ Phải tự cài Upstash hoặc Fly Redis |
| Free tier | 3 shared-cpu VMs free + 3GB volume |

Chi phí thật: **~$0-10/tháng** nếu nhẹ.

### Option C — Render

| Hạng mục | Render |
|---|---|
| Backend | ✅ Web Service Docker |
| Postgres | ✅ Free 90 ngày, sau đó $7/mo |
| Redis | ❌ Không có managed, dùng Upstash |

Chi phí thật: **~$7-25/tháng**.

### Option D — Giữ backend local + Cloudflare Tunnel

Đã có sẵn `make tunnel`. URL `*.trycloudflare.com` đổi mỗi lần restart.

| Pros | Cons |
|---|---|
| Free | URL đổi mỗi lần restart |
| Setup 0 phút | Phụ thuộc máy a phải bật |
| Realtime + queue chạy ngon | Không production-grade |

→ Chỉ phù hợp **demo, dev, share cho 1-2 người**.

### Option E — Backend local + Cloudflare Named Tunnel (cố định URL)

Nâng cấp option D: `cloudflared tunnel create` để có URL cố định
(vd `api.relax-project.vu-quang-minh.com`). Free, URL không đổi, vẫn
phụ thuộc máy a bật.

## Đề xuất em

| Mục tiêu | Hành động |
|---|---|
| **Demo tuần này** | Option D (`make tunnel`) — gửi URL `trycloudflare.com` cho khách test, kết hợp Vercel web đã có |
| **Demo dài hạn 1 tháng** | Option E (Cloudflare named tunnel) — URL cố định, vẫn free |
| **Soft launch public** | Option A (Railway) — production-grade, full stack ở 1 nhà cung cấp |
| **Học/portfolio** | Option B (Fly.io) — rẻ nhất, Docker-native |

## Sự thật phũ phàng về Vercel backend

A đã trả tiền tâm trí (debug 500) cho cái deploy không bao giờ chạy
được. **Em đề xuất xoá** `relax-project-backend.vercel.app` để khỏi
nhầm lẫn. Vercel chỉ giữ cho `relax-project-web-dashboard.vercel.app`.

## Kế hoạch hành động

1. ⚠️ **Rotate** Google Client Secret (đã lộ public)
2. 🗑️ **Xoá** Vercel backend deployment
3. ⚙️ Set 3 env trên Vercel web:
   - `NEXT_PUBLIC_API_URL=<URL backend chọn ở dưới>`
   - `NEXT_PUBLIC_GOOGLE_CLIENT_ID=627379199532-…`
   - Redeploy
4. 🌍 Chọn 1 trong 4 path backend (D/E cho ngắn, A/B cho dài)
5. 📝 Update backend `CORS_ORIGINS` để có URL Vercel web

Em sẽ giúp a setup cụ thể bất kỳ path nào — chỉ cần nói "đi
Railway"/"đi Cloudflare named tunnel"/v.v.
