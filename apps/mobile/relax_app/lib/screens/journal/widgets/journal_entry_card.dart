import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// A single journal entry card with title, body preview, favourite toggle,
/// and a delete button.
class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({
    super.key,
    required this.entry,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  final Map<String, dynamic> entry;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final fav = entry['isFavorite'] == true || entry['favorite'] == true;
    final title = (entry['title'] as String?) ?? '';
    final content = (entry['content'] as String?) ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: context.appText,
                fontSize: 15,
              ),
            ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: RelaxColors.plum,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: onToggleFavorite,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    fav ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: fav ? RelaxColors.coral : RelaxColors.slate,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline,
                      size: 20, color: RelaxColors.slate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
