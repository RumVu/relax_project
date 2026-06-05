import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../pixel/pixel_panel.dart';

class PixelBottomNav extends StatelessWidget {
  const PixelBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = context.copy.navItems;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: PixelPanel(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = selectedIndex == index;
              return Expanded(
                child: Tooltip(
                  message: item.label,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 58,
                      decoration: BoxDecoration(
                        color: selected
                            ? RelaxTheme.purple
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: RelaxTheme.purple.withValues(
                                    alpha: .35,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            color: selected
                                ? Colors.white
                                : context.relax.muted,
                          ),
                          const SizedBox(height: 3),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : context.relax.muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
