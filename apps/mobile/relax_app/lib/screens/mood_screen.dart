import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/theme.dart';

/// Màn ghi cảm xúc: chọn 1 trong các mood lấy từ /mood-checkins/options,
/// kéo cường độ 1-5, viết ghi chú, gửi POST /mood-checkins/me. Bên dưới
/// hiển thị lịch sử gần đây từ /mood-checkins/me.
class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  List<Map<String, dynamic>> _options = [];
  List<Map<String, dynamic>> _history = [];
  String? _selectedMood;
  double _intensity = 3;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        RelaxApi.instance.get('/mood-checkins/options'),
        RelaxApi.instance.get('/mood-checkins/me', query: {'limit': 8}),
      ]);
      final opts = results[0].data;
      final hist = results[1].data;
      _options = (opts is List)
          ? opts.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
          : [];
      final histItems = hist is Map ? hist['items'] : hist;
      _history = (histItems is List)
          ? histItems
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
      _selectedMood ??= _options.isNotEmpty ? _options.first['mood'] as String? : null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_selectedMood == null) return;
    setState(() => _saving = true);
    try {
      final res = await RelaxApi.instance.post('/mood-checkins/me', body: {
        'mood': _selectedMood,
        'intensity': _intensity.round(),
        if (_noteCtrl.text.trim().isNotEmpty) 'note': _noteCtrl.text.trim(),
        'tags': ['mobile'],
      });
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        _noteCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: RelaxColors.mint,
          content: Text('Đã ghi lại cảm xúc của bạn.'),
        ));
        await _load();
      } else {
        final msg = (res.data?['message'] as String?) ?? 'Không lưu được cảm xúc';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: RelaxColors.coral,
          content: Text(msg),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: RelaxColors.coral,
          content: Text(e.toString()),
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: RelaxColors.violet,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const Text(
              'Hôm nay bạn thấy thế nào?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: RelaxColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Chọn cảm xúc gần nhất với bạn lúc này.',
              style: TextStyle(color: RelaxColors.slate),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: RelaxColors.violet),
                ),
              )
            else if (_error != null)
              _ErrorBox(message: _error!, onRetry: _load)
            else ...[
              _MoodGrid(
                options: _options,
                selected: _selectedMood,
                onSelect: (m) => setState(() => _selectedMood = m),
              ),
              const SizedBox(height: 24),
              _IntensitySlider(
                value: _intensity,
                onChanged: (v) => setState(() => _intensity = v),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                maxLength: 120,
                decoration: const InputDecoration(
                  hintText: 'Thêm vài dòng ghi chú (không bắt buộc)…',
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.favorite),
                  label: Text(_saving ? 'Đang lưu…' : 'Ghi lại cảm xúc'),
                ),
              ),
              const SizedBox(height: 28),
              if (_history.isNotEmpty) ...[
                const Text(
                  'Gần đây',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: RelaxColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                ..._history.map(_buildHistoryRow),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryRow(Map<String, dynamic> h) {
    final mood = h['mood'] as String?;
    final opt = _options.firstWhere(
      (o) => o['mood'] == mood,
      orElse: () => {'label': mood ?? '—'},
    );
    final note = (h['note'] as String?) ?? '';
    final intensity = (h['intensity'] as num?)?.toInt();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RelaxColors.lilac),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: RelaxColors.violet.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.favorite, size: 18, color: RelaxColors.violet),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (opt['label'] as String?) ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: RelaxColors.ink,
                  ),
                ),
                if (note.isNotEmpty)
                  Text(
                    note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: RelaxColors.slate, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (intensity != null)
            Text(
              '$intensity/5',
              style: const TextStyle(
                color: RelaxColors.violet,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _MoodGrid extends StatelessWidget {
  const _MoodGrid({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<Map<String, dynamic>> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((o) {
        final mood = o['mood'] as String;
        final label = (o['label'] as String?) ?? mood;
        final isSel = selected == mood;
        return GestureDetector(
          onTap: () => onSelect(mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSel ? RelaxColors.violet : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSel ? RelaxColors.violet : RelaxColors.lilac,
                width: isSel ? 2 : 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSel ? Colors.white : RelaxColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _IntensitySlider extends StatelessWidget {
  const _IntensitySlider({required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cường độ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: RelaxColors.ink,
              ),
            ),
            Text(
              '${value.round()}/5',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: RelaxColors.violet,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 4,
          activeColor: RelaxColors.violet,
          inactiveColor: RelaxColors.lilac,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RelaxColors.coral.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RelaxColors.coral),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Không tải được dữ liệu',
            style: TextStyle(fontWeight: FontWeight.w800, color: RelaxColors.coral),
          ),
          const SizedBox(height: 4),
          Text(message,
              style: const TextStyle(color: RelaxColors.coral, fontSize: 12)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
