import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _sending = false;
  String _type = 'BUG';

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_messageCtrl.text.trim().isEmpty) {
      showSoftToast(context, message: context.t('Vui lòng nhập nội dung chi tiết'), tone: SoftToastTone.error);
      return;
    }

    setState(() => _sending = true);
    HapticFeedback.lightImpact();

    try {
      final subject = '[${_type}] ${_subjectCtrl.text.trim().isNotEmpty ? _subjectCtrl.text.trim() : "Phản hồi" }';
      final res = await RelaxApi.instance.post('/feedbacks', body: {
        'subject': subject,
        'message': _messageCtrl.text.trim(),
      });

      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        showSoftToast(
          context,
          message: context.t('Cảm ơn bạn đã gửi phản hồi đóng góp phát triển ứng dụng! 🌸'),
          tone: SoftToastTone.success,
        );
        context.pop();
      } else {
        final msg = (res.data?['message'] as String?) ?? context.t('Không gửi được phản hồi');
        showSoftToast(context, message: msg, tone: SoftToastTone.error);
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context, message: e.toString(), tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
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
          context.t('Gửi phản hồi 💬'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              context.t('Đóng góp ý kiến của bạn'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.appText),
            ),
            const SizedBox(height: 4),
            Text(
              context.t('Chúng tôi luôn luôn sẵn sàng lắng nghe mọi góp ý của bạn để cải thiện ứng dụng ngày một tốt hơn.'),
              style: TextStyle(color: context.mutedText, fontSize: 13),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: InputDecoration(
                labelText: context.t('Loại phản hồi'),
              ),
              dropdownColor: context.surface,
              items: [
                DropdownMenuItem(value: 'BUG', child: Text(context.t('Báo cáo lỗi (Bug)'))),
                DropdownMenuItem(value: 'FEATURE', child: Text(context.t('Đề xuất tính năng (Feature)'))),
                DropdownMenuItem(value: 'FEEDBACK', child: Text(context.t('Góp ý chung (Feedback)'))),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _type = val);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subjectCtrl,
              decoration: InputDecoration(
                labelText: context.t('Tiêu đề ngắn gọn'),
                hintText: context.t('Ví dụ: Lỗi không phát nhạc khi tắt màn hình'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: context.t('Chi tiết phản hồi'),
                hintText: context.t('Mô tả chi tiết vấn đề bạn gặp phải, hoặc đề xuất của bạn...'),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _sending ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RelaxColors.violet,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _sending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        context.t('Gửi phản hồi'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
