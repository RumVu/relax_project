import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';

class CbtThoughtRecordScreen extends StatefulWidget {
  const CbtThoughtRecordScreen({super.key});

  @override
  State<CbtThoughtRecordScreen> createState() => _CbtThoughtRecordScreenState();
}

class _CbtThoughtRecordScreenState extends State<CbtThoughtRecordScreen> {
  late Box<String> _cbtBox;
  bool _loading = true;
  List<Map<String, dynamic>> _history = [];

  // Form State
  int _currentStep = 0;
  final _situationCtrl = TextEditingController();
  final _thoughtsCtrl = TextEditingController();
  String _emotion = 'ANXIOUS';
  int _intensity = 5;
  final _evidenceCtrl = TextEditingController();
  final _reframeCtrl = TextEditingController();

  final List<String> _emotions = ['ANXIOUS', 'STRESSED', 'SAD', 'ANGRY', 'TIRED'];

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _cbtBox = await Hive.openBox<String>('cbt_thought_records');
    _loadHistory();
  }

  void _loadHistory() {
    final List<Map<String, dynamic>> list = [];
    for (var key in _cbtBox.keys) {
      final val = _cbtBox.get(key);
      if (val != null) {
        try {
          final decoded = jsonDecode(val) as Map<String, dynamic>;
          list.add({'key': key, ...decoded});
        } catch (_) {}
      }
    }
    list.sort((a, b) => (b['createdAt'] as String? ?? '').compareTo(a['createdAt'] as String? ?? ''));
    setState(() {
      _history = list;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _situationCtrl.dispose();
    _thoughtsCtrl.dispose();
    _evidenceCtrl.dispose();
    _reframeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_situationCtrl.text.trim().isEmpty || _reframeCtrl.text.trim().isEmpty) {
      showSoftToast(context, message: context.t('Vui lòng điền đủ thông tin tái nhận thức'), tone: SoftToastTone.error);
      return;
    }

    final entry = {
      'situation': _situationCtrl.text.trim(),
      'thoughts': _thoughtsCtrl.text.trim(),
      'emotion': _emotion,
      'intensity': _intensity,
      'evidence': _evidenceCtrl.text.trim(),
      'reframe': _reframeCtrl.text.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    HapticFeedback.mediumImpact();
    await _cbtBox.add(jsonEncode(entry));
    showSoftToast(context, message: context.t('Đã lưu thought reframe mới 🌟'), tone: SoftToastTone.success);

    // Reset Form
    _situationCtrl.clear();
    _thoughtsCtrl.clear();
    _evidenceCtrl.clear();
    _reframeCtrl.clear();
    setState(() {
      _currentStep = 0;
      _intensity = 5;
    });

    _loadHistory();
  }

  Future<void> _delete(dynamic key) async {
    await _cbtBox.delete(key);
    _loadHistory();
    if (mounted) {
      showSoftToast(context, message: context.t('Đã xóa ghi chép'), tone: SoftToastTone.success);
    }
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
          context.t('Thought Reframe (CBT) 🧠'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: RelaxColors.violet))
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  _buildIntroCard(),
                  const SizedBox(height: 20),
                  _buildWizard(),
                  const SizedBox(height: 30),
                  if (_history.isNotEmpty) ...[
                    Text(
                      context.t('Lịch sử Reframe của bạn'),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.appText),
                    ),
                    const SizedBox(height: 12),
                    ..._history.map((h) => _buildHistoryCard(h)),
                  ]
                ],
              ),
            ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RelaxColors.violet.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RelaxColors.violet.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Text('🧠', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.t('Thay đổi cách nhìn nhận (Reframing) giúp giải tỏa stress và lo lắng thông qua phương pháp tự nhận thức CBT.'),
              style: TextStyle(color: context.appText, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWizard() {
    final List<Widget> steps = [
      _buildStepInput(
        title: context.t('Bước 1: Tình huống xảy ra'),
        subtitle: context.t('Chuyện gì vừa xảy ra khiến bạn khó chịu?'),
        controller: _situationCtrl,
        hint: context.t('Ví dụ: Mình gửi tin nhắn công việc nhưng sếp không phản hồi sau 2 tiếng...'),
      ),
      _buildStepInput(
        title: context.t('Bước 2: Suy nghĩ tự động'),
        subtitle: context.t('Suy nghĩ tiêu cực nào lập tức xuất hiện trong đầu bạn?'),
        controller: _thoughtsCtrl,
        hint: context.t('Ví dụ: Chắc sếp ghét mình hoặc mình làm sai việc gì rồi...'),
      ),
      _buildStepEmotion(),
      _buildStepInput(
        title: context.t('Bước 3: Bằng chứng khách quan'),
        subtitle: context.t('Có bằng chứng thực tế nào ủng hộ hoặc phản bác suy nghĩ trên không?'),
        controller: _evidenceCtrl,
        hint: context.t('Ví dụ: Sếp thường bận họp chiều nay. Sếp vẫn khen báo cáo tuần trước của mình.'),
      ),
      _buildStepInput(
        title: context.t('Bước 4: Góc nhìn mới (Reframe)'),
        subtitle: context.t('Một cách giải thích khách quan và nhẹ lòng hơn là gì?'),
        controller: _reframeCtrl,
        hint: context.t('Ví dụ: Sếp đang bận họp và sẽ trả lời khi rảnh. Mình không cần quá lo lắng.'),
      ),
    ];

    return Card(
      color: context.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${context.t("Bước")} ${_currentStep + 1}/5',
                  style: const TextStyle(color: RelaxColors.violet, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${((_currentStep + 1) * 20)}%',
                  style: TextStyle(color: context.mutedText, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentStep + 1) / 5,
              backgroundColor: context.fieldBorder,
              color: RelaxColors.violet,
            ),
            const SizedBox(height: 20),
            steps[_currentStep],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: () => setState(() => _currentStep--),
                    child: Text(context.t('Quay lại')),
                  )
                else
                  const SizedBox(),
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep < 4) {
                      setState(() => _currentStep++);
                    } else {
                      _save();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RelaxColors.violet,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _currentStep == 4 ? context.t('Hoàn thành') : context.t('Tiếp tục'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStepInput({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.appText)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 12, color: context.mutedText)),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStepEmotion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.t('Cảm xúc đi kèm'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.appText)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _emotion,
          decoration: InputDecoration(
            labelText: context.t('Chọn cảm xúc'),
          ),
          dropdownColor: context.surface,
          items: _emotions.map((e) => DropdownMenuItem(value: e, child: Text(context.t(e)))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _emotion = val);
          },
        ),
        const SizedBox(height: 20),
        Text(
          '${context.t("Mức độ ảnh hưởng")}: $_intensity/10',
          style: TextStyle(fontWeight: FontWeight.bold, color: context.appText),
        ),
        Slider(
          value: _intensity.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: RelaxColors.violet,
          onChanged: (v) => setState(() => _intensity = v.round()),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final date = DateTime.tryParse(item['createdAt'] ?? '')?.toLocal();
    final dateStr = date != null ? '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, "0")}' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: RelaxColors.violet.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${context.t(item['emotion'] ?? '')} (${item['intensity']}/10)',
                  style: const TextStyle(color: RelaxColors.violet, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              Row(
                children: [
                  Text(dateStr, style: TextStyle(color: context.mutedText, fontSize: 11)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _delete(item['key']),
                    child: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildItemDetail(context.t('Tình huống'), item['situation'] ?? ''),
          _buildItemDetail(context.t('Suy nghĩ tự động'), item['thoughts'] ?? '', italic: true),
          if (item['evidence'] != null && item['evidence'].toString().isNotEmpty)
            _buildItemDetail(context.t('Bằng chứng khách quan'), item['evidence']),
          _buildItemDetail(context.t('Góc nhìn mới (Reframe)'), item['reframe'] ?? '', color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildItemDetail(String label, String value, {bool italic = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: context.appText, fontSize: 13, height: 1.4),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: value,
              style: TextStyle(
                fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                color: color ?? context.appText,
                fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
