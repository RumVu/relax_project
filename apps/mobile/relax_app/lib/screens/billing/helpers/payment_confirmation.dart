import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api_client.dart';
import '../../../core/auth_state.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../../../widgets/soft_toast.dart';

/// Execute the payment-confirmation flow.
///
/// For SePay-active mode, polls GET /billing/me/payments/:id up to 5 times
/// waiting for COMPLETED status.
/// For dev mode, calls POST /billing/me/payments/:id/confirm directly.
///
/// [parentCtx] — the BillingScreen's context (used for dialogs & toasts).
/// [sheetCtx]  — the bottom-sheet context (closed on success).
/// [paymentId] — the payment to confirm.
/// [isSepayActive] — whether SePay webhook is configured.
/// [onReload]  — callback to refresh local billing data after success.
Future<void> confirmPayment({
  required BuildContext parentCtx,
  required BuildContext sheetCtx,
  required String paymentId,
  required bool isSepayActive,
  required VoidCallback onReload,
}) async {
  final successMsg =
      parentCtx.t('Thanh toán thành công! Gói đã được kích hoạt.');
  final confirmDevMsg =
      parentCtx.t('Đã xác nhận! Gói (DEV) đã được kích hoạt.');
  final errorMsgPrefix = parentCtx.t('Lỗi:');
  final notReceivedMsgTitle = parentCtx.t('Chưa nhận được giao dịch');
  final notReceivedMsgContent = parentCtx.t(
      'Hệ thống chưa ghi nhận được khoản chuyển của bạn. Vui lòng kiểm tra lại số tài khoản, số tiền và nội dung chuyển khoản thô đã đúng chưa.\n\nNếu bạn đã chuyển khoản thành công, vui lòng chờ 1-2 phút hoặc liên hệ với admin để được hỗ trợ.');
  final closeBtnText = parentCtx.t('Đóng');

  if (isSepayActive) {
    // Show verification loading dialog
    showDialog(
      context: parentCtx,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: RelaxColors.violet),
                const SizedBox(height: 16),
                Text(
                  parentCtx.t('Đang kiểm tra giao dịch...'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    bool confirmed = false;
    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(seconds: 3));
      try {
        final res =
            await RelaxApi.instance.get('/billing/me/payments/$paymentId');
        if (res.statusCode == 200 && res.data is Map) {
          final status = res.data['status'] as String?;
          if (status == 'COMPLETED') {
            confirmed = true;
            break;
          }
        }
      } catch (e) {
        // Ignore transient request errors during polling
      }
    }

    // Hide verification loader
    if (parentCtx.mounted) {
      Navigator.pop(parentCtx);
    }

    if (confirmed) {
      if (sheetCtx.mounted) {
        Navigator.pop(sheetCtx); // Close payment sheet
      }
      if (parentCtx.mounted) {
        showSoftToast(parentCtx,
            message: successMsg, tone: SoftToastTone.success);
        parentCtx.read<AuthState>().refreshUser();
      }
      onReload(); // Refresh local screen details
    } else {
      if (parentCtx.mounted) {
        showDialog(
          context: parentCtx,
          builder: (ctx) => AlertDialog(
            title: Text(notReceivedMsgTitle),
            content: Text(notReceivedMsgContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(closeBtnText),
              ),
            ],
          ),
        );
      }
    }
  } else {
    // Dev mode: allow manual confirmation bypass
    showDialog(
      context: parentCtx,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final res = await RelaxApi.instance.post(
        '/billing/me/payments/$paymentId/confirm',
      );
      if (parentCtx.mounted) {
        Navigator.pop(parentCtx);
      }
      if (!sheetCtx.mounted) return;
      Navigator.pop(sheetCtx);

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (parentCtx.mounted) {
          showSoftToast(parentCtx,
              message: confirmDevMsg, tone: SoftToastTone.success);
          parentCtx.read<AuthState>().refreshUser();
        }
        onReload();
      } else {
        final msg =
            (res.data is Map ? res.data['message'] as String? : null) ??
                'Chưa xác nhận được — hệ thống sẽ tự kiểm tra.';
        if (parentCtx.mounted) {
          showSoftToast(parentCtx,
              message: parentCtx.t(msg), tone: SoftToastTone.info);
        }
      }
    } catch (e) {
      if (parentCtx.mounted) {
        Navigator.pop(parentCtx);
        showSoftToast(parentCtx,
            message: '$errorMsgPrefix $e', tone: SoftToastTone.error);
      }
    }
  }
}
