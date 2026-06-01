#!/usr/bin/env bash
# =============================================================================
# Seed curated ambient sounds into Postgres.
#
# The old version generated procedural ffmpeg "music" clips. Those were useful
# for demos, but too synthetic for product. This manifest uses direct Mixkit
# audio URLs under the Mixkit Free License:
#   https://mixkit.co/license/
#
# Important: do not put ordinary YouTube watch URLs in `soundUrl`.
# - Browser <audio> cannot stream them as stable MP3 assets.
# - Pulling audio from random YouTube videos is a copyright/TOS trap.
# If a track from YouTube Audio Library is chosen later, download the licensed
# file and upload it through the admin UI / storage flow first.
#
# Usage:
#   bash scripts/seed-ambient-sounds.sh
#
# Requires Docker Postgres container `digital-cigarette-postgres`.
# =============================================================================

set -euo pipefail

SOUNDS=(
  "serene-view|LOFI|Serene View|Chillout nhẹ, sạch tai cho lúc cần hạ nhịp.|https://images.unsplash.com/photo-1453738773917-9c3eff1db985?w=600|https://assets.mixkit.co/music/443/443.mp3|114"
  "sleepy-cat|LOFI|Sleepy Cat|Nhạc chill mềm, hợp màn nghỉ ngắn buổi tối.|https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=600|https://assets.mixkit.co/music/135/135.mp3|119"
  "curiosity|LOFI|Curiosity|Chillout sáng, đủ nhẹ để làm nền không gây mệt.|https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600|https://assets.mixkit.co/music/480/480.mp3|100"
  "thinking-about-you|LOFI|Thinking About You|Nhạc nền chillout ấm, hợp viết nhật ký và thư giãn.|https://images.unsplash.com/photo-1495995083802-c39e3a35a45e?w=600|https://assets.mixkit.co/music/234/234.mp3|118"
  "sweet-september|LOFI|Sweet September|Beat hip-hop/chill dịu, không gắt và không nhựa.|https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?w=600|https://assets.mixkit.co/music/282/282.mp3|99"
  "smooth-jazz|LOFI|Smooth Jazz|Downtempo jazz nhẹ, lịch sự hơn bộ synth cũ.|https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600|https://assets.mixkit.co/music/640/640.mp3|142"
  "light-rain-loop|RAIN|Light Rain Loop|Mưa nhẹ đều, ít chi tiết thừa để dễ loop.|https://images.unsplash.com/photo-1519692933481-e162a57d6721?w=600|https://assets.mixkit.co/active_storage/sfx/2393/2393-preview.mp3|30"
  "rain-long-loop|RAIN|Rain Long Loop|Mưa dài, nền ổn cho tập trung hoặc ngủ ngắn.|https://images.unsplash.com/photo-1438449805896-28a666819a20?w=600|https://assets.mixkit.co/active_storage/sfx/2394/2394-preview.mp3|30"
  "light-rain-atmosphere|RAIN|Light Rain Atmosphere|Mưa mỏng và thoáng, không quá ồn.|https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?w=600|https://assets.mixkit.co/active_storage/sfx/2474/2474-preview.mp3|30"
  "sea-waves-with-birds|NATURE|Sea Waves With Birds|Sóng biển và chim xa, hợp bài thở chậm.|https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=600|https://assets.mixkit.co/active_storage/sfx/1185/1185-preview.mp3|30"
  "water-flowing-ambience|NATURE|Water Flowing Ambience|Suối nước sạch, nghe tự nhiên hơn tiếng synth.|https://images.unsplash.com/photo-1474440692490-2e83ae13ba29?w=600|https://assets.mixkit.co/active_storage/sfx/3126/3126-preview.mp3|30"
  "river-forest-birds|NATURE|River In The Forest With Birds|Nước chảy và chim rừng, nhẹ nhàng để nghỉ mắt.|https://images.unsplash.com/photo-1448375240586-882707db888b?w=600|https://assets.mixkit.co/active_storage/sfx/1216/1216-preview.mp3|30"
  "morning-birds|NATURE|Morning Birds|Chim sáng vừa đủ, không chói tai.|https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?w=600|https://assets.mixkit.co/active_storage/sfx/2472/2472-preview.mp3|30"
  "wind-blowing-ambience|AMBIENT|Wind Blowing Ambience|Gió nền rộng, hợp thiền và kéo giãn.|https://images.unsplash.com/photo-1505672678657-cc7037095e60?w=600|https://assets.mixkit.co/active_storage/sfx/2658/2658-preview.mp3|30"
  "campfire-night-wind|AMBIENT|Campfire Night Wind|Lửa trại và gió đêm, ấm nhưng không quá kịch.|https://images.unsplash.com/photo-1475139441338-693e7dbe20b6?w=600|https://assets.mixkit.co/active_storage/sfx/1736/1736-preview.mp3|30"
  "campfire-crackles|AMBIENT|Campfire Crackles|Tiếng củi nổ nhỏ, hợp màn nghỉ cuối ngày.|https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=600|https://assets.mixkit.co/active_storage/sfx/1330/1330-preview.mp3|30"
  "night-forest-insects|SLEEP|Night Forest With Insects|Không khí rừng đêm dịu, phù hợp thư giãn trước ngủ.|https://images.unsplash.com/photo-1532978879514-6cfa608be43c?w=600|https://assets.mixkit.co/active_storage/sfx/2414/2414-preview.mp3|30"
  "summer-night-crickets|SLEEP|Summer Night Crickets|Dế đêm đều, ít biến động để dễ chìm vào giấc.|https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=600|https://assets.mixkit.co/active_storage/sfx/1789/1789-preview.mp3|30"
  "office-ambience|FOCUS|Office Ambience|Âm nền văn phòng nhẹ cho chế độ tập trung.|https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=600|https://assets.mixkit.co/active_storage/sfx/447/447-preview.mp3|30"
  "slow-typing-keyboard|FOCUS|Slow Typing On A Keyboard|Tiếng gõ phím chậm, dùng khi cần nền làm việc.|https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600|https://assets.mixkit.co/active_storage/sfx/2532/2532-preview.mp3|30"
)

quote_sql() {
  local value="$1"
  value="${value//\'/\'\'}"
  printf "'%s'" "$value"
}

values=""
for row in "${SOUNDS[@]}"; do
  IFS='|' read -r key category title description image_url sound_url duration <<< "$row"
  [[ -n "$values" ]] && values+=$',\n'
  values+="('curated-${key}', $(quote_sql "$title"), $(quote_sql "$description"), $(quote_sql "$category"), $(quote_sql "$sound_url"), $(quote_sql "$image_url"), ${duration}, true, NOW(), NOW())"
done

SQL=$(cat <<EOF
DELETE FROM sound_sessions WHERE "soundId" IN (SELECT id FROM ambient_sounds);
DELETE FROM ambient_sounds;

INSERT INTO ambient_sounds (id, title, description, category, "soundUrl", "imageUrl", duration, "isActive", "createdAt", "updatedAt")
VALUES
${values};
EOF
)

echo "→ Replacing ambient_sounds with ${#SOUNDS[@]} curated Mixkit tracks"
docker exec -i digital-cigarette-postgres \
  psql -U postgres -d digital_cigarette_break -v ON_ERROR_STOP=1 -c "$SQL"

echo "✓ Done — curated ambient sound catalog is ready."
