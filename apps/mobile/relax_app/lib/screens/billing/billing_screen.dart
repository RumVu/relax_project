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

    final price = plan['price'] ?? plan['amount'] ?? 0;
    final isFree = price == 0 || price == '0' || planSlug.toUpperCase() == 'FREE';

    if (isFree) {
      await _confirmDowngrade(planSlug);
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

  Future<void> _confirmDowngrade(String planSlug) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.t('Xác nhận hạ gói')),
        content: Text(ctx.t(
            'Bạn đồng ý với việc hạ gói chứ? Điều này sẽ không thể hoàn tác đâu nha.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.t('Huỷ')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.t('Xác nhận'),
                style: const TextStyle(color: RelaxColors.coral, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final res = await RelaxApi.instance.post(
        '/billing/me/downgrade',
        body: {'planName': planSlug},
      );
      if (mounted) {
        if (res.data is Map) {
          final data = Map<String, dynamic>.from(res.data as Map);
          setState(() {
            _subscription = {
              'subscription': data['subscription'],
              'providerStatus': _subscription?['providerStatus'],
            };
          });
        }
        showSoftToast(context,
            message: context.t('Đã hạ gói thành công!'),
            tone: SoftToastTone.success);
        await _load();
      }
    } catch (e) {
      if (mounted) {
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
                      const SizedBox(height: 24),
                      const _FeatureComparisonSection(),
                    ],
                  ),
                ),
    );
  }
}

class _FeatureComparisonSection extends StatefulWidget {
  const _FeatureComparisonSection();

  @override
  State<_FeatureComparisonSection> createState() =>
      _FeatureComparisonSectionState();
}

class _FeatureComparisonSectionState extends State<_FeatureComparisonSection> {
  List<Map<String, dynamic>> _features = [];
  String _plan = 'FREE';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await RelaxApi.instance.get('/entitlements/me');
      if (res.data is Map && mounted) {
        final data = res.data as Map<String, dynamic>;
        setState(() {
          _features = (data['features'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              [];
          _plan = data['plan'] as String? ?? 'FREE';
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _features.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t('SO SÁNH TÍNH NĂNG'),
          style: const TextStyle(
            color: RelaxColors.slate,
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.fieldBorder),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: RelaxColors.violet.withValues(alpha: 0.06),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(context.t('Tính năng'),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: context.appText)),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(context.t('Free'),
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: context.mutedText)),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text('Pro',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: RelaxColors.violet)),
                      ),
                    ),
                  ],
                ),
              ),
              ..._features.map((f) {
                final label = f['label'] as String? ?? '';
                final free = f['free'] as bool? ?? false;
                final premium = f['premium'] as bool? ?? false;
                final unlocked = f['unlocked'] as bool? ?? false;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: context.fieldBorder, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          context.t(label),
                          style: TextStyle(
                            fontSize: 13,
                            color: unlocked
                                ? context.appText
                                : context.mutedText,
                            fontWeight:
                                unlocked ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Icon(
                            free
                                ? Icons.check_circle
                                : Icons.remove_circle_outline,
                            color:
                                free ? RelaxColors.mint : context.mutedText,
                            size: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Icon(
                            premium
                                ? Icons.check_circle
                                : Icons.remove_circle_outline,
                            color: premium
                                ? RelaxColors.violet
                                : context.mutedText,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '${context.t('Gói hiện tại:')} $_plan',
            style: TextStyle(
              color: context.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
