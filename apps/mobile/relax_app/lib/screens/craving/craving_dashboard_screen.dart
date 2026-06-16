import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/premium_blur.dart';

/// Craving dashboard: stats, hourly chart, top triggers, best activities,
/// wellness streak, and craving reduction goal card.
class CravingDashboardScreen extends StatefulWidget {
  const CravingDashboardScreen({super.key});

  @override
  State<CravingDashboardScreen> createState() => _CravingDashboardScreenState();
}

class _CravingDashboardScreenState extends State<CravingDashboardScreen> {
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _goal;
  bool _loading = true;
  bool _editingGoal = false;

  final _dailyTargetCtrl = TextEditingController();
  final _currentDailyCtrl = TextEditingController();
  final _replacementCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _dailyTargetCtrl.dispose();
    _currentDailyCtrl.dispose();
    _replacementCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        RelaxApi.instance.get('/craving/stats'),
        RelaxApi.instance.get('/craving/goal'),
      ]);
      if (!mounted) return;
      setState(() {
        _stats = results[0].data as Map<String, dynamic>?;
        _goal = results[1].data as Map<String, dynamic>?;
        _loading = false;
        _syncGoalFields();
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _syncGoalFields() {
    if (_goal == null) return;
    _dailyTargetCtrl.text = '${_goal!['dailyTarget'] ?? 0}';
    _currentDailyCtrl.text = '${_goal!['currentDaily'] ?? 0}';
    _replacementCtrl.text = '${_goal!['replacementGoal'] ?? 1}';
  }

  Future<void> _saveGoal() async {
    try {
      await RelaxApi.instance.patch('/craving/goal', body: {
        'dailyTarget': int.tryParse(_dailyTargetCtrl.text) ?? 0,
        'currentDaily': int.tryParse(_currentDailyCtrl.text) ?? 0,
        'replacementGoal': int.tryParse(_replacementCtrl.text) ?? 1,
      });
      setState(() => _editingGoal = false);
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDark ? const Color(0xFF0d1117) : RelaxColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Theo dõi cơn thèm'),
          style: TextStyle(
            color: context.appText,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: context.appText),
            onPressed: () => context.push('/craving-flow'),
            tooltip: context.t('Ghi nhận cơn thèm'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatsCards(context),
                  const SizedBox(height: 16),
                  PremiumBlur(
                    child: Column(
                      children: [
                  _buildHourlyChart(context),
                  const SizedBox(height: 16),
                  _buildTopTriggers(context),
                  const SizedBox(height: 16),
                  _buildBestActivities(context),
                  const SizedBox(height: 16),
                  _buildGoalCard(context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: child,
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    final total = _stats?['total'] ?? 0;
    final resisted = _stats?['resisted'] ?? 0;
    final rate = _stats?['resistanceRate'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _card(
            context,
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('$total',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: context.appText)),
                ),
                const SizedBox(height: 4),
                Text(context.t('Tổng cơn thèm'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        color: context.appText.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _card(
            context,
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('$resisted',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: RelaxColors.mint)),
                ),
                const SizedBox(height: 4),
                Text(context.t('Đã kháng cự'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        color: context.appText.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _card(
            context,
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('$rate%',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: RelaxColors.violet)),
                ),
                const SizedBox(height: 4),
                Text(context.t('Tỷ lệ kháng cự'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        color: context.appText.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyChart(BuildContext context) {
    final dist = (_stats?['hourlyDistribution'] as List<dynamic>?) ??
        List.filled(24, 0);
    final maxVal =
        dist.fold<int>(0, (m, v) => (v as int) > m ? v : m);

    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t('Phân bố theo giờ'),
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: context.appText)),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(24, (i) {
                final val = (dist[i] as int);
                final h = maxVal > 0 ? (val / maxVal) * 60 : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: h,
                          decoration: BoxDecoration(
                            color: RelaxColors.violet
                                .withValues(alpha: val > 0 ? 0.7 : 0.15),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (i % 6 == 0)
                          Text('${i}h',
                              style: TextStyle(
                                  fontSize: 9,
                                  color:
                                      context.appText.withValues(alpha: 0.4))),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTriggers(BuildContext context) {
    final triggers = (_stats?['topTriggers'] as List<dynamic>?) ?? [];
    if (triggers.isEmpty) return const SizedBox.shrink();

    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t('Nguyên nhân hàng đầu'),
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: context.appText)),
          const SizedBox(height: 12),
          ...triggers.map((t) {
            final reason = t['reason'] as String? ?? '';
            final count = t['count'] as int? ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_reasonLabel(context, reason),
                        style: TextStyle(color: context.appText)),
                  ),
                  Text('$count',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: context.appText.withValues(alpha: 0.6))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBestActivities(BuildContext context) {
    final activities = (_stats?['bestActivities'] as List<dynamic>?) ?? [];
    if (activities.isEmpty) return const SizedBox.shrink();

    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t('Hoạt động hiệu quả nhất'),
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: context.appText)),
          const SizedBox(height: 12),
          ...activities.map((a) {
            final activity = a['activity'] as String? ?? '';
            final avgDrop = a['avgDrop'] ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(activity,
                        style: TextStyle(color: context.appText)),
                  ),
                  Text('-$avgDrop',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: RelaxColors.mint)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context) {
    final dailyTarget = _goal?['dailyTarget'] ?? 0;
    final currentDaily = _goal?['currentDaily'] ?? 0;
    final replacementGoal = _goal?['replacementGoal'] ?? 1;

    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(context.t('Mục tiêu giảm hút'),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: context.appText)),
              ),
              IconButton(
                icon: Icon(
                  _editingGoal ? Icons.close : Icons.edit_outlined,
                  size: 20,
                  color: context.appText.withValues(alpha: 0.5),
                ),
                onPressed: () =>
                    setState(() => _editingGoal = !_editingGoal),
              ),
            ],
          ),
          if (!_editingGoal) ...[
            const SizedBox(height: 8),
            _goalRow(context, context.t('Hiện tại'), '$currentDaily ${context.t("điếu/ngày")}'),
            _goalRow(context, context.t('Mục tiêu'), '$dailyTarget ${context.t("điếu/ngày")}'),
            _goalRow(
                context, context.t('Break thay thế/điếu'), '$replacementGoal ${context.t("phút")}'),
            if (dailyTarget > currentDaily && currentDaily > 0) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: currentDaily / dailyTarget,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(RelaxColors.mint),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.t('Tăng {count} lần nghỉ/ngày').replaceAll('{count}', '${dailyTarget - currentDaily}'),
                style: TextStyle(
                    fontSize: 12,
                    color: RelaxColors.mint.withValues(alpha: 0.8)),
              ),
            ],
          ] else ...[
            const SizedBox(height: 8),
            _goalInput(context, context.t('Hiện tại (điếu/ngày)'), _currentDailyCtrl),
            _goalInput(context, context.t('Mục tiêu (điếu/ngày)'), _dailyTargetCtrl),
            _goalInput(context, context.t('Break thay thế/điếu (phút)'), _replacementCtrl),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RelaxColors.violet,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(context.t('Lưu mục tiêu')),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _goalRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: context.appText.withValues(alpha: 0.6),
                    fontSize: 14)),
          ),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.appText,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _goalInput(
      BuildContext context, String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: TextStyle(color: context.appText),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: context.appText.withValues(alpha: 0.5), fontSize: 13),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: context.surfaceAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  String _reasonLabel(BuildContext context, String reason) {
    const labels = {
      'SMOKE_CRAVING': 'Thèm thuốc',
      'STRESS': 'Căng thẳng',
      'BOREDOM': 'Chán',
      'SLEEPY': 'Buồn ngủ',
      'OVERWHELMED': 'Quá tải',
      'LONELY': 'Cô đơn',
      'HABIT': 'Thói quen',
      'SOCIAL': 'Xã hội',
      'OTHER': 'Khác',
    };
    return context.t(labels[reason] ?? reason);
  }
}
