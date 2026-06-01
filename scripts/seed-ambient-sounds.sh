#!/usr/bin/env bash
# =============================================================================
# Seed product-ready ambient sounds into Supabase Storage + Postgres.
#
# The catalog below uses direct Mixkit music files under the Mixkit Free License:
#   https://mixkit.co/license/
#
# Why this script uploads to Supabase instead of saving random YouTube links:
# - Browser audio players need stable MP3 assets, not YouTube watch pages.
# - Pulling audio from random YouTube videos is a copyright/TOS risk.
# - Supabase Storage gives the admin UI and DB one matching source of truth.
#
# Usage:
#   bash scripts/seed-ambient-sounds.sh
#
# Requires:
#   - docker Postgres container `digital-cigarette-postgres`
#   - apps/backend/.env with SUPABASE_URL + SUPABASE_SECRET_KEY for upload
# =============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [ -f apps/backend/.env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./apps/backend/.env
  set +a
fi

: "${SUPABASE_BUCKET:=public-assets}"

SOUNDS=(
  "serene-view|LOFI|Serene View|Chillout nhẹ, sạch tai cho lúc cần hạ nhịp.|https://images.unsplash.com/photo-1453738773917-9c3eff1db985?w=600|https://assets.mixkit.co/music/443/443.mp3|114"
  "sweet-september|LOFI|Sweet September|Beat chill/hip-hop dịu, hợp dashboard thư giãn.|https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?w=600|https://assets.mixkit.co/music/282/282.mp3|99"
  "sleepy-cat|LOFI|Sleepy Cat|Nhạc chill mềm, hợp màn nghỉ ngắn buổi tối.|https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=600|https://assets.mixkit.co/music/135/135.mp3|119"
  "thinking-about-you|LOFI|Thinking About You|Nhạc nền chillout ấm, hợp viết nhật ký và thư giãn.|https://images.unsplash.com/photo-1495995083802-c39e3a35a45e?w=600|https://assets.mixkit.co/music/234/234.mp3|118"
  "digital-clouds|LOFI|Digital Clouds|Lofi điện tử nhẹ, không quá sáng, không quá buồn.|https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=600|https://assets.mixkit.co/music/175/175.mp3|101"
  "day-dreamin-with-u|LOFI|Day Dreamin' with U|Chill R&B/lofi mềm, nghe dễ vào mood.|https://images.unsplash.com/photo-1495567720989-cebdbdd97913?w=600|https://assets.mixkit.co/music/988/988.mp3|118"
  "curiosity|CHILL|Curiosity|Chillout sáng, đủ nhẹ để làm nền không gây mệt.|https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600|https://assets.mixkit.co/music/480/480.mp3|100"
  "smooth-jazz|CHILL|Smooth Jazz|Downtempo jazz nhẹ, lịch sự hơn bộ synth cũ.|https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600|https://assets.mixkit.co/music/640/640.mp3|142"
  "serene-moments|CHILL|Serene Moments|Chillout yên hơn, hợp nghỉ mắt và đọc vài dòng.|https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=600|https://assets.mixkit.co/music/27/27.mp3|119"
  "relaxation-04|CHILL|Relaxation 04|Chill nhẹ, vừa đủ nhịp để thư giãn mà không buồn ngủ.|https://images.unsplash.com/photo-1519681393784-d120267933ba?w=600|https://assets.mixkit.co/music/750/750.mp3|130"
  "valley-sunset|MEDITATION|Valley Sunset|Ambient thiền nhẹ, hợp thả lỏng cuối ngày.|https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=600|https://assets.mixkit.co/music/127/127.mp3|134"
  "relax-beat|MEDITATION|Relax Beat|Beat chậm kiểu thiền hiện đại, sạch và dễ nghe.|https://images.unsplash.com/photo-1545389336-cf090694435e?w=600|https://assets.mixkit.co/music/292/292.mp3|108"
  "spirit-in-the-woods|MEDITATION|Spirit in the Woods|Ambient rừng sâu, hợp thở chậm và ngắt stress.|https://images.unsplash.com/photo-1448375240586-882707db888b?w=600|https://assets.mixkit.co/music/139/139.mp3|113"
  "forest-treasure|MEDITATION|Forest Treasure|Ambient mềm, có cảm giác tĩnh và rộng.|https://images.unsplash.com/photo-1473773508845-188df298d2d1?w=600|https://assets.mixkit.co/music/138/138.mp3|104"
  "meditation|MEDITATION|Meditation|Track thiền êm, hợp popup thư giãn sau khi finish.|https://images.unsplash.com/photo-1593811167562-9cef47bfc4d7?w=600|https://assets.mixkit.co/music/441/441.mp3|118"
  "smooth-meditation|BUDDHA_CHILL|Smooth Meditation|Thiền êm và sâu hơn, không bị tiếng hiệu ứng lạc mood.|https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=600|https://assets.mixkit.co/music/324/324.mp3|154"
  "yoga-song|BUDDHA_CHILL|Yoga Song|Chill thiền/yoga gọn, hợp session ngắn.|https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=600|https://assets.mixkit.co/music/444/444.mp3|98"
  "nature-yoga|BUDDHA_CHILL|Nature Yoga|Yoga/meditation sáng, nghe nhẹ mà không bị sến.|https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=600|https://assets.mixkit.co/music/442/442.mp3|108"
  "deep-meditation|BUDDHA_CHILL|Deep Meditation|Ambient sâu, hợp lúc cần giảm nhịp thật sự.|https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=600|https://assets.mixkit.co/music/109/109.mp3|147"
  "nap-time|BUDDHA_CHILL|Nap Time|Track nghỉ ngắn, chill thiền nhẹ trước khi quay lại việc.|https://images.unsplash.com/photo-1495195134817-aeb325a55b65?w=600|https://assets.mixkit.co/music/340/340.mp3|103"
)

quote_sql() {
  local value="$1"
  value="$(printf '%s' "$value" | sed "s/'/''/g")"
  printf "'%s'" "$value"
}

supabase_public_url() {
  local key="$1"
  printf '%s/storage/v1/object/public/%s/ambient-sounds/%s.mp3' \
    "$SUPABASE_URL" "$SUPABASE_BUCKET" "$key"
}

upload_sound() {
  local key="$1"
  local source_url="$2"
  local file="$WORK/${key}.mp3"
  local remote_path="ambient-sounds/${key}.mp3"
  local status

  curl --fail --location --silent --show-error "$source_url" --output "$file"
  status=$(curl --silent --show-error --output /dev/null --write-out "%{http_code}" \
    --request POST "$SUPABASE_URL/storage/v1/object/$SUPABASE_BUCKET/$remote_path" \
    --header "apikey: $SUPABASE_SECRET_KEY" \
    --header "Content-Type: audio/mpeg" \
    --header "x-upsert: true" \
    --data-binary "@$file")

  if [[ ! "$status" =~ ^20 ]]; then
    echo "✗ Upload failed for $remote_path (HTTP $status)" >&2
    exit 1
  fi
}

WORK="$(mktemp -d -t curated-ambient-sounds.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

if [[ -n "${SUPABASE_URL:-}" && -n "${SUPABASE_SECRET_KEY:-}" ]]; then
  echo "→ Uploading ${#SOUNDS[@]} curated MP3 files to Supabase Storage bucket=$SUPABASE_BUCKET"
  for row in "${SOUNDS[@]}"; do
    IFS='|' read -r key _category _title _description _image_url source_url _duration <<< "$row"
    upload_sound "$key" "$source_url"
  done
  echo "  ✓ Supabase files are synced"
else
  echo "→ SUPABASE_URL/SUPABASE_SECRET_KEY not set; DB will use Mixkit source URLs directly"
fi

values=""
for row in "${SOUNDS[@]}"; do
  IFS='|' read -r key category title description image_url source_url duration <<< "$row"
  sound_url="$source_url"
  if [[ -n "${SUPABASE_URL:-}" && -n "${SUPABASE_SECRET_KEY:-}" ]]; then
    sound_url="$(supabase_public_url "$key")"
  fi

  [[ -n "$values" ]] && values+=$',\n'
  values+="('curated-${key}', $(quote_sql "$title"), $(quote_sql "$description"), $(quote_sql "$category"), $(quote_sql "$sound_url"), $(quote_sql "$image_url"), ${duration}, true, NOW(), NOW())"
done

SQL=$(cat <<EOF
DELETE FROM sound_sessions WHERE "soundId" IN (SELECT id FROM ambient_sounds);
DELETE FROM ambient_sounds;
DELETE FROM search_indices WHERE "entityType" = 'AMBIENT_SOUND';

INSERT INTO ambient_sounds (id, title, description, category, "soundUrl", "imageUrl", duration, "isActive", "createdAt", "updatedAt")
VALUES
${values};

INSERT INTO search_indices (id, "entityType", "entityId", title, content, tags, "createdAt", "updatedAt")
SELECT
  'search-' || id,
  'AMBIENT_SOUND',
  id,
  title,
  concat_ws(' ', title, description, category, "soundUrl", duration || 's', 'active'),
  ARRAY['sound', 'ambient', lower(category), 'active'],
  NOW(),
  NOW()
FROM ambient_sounds;
EOF
)

echo "→ Replacing ambient_sounds with ${#SOUNDS[@]} chill/lofi/meditation tracks"
docker exec -i digital-cigarette-postgres \
  psql -U postgres -d digital_cigarette_break -v ON_ERROR_STOP=1 -c "$SQL"

echo "✓ Done — Supabase Storage and the ambient sound catalog now match."
