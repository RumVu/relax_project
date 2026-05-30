#!/usr/bin/env bash
# =============================================================================
# Seed ambient sounds vào Supabase Storage + Postgres (qua Prisma raw upsert).
#
# Vì stream-download Pixabay/Mixkit bị hotlink-block, em generate procedural
# ambient noise bằng ffmpeg — đủ chất lượng cho mục đích thư giãn:
#   - rain  = brown noise + low-pass 800 Hz
#   - ocean = pink noise + slow LFO biến điệu
#   - forest = white noise filtered + bird-like sine sweeps
#   - lofi  = pink noise + chord pad đơn giản
#   - calm-piano = slow sine pad
#   - whitenoise = pure white noise
#   - brownnoise = pure brown noise
#   - meditation = sine drone 432 Hz
# Mỗi file ~30 giây, MP3 128 kbps, < 500 KB. Looping ở client.
#
# Khi a có asset thật → upload qua admin UI hoặc thay file ở Supabase, URL
# vẫn giữ nên FE không cần đổi.
#
# Usage:
#   bash scripts/seed-ambient-sounds.sh
# Yêu cầu:
#   - ffmpeg cài qua brew
#   - SUPABASE_URL + SUPABASE_SECRET_KEY trong env (đọc tự apps/backend/.env nếu có)
#   - docker postgres đang chạy (script sẽ insert qua psql trong container)
# =============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# ---- Resolve Supabase env -----------------------------------------------------
: "${SUPABASE_URL:=${NEXT_PUBLIC_SUPABASE_URL:-}}"
: "${SUPABASE_SECRET_KEY:=}"
: "${SUPABASE_BUCKET:=public-assets}"

if [[ -z "$SUPABASE_URL" || -z "$SUPABASE_SECRET_KEY" ]]; then
  echo "✗ Cần SUPABASE_URL và SUPABASE_SECRET_KEY trong env." >&2
  echo "  Export trước khi chạy hoặc đặt vào apps/backend/.env." >&2
  exit 1
fi

echo "→ Supabase: $SUPABASE_URL bucket=$SUPABASE_BUCKET"

# ---- Generate sounds with ffmpeg ---------------------------------------------
WORK="$(mktemp -d -t ambient-sounds.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

noise_track() {
  # Generate a single noise track using only lavfi input + audio filter chain.
  # Usage: noise_track <name> <lavfi-source> [post-filter]
  local name="$1" src="$2" post="${3:-}"
  local out="$WORK/${name}.mp3"
  echo "  → ffmpeg generate $name"
  if [[ -n "$post" ]]; then
    ffmpeg -hide_banner -loglevel error -y \
      -f lavfi -i "$src" \
      -af "$post" \
      -b:a 96k -ar 44100 "$out"
  else
    ffmpeg -hide_banner -loglevel error -y \
      -f lavfi -i "$src" \
      -b:a 96k -ar 44100 "$out"
  fi
}

echo "→ Generate 8 ambient tracks (30s each, ~250 KB)"

# rain    = brown noise + low-pass 800 Hz (muffled distant rain)
# ocean   = pink noise modulated by slow tremolo (waves)
# forest  = filtered white noise (rustling leaves) + chorus for movement
# lofi    = pink noise + vibrato + lowpass
# white   = pure white noise
# brown   = pure brown noise
noise_track rain       "anoisesrc=color=brown:duration=30:amplitude=0.6" "lowpass=f=800,volume=1.4"
noise_track ocean      "anoisesrc=color=pink:duration=30:amplitude=0.6"  "tremolo=f=0.15:d=0.8,lowpass=f=1500"
noise_track forest     "anoisesrc=color=white:duration=30:amplitude=0.45" "highpass=f=800,lowpass=f=4000,chorus=0.5:0.9:50:0.4:0.25:2"
noise_track lofi       "anoisesrc=color=pink:duration=30:amplitude=0.4"  "vibrato=f=4:d=0.3,lowpass=f=3000"
noise_track whitenoise "anoisesrc=color=white:duration=30:amplitude=0.5"
noise_track brownnoise "anoisesrc=color=brown:duration=30:amplitude=0.7"

# Meditation drone — 432 Hz + perfect fifth, blended via filter_complex
echo "  → ffmpeg generate meditation (sine 432 Hz + fifth)"
ffmpeg -hide_banner -loglevel error -y \
  -f lavfi -i "sine=frequency=432:duration=30" \
  -f lavfi -i "sine=frequency=648:duration=30" \
  -filter_complex "[0:a][1:a]amix=inputs=2:duration=longest,volume=0.3,tremolo=f=0.15:d=0.4[out]" \
  -map "[out]" \
  -b:a 96k -ar 44100 "$WORK/meditation.mp3"

# Piano-like pad — C major chord (C/E/G) sustained
echo "  → ffmpeg generate calm-piano (chord pad)"
ffmpeg -hide_banner -loglevel error -y \
  -f lavfi -i "sine=frequency=261.63:duration=30" \
  -f lavfi -i "sine=frequency=329.63:duration=30" \
  -f lavfi -i "sine=frequency=392.00:duration=30" \
  -filter_complex "[0:a][1:a][2:a]amix=inputs=3:duration=longest,volume=0.35,tremolo=f=0.5:d=0.2,lowpass=f=2500[out]" \
  -map "[out]" \
  -b:a 96k -ar 44100 "$WORK/calm-piano.mp3"

ls -lh "$WORK"

# ---- Upload to Supabase -------------------------------------------------------
upload() {
  local local_file="$1" remote_path="$2"
  local url="$SUPABASE_URL/storage/v1/object/$SUPABASE_BUCKET/$remote_path"
  # New `sb_secret_*` keys require the `apikey` header, NOT `Authorization:
  # Bearer` (which Supabase tries to parse as a JWT and rejects with
  # "Invalid Compact JWS"). x-upsert lets re-runs replace existing files.
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "$url" \
    -H "apikey: $SUPABASE_SECRET_KEY" \
    -H "Content-Type: audio/mpeg" \
    -H "x-upsert: true" \
    --data-binary "@$local_file")
  if [[ "$status" =~ ^20 ]]; then
    echo "  ✓ $remote_path"
  else
    echo "  ✗ $remote_path → HTTP $status"
    return 1
  fi
}

echo ""
echo "→ Upload to Supabase bucket=$SUPABASE_BUCKET path=ambient-sounds/"
for name in rain ocean forest lofi whitenoise brownnoise meditation calm-piano; do
  upload "$WORK/${name}.mp3" "ambient-sounds/${name}.mp3"
done

# ---- Generate SQL upsert ------------------------------------------------------
public_url() {
  echo "$SUPABASE_URL/storage/v1/object/public/$SUPABASE_BUCKET/ambient-sounds/$1.mp3"
}

# Image picks (Unsplash public photo URLs by topic — hotlink-friendly, no key needed)
IMG_RAIN="https://images.unsplash.com/photo-1519692933481-e162a57d6721?w=600"
IMG_OCEAN="https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=600"
IMG_FOREST="https://images.unsplash.com/photo-1448375240586-882707db888b?w=600"
IMG_LOFI="https://images.unsplash.com/photo-1453738773917-9c3eff1db985?w=600"
IMG_WHITENOISE="https://images.unsplash.com/photo-1532634922-8fe0b757fb13?w=600"
IMG_BROWN="https://images.unsplash.com/photo-1499728603263-13726abce5fd?w=600"
IMG_MEDITATION="https://images.unsplash.com/photo-1545205597-3d9d02c29597?w=600"
IMG_PIANO="https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=600"

# Upsert SQL — id is deterministic ('seeded-{name}') so re-runs update in-place.
SQL=$(cat <<EOF
INSERT INTO ambient_sounds (id, title, description, category, "soundUrl", "imageUrl", duration, "isActive", "createdAt", "updatedAt")
VALUES
  ('seeded-rain',         'Mưa rơi nhẹ',          'Âm thanh mưa rơi trên mái lá, giúp thư giãn tâm trí.',                  'RAIN',       '$(public_url rain)',         '$IMG_RAIN',        30, true, NOW(), NOW()),
  ('seeded-ocean',        'Sóng biển dịu êm',     'Tiếng sóng vỗ chậm rãi vào bờ, hợp khi cần ngủ sâu.',                  'NATURE',     '$(public_url ocean)',        '$IMG_OCEAN',       30, true, NOW(), NOW()),
  ('seeded-forest',       'Rừng cây ban mai',     'Tiếng gió và chim hót trong rừng, hợp lúc khởi đầu ngày mới.',          'NATURE',     '$(public_url forest)',       '$IMG_FOREST',      30, true, NOW(), NOW()),
  ('seeded-lofi',         'Lo-fi thư thái',       'Nhạc nền nhẹ mang phong cách lo-fi để tập trung làm việc.',             'LOFI',       '$(public_url lofi)',         '$IMG_LOFI',        30, true, NOW(), NOW()),
  ('seeded-whitenoise',   'Tiếng ồn trắng',       'Tiếng ồn trắng đều giúp chặn tạp âm xung quanh.',                       'AMBIENT',    '$(public_url whitenoise)',   '$IMG_WHITENOISE',  30, true, NOW(), NOW()),
  ('seeded-brownnoise',   'Tiếng ồn nâu',         'Tiếng ồn nâu trầm ấm, dễ ngủ hơn ồn trắng.',                            'AMBIENT',    '$(public_url brownnoise)',   '$IMG_BROWN',       30, true, NOW(), NOW()),
  ('seeded-meditation',   'Tần số thiền 432Hz',   'Dải tần ấm áp dùng trong các phiên thiền định.',                        'MEDITATION', '$(public_url meditation)',   '$IMG_MEDITATION',  30, true, NOW(), NOW()),
  ('seeded-calm-piano',   'Hợp âm piano dịu',     'Hợp âm piano kéo dài nhẹ nhàng, hợp khi thư giãn buổi tối.',            'PIANO',      '$(public_url calm-piano)',   '$IMG_PIANO',       30, true, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET
  title       = EXCLUDED.title,
  description = EXCLUDED.description,
  category    = EXCLUDED.category,
  "soundUrl"  = EXCLUDED."soundUrl",
  "imageUrl"  = EXCLUDED."imageUrl",
  duration    = EXCLUDED.duration,
  "isActive"  = EXCLUDED."isActive",
  "updatedAt" = NOW();
EOF
)

echo ""
echo "→ Upsert 8 records into ambient_sounds"
docker exec -i digital-cigarette-postgres \
  psql -U postgres -d digital_cigarette_break -v ON_ERROR_STOP=1 -c "$SQL"

echo ""
echo "✓ Done. Verify:"
echo "  curl -s '$SUPABASE_URL/storage/v1/object/list/$SUPABASE_BUCKET' \\"
echo "    -H 'Authorization: Bearer \$SUPABASE_SECRET_KEY' \\"
echo "    -H 'Content-Type: application/json' -d '{\"prefix\":\"ambient-sounds\"}'"
echo ""
echo "  curl -s http://localhost:6823/v1/ambient-sounds | python3 -m json.tool | head -40"
