import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

class MethodsCard extends StatelessWidget {
  const MethodsCard({super.key, required this.name});

  final String name;

  static const _methods = [
    ('Thiền định', 'assets/hinh_phuong_thuc/hinh-thien.png', '/meditation'),
    ('Hít thở', 'assets/hinh_phuong_thuc/hinh-hit-tho.png', '/breathing'),
    ('Nhật ký', 'assets/hinh_phuong_thuc/hinh-viet-nhat-ki.png', '/journal'),
    ('Nhạc', 'assets/hinh_phuong_thuc/hinh-nghe-nhac.png', '/sounds'),
    ('Podcast', 'assets/hinh_phuong_thuc/hinh-podcast.png', '/podcast'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${context.t('Phương thức phù hợp cho')} $name',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: _methods.map((m) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.push(m.$3);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: context.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.fieldBorder),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          m.$2,
                          width: 36,
                          height: 36,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.t(m.$1),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: context.appText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
