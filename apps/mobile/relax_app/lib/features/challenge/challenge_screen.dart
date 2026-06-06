import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../shared/widgets/layout/app_scroll.dart';
import '../../shared/widgets/layout/header_bar.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_button.dart';
import '../../shared/widgets/pixel/pixel_panel.dart';

/// Challenger tab — placeholder nhưng vẫn dẫn dắt user.
///
/// Thay vì "Sắp ra mắt" chết tab → giờ là 3 mini-challenges có thể bấm ngay
/// để user "thử thách bản thân" trong khi Challenger thật đang phát triển:
///   - "Hít thở 3 vòng" → Home tab → Hít thở
///   - "Ghi 1 dòng nhật ký" → Home tab → Journal
///   - "Check-in cảm xúc" → Home tab → tap mood
class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key, this.onJumpToHome});

  /// Khi user bấm 1 mini-challenge → shell switch về tab Home để user thực
  /// hiện ngay (mỗi mini đã có entry point ở Home).
  final VoidCallback? onJumpToHome;

  @override
  Widget build(BuildContext context) {
    return AppScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBar(
            icon: Icons.emoji_events_outlined,
            title: 'Challenger',
            subtitle: 'Mỗi ngày một nhịp nhỏ — bạn xứng đáng dịu dàng ~',
            bellHasBadge: false,
          ),
          const SizedBox(height: 14),
          PixelPanel(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              children: [
                const PixelCatScene(scene: CatScene.sleep, height: 130),
                const SizedBox(height: 10),
                Text(
                  'Thử thách hôm nay ✦',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chọn 1 nhịp nhỏ phía dưới — chỉ 2-5 phút thôi nhưng đủ '
                  'để bạn thấy nhẹ hơn một chút 💜',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _MiniChallengeCard(
            index: 1,
            emoji: '🌬️',
            title: 'Hít thở 3 nhịp',
            subtitle: '2 phút · giúp dịu thần kinh giao cảm',
            onTap: onJumpToHome,
          ),
          const SizedBox(height: 10),
          _MiniChallengeCard(
            index: 2,
            emoji: '✍️',
            title: 'Ghi 1 dòng nhật ký',
            subtitle: '5 phút · gọi tên cảm xúc đang ở đâu',
            onTap: onJumpToHome,
          ),
          const SizedBox(height: 10),
          _MiniChallengeCard(
            index: 3,
            emoji: '💜',
            title: 'Check-in cảm xúc',
            subtitle: '30 giây · 1 tap trên Home — vẫn đáng giá',
            onTap: onJumpToHome,
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Bộ Challenger đầy đủ với streaks + reward đang được hoàn thiện ✦',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: context.relax.muted,
              ),
            ),
          ),
          const SizedBox(height: 16),
          PixelButton(
            icon: Icons.bar_chart_rounded,
            label: 'Xem thống kê & lịch sử',
            onPressed: onJumpToHome,
          ),
        ],
      ),
    );
  }
}

class _MiniChallengeCard extends StatelessWidget {
  const _MiniChallengeCard({
    required this.index,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final int index;
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: RelaxTheme.purple.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THỬ THÁCH ${index.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: RelaxTheme.lavender,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: RelaxTheme.lavender,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
