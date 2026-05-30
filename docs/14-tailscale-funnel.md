# Tailscale Funnel — backend public với URL cố định

> **Mục tiêu:** đóng máy, mở máy, bật Docker → backend tự lên kèm URL công
> khai **giữ nguyên mãi mãi**. Không phải Cloudflare quick-tunnel (random URL
> mỗi lần restart).

## Kết quả cuối cùng

- URL công khai cố định: `https://relax-backend.<tailnet-tên-của-a>.ts.net`
- Container `digital-cigarette-tailscale` tự khởi động khi Docker bật
- Bị lỗi → Docker restart container (volume `tailscale_state` giữ định danh
  máy, URL không đổi)
- Vercel env `NEXT_PUBLIC_API_URL` set **1 lần** rồi quên

## Setup 1 lần duy nhất (~5 phút)

### Bước 1 — Tạo Tailscale account (free)

https://login.tailscale.com/start → login bằng Google/GitHub/Microsoft.

Sau khi xong, a có 1 "tailnet" — vd `rumvu.tail-scale.ts.net` (tên này tự đặt
ở admin panel hoặc Tailscale auto-gen).

### Bước 2 — Bật HTTPS Certificates

https://login.tailscale.com/admin/dns

Trong section **HTTPS Certificates**, bấm **Enable HTTPS**.

> Cần thiết vì Funnel chỉ chạy trên HTTPS (port 443).

### Bước 3 — Bật Funnel cho tailnet

https://login.tailscale.com/admin/settings/features

Cuộn xuống section **Funnel**, bấm **Enable Funnel**.

### Bước 4 — Tạo Auth Key (reusable)

https://login.tailscale.com/admin/settings/keys

Bấm **Generate auth key**:
- ✅ **Reusable** (để container tái join được sau khi clear state nếu cần)
- ✅ **Ephemeral: NO** (cần persistent device để URL không đổi)
- **Expiry**: 90 ngày là default (sau 90 ngày phải regen key, nhưng device
  vẫn còn — chỉ blocker cho việc khởi tạo lần đầu)
- **Tags**: để trống cũng được, hoặc add `tag:funnel`

Copy key dạng `tskey-auth-...`.

### Bước 5 — Set TS_AUTHKEY env

Thêm vào file `apps/backend/.env` (gitignored):

```env
TS_AUTHKEY=tskey-auth-xxxxxxxxxxxx
TS_HOSTNAME=relax-backend
```

Hoặc export inline khi chạy:

```bash
export TS_AUTHKEY=tskey-auth-xxxxxxxxxxxx
```

### Bước 6 — Khởi động container

```bash
make funnel
```

(target này = `docker compose --profile api --profile funnel up -d --build`)

### Bước 7 — Lấy URL công khai

```bash
make funnel-url
```

In ra dạng `https://relax-backend.<tailnet>.ts.net`. Test:

```bash
curl $(make funnel-url)/health
# {"status":"ok",...}
```

### Bước 8 — Set Vercel env (1 lần)

Vercel dashboard → Settings → Environment Variables:

- `NEXT_PUBLIC_API_URL` = URL từ bước 7
- Redeploy

**Đây là lần CUỐI a phải đụng Vercel env.** URL không bao giờ đổi nữa.

## Vận hành hàng ngày

Sau setup lần đầu:

| Tình huống | Tự động |
|---|---|
| A đóng laptop, sáng mai mở lại + bật Docker Desktop | Docker auto-start cả 4 container (postgres, redis, backend, tailscale). URL Tailscale **không đổi**. |
| Tailscale container crash | `restart: unless-stopped` → Docker tự restart container. |
| Backend container crash | Tự restart, Tailscale vẫn proxy đến `backend:6823` qua docker network. |
| A `make backend-stop` | Tailscale container cũng dừng (`depends_on: backend`). |
| Reboot máy | Docker Desktop start lúc login (nếu a bật "Start Docker Desktop when you sign in"). |

## Kiểm tra trạng thái

```bash
docker exec digital-cigarette-tailscale tailscale status
docker exec digital-cigarette-tailscale tailscale funnel status
```

## Troubleshooting

### URL trả 502 Bad Gateway

Backend container down hoặc unhealthy. Check:
```bash
docker compose --profile api ps
curl http://localhost:6823/health
```

### URL không reachable từ ngoài (timeout)

Funnel chưa bật ở admin panel. Bước 3 ở trên.

### Tailscale container exit ngay

Auth key sai/hết hạn. Generate key mới ở bước 4 → update env → restart:
```bash
docker compose --profile funnel up -d --force-recreate tailscale
```

### Đổi hostname → URL đổi → phải update Vercel

Default `TS_HOSTNAME=relax-backend`. Nếu đổi → URL đổi → set lại Vercel env.

## Vì sao chọn Tailscale Funnel thay vì Cloudflare Named Tunnel?

| | Tailscale Funnel | Cloudflare Named Tunnel |
|---|---|---|
| Domain riêng | ❌ Không cần | ✅ Cần (mua ~$10/năm) |
| URL cố định | ✅ `<host>.<tailnet>.ts.net` | ✅ `api.<your-domain>.com` |
| Bandwidth limit | ⚠️ Free tier ~1 GB/tháng | Không limit |
| Auto-restart docker | ✅ Same | ✅ Same |
| Setup time | ~5 phút | ~10 phút + cần domain |

Nếu a vượt 1 GB/tháng (~30k pageviews) → upgrade Tailscale Personal Pro
($5/tháng) hoặc switch sang Cloudflare với domain.
