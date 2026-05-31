#!/usr/bin/env bash
# =============================================================================
# Seed ambient sounds vào Supabase Storage + Postgres.
#
# 50 tracks procedural (ffmpeg) — mỗi track ~30s MP3 96 kbps (~350 KB),
# loop ở client. Categories:
#   RAIN (8) NATURE (8) ANIMAL (6) URBAN (6) MUSIC (6) FOCUS (6)
#   MEDITATION (4) SLEEP (4) CRACKLE (2)
#
# Khi a có asset thật → upload qua admin UI thay file ở Supabase, URL
# vẫn giữ nên FE không cần đổi.
#
# Usage:
#   SUPABASE_URL=... SUPABASE_SECRET_KEY=... bash scripts/seed-ambient-sounds.sh
# Yêu cầu:
#   - ffmpeg (brew install ffmpeg)
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
  if [ -f apps/backend/.env ]; then
    set -a; . ./apps/backend/.env; set +a
  fi
fi
if [[ -z "$SUPABASE_URL" || -z "$SUPABASE_SECRET_KEY" ]]; then
  echo "✗ Cần SUPABASE_URL + SUPABASE_SECRET_KEY (env hoặc apps/backend/.env)" >&2
  exit 1
fi

echo "→ Supabase: $SUPABASE_URL bucket=$SUPABASE_BUCKET"

# ---- 50-track manifest --------------------------------------------------------
# Format per row: name|category|title|description|imageUrl|src|post
#   - src:  lavfi expression ('anoisesrc=...' OR 'sine=...')
#   - post: -af filter chain (use 'anull' if no filter)
# meditation/piano use MULTI_TRACKS (multi-input filter_complex).
TRACKS=(
  # RAIN (8)
  "rain-soft|RAIN|Mưa rơi nhẹ|Âm mưa rơi đều, dịu nhẹ.|https://images.unsplash.com/photo-1519692933481-e162a57d6721?w=600|anoisesrc=color=brown:duration=30:amplitude=0.6|lowpass=f=800,volume=1.4"
  "rain-storm|RAIN|Mưa giông xa|Mưa lớn xa xa, hợp lúc nghỉ trưa.|https://images.unsplash.com/photo-1428592953211-077101b2021b?w=600|anoisesrc=color=brown:duration=30:amplitude=0.75|lowpass=f=500,volume=1.5"
  "rain-window|RAIN|Mưa rơi trên cửa sổ|Tiếng mưa nhỏ tí tách lên kính.|https://images.unsplash.com/photo-1438449805896-28a666819a20?w=600|anoisesrc=color=pink:duration=30:amplitude=0.5|highpass=f=1500,lowpass=f=4000,volume=1.3"
  "rain-roof|RAIN|Mưa mái tôn|Tiếng mưa đập mái tôn nhịp đều.|https://images.unsplash.com/photo-1493314894560-5c412a56c17c?w=600|anoisesrc=color=brown:duration=30:amplitude=0.55|highpass=f=300,lowpass=f=2500,vibrato=f=8:d=0.2"
  "rain-bus|RAIN|Trong xe khi mưa|Cảm giác đang ngồi xe buýt mưa đêm.|https://images.unsplash.com/photo-1572025442646-866d16c84a54?w=600|anoisesrc=color=brown:duration=30:amplitude=0.5|lowpass=f=600,chorus=0.6:0.9:50:0.4:0.25:2"
  "rain-light|RAIN|Mưa rất nhẹ|Vài hạt mưa rơi rải rác.|https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?w=600|anoisesrc=color=pink:duration=30:amplitude=0.35|highpass=f=2000,lowpass=f=5000"
  "rain-thunder|RAIN|Mưa kèm sấm xa|Sấm xa xa cùng tiếng mưa đều.|https://images.unsplash.com/photo-1605727216801-e27ce1d0cc28?w=600|anoisesrc=color=brown:duration=30:amplitude=0.7|lowpass=f=400,tremolo=f=0.1:d=0.5,volume=1.5"
  "rain-drizzle|RAIN|Mưa lất phất|Mưa lất phất ngày mây mù.|https://images.unsplash.com/photo-1556485689-33e55ab56127?w=600|anoisesrc=color=pink:duration=30:amplitude=0.45|highpass=f=800,lowpass=f=3500,vibrato=f=3:d=0.15"

  # NATURE (8)
  "ocean-waves|NATURE|Sóng biển dịu êm|Tiếng sóng vỗ chậm rãi vào bờ.|https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=600|anoisesrc=color=pink:duration=30:amplitude=0.6|tremolo=f=0.15:d=0.8,lowpass=f=1500"
  "ocean-deep|NATURE|Sóng biển đêm|Sóng sâu trầm dưới đêm trăng.|https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=600|anoisesrc=color=brown:duration=30:amplitude=0.7|tremolo=f=0.1:d=0.7,lowpass=f=900"
  "forest-morning|NATURE|Rừng cây ban mai|Gió và chim hót lúc khởi đầu ngày.|https://images.unsplash.com/photo-1448375240586-882707db888b?w=600|anoisesrc=color=white:duration=30:amplitude=0.45|highpass=f=800,lowpass=f=4000,chorus=0.5:0.9:50:0.4:0.25:2"
  "stream-creek|NATURE|Suối nhỏ chảy|Tiếng suối nhỏ róc rách qua đá.|https://images.unsplash.com/photo-1474440692490-2e83ae13ba29?w=600|anoisesrc=color=white:duration=30:amplitude=0.5|highpass=f=600,lowpass=f=3000,vibrato=f=6:d=0.2"
  "waterfall|NATURE|Thác nước xa|Tiếng thác trầm vọng lại.|https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?w=600|anoisesrc=color=white:duration=30:amplitude=0.6|lowpass=f=2000,volume=1.3"
  "wind-soft|NATURE|Gió nhẹ qua đồi|Gió nhẹ thổi qua đồng cỏ.|https://images.unsplash.com/photo-1505672678657-cc7037095e60?w=600|anoisesrc=color=pink:duration=30:amplitude=0.4|lowpass=f=1000,tremolo=f=0.2:d=0.4"
  "birds-dawn|NATURE|Chim hót bình minh|Tiếng chim líu lo lúc rạng đông.|https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?w=600|anoisesrc=color=white:duration=30:amplitude=0.3|highpass=f=2500,lowpass=f=8000,vibrato=f=12:d=0.3,volume=0.7"
  "bamboo-rain|NATURE|Giọt nước trong vườn tre|Nước nhỏ giọt trong vườn tre.|https://images.unsplash.com/photo-1496857598081-d4b88b88ce6f?w=600|anoisesrc=color=pink:duration=30:amplitude=0.35|highpass=f=3000,vibrato=f=2:d=0.5,volume=0.8"

  # ANIMAL (6)
  "cat-purr|ANIMAL|Mèo rừ rừ|Tiếng mèo rừ rừ ấm áp, dỗ ngủ.|https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=600|anoisesrc=color=brown:duration=30:amplitude=0.6|lowpass=f=300,tremolo=f=18:d=0.5,volume=1.2"
  "cat-sleep|ANIMAL|Mèo ngủ thở đều|Tiếng mèo thở khi ngủ.|https://images.unsplash.com/photo-1573865526739-10659fec78a5?w=600|anoisesrc=color=brown:duration=30:amplitude=0.4|lowpass=f=400,tremolo=f=0.5:d=0.6"
  "dog-breathing|ANIMAL|Chó nằm thở|Chó nằm cạnh, thở đều êm.|https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=600|anoisesrc=color=brown:duration=30:amplitude=0.5|lowpass=f=500,tremolo=f=0.3:d=0.5"
  "puppy-soft|ANIMAL|Cún con ngủ|Cún con thở nhẹ trong ổ.|https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=600|anoisesrc=color=pink:duration=30:amplitude=0.35|lowpass=f=600,tremolo=f=0.4:d=0.4"
  "horse-pasture|ANIMAL|Đồng cỏ ngựa|Tiếng ngựa khe khẽ trên đồng.|https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?w=600|anoisesrc=color=brown:duration=30:amplitude=0.55|lowpass=f=700,vibrato=f=1.5:d=0.3"
  "frog-pond|ANIMAL|Ao ếch ban đêm|Tiếng ếch nhái trong ao đêm hè.|https://images.unsplash.com/photo-1572947650440-e8a97ef053b2?w=600|anoisesrc=color=pink:duration=30:amplitude=0.4|highpass=f=400,lowpass=f=2000,tremolo=f=4:d=0.6"

  # URBAN / CAFE (6)
  "cafe-warm|URBAN|Quán cà phê sáng|Tiếng máy pha cà phê và rì rầm.|https://images.unsplash.com/photo-1453614512568-c4024d13c247?w=600|anoisesrc=color=pink:duration=30:amplitude=0.5|lowpass=f=2500,chorus=0.5:0.9:50:0.4:0.25:2"
  "cafe-midnight|URBAN|Cà phê đêm khuya|Tiếng rì rầm yên tĩnh quán đêm.|https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=600|anoisesrc=color=brown:duration=30:amplitude=0.45|lowpass=f=1500,tremolo=f=0.3:d=0.3"
  "fireplace|URBAN|Lò sưởi củi nổ|Tiếng củi nổ lép bép, ấm áp.|https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=600|anoisesrc=color=white:duration=30:amplitude=0.5|highpass=f=1000,lowpass=f=5000,vibrato=f=15:d=0.3"
  "fan-room|URBAN|Quạt máy ngày hè|Tiếng quạt trần đều đều buổi trưa.|https://images.unsplash.com/photo-1626982126125-9b8d68330229?w=600|anoisesrc=color=white:duration=30:amplitude=0.45|lowpass=f=2000,vibrato=f=10:d=0.1"
  "library|URBAN|Thư viện yên ắng|Tiếng trang giấy lật, không gian học.|https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=600|anoisesrc=color=pink:duration=30:amplitude=0.3|highpass=f=2000,lowpass=f=4500"
  "train-ride|URBAN|Trên chuyến tàu|Tiếng tàu chạy đều trên đường ray.|https://images.unsplash.com/photo-1474487548417-781cb71495f3?w=600|anoisesrc=color=brown:duration=30:amplitude=0.55|lowpass=f=1200,tremolo=f=2:d=0.2"

  # MUSIC / LOFI (6)
  "lofi-chill|LOFI|Lo-fi thư thái|Nhạc nền nhẹ phong cách lo-fi.|https://images.unsplash.com/photo-1453738773917-9c3eff1db985?w=600|anoisesrc=color=pink:duration=30:amplitude=0.4|vibrato=f=4:d=0.3,lowpass=f=3000"
  "lofi-cat|LOFI|Lo-fi cùng mèo|Beat lo-fi mềm cho lúc làm việc cùng mèo.|https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=600|anoisesrc=color=pink:duration=30:amplitude=0.45|vibrato=f=3:d=0.25,lowpass=f=2800,tremolo=f=1.2:d=0.3"
  "lofi-rainy|LOFI|Lo-fi đêm mưa|Lo-fi cùng tiếng mưa đêm khuya.|https://images.unsplash.com/photo-1483347756197-71ef80e95f73?w=600|anoisesrc=color=pink:duration=30:amplitude=0.5|vibrato=f=2:d=0.3,lowpass=f=2500,volume=1.1"
  "lofi-study|LOFI|Lo-fi học bài|Beat đều đặn để tập trung học.|https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600|anoisesrc=color=pink:duration=30:amplitude=0.4|vibrato=f=5:d=0.2,lowpass=f=3000"
  "lofi-sunset|LOFI|Lo-fi hoàng hôn|Lo-fi nhẹ lúc trời tắt nắng.|https://images.unsplash.com/photo-1495995083802-c39e3a35a45e?w=600|anoisesrc=color=pink:duration=30:amplitude=0.45|vibrato=f=3.5:d=0.25,lowpass=f=2700"
  "lofi-jazz|LOFI|Lo-fi pha jazz|Lo-fi pha chút jazz cuối tuần.|https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?w=600|anoisesrc=color=pink:duration=30:amplitude=0.4|vibrato=f=6:d=0.2,lowpass=f=3200,chorus=0.5:0.9:50:0.4:0.25:2"

  # FOCUS / DEEP NOISE (6)
  "white-noise|FOCUS|Tiếng ồn trắng|Ồn trắng đều, chặn tạp âm xung quanh.|https://images.unsplash.com/photo-1532634922-8fe0b757fb13?w=600|anoisesrc=color=white:duration=30:amplitude=0.5|anull"
  "brown-noise|FOCUS|Tiếng ồn nâu|Ồn nâu trầm ấm, dễ ngủ hơn ồn trắng.|https://images.unsplash.com/photo-1499728603263-13726abce5fd?w=600|anoisesrc=color=brown:duration=30:amplitude=0.7|anull"
  "pink-noise|FOCUS|Tiếng ồn hồng|Ồn hồng cân bằng, dễ chịu cho tai.|https://images.unsplash.com/photo-1487611459768-bd414656ea10?w=600|anoisesrc=color=pink:duration=30:amplitude=0.55|anull"
  "deep-hum|FOCUS|Hum nền sâu|Drone trầm để gom sự chú ý.|https://images.unsplash.com/photo-1505236858219-8359eb29e329?w=600|sine=frequency=120:duration=30|volume=0.4,tremolo=f=0.3:d=0.2"
  "keyboard-rain|FOCUS|Bàn phím và mưa|Tiếng phím gõ nhẹ trong mưa.|https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600|anoisesrc=color=pink:duration=30:amplitude=0.4|highpass=f=1500,lowpass=f=4500,vibrato=f=8:d=0.15"
  "cosmic-drift|FOCUS|Trôi vũ trụ|Âm không gian, để chìm vào suy nghĩ.|https://images.unsplash.com/photo-1462331940025-496dfbfc7564?w=600|anoisesrc=color=pink:duration=30:amplitude=0.35|lowpass=f=1500,chorus=0.6:0.9:50:0.4:0.25:2,tremolo=f=0.2:d=0.4"

  # SLEEP (4)
  "sleep-soft|SLEEP|Giấc ngủ êm|Nền êm dịu nhất cho giấc ngủ.|https://images.unsplash.com/photo-1455657509395-c93b4f0e5ce8?w=600|anoisesrc=color=brown:duration=30:amplitude=0.5|lowpass=f=500,volume=0.9"
  "sleep-rain-soft|SLEEP|Mưa nhỏ ngủ ngon|Mưa rất nhẹ cho lúc khó ngủ.|https://images.unsplash.com/photo-1501426026826-31c667bdf23d?w=600|anoisesrc=color=brown:duration=30:amplitude=0.4|lowpass=f=600,vibrato=f=2:d=0.2"
  "sleep-fan|SLEEP|Quạt đêm|Tiếng quạt giúp dễ vào giấc.|https://images.unsplash.com/photo-1611073761665-da94f0aa6f17?w=600|anoisesrc=color=white:duration=30:amplitude=0.4|lowpass=f=1500,vibrato=f=8:d=0.1"
  "sleep-night-air|SLEEP|Không khí đêm|Không gian yên tĩnh giữa đêm.|https://images.unsplash.com/photo-1532978879514-6cfa608be43c?w=600|anoisesrc=color=pink:duration=30:amplitude=0.3|lowpass=f=800,volume=0.7"

  # CRACKLE (2)
  "vinyl-crackle|CRACKLE|Tiếng đĩa than|Đĩa than xoay vòng, ấm áp.|https://images.unsplash.com/photo-1461360228754-6e81c478b882?w=600|anoisesrc=color=white:duration=30:amplitude=0.3|highpass=f=2000,lowpass=f=6000,vibrato=f=20:d=0.2"
  "campfire|CRACKLE|Lửa trại|Tiếng lửa trại lép bép nhẹ.|https://images.unsplash.com/photo-1475139441338-693e7dbe20b6?w=600|anoisesrc=color=white:duration=30:amplitude=0.45|highpass=f=800,lowpass=f=4500,vibrato=f=12:d=0.4"
)

# meditation + calm-piano use multi-input filter_complex
MULTI_TRACKS=(
  "meditation-432|MEDITATION|Tần số thiền 432Hz|Dải tần ấm áp dùng trong thiền định.|https://images.unsplash.com/photo-1545205597-3d9d02c29597?w=600|MULTI:sine=frequency=432:duration=30;sine=frequency=648:duration=30;[0:a][1:a]amix=inputs=2:duration=longest,volume=0.3,tremolo=f=0.15:d=0.4"
  "meditation-528|MEDITATION|Tần số chữa lành 528Hz|Tần số được cho là giúp thư thái.|https://images.unsplash.com/photo-1591291621164-2c6367723315?w=600|MULTI:sine=frequency=528:duration=30;sine=frequency=792:duration=30;[0:a][1:a]amix=inputs=2:duration=longest,volume=0.3,tremolo=f=0.18:d=0.4"
  "meditation-low|MEDITATION|Drone trầm|Âm trầm cho thiền sâu.|https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=600|MULTI:sine=frequency=80:duration=30;sine=frequency=120:duration=30;[0:a][1:a]amix=inputs=2:duration=longest,volume=0.35,tremolo=f=0.12:d=0.3"
  "meditation-bowl|MEDITATION|Chuông thiền|Âm chuông Tây Tạng kéo dài.|https://images.unsplash.com/photo-1591291621099-fd31fcc7b9f7?w=600|MULTI:sine=frequency=256:duration=30;sine=frequency=384:duration=30;sine=frequency=512:duration=30;[0:a][1:a][2:a]amix=inputs=3:duration=longest,volume=0.3,tremolo=f=0.2:d=0.5"
  "piano-major|PIANO|Hợp âm C trưởng|Hợp âm Đô trưởng dịu nhẹ.|https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=600|MULTI:sine=frequency=261.63:duration=30;sine=frequency=329.63:duration=30;sine=frequency=392.00:duration=30;[0:a][1:a][2:a]amix=inputs=3:duration=longest,volume=0.35,tremolo=f=0.5:d=0.2,lowpass=f=2500"
  "piano-minor|PIANO|Hợp âm A thứ|Hợp âm La thứ man mác.|https://images.unsplash.com/photo-1466150036782-869a824aeb25?w=600|MULTI:sine=frequency=220.00:duration=30;sine=frequency=261.63:duration=30;sine=frequency=329.63:duration=30;[0:a][1:a][2:a]amix=inputs=3:duration=longest,volume=0.35,tremolo=f=0.4:d=0.25,lowpass=f=2300"
  "piano-evening|PIANO|Piano buổi tối|Hợp âm piano cho lúc thư giãn tối.|https://images.unsplash.com/photo-1571115332905-d8c5dcdaa9a4?w=600|MULTI:sine=frequency=196:duration=30;sine=frequency=246.94:duration=30;sine=frequency=293.66:duration=30;[0:a][1:a][2:a]amix=inputs=3:duration=longest,volume=0.32,tremolo=f=0.4:d=0.3,lowpass=f=2400"
)

# ---- Generate sounds with ffmpeg --------------------------------------------
WORK="$(mktemp -d -t ambient-sounds.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

FFMPEG_BASE=(ffmpeg -hide_banner -loglevel error -y)
FFMPEG_ENCODE=(-b:a 96k -ar 44100)

gen_noise() {
  local name="$1" src="$2" post="$3"
  "${FFMPEG_BASE[@]}" -f lavfi -i "$src" -af "$post" "${FFMPEG_ENCODE[@]}" "$WORK/${name}.mp3"
}

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

total=$(( ${#TRACKS[@]} + ${#MULTI_TRACKS[@]} ))
echo "→ Generate $total ambient tracks in parallel"
pids=()
for row in "${TRACKS[@]}"; do
  IFS='|' read -r name _cat _title _desc _img src post <<< "$row"
  gen_noise "$name" "$src" "$post" &
  pids+=($!)
done
for row in "${MULTI_TRACKS[@]}"; do
  IFS='|' read -r name _cat _title _desc _img spec <<< "$row"
  gen_multi "$name" "${spec#MULTI:}" &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid"; done
echo "  ✓ All $total tracks generated"

# ---- Upload to Supabase (parallel) ------------------------------------------
# New `sb_secret_*` keys require `apikey` header (NOT Authorization: Bearer
# which Supabase parses as JWT → "Invalid Compact JWS").
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
  if [[ ! "$status" =~ ^20 ]]; then
    echo "  ✗ $remote_path → HTTP $status" >&2
    return 1
  fi
}

echo "→ Upload to Supabase bucket=$SUPABASE_BUCKET (parallel)"
pids=()
for row in "${TRACKS[@]}" "${MULTI_TRACKS[@]}"; do
  IFS='|' read -r name _rest <<< "$row"
  upload "$WORK/${name}.mp3" "ambient-sounds/${name}.mp3" &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid"; done
echo "  ✓ $total uploads done"

# ---- Build + execute SQL upsert ---------------------------------------------
# Wipe ALL existing ambient_sounds first (clean slate). Re-running this
# script is idempotent — seeded-{name} ids stay stable across runs.
public_url() {
  echo "$SUPABASE_URL/storage/v1/object/public/$SUPABASE_BUCKET/ambient-sounds/$1.mp3"
}

values=""
for row in "${TRACKS[@]}" "${MULTI_TRACKS[@]}"; do
  IFS='|' read -r name cat title desc img _rest <<< "$row"
  title_sql="${title//\'/\'\'}"
  desc_sql="${desc//\'/\'\'}"
  url=$(public_url "$name")
  [[ -n "$values" ]] && values+=$',\n'
  values+="('seeded-${name}', '${title_sql}', '${desc_sql}', '${cat}', '${url}', '${img}', 30, true, NOW(), NOW())"
done

SQL=$(cat <<EOF
-- Clean slate: drop everything, re-seed canonical set.
DELETE FROM sound_sessions WHERE "soundId" IN (SELECT id FROM ambient_sounds);
DELETE FROM ambient_sounds;

INSERT INTO ambient_sounds (id, title, description, category, "soundUrl", "imageUrl", duration, "isActive", "createdAt", "updatedAt")
VALUES
${values};
EOF
)

echo ""
echo "→ Wipe + upsert $total records into ambient_sounds"
docker exec -i digital-cigarette-postgres \
  psql -U postgres -d digital_cigarette_break -v ON_ERROR_STOP=1 -c "$SQL"

echo ""
echo "✓ Done — $total sounds in DB + Supabase."
echo "  curl -s http://localhost:6823/v1/ambient-sounds | python3 -m json.tool | head"
