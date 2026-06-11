import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/locale_controller.dart';
import '../../../core/secure_storage.dart';
import '../../../core/theme.dart';
import '../../../widgets/soft_toast.dart';

// Bottom sheet for selecting reminder notification sound.
void showSoundSelectorSheet(
  BuildContext context, {
  required String selectedSound,
  required ValueChanged<String> onSoundChanged,
}) {
  const sounds = [
    {'name': 'Tiếng mèo con kêu 🐱', 'key': 'cat_meow'},
    {'name': 'Chuông gió mùa xuân 🎐', 'key': 'wind_chimes'},
    {'name': 'Tiếng mưa rơi tí tách 🌧️', 'key': 'rain'},
    {'name': 'Sóng biển rì rào 🌊', 'key': 'ocean'},
    {'name': 'Tiếng chuông thiền 🔔', 'key': 'bell'},
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: sheetCtx.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: sheetCtx.fieldBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.t('Chọn âm báo nhắc nhở 🔔'),
            style: TextStyle(
              color: sheetCtx.appText,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sounds.length,
              itemBuilder: (ctx, index) {
                final s = sounds[index];
                final name = s['name']!;
                final isSelected = selectedSound == name;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    context.t(name),
                    style: TextStyle(
                      color: sheetCtx.appText,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                          color: RelaxColors.violet)
                      : null,
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    onSoundChanged(name);
                    try {
                      await secureStorage.write(
                        key: 'relax_reminder_sound',
                        value: name,
                      );
                    } catch (_) {}
                    if (!context.mounted) return;
                    showSoftToast(context,
                        message: context.t('Đã thay đổi âm báo: {sound}',
                            {'sound': context.t(name)}),
                        tone: SoftToastTone.success);

                    if (!sheetCtx.mounted) return;
                    Navigator.pop(sheetCtx);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
