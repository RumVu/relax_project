import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';
import 'helpers/billing_formatters.dart';
import 'helpers/payment_confirmation.dart';
import 'widgets/checkout_sheet.dart';
import 'widgets/current_plan_card.dart';
import 'widgets/payment_history_sheet.dart';
import 'widgets/plan_card.dart';

/// Màn hình Billing — hiển thị gói hiện tại, danh sách gói mua, và cho phép
/// nạp tiền qua SePay. Flow:
///   1. GET /billing/me     → subscription hiện tại
///   2. GET /billing/plans  → danh sách gói
///   3. POST /billing/me/checkout-session → tạo phiên thanh toán
class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  bool _loading = true;
  Map<String, dynamic>? _subscription;
  List<Map<String, dynamic>> _plans = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await RelaxApi.instance.get('/billing/me');
      _subscription = res.data is Map ? Map<String, dynamic>.from(res.data as Map) : null;

      final resPlans = await RelaxApi.instance.get('/billing/plans');
      final plansData = resPlans.data;
      final plansList = plansData is Map ? plansData['items'] ?? plansData : plansData;
      _plans = (plansList is List)
          ? plansList
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkout(Map<String, dynamic> plan) async {
    final planSlug = (plan['slug'] ?? plan['name'] ?? '') as String;

    if (isCurrentPlan(plan, _subscription)) {
      if (mounted) {
        showSoftToast(context,
            message: context.t('Bạn đang dùng gói này rồi!'), tone: SoftToastTone.info);
      }
      return;
    }

    // Show loading
    if (!mounted) return;
    final nav = Navigator.of(context);
    final ctx = context;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final body = <String, dynamic>{
        'provider': 'SEPAY',
        'planName': planSlug,
      };

      final res = await RelaxApi.instance.post(
        '/billing/me/checkout-session',
        body: body,
      );

      if (!mounted) return;
      nav.pop(); // Close loading

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data is Map
            ? Map<String, dynamic>.from(res.data as Map)
            : <String, dynamic>{};
        showCheckoutSheet(
          context,
          data: data,
          planSlug: planSlug,
          onConfirmPayment: (sheetCtx, paymentId, isSepayActive) =>
              confirmPayment(
            parentCtx: context,
            sheetCtx: sheetCtx,
            paymentId: paymentId,
            isSepayActive: isSepayActive,
            onReload: _load,
          ),
        );
      } else {
        final msg =
            (res.data is Map ? res.data['message'] as String? : null) ??
                'Không tạo được phiên thanh toán.';
        if (context.mounted) {
          showSoftToast(context, message: context.t(msg), tone: SoftToastTone.error);
        }
      }
    } catch (e) {
      if (context.mounted) {
        nav.pop(); // Close loading
        showSoftToast(context,
            message: '${context.t('Lỗi:')} $e', tone: SoftToastTone.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Nâng cấp ✨'),
          style: TextStyle(
            color: context.appText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: RelaxColors.violet))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: RelaxColors.coral, size: 48),
                      const SizedBox(height: 12),
                      Text(context.t('Không tải được thông tin gói'),
                          style: TextStyle(color: context.mutedText)),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _load,
                        child: Text(context.t('Thử lại')),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    children: [
                      // Current plan card
                      CurrentPlanCard(
                        subscription: _subscription,
                        tierName: (tier) => tierDisplayName(context, tier),
                      ),
                      const SizedBox(height: 28),
                      // Available plans
                      Text(
                        context.t('CHỌN GÓI'),
                        style: const TextStyle(
                          color: RelaxColors.slate,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._plans.map((plan) {
                        final name = (plan['name'] ?? plan['slug'] ?? '') as String;
                        final desc = (plan['description'] ?? '') as String;
                        final price = plan['price'] ?? plan['priceVnd'] ?? 0;
                        final isCurrent = isCurrentPlan(plan, _subscription);
                        final features =
                            plan['features'] is List ? plan['features'] as List : [];
                        return PlanCard(
                          name: tierDisplayName(context, name),
                          description: context.t(desc),
                          price: formatPrice(context, price),
                          isCurrent: isCurrent,
                          features: features
                              .map((f) => f is String ? context.t(f) : '$f')
                              .toList(),
                          onTap: () => _checkout(plan),
                        );
                      }),
                      const SizedBox(height: 24),
                      // Payment history link
                      TextButton.icon(
                        onPressed: () => showPaymentHistorySheet(context),
                        icon: const Icon(Icons.receipt_long_outlined,
                            color: RelaxColors.violet),
                        label: Text(context.t('Lịch sử thanh toán'),
                            style: const TextStyle(color: RelaxColors.violet)),
                      ),
                    ],
                  ),
                ),
    );
  }
}
