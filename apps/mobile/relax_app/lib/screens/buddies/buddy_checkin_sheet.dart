import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';

/// Bottom sheet that lets the user send a soft SOS / check-in message
/// to one of their trusted buddies.
class BuddyCheckinSheet extends StatefulWidget {
  const BuddyCheckinSheet({super.key, required this.buddy});

  /// The buddy (friend) map – must contain at least `id` and `name`/`email`.
  final Map<String, dynamic> buddy;

  /// Convenience helper – shows the sheet as a modal bottom sheet.
  static Future<void> show(
      BuildContext context, Map<String, dynamic> buddy) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BuddyCheckinSheet(buddy: buddy),
    );
  }

  @override
  State<BuddyCheckinSheet> createState() => _BuddyCheckinSheetState();
}

class _BuddyCheckinSheetState extends State<BuddyCheckinSheet> {
  static const _templates = [
    'Mình đang hơi không ổn. Check mình chút được không?',
    'Mình cần ai đó nói chuyện. Rảnh không?',
    'Mình đang cần hỗ trợ. Gọi mình khi rảnh nhé.',
  ];

  String? _selectedMessage;
  final _customCtrl = TextEditingController();
  bool _confirming = false;
  bool _sending = false;

  String get _buddyName {
    final user = widget.buddy['friend'] as Map? ?? widget.buddy;
    return user['name'] as String? ??
        (user['email'] as String?)?.split('@').first ??
        '?';
  }

  String get _buddyId {
    final user = widget.buddy['friend'] as Map? ?? widget.buddy;
    return user['id'] as String? ?? '';
  }

  String get _effectiveMessage =>
      _selectedMessage ?? _customCtrl.text.trim();

  Future<void> _send() async {
    final msg = _effectiveMessage;
    if (msg.isEmpty) return;

    setState(() => _sending = true);
    try {
      await RelaxApi.instance.post('/buddy-circle/nudge/$_buddyId');
      if (mounted) {
        showSoftToast(context,
            message: context.t('Đã gửi tin nhắn cho {name}', {'name': _buddyName}),
            tone: SoftToastTone.success);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: e.toString(), tone: SoftToastTone.error);
        setState(() {
          _sending = false;
          _confirming = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: context.fieldBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                const Icon(Icons.favorite, color: RelaxColors.violet, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.t('Liên hệ bạn thân'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: context.appText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.t('Gửi tin nhắn cho {name}', {'name': _buddyName}),
              style: TextStyle(color: context.mutedText, fontSize: 13),
            ),
            const SizedBox(height: 20),

            if (!_confirming) ...[
              // Template cards
              ..._templates.map((tpl) {
                final selected = _selectedMessage == tpl;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedMessage = selected ? null : tpl;
                      if (!selected) _customCtrl.clear();
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? RelaxColors.violet.withValues(alpha: 0.08)
                          : context.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? RelaxColors.violet.withValues(alpha: 0.4)
                            : context.fieldBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.t(tpl),
                            style: TextStyle(
                              color: context.appText,
                              fontSize: 13,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle,
                              color: RelaxColors.violet, size: 20),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 8),

              // Custom message
              TextField(
                controller: _customCtrl,
                maxLines: 3,
                minLines: 1,
                onChanged: (_) =>
                    setState(() => _selectedMessage = null),
                decoration: InputDecoration(
                  hintText: context.t('Hoặc viết tin nhắn riêng...'),
                  hintStyle: TextStyle(color: context.mutedText, fontSize: 13),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.fieldBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: RelaxColors.violet),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 20),

              // Next button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RelaxColors.violet,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _effectiveMessage.isEmpty
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          setState(() => _confirming = true);
                        },
                  child: Text(
                    context.t('Tiếp tục'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Confirmation step
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: RelaxColors.violet.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: RelaxColors.violet.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('Tin nhắn sẽ gửi:'),
                      style: TextStyle(
                        color: context.mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _effectiveMessage,
                      style: TextStyle(
                        color: context.appText,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                context.t('Bạn có chắc muốn gửi tin nhắn này?'),
                style: TextStyle(
                  color: context.appText,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: context.fieldBorder),
                      ),
                      onPressed: _sending
                          ? null
                          : () => setState(() => _confirming = false),
                      child: Text(
                        context.t('Hủy'),
                        style: TextStyle(
                          color: context.appText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RelaxColors.violet,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _sending ? null : _send,
                      child: _sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              context.t('Gửi'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
