import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../../../widgets/soft_toast.dart';

class WakeUpDialog extends StatefulWidget {
  const WakeUpDialog({
    super.key,
    required this.startedAt,
    required this.endedAt,
    required this.onLogged,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final VoidCallback onLogged;

  @override
  State<WakeUpDialog> createState() => _WakeUpDialogState();
}

class _WakeUpDialogState extends State<WakeUpDialog> {
  double _quality = 7.0;
  final TextEditingController _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await RelaxApi.instance.post(
        '/sleep/sessions',
        body: {
          'startedAt': widget.startedAt.toUtc().toIso8601String(),
          'endedAt': widget.endedAt.toUtc().toIso8601String(),
          'quality': _quality.toInt(),
          'note': _noteController.text.trim(),
        },
      );
      widget.onLogged();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showSoftToast(context, message: e.toString(), tone: SoftToastTone.error);
      }
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.t('Chào buổi sáng! ☀️')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.t('Bạn đánh giá chất lượng giấc ngủ tối qua như thế nào?')),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_quality.toInt()} / 10',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            Slider(
              value: _quality,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              activeColor: RelaxColors.violet,
              onChanged: (v) => setState(() => _quality = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: context.t('Ghi chú (mơ thấy gì, có tỉnh giấc không...)'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_submitting)
          const Center(child: CircularProgressIndicator(color: RelaxColors.violet))
        else ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.t('Bỏ qua')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: RelaxColors.violet),
            onPressed: _submit,
            child: Text(context.t('Lưu')),
          ),
        ]
      ],
    );
  }
}
