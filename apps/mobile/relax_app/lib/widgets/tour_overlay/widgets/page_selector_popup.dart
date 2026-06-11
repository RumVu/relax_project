import 'package:flutter/material.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../models/tour_config.dart';
import 'glass_popup.dart';

/// Popup that lets the user pick which page to restart the tour from.
class PageSelectorPopup extends StatefulWidget {
  const PageSelectorPopup({
    super.key,
    required this.onCancel,
    required this.onSelect,
  });

  final VoidCallback onCancel;
  final ValueChanged<int> onSelect;

  @override
  State<PageSelectorPopup> createState() => _PageSelectorPopupState();
}

class _PageSelectorPopupState extends State<PageSelectorPopup> {
  int _selectedRestartPage = 0; // 0: Home, 1: Relax, 2: Analytics, 3: Settings

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassPopup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, color: RelaxColors.plum, size: 44),
            const SizedBox(height: 16),
            Text(
              context.t('Chọn trang muốn quay lại'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(kTourPageNames.length, (index) {
              final isSelected = _selectedRestartPage == index;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedRestartPage = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? RelaxColors.violet.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
                      border: Border.all(
                        color: isSelected ? RelaxColors.violet : Colors.white12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? RelaxColors.violet : Colors.white30,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          context.t(kTourPageNames[index]),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: widget.onCancel,
                    child: Text(
                      context.t('Hủy'),
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RelaxColors.violet,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => widget.onSelect(_selectedRestartPage),
                    child: Text(
                      context.t('Đi thoaii'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
