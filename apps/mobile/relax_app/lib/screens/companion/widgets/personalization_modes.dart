import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../../../widgets/soft_toast.dart';
import '../models/personalization_mode.dart';

/// Displays the list of personalization mode cards, highlighting the currently
/// selected mode.
class PersonalizationModes extends StatelessWidget {
  const PersonalizationModes({
    super.key,
    required this.currentMode,
    required this.busy,
    required this.customAssets,
    required this.onChangeMode,
  });

  /// The currently-active personalization mode key (e.g. 'DEFAULT').
  final String currentMode;

  /// Whether the screen is currently performing an async operation.
  final bool busy;

  /// The list of custom companion assets (used when the user picks CUSTOM).
  final List<Map<String, dynamic>> customAssets;

  /// Callback to change the personalization mode.
  final void Function(String mode, {String? assetId}) onChangeMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: personalizationModes.map((m) {
        final mode = m.mode;
        final label = context.t(m.label);
        final icon = m.icon;
        final isSelected = currentMode == mode;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          color: context.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? RelaxColors.violet : context.fieldBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            leading: Icon(icon, color: isSelected ? RelaxColors.violet : context.mutedText),
            title: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isSelected ? RelaxColors.violet : context.appText,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: RelaxColors.violet)
                : null,
            onTap: busy
                ? null
                : (isSelected && mode != 'CUSTOM')
                    ? null
                    : () {
                        if (mode == 'CUSTOM') {
                          if (customAssets.isNotEmpty) {
                            final randomAsset = customAssets[
                                Random().nextInt(customAssets.length)];
                            onChangeMode('CUSTOM',
                                assetId: randomAsset['id'] as String);
                          } else {
                            showSoftToast(context,
                                message: context.t('Kho linh thú tự chọn trống.'),
                                tone: SoftToastTone.info);
                          }
                        } else {
                          onChangeMode(mode);
                        }
                      },
          ),
        );
      }).toList(),
    );
  }
}
