import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../../../widgets/soft_toast.dart';
import '../helpers/billing_formatters.dart';

/// Fetch payment history from the API and display it in a modal bottom sheet.
Future<void> showPaymentHistorySheet(BuildContext ctx) async {
  final errorMsgPrefix = ctx.t('Lỗi:');
  showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    final res = await RelaxApi.instance.get('/billing/me/payments');
    if (!ctx.mounted) return;
    Navigator.pop(ctx); // Close loading

    final payments = <Map<String, dynamic>>[];
    if (res.statusCode == 200) {
      final data = res.data;
      final items = data is Map ? data['items'] ?? data : data;
      if (items is List) {
        for (final p in items) {
          if (p is Map) payments.add(Map<String, dynamic>.from(p));
        }
      }
    }

    if (!ctx.mounted) return;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetCtx).size.height * 0.65,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: sheetCtx.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: sheetCtx.fieldBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              sheetCtx.t('Lịch sử thanh toán'),
              style: TextStyle(
                color: sheetCtx.appText,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            if (payments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(sheetCtx.t('Chưa có giao dịch nào.'),
                    style: TextStyle(color: sheetCtx.mutedText)),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: payments.length,
                  separatorBuilder: (_, index) =>
                      Divider(height: 1, color: sheetCtx.fieldBorder),
                  itemBuilder: (_, i) {
                    final p = payments[i];
                    final amount = p['amount'];
                    final status =
                        (p['status'] as String?) ?? 'UNKNOWN';
                    final createdAt = p['createdAt'] as String?;
                    final date = createdAt != null
                        ? DateTime.tryParse(createdAt)
                        : null;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        status == 'COMPLETED'
                            ? Icons.check_circle
                            : status == 'PENDING'
                                ? Icons.hourglass_bottom
                                : Icons.cancel,
                        color: status == 'COMPLETED'
                            ? RelaxColors.mint
                            : status == 'PENDING'
                                ? RelaxColors.sun
                                : RelaxColors.coral,
                      ),
                      title: Text(formatPrice(ctx, amount),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: sheetCtx.appText)),
                      subtitle: Text(
                        date != null
                            ? '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'
                            : status,
                        style: TextStyle(
                            color: sheetCtx.mutedText, fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: status == 'COMPLETED'
                              ? RelaxColors.mint.withValues(alpha: 0.15)
                              : status == 'PENDING'
                                  ? RelaxColors.sun
                                      .withValues(alpha: 0.15)
                                  : RelaxColors.coral
                                      .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status == 'COMPLETED'
                              ? sheetCtx.t('Thành công')
                              : status == 'PENDING'
                                  ? sheetCtx.t('Đang chờ')
                                  : status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: status == 'COMPLETED'
                                ? RelaxColors.mint
                                : status == 'PENDING'
                                    ? RelaxColors.sun
                                    : RelaxColors.coral,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: MediaQuery.of(sheetCtx).padding.bottom + 8),
          ],
        ),
      ),
    );
  } catch (e) {
    if (ctx.mounted) {
      Navigator.pop(ctx);
      showSoftToast(ctx,
          message: '$errorMsgPrefix $e', tone: SoftToastTone.error);
    }
  }
}
