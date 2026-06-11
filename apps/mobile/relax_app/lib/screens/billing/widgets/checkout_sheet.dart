import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../helpers/billing_formatters.dart';
import 'info_row.dart';

/// Show the checkout / bank-transfer bottom sheet for a given plan.
///
/// [data] is the raw response from POST /billing/me/checkout-session.
/// [planSlug] is the plan being purchased.
/// [onConfirmPayment] is invoked when the user taps "Tôi đã chuyển khoản".
void showCheckoutSheet(
  BuildContext context, {
  required Map<String, dynamic> data,
  required String planSlug,
  required void Function(BuildContext sheetCtx, String paymentId, bool isSepayActive)
      onConfirmPayment,
}) {
  final checkout = data['checkout'] is Map
      ? Map<String, dynamic>.from(data['checkout'] as Map)
      : null;
  final payment = data['payment'] is Map
      ? Map<String, dynamic>.from(data['payment'] as Map)
      : null;

  final paymentId = (data['paymentId'] ??
      payment?['id'] ??
      checkout?['paymentId']) as String?;
  final transferContent = (data['transferContent'] ??
      checkout?['transferContent'] ??
      (payment != null ? 'RELAX${payment['id']}' : null)) as String?;
  final bankAccount = (data['bankAccount'] ??
      checkout?['bankAccount'] ??
      checkout?['accountNo']) as String?;
  final bankName = (data['bankName'] ??
      checkout?['bankName'] ??
      checkout?['bankId']) as String?;
  final amount = data['amount'] ?? checkout?['amount'] ?? payment?['amount'];
  final qrUrl = (data['qrUrl'] ??
      checkout?['qrUrl'] ??
      checkout?['qrCodeUrl']) as String?;
  final isSepayActive = data['configured'] == true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ctx.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ctx.fieldBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.t('Thanh toán gói {tier}',
                {'tier': tierDisplayName(context, planSlug)}),
            style: TextStyle(
              color: ctx.appText,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20),
          if (bankName != null)
            InfoRow(label: context.t('Ngân hàng'), value: bankName),
          if (bankAccount != null)
            InfoRow(
              label: context.t('Số tài khoản'),
              value: bankAccount,
              copyValue: bankAccount,
            ),
          if (amount != null)
            InfoRow(
              label: context.t('Số tiền'),
              value: formatPrice(context, amount),
              copyValue: amount.toString(),
            ),
          if (transferContent != null)
            InfoRow(
              label: context.t('Nội dung CK'),
              value: transferContent,
              copyValue: transferContent,
            ),
          if (qrUrl != null) ...[
            const SizedBox(height: 16),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(qrUrl,
                    width: 200, height: 200, fit: BoxFit.contain),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            context.t(
                'Sau khi chuyển khoản, hệ thống sẽ tự xác nhận trong vài phút.'),
            style: TextStyle(color: ctx.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (paymentId != null)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: RelaxColors.violet,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () =>
                    onConfirmPayment(ctx, paymentId, isSepayActive),
                child: Text(context.t('Tôi đã chuyển khoản'),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.t('Đóng'),
                  style: TextStyle(
                      color: ctx.mutedText, fontWeight: FontWeight.w600)),
            ),
          ),
          SizedBox(height: MediaQuery.of(ctx).padding.bottom),
        ],
      ),
    ),
  );
}
