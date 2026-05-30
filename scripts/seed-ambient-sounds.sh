#!/usr/bin/env bash
# =============================================================================
# Seed ambient sounds vào Supabase Storage + Postgres.
#
# Pixabay/Mixkit chặn hotlink download → script generate procedural ambient
# noise bằng ffmpeg. Đủ chất lượng làm placeholder để admin upload thật sau:
#
#   rain        brown noise + low-pass 800 Hz (mưa xa)
#   ocean       pink noise + tremolo chậm (sóng vỗ)
#   forest      white noise filter + chorus (lá xào xạc)
#   lofi        pink noise + vibrato + lowpass
#   whitenoise  white noise nguyên bản
#   brownnoise  brown noise nguyên bản
#   meditation  sine 432 Hz + perfect fifth
#   calm-piano  C-major chord sustained (C/E/G)
#
# Mỗi file ~30s MP3 96 kbps (~350 KB). Loop ở client. Khi a có asset thật
# → upload qua admin UI hoặc thay file ở Supabase, URL không đổi.
#
# Usage:
#   SUPABASE_URL=... SUPABASE_SECRET_KEY=... bash scripts/seed-ambient-sounds.sh
# Yêu cầu:
#   - ffmpeg (brew install ffmpeg)
#   - SUPABASE_URL + SUPABASE_SECRET_KEY trong env
#   - docker postgres `digital-cigarette-postgres` đang chạy
# =============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# ---- Resolve env -------------------------------------------------------------
: "${SUPABASE_URL:=}"
: "${SUPABASE_SECRET_KEY:=}"
: "${SUPABASE_BUCKET:=public-assets}"

if [[ -z "$SUPABASE_URL" || -z "$SUPABASE_SECRET_KEY" ]]; then
  echo "✗ Cần SUPABASE_URL và SUPABASE_SECRET_KEY trong env." >&2
  exit 1
fi

echo "→ Supabase: $SUPABASE_URL bucket=$SUPABASE_BUCKET"

# ---- Track manifest ----------------------------------------------------------
# Một dòng = một track: name|category|title|description|imageUrl|ffmpeg-source|post-filter
# - ffmpeg-source: lavfi `anoisesrc=...` hoặc `sine=...` cho tone
# - post-filter:   chuỗi `-af` áp dụng sau (dùng `anull` nếu không cần)
# Manifest này drive cả 3 pha: generate, upload, upsert SQL.
TRACKS=(
  "rain|RAIN|Mưa rơi nhẹ|Âm thanh mưa rơi trên mái lá, giúp thư giãn tâm trí.|https://images.unsplash.com/photo-1519692933481-e162a57d6721?w=600|anoisesrc=color=brown:duration=30:amplitude=0.6|lowpass=f=800,volume=1.4"
  "ocean|NATURE|Sóng biển dịu êm|Tiếng sóng vỗ chậm rãi vào bờ, hợp khi cần ngủ sâu.|https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=600|anoisesrc=color=pink:duration=30:amplitude=0.6|tremolo=f=0.15:d=0.8,lowpass=f=1500"
  "forest|NATURE|Rừng cây ban mai|Tiếng gió và chim hót trong rừng, hợp lúc khởi đầu ngày mới.|https://images.unsplash.com/photo-1448375240586-882707db888b?w=600|anoisesrc=color=white:duration=30:amplitude=0.45|highpass=f=800,lowpass=f=4000,chorus=0.5:0.9:50:0.4:0.25:2"
  "lofi|LOFI|Lo-fi thư thái|Nhạc nền nhẹ mang phong cách lo-fi để tập trung làm việc.|https://images.unsplash.com/photo-1453738773917-9c3eff1db985?w=600|anoisesrc=color=pink:duration=30:amplitude=0.4|vibrato=f=4:d=0.3,lowpass=f=3000"
  "whitenoise|AMBIENT|Tiếng ồn trắng|Tiếng ồn trắng đều giúp chặn tạp âm xung quanh.|https://images.unsplash.com/photo-1532634922-8fe0b757fb13?w=600|anoisesrc=color=white:duration=30:amplitude=0.5|anull"
  "brownnoise|AMBIENT|Tiếng ồn nâu|Tiếng ồn nâu trầm ấm, dễ ngủ hơn ồn trắng.|https://images.unsplash.com/photo-1499728603263-13726abce5fd?w=600|anoisesrc=color=brown:duration=30:amplitude=0.7|anull"
)

# meditation + calm-piano cần multi-input filter_complex (không khớp shape ở
# trên), nên generate riêng bằng MULTI_TRACKS. Cùng manifest fields nhưng
# `ffmpeg-source` field là special token: `MULTI:filter_complex_expr`.
MULTI_TRACKS=(
  "meditation|MEDITATION|Tần số thiền 432Hz|Dải tần ấm áp dùng trong các phiên thiền định.|https://images.unsplash.com/photo-1545205597-3d9d02c29597?w=600|MULTI:sine=frequency=432:duration=30;sine=frequency=648:duration=30;[0:a][1:a]amix=inputs=2:duration=longest,volume=0.3,tremolo=f=0.15:d=0.4"
  "calm-piano|PIANO|Hợp âm piano dịu|Hợp âm piano kéo dài nhẹ nhàng, hợp khi thư giãn buổi tối.|https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=600|MULTI:sine=frequency=261.63:duration=30;sine=frequency=329.63:duration=30;sine=frequency=392.00:duration=30;[0:a][1:a][2:a]amix=inputs=3:duration=longest,volume=0.35,tremolo=f=0.5:d=0.2,lowpass=f=2500"
)

# ---- Generate sounds with ffmpeg --------------------------------------------
WORK="$(mktemp -d -t ambient-sounds.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

# Common ffmpeg flags (hide chatter, error-only logs, overwrite, MP3 96k 44.1).
FFMPEG_BASE=(ffmpeg -hide_banner -loglevel error -y)
FFMPEG_ENCODE=(-b:a 96k -ar 44100)

# Simple single-input track: lavfi source + optional -af chain. Use `anull`
# in the manifest when no filter is needed — avoids an if/else branch.
gen_noise() {
  local name="$1" src="$2" post="$3"
  "${FFMPEG_BASE[@]}" -f lavfi -i "$src" -af "$post" "${FFMPEG_ENCODE[@]}" "$WORK/${name}.mp3"
}

# Multi-input track: `;` separates inputs and the trailing filter_complex.
# Last segment is the complex graph; everything before is a `-i` source.
# Index math (instead of `parts[-1]`) for portability with macOS bash 3.2.
gen_multi() {
  local name="$1" spec="$2"
  IFS=';' read -ra parts <<< "$spec"
  local last=$((${#parts[@]} - 1))
  local fc="${parts[$last]}"
  local sources=("${parts[@]:0:$last}")
  local args=()
  for src in "${sources[@]}"; do
    args+=(-f lavfi -i "$src")
  done
  "${FFMPEG_BASE[@]}" "${args[@]}" \
    -filter_complex "${fc},aformat=channel_layouts=stereo[out]" \
    -map "[out]" "${FFMPEG_ENCODE[@]}" "$WORK/${name}.mp3"
}

echo "→ Generate 8 ambient tracks in parallel"
pids=()
for row in "${TRACKS[@]}"; do
  IFS='|' read -r name _cat _title _desc _img src post <<< "$row"
  echo "  → ffmpeg generate $name"
  gen_noise "$name" "$src" "$post" &
  pids+=($!)
done
for row in "${MULTI_TRACKS[@]}"; do
  IFS='|' read -r name _cat _title _desc _img spec <<< "$row"
  echo "  → ffmpeg generate $name"
  gen_multi "$name" "${spec#MULTI:}" &
  pids+=($!)
done
# Wait for all ffmpeg jobs; any failure aborts the script via `set -e`.
for pid in "${pids[@]}"; do wait "$pid"; done

# ---- Upload to Supabase (parallel) ------------------------------------------
# New `sb_secret_*` keys require the `apikey` header, NOT `Authorization:
# Bearer` (which Supabase tries to parse as a JWT and rejects with
# "Invalid Compact JWS"). x-upsert lets re-runs replace existing files.
upload() {
  local local_file="$1" remote_path="$2"
  local url="$SUPABASE_URL/storage/v1/object/$SUPABASE_BUCKET/$remote_path"
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
    echo "  ✗ $remote_path → HTTP $status" >&2
    return 1
  fi
}

echo ""
echo "→ Upload to Supabase bucket=$SUPABASE_BUCKET (parallel)"
pids=()
for row in "${TRACKS[@]}" "${MULTI_TRACKS[@]}"; do
  IFS='|' read -r name _rest <<< "$row"
  upload "$WORK/${name}.mp3" "ambient-sounds/${name}.mp3" &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid"; done

# ---- Build + execute SQL upsert ---------------------------------------------
# Idempotent: deterministic id `seeded-{name}` so re-runs UPDATE in place.
public_url() {
  echo "$SUPABASE_URL/storage/v1/object/public/$SUPABASE_BUCKET/ambient-sounds/$1.mp3"
}

values=""
for row in "${TRACKS[@]}" "${MULTI_TRACKS[@]}"; do
  IFS='|' read -r name cat title desc img _rest <<< "$row"
  # Escape single quotes for SQL literals (Postgres: '' inside a string).
  title_sql="${title//\'/\'\'}"
  desc_sql="${desc//\'/\'\'}"
  url=$(public_url "$name")
  [[ -n "$values" ]] && values+=$',\n'
  values+="('seeded-${name}', '${title_sql}', '${desc_sql}', '${cat}', '${url}', '${img}', 30, true, NOW(), NOW())"
done

SQL=$(cat <<EOF
INSERT INTO ambient_sounds (id, title, description, category, "soundUrl", "imageUrl", duration, "isActive", "createdAt", "updatedAt")
VALUES
${values}
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
echo "  curl -s -X POST '$SUPABASE_URL/storage/v1/object/list/$SUPABASE_BUCKET' \\"
echo "    -H 'apikey: \$SUPABASE_SECRET_KEY' \\"
echo "    -H 'Content-Type: application/json' -d '{\"prefix\":\"ambient-sounds\"}'"
echo ""
echo "  curl -s http://localhost:6823/v1/ambient-sounds | python3 -m json.tool | head -40"
