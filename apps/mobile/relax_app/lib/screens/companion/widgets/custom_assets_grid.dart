import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../helpers/companion_helpers.dart';

/// A grid of selectable custom companion assets.
class CustomAssetsGrid extends StatelessWidget {
  const CustomAssetsGrid({
    super.key,
    required this.customAssets,
    required this.currentAssetId,
    required this.busy,
    required this.onSelectAsset,
  });

  /// The list of custom companion assets to display.
  final List<Map<String, dynamic>> customAssets;

  /// The ID of the currently-selected asset, if any.
  final String? currentAssetId;

  /// Whether the screen is currently performing an async operation.
  final bool busy;

  /// Callback invoked when the user selects an asset.
  final void Function(String assetId) onSelectAsset;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: customAssets.length,
      itemBuilder: (context, idx) {
        final asset = customAssets[idx];
        final id = asset['id'] as String;
        final name = asset['name'] as String;
        final preview = asset['previewImageUrl'] as String?;
        final type = asset['type'] as String?;
        final isSelected = currentAssetId == id;

        return GestureDetector(
          onTap: busy || isSelected
              ? null
              : () => onSelectAsset(id),
          child: Container(
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? RelaxColors.violet : context.fieldBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  child: preview != null && preview.isNotEmpty
                      ? Image.network(
                          preview,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, stack) => Text(
                            fallbackEmoji(type),
                            style: const TextStyle(fontSize: 28),
                          ),
                        )
                      : Text(
                          fallbackEmoji(type),
                          style: const TextStyle(fontSize: 28),
                        ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? RelaxColors.violet : context.appText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
