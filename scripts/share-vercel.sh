#!/usr/bin/env bash
# =============================================================================
# share-vercel.sh — backend docker + Cloudflare public tunnel.
#
# Flow:
#   1. Verify Docker daemon + cloudflared CLI sẵn sàng.
#   2. Boot infra (postgres + redis) + backend container với CORS allow Vercel.
#   3. Đợi backend /health trả 200.
#   4. Spawn `cloudflared tunnel --url http://localhost:6823`.
#   5. Extract URL trycloudflare, in bảng hướng dẫn set env Vercel, ghi
#      `.tunnel-url` để a copy lại.
#   6. Stream log cloudflared. Ctrl+C → cleanup tunnel (docker vẫn chạy).
#
# Env override:
#   BACKEND_PORT          (default 6823)
#   VERCEL_WEB_URL        (default https://relax-project-web-dashboard.vercel.app)
#   JWT_SECRET            (auto-generate nếu chưa set)
# =============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

BACKEND_PORT="${BACKEND_PORT:-6823}"
VERCEL_WEB_URL="${VERCEL_WEB_URL:-https://relax-project-web-dashboard.vercel.app}"
GOOGLE_CLIENT_ID_DEFAULT="884741112800-aq6rsskn13eiv1r3f3e5qbttlj82skcs.apps.googleusercontent.com"

red()    { printf '\033[31m%s\033[0m\n' "$*"; }
green()  { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
bold()   { printf '\033[1m%s\033[0m\n' "$*"; }

step() { printf '\n\033[1;36m▶ %s\033[0m\n' "$*"; }

# ----- 1. Prerequisites ------------------------------------------------------

step "1/5  Kiểm tra Docker + cloudflared"

if ! command -v docker >/dev/null 2>&1; then
  red "✗ Không thấy lệnh 'docker'. Cài Docker Desktop: https://www.docker.com/products/docker-desktop"
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  red "✗ Docker daemon chưa chạy."
  yellow "  → Mở Docker Desktop (Applications → Docker), đợi 30-60s tới khi"
  yellow "    icon docker trên menu bar không còn xoay rồi chạy lại lệnh này."
  yellow "  Hoặc: open -a Docker"
  exit 1
fi
green "  ✓ Docker daemon up"

if ! command -v cloudflared >/dev/null 2>&1; then
  red "✗ Không thấy lệnh 'cloudflared'. Cài: brew install cloudflared"
  exit 1
fi
green "  ✓ cloudflared $(cloudflared --version 2>&1 | head -1 | awk '{print $3}')"

# ----- 2. Env wiring ---------------------------------------------------------

step "2/5  Chuẩn bị env"

export JWT_SECRET="${JWT_SECRET:-$(openssl rand -hex 32)}"
export CORS_ORIGINS="${CORS_ORIGINS:-${VERCEL_WEB_URL},http://localhost:3000,http://localhost:3233}"
export GOOGLE_CLIENT_ID="${GOOGLE_CLIENT_ID:-$GOOGLE_CLIENT_ID_DEFAULT}"
export GOOGLE_REDIRECT_URI="${GOOGLE_REDIRECT_URI:-${VERCEL_WEB_URL}/auth/google/callback}"
export NODE_ENV="${NODE_ENV:-production}"

echo "  CORS_ORIGINS  = $CORS_ORIGINS"
echo "  Google Client = ${GOOGLE_CLIENT_ID:0:30}…"
echo "  Google Redirect = $GOOGLE_REDIRECT_URI"
if [[ -z "${GOOGLE_CLIENT_SECRET:-}" ]]; then
  yellow "  ! GOOGLE_CLIENT_SECRET chưa có trong shell. Backend vẫn có thể lấy từ apps/backend/.env,"
  yellow "    nhưng Google OAuth code flow sẽ fail nếu backend deploy không có secret của client mới."
fi

# ----- 3. Boot backend stack -------------------------------------------------

step "3/5  Khởi động Postgres + Redis + backend (docker profile 'api')"

docker compose --profile api up -d --build 2>&1 | tail -15

# Wait for backend /health
echo "  → Đợi backend healthy ở http://localhost:${BACKEND_PORT}/health ..."
ready=0
for i in $(seq 1 30); do
  if curl -sf "http://localhost:${BACKEND_PORT}/health" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 2
done

if (( ready )); then
  green "  ✓ backend ready"
else
  red "✗ Backend không trả /health trong 60s. Log:"
  docker compose logs --tail=40 backend
  exit 1
fi

# ----- 4. Spawn cloudflared --------------------------------------------------

step "4/5  Mở Cloudflare tunnel"

LOG_FILE="$(mktemp -t cloudflared-backend.XXXXXX)"
cloudflared tunnel --no-autoupdate --url "http://localhost:${BACKEND_PORT}" \
  >"$LOG_FILE" 2>&1 &
TUNNEL_PID=$!

cleanup() {
  echo ""
  yellow "↘ Stopping cloudflared (PID $TUNNEL_PID). Docker backend vẫn chạy."
  yellow "  Stop hẳn:  docker compose --profile api down"
  kill "$TUNNEL_PID" 2>/dev/null || true
  rm -f "$LOG_FILE"
}
trap cleanup EXIT INT TERM

TUNNEL_URL=""
for i in $(seq 1 60); do
  TUNNEL_URL="$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' "$LOG_FILE" 2>/dev/null | head -1 || true)"
  if [[ -n "$TUNNEL_URL" ]]; then break; fi
  sleep 1
done

if [[ -z "$TUNNEL_URL" ]]; then
  red "✗ Không lấy được URL trycloudflare sau 60s. Log:"
  tail -30 "$LOG_FILE"
  exit 1
fi

echo "$TUNNEL_URL" > "$ROOT/.tunnel-url"

# ----- 5. Print instructions -------------------------------------------------

step "5/5  Sẵn sàng — copy URL bên dưới vào Vercel"

cat <<EOF

╔════════════════════════════════════════════════════════════════════════╗
║  BACKEND PUBLIC URL                                                    ║
║    $(printf '%-67s' "$TUNNEL_URL")    ║
║  (cũng được ghi vào .tunnel-url ở project root)                       ║
╚════════════════════════════════════════════════════════════════════════╝

Test nhanh:
  curl $TUNNEL_URL/health
  curl $TUNNEL_URL/docs            # Swagger (nếu SWAGGER_PUBLIC=true)

VERCEL dashboard → relax-project-web-dashboard → Settings → Environment Variables:

  NEXT_PUBLIC_API_URL              =  $TUNNEL_URL
  NEXT_PUBLIC_GOOGLE_CLIENT_ID     =  $GOOGLE_CLIENT_ID

Backend deploy/local env cũng phải có:
  GOOGLE_CLIENT_ID                 =  $GOOGLE_CLIENT_ID
  GOOGLE_CLIENT_SECRET             =  <secret của OAuth client mới>
  GOOGLE_REDIRECT_URI              =  $GOOGLE_REDIRECT_URI

Google Cloud OAuth client phải có redirect URI:
  $GOOGLE_REDIRECT_URI

Sau đó: Deployments → ⋯ → Redeploy (bỏ chọn "use existing build cache").

Frontend production:  $VERCEL_WEB_URL

──────────────────────────────────────────────────────────────────────────
 Tunnel đang chạy. Ctrl+C để stop tunnel.
 URL trycloudflare ĐỔI MỖI LẦN restart — sau khi Ctrl+C phải set lại
 Vercel env nếu chạy lại. Muốn URL cố định → dùng cloudflare named
 tunnel (free, xem docs/12-project-audit.md).
──────────────────────────────────────────────────────────────────────────

EOF

# Stream cloudflared log so a thấy live traffic
tail -f "$LOG_FILE" &
TAIL_PID=$!
trap "kill $TAIL_PID 2>/dev/null || true; cleanup" EXIT INT TERM

wait "$TUNNEL_PID"
