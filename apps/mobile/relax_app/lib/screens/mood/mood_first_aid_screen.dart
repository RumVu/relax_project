import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale_controller.dart';
import '../../core/theme.dart';

class MoodFirstAidScreen extends StatelessWidget {
  const MoodFirstAidScreen({super.key});

  static const _firstAidOptions = [
    (
      'OVERWHELMED',
      'Tôi đang quá tải',
      '😫',
      'Hít thở cân bằng 4-4 để định hình lại suy nghĩ.',
      '/breathing',
      RelaxColors.plum
    ),
    (
      'CANT_FOCUS',
      'Tôi mất tập trung',
      '🧠',
      'Mở soundscape tiếng ồn nâu giúp gom tụ tinh thần.',
      '/soundscape?preset=Tập trung',
      RelaxColors.violet
    ),
    (
      'ANGRY',
      'Tôi đang tức giận',
      '🔥',
      'Thở thở xả hơi để hạ nhiệt cảm xúc tức thì.',
      '/breathing',
      Color(0xFFEF4444)
    ),
    (
      'EMPTY',
      'Tôi thấy trống rỗng',
      '🌪️',
      'Xem gợi ý chữa lành và những câu nói ấm áp.',
      '/recommendations',
      Color(0xFF3B82F6)
    ),
    (
      'ABOUT_TO_CRY',
      'Tôi chuẩn bị khóc',
      '😢',
      'Lắng nghe những giai điệu lofi dịu êm chở che.',
      '/soundscape?preset=Thư giãn',
      Color(0xFF8B5CF6)
    ),
    (
      'NEED_CALM',
      'Tôi cần dịu lại ngay',
      '🍃',
      'Hít thở grounding 5 giác quan hạ nhiệt khẩn cấp.',
      '/calm-now',
      Color(0xFF10B981)
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDark ? const Color(0xFF0d1117) : RelaxColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Sơ cứu cảm xúc 🩹'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            Text(
              context.t('Emotional First Aid'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: context.appText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.t('Khi bạn cảm thấy mất kiểm soát, hãy chọn một hành động nhanh 1-3 phút dưới đây để dịu tâm trí.'),
              style: TextStyle(color: context.mutedText, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ..._firstAidOptions.map((opt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(opt.$5);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.fieldBorder),
                      boxShadow: [
                        BoxShadow(
                          color: opt.$6.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: opt.$6.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(opt.$3, style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.t(opt.$2),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: context.appText,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                context.t(opt.$4),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: context.appText.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
