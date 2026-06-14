import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../../../widgets/soft_toast.dart';

class MoodBudgetWidget extends StatefulWidget {
  const MoodBudgetWidget({super.key});

  @override
  State<MoodBudgetWidget> createState() => _MoodBudgetWidgetState();
}

class _MoodBudgetWidgetState extends State<MoodBudgetWidget> {
  late Box _budgetBox;
  bool _loading = true;
  int _energy = 70;
  int _stress = 45;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _budgetBox = await Hive.openBox('mood_budget');
    setState(() {
      _energy = (_budgetBox.get('energy', defaultValue: 70) as num).toInt();
      _stress = (_budgetBox.get('stress', defaultValue: 45) as num).toInt();
      _loading = false;
    });
  }

  Future<void> _adjust(int energyDiff, int stressDiff, String activityName) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _energy = (_energy + energyDiff).clamp(0, 100);
      _stress = (_stress + stressDiff).clamp(0, 100);
    });
    await _budgetBox.put('energy', _energy);
    await _budgetBox.put('stress', _stress);

    if (mounted) {
      showSoftToast(
        context,
        message: '${context.t("Đã hoàn thành")} $activityName! +$energyDiff ${context.t("Năng lượng")} ⚡',
        tone: SoftToastTone.success,
      );
    }
  }

  String getRecoveryNeed() {
    if (_energy < 40 || _stress > 70) return 'HIGH';
    if (_energy < 70 || _stress > 40) return 'MEDIUM';
    return 'LOW';
  }

  Color getRecoveryColor(String need) {
    if (need == 'HIGH') return Colors.redAccent;
    if (need == 'MEDIUM') return Colors.orangeAccent;
    return RelaxColors.mint;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator(color: RelaxColors.violet)),
      );
    }

    final need = getRecoveryNeed();
    final needColor = getRecoveryColor(need);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.fieldBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.t('Emotional Energy Budget ⚡'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: context.appText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: needColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${context.t("Recovery")}: ${context.t(need)}',
                  style: TextStyle(
                    color: needColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: context.t('Năng lượng (Energy)'),
                  value: '$_energy/100',
                  progress: _energy / 100,
                  color: RelaxColors.mint,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricTile(
                  label: context.t('Căng thẳng (Stress)'),
                  value: '$_stress/100',
                  progress: _stress / 100,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            context.t('Hoạt động nạp lại năng lượng:'),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.mutedText),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _rechargeButton('Breathing', '+10', () => _adjust(10, -10, context.t('Hít thở sâu'))),
                const SizedBox(width: 8),
                _rechargeButton('Walk Break', '+15', () => _adjust(15, -15, context.t('Đi dạo ngắn'))),
                const SizedBox(width: 8),
                _rechargeButton('Journal', '+8', () => _adjust(8, -5, context.t('Viết nhật ký'))),
                const SizedBox(width: 8),
                _rechargeButton('Sleep Routine', '+20', () => _adjust(20, -20, context.t('Routine ngủ ngon'))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: context.mutedText)),
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.appText)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: context.fieldBorder,
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _rechargeButton(String name, String points, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: RelaxColors.violet.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: RelaxColors.violet.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.t(name),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: RelaxColors.violet),
            ),
            const SizedBox(width: 4),
            Text(
              points,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: RelaxColors.mint),
            ),
          ],
        ),
      ),
    );
  }
}
