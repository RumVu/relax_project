# Cách chạy production (backend tunnel + Vercel frontend)

> Topology: frontend Vercel (đã deploy) → Cloudflare tunnel →
> backend Docker chạy trên máy a → Postgres + Redis Docker.

## 0. One-time setup (làm 1 lần duy nhất)

```bash
# Cài cloudflared (nếu chưa)
brew install cloudflared

# Mở Docker Desktop và đợi icon menu bar đứng yên
open -a Docker

# Kiểm tra mọi prerequisite
make doctor
```

`make doctor` phải in toàn ✓. Nếu thấy ✗ thì sửa trước khi đi tiếp.

## 1. Mỗi lần muốn chạy

```bash
make share-vercel
```

Script sẽ:
1. Pre-check Docker + cloudflared.
2. Boot Postgres + Redis + backend trong docker.
3. Đợi backend healthy.
4. Mở Cloudflare tunnel → in URL `https://<random>.trycloudflare.com`.
5. Lưu URL vào `.tunnel-url` (gitignored).

Output ví dụ:

```
╔════════════════════════════════════════════════════════════════════════╗
║  BACKEND PUBLIC URL                                                    ║
║    https://elephant-rapid-purple.trycloudflare.com                    ║
╚════════════════════════════════════════════════════════════════════════╝

VERCEL dashboard → Settings → Environment Variables:
  NEXT_PUBLIC_API_URL = https://elephant-rapid-purple.trycloudflare.com
  ...
```

## 2. Update Vercel env (LẦN ĐẦU hoặc khi tunnel URL đổi)

URL tunnel **đổi mỗi lần** restart `make share-vercel`. Sau khi
script in URL ra:

1. https://vercel.com/dashboard → project `relax-project-web-dashboard`
2. Settings → Environment Variables
3. Set/update:
   - `NEXT_PUBLIC_API_URL` = URL trycloudflare vừa lấy
   - `NEXT_PUBLIC_GOOGLE_CLIENT_ID` = `884741112800-aq6rsskn13eiv1r3f3e5qbttlj82skcs.apps.googleusercontent.com`
4. Deployments → click ⋯ trên deployment mới nhất → **Redeploy**
   (bỏ tick "Use existing build cache" để env mới chắc chắn được pickup)
5. Đợi ~2-3 phút build xong.

> Muốn URL **cố định** không phải update Vercel mỗi lần: dùng
> Cloudflare named tunnel (xem cuối doc).

## 3. Test end-to-end

Khi tunnel sống + Vercel redeploy xong:

```bash
# Test trực tiếp tunnel (terminal)
curl $(make tunnel-url)/health
# → {"status":"ok",...}

# Test qua frontend
open https://relax-project-web-dashboard.vercel.app
```

Bấm "Sign in with Google" → chọn account → nếu thành công vào được
dashboard là toàn bộ chuỗi đã chạy.

## 4. Stop / restart

| Tác vụ | Lệnh |
|---|---|
| Stop tunnel (giữ backend chạy) | `Ctrl+C` trong terminal đang chạy share-vercel |
| Stop backend docker | `make backend-stop` |
| Stop hẳn (xoá container, giữ data Postgres) | `make backend-stop` rồi `docker compose down` |
| Xoá luôn data (DESTRUCTIVE) | `make infra-reset` |
| Xem log backend live | `docker compose logs -f backend` |
| Xem log tunnel | nó đã stream sẵn trong terminal share-vercel |

## 5. Troubleshooting

### "Cannot connect to the Docker daemon"
Docker Desktop chưa chạy hoặc chưa ready. Mở Docker, đợi 30-60s,
rerun `make doctor`.

### Backend không healthy sau 60s
```bash
docker compose logs --tail=80 backend
```
Thường là `DATABASE_URL` sai (postgres chưa lên) hoặc `JWT_SECRET`
quá yếu. Script tự sinh secret ngon, nhưng nếu a export biến
`JWT_SECRET` ngoài shell mà ngắn quá thì backend từ chối.

### Tunnel URL không lấy được sau 60s
Mạng a chặn cloudflared, hoặc Cloudflare đang outage. Thử:
```bash
cloudflared tunnel --url http://localhost:6823
```
chạy tay xem có in URL không.

### Frontend Vercel báo CORS/network error
- Vercel env `NEXT_PUBLIC_API_URL` đã đúng URL tunnel mới chưa?
- Đã redeploy chưa? (env cũ vẫn nằm trong build cũ cho tới khi rebuild)
- Backend log có thấy request không? `docker compose logs -f backend`
- Có thể CORS chưa allow URL Vercel — set lại biến môi trường:
  ```bash
  CORS_ORIGINS=https://relax-project-web-dashboard.vercel.app,http://localhost:3233 make share-vercel
  ```

### Google Sign-In thất bại
- Vercel env `NEXT_PUBLIC_GOOGLE_CLIENT_ID` set chưa? Redeploy chưa?
- Backend env `GOOGLE_CLIENT_ID` có trùng client mới không?
- Backend env `GOOGLE_CLIENT_SECRET` đã set chưa? Flow hiện tại dùng
  authorization code nên backend bắt buộc có secret để đổi code với Google.
- Backend env `GOOGLE_REDIRECT_URI` có đúng
  `https://relax-project-web-dashboard.vercel.app/auth/google/callback`
  không? Sai 1 ký tự là Google từ chối đổi code.
- Google Cloud Console đang dùng OAuth client mới:
  `884741112800-aq6rsskn13eiv1r3f3e5qbttlj82skcs.apps.googleusercontent.com`.
- Authorized JavaScript origins ở Google Cloud Console có Vercel URL chưa?
  https://console.cloud.google.com → APIs & Services → Credentials →
  click Client → Authorized JavaScript origins → add Vercel URL.
- Authorized redirect URIs phải có đúng:
  `https://relax-project-web-dashboard.vercel.app/auth/google/callback`.
- Nếu test local callback thì thêm:
  `http://localhost:3233/auth/google/callback`.
- Nếu vẫn gặp `redirect_uri_mismatch`, xoá OAuth client cũ khỏi env/deploy
  và redeploy lại bằng client mới.

### URL tunnel cố định (không đổi mỗi lần)

Quick tunnel đổi URL mỗi restart. Named tunnel free + URL cố định:

```bash
# 1. Login (mở browser → chọn domain ở Cloudflare)
cloudflared tunnel login

# 2. Tạo tunnel
cloudflared tunnel create relax-backend

# 3. Route subdomain
cloudflared tunnel route dns relax-backend api.relax.<domain>.com

# 4. Tạo config
mkdir -p ~/.cloudflared
cat > ~/.cloudflared/config.yml <<EOF
tunnel: relax-backend
credentials-file: ~/.cloudflared/<tunnel-id>.json
ingress:
  - hostname: api.relax.<domain>.com
    service: http://localhost:6823
  - service: http_status:404
EOF

# 5. Chạy
cloudflared tunnel run relax-backend
```

URL `https://api.relax.<domain>.com` cố định, set Vercel env 1 lần
là xong.

## 6. Cheat sheet

```bash
# Lần đầu
brew install cloudflared
open -a Docker
make doctor

# Mỗi lần chạy
make share-vercel              # boot + tunnel + in URL
make tunnel-url                # lấy lại URL hiện tại

# Stop
Ctrl+C                          # stop tunnel
make backend-stop               # stop docker

# Debug
docker compose logs -f backend  # log backend live
curl $(make tunnel-url)/health  # test tunnel
```
