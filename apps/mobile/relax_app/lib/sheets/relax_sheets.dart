part of 'package:relax_app/main.dart';

void showPlayerSheet(BuildContext context, Activity activity) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PixelCatScene(scene: CatScene.laptop, height: 190),
            Text(
              'Đang nghe nhạc',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Lo-fi Chill · Pixel Beats',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Slider(value: .42, onChanged: (_) {}),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                FilledButton(
                  onPressed: () {},
                  child: const Icon(Icons.pause_rounded),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_next_rounded),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

void showFeedbackSheet(BuildContext context, Activity activity) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '♥ Bạn ổn chứ? ♥',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const CatAvatar(size: 82),
            const SizedBox(height: 10),
            Text(
              'Hoạt động vừa rồi giúp bạn thế nào?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Row(
              children: const [
                Expanded(child: RatingChip(label: 'Rất tệ', selected: false)),
                SizedBox(width: 6),
                Expanded(child: RatingChip(label: 'Tệ', selected: false)),
                SizedBox(width: 6),
                Expanded(
                  child: RatingChip(label: 'Bình thường', selected: false),
                ),
                SizedBox(width: 6),
                Expanded(child: RatingChip(label: 'Tốt', selected: false)),
                SizedBox(width: 6),
                Expanded(child: RatingChip(label: 'Rất tốt', selected: true)),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Viết vài dòng cho Thi Ái nghe nè...',
                filled: true,
                fillColor: context.relax.surfaceSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 14),
            PixelButton(
              icon: Icons.arrow_forward_rounded,
              label: 'Continue',
              filled: true,
              onPressed: () {
                Navigator.of(context).pop();
                showEncourageSheet(context);
              },
            ),
            const SizedBox(height: 8),
            PixelButton(
              icon: Icons.work_outline_rounded,
              label: "I'm fine, I'm going back to my work",
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    },
  );
}

void showEncourageSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mức độ giảm tải',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            const PixelCatScene(scene: CatScene.wave, height: 160),
            Text(
              'Thi Ái thấy bạn đã giảm stress khoảng 27% rồi nè!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            PixelButton(
              icon: Icons.home_rounded,
              label: 'Quay về trang chủ',
              filled: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    },
  );
}

void showConfirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
  bool danger = false,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CatAvatar(size: 110),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: danger
                      ? context.relax.danger
                      : RelaxTheme.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(action),
              ),
            ),
            const SizedBox(height: 8),
            PixelButton(
              icon: Icons.close_rounded,
              label: 'Hủy bỏ',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    },
  );
}

class RatingChip extends StatelessWidget {
  const RatingChip({super.key, required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: selected
            ? RelaxTheme.purple.withValues(alpha: .22)
            : context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? RelaxTheme.purple : context.relax.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets_rounded, color: RelaxTheme.lavender, size: 20),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
