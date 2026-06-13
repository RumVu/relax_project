import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/locale_controller.dart';
import '../core/theme.dart';
import 'soft_toast.dart';

/// Bottom sheet cho phép đánh giá nội dung sau session — 5 sao + review text.
class ContentRatingSheet extends StatefulWidget {
  const ContentRatingSheet({
    super.key,
    required this.contentType,
    required this.contentId,
  });

  final String contentType;
  final String contentId;

  @override
  State<ContentRatingSheet> createState() => _ContentRatingSheetState();
}

class _ContentRatingSheetState extends State<ContentRatingSheet> {
  int _stars = 0;
  bool _submitting = false;
  final _reviewCtrl = TextEditingController();

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars == 0) return;
    setState(() => _submitting = true);
    try {
      final body = <String, dynamic>{
        'contentType': widget.contentType,
        'contentId': widget.contentId,
        'rating': _stars,
        if (_reviewCtrl.text.trim().isNotEmpty)
          'review': _reviewCtrl.text.trim(),
      };
      final res = await RelaxApi.instance.post(
        '/recommendations/content-ratings',
        body: body,
      );
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        showSoftToast(
          context,
          message: context.t('Cảm ơn bạn đã đánh giá!'),
          tone: SoftToastTone.success,
        );
        Navigator.of(context).pop();
      } else {
        final msg = (res.data?['message'] as String?) ??
            context.t('Không gửi được đánh giá');
        showSoftToast(context, message: msg, tone: SoftToastTone.error);
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(
          context,
          message: e.toString(),
          tone: SoftToastTone.error,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.mutedText.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.t('Đánh giá nội dung'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.t('Chia sẻ cảm nhận của bạn để chúng mình gợi ý tốt hơn.'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.mutedText),
          ),
          const SizedBox(height: 20),
          // Stars row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _stars = starIndex),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    starIndex <= _stars
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 40,
                    color: starIndex <= _stars
                        ? RelaxColors.sun
                        : context.mutedText.withValues(alpha: 0.4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _reviewCtrl,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: context.t('Viết vài dòng cảm nhận (không bắt buộc)…'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _stars == 0 || _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.t('Gửi đánh giá')),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
