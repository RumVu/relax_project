import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../shared/widgets/layout/app_scroll.dart';
import '../../shared/widgets/layout/header_bar.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_panel.dart';

/// Challenger tab — đang phát triển.
/// Nội dung cũ (Stats / streak / hoạt động yêu thích) đã được dời sang
/// Setup → "Thống kê tình trạng" (tap để mở sheet thật).
class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBar(
            icon: Icons.emoji_events_outlined,
            title: 'Challenger',
            subtitle: 'Thử thách nhỏ mỗi ngày để chăm sóc bản thân.',
            bellHasBadge: false,
          ),
          const SizedBox(height: 28),
          PixelPanel(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const PixelCatScene(scene: CatScene.sleep, height: 160),
                const SizedBox(height: 16),
                Text(
                  'Sắp ra mắt ✦',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tính năng Challenger đang được hoàn thiện.\nHẹn bạn vài bản cập nhật nữa nha 💜',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: RelaxTheme.purple.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bar_chart_rounded,
                        size: 16,
                        color: RelaxTheme.lavender,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Xem thống kê ở Setup',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: RelaxTheme.lavender,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
