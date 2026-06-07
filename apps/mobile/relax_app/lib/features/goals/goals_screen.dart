import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/services/goals/goals_service.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_button.dart';

/// Goals screen — đặt mục tiêu tuần mềm cho 3 hoạt động chính.
/// Nhận progress thực tế từ shell (mood check-in, relax session, journal entry)
/// để hiển thị tiến độ so với mục tiêu.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({
    super.key,
    this.progressMoodCount = 0,
    this.progressRelaxCount = 0,
    this.progressJournalCount = 0,
  });

  /// Số check-in mood trong tuần hiện tại (tính từ shell).
  final int progressMoodCount;

  /// Số phiên thư giãn hoàn thành trong tuần hiện tại.
  final int progressRelaxCount;

  /// Số entries nhật ký viết trong tuần hiện tại.
  final int progressJournalCount;

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  Goals? _goals;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final g = await GoalsService.instance.load();
    if (!mounted) return;
    setState(() => _goals = g);
  }

  Future<void> _save() async {
    if (_goals == null) return;
    setState(() => _saving = true);
    await GoalsService.instance.save(_goals!);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu mục tiêu tuần ✦')),
    );
    Navigator.of(context).pop(_goals);
  }

  @override
  Widget build(BuildContext context) {
    final g = _goals;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Mục tiêu của bạn'),
      ),
      body: g == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                const Center(child: CatAvatar(size: 80)),
                const SizedBox(height: 12),
                Text(
                  'Đặt mục tiêu nhẹ nhàng cho tuần ✦',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Không có ai chấm điểm bạn. Đây chỉ là kim chỉ nam mềm — '
                  'không đạt cũng không sao 💜',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _GoalSlider(
                  emoji: '💜',
                  title: 'Check-in cảm xúc',
                  unit: 'lần/tuần',
                  value: g.moodCheckinsWeek,
                  min: 1,
                  max: 21,
                  desc: 'Đề xuất: 3-5 lần/tuần. Mỗi sáng + tối là lý tưởng.',
                  progress: widget.progressMoodCount,
                  onChanged: (v) => setState(() =>
                      _goals = g.copyWith(moodCheckinsWeek: v.round())),
                ),
                const SizedBox(height: 16),
                _GoalSlider(
                  emoji: '🌿',
                  title: 'Phiên thư giãn',
                  unit: 'phiên/tuần',
                  value: g.relaxSessionsWeek,
                  min: 1,
                  max: 14,
                  desc: 'Đề xuất: 2-3 phiên/tuần — đủ để xây thói quen.',
                  progress: widget.progressRelaxCount,
                  onChanged: (v) => setState(() =>
                      _goals = g.copyWith(relaxSessionsWeek: v.round())),
                ),
                const SizedBox(height: 16),
                _GoalSlider(
                  emoji: '✍️',
                  title: 'Nhật ký',
                  unit: 'entry/tuần',
                  value: g.journalEntriesWeek,
                  min: 0,
                  max: 7,
                  desc: 'Đề xuất: 1-2 entry/tuần khi cảm thấy nhiều quá.',
                  progress: widget.progressJournalCount,
                  onChanged: (v) => setState(() =>
                      _goals = g.copyWith(journalEntriesWeek: v.round())),
                ),
                const SizedBox(height: 28),
                PixelButton(
                  icon: _saving ? Icons.hourglass_top_rounded : Icons.save_rounded,
                  label: _saving ? 'Đang lưu...' : 'Lưu mục tiêu',
                  filled: true,
                  onPressed: _saving ? null : _save,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RelaxTheme.lavender.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 14,
                        color: RelaxTheme.lavender,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mục tiêu được kiểm tra hàng tuần ở "Hành trình". '
                          'Đặt thấp hơn bạn nghĩ — vượt mong đợi cảm giác '
                          'tốt hơn ✦',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 11,
                                color: context.relax.muted,
                              ),
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

class _GoalSlider extends StatelessWidget {
  const _GoalSlider({
    required this.emoji,
    required this.title,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.desc,
    required this.onChanged,
    this.progress = 0,
  });
  final String emoji;
  final String title;
  final String unit;
  final int value;
  final int min;
  final int max;
  final String desc;
  final ValueChanged<double> onChanged;
  /// Progress thực tế trong tuần (từ API), 0 nếu chưa có.
  final int progress;

  @override
  Widget build(BuildContext context) {
    final progressFraction = value > 0
        ? (progress / value).clamp(0.0, 1.0)
        : 0.0;
    final achieved = progress >= value && value > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: achieved
              ? RelaxTheme.lavender.withValues(alpha: .5)
              : context.relax.border,
          width: achieved ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: achieved ? RelaxTheme.lavender : RelaxTheme.purple,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  achieved
                      ? '✦ Đạt!'
                      : '$value $unit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 11.5,
            ),
          ),
          // Progress bar thực tế (nếu có dữ liệu)
          if (progress > 0 || value > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progressFraction,
                      minHeight: 6,
                      backgroundColor: context.relax.surfaceSoft,
                      valueColor: AlwaysStoppedAnimation(
                        achieved
                            ? RelaxTheme.lavender
                            : RelaxTheme.purple.withValues(alpha: .7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$progress / $value',
                  style: TextStyle(
                    color: achieved
                        ? RelaxTheme.lavender
                        : context.relax.muted,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
          Slider(
            value: value.toDouble().clamp(min.toDouble(), max.toDouble()),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: '$value',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
