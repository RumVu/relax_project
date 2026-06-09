import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../core/auth_state.dart';
import '../core/locale_controller.dart';
import '../core/theme.dart';
import '../widgets/soft_toast.dart';

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

  String _formatPrice(dynamic price) {
    if (price == null) return context.t('Miễn phí');
    final n = (price is num) ? price.toInt() : int.tryParse('$price') ?? 0;
    if (n == 0) return context.t('Miễn phí');
    // Format VND with dot separator
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()}đ';
  }

  String _tierDisplayName(String? tier) {
    switch (tier?.toUpperCase()) {
      case 'CHILL_PLUS':
        return 'Chill+';
      case 'CHILL_PLUS_ANNUAL':
        return context.t('Chill+ Năm');
      case 'PREMIUM':
        return 'Premium';
      case 'FREE':
        return context.t('Miễn phí');
      default:
        return tier ?? context.t('Miễn phí');
    }
  }

  bool _isCurrentPlan(Map<String, dynamic> plan) {
    final planTier = (plan['slug'] ?? plan['name'] ?? '') as String;
    final subObj = _subscription?['subscription'] as Map?;
    final currentTier = (subObj?['planName'] ?? subObj?['plan'] ?? subObj?['tier'] ?? _subscription?['tier'] ?? _subscription?['plan'] ?? 'FREE') as String;
    return planTier.toUpperCase() == currentTier.toUpperCase();
  }

  Future<void> _checkout(Map<String, dynamic> plan) async {
    final planSlug = (plan['slug'] ?? plan['name'] ?? '') as String;

    if (_isCurrentPlan(plan)) {
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
        _showCheckoutInfo(data, planSlug);
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

  void _showCheckoutInfo(Map<String, dynamic> data, String planSlug) {
    final checkout = data['checkout'] is Map ? Map<String, dynamic>.from(data['checkout'] as Map) : null;
    final payment = data['payment'] is Map ? Map<String, dynamic>.from(data['payment'] as Map) : null;

    final paymentId = (data['paymentId'] ?? payment?['id'] ?? checkout?['paymentId']) as String?;
    final transferContent = (data['transferContent'] ?? checkout?['transferContent'] ?? (payment != null ? 'RELAX${payment['id']}' : null)) as String?;
    final bankAccount = (data['bankAccount'] ?? checkout?['bankAccount'] ?? checkout?['accountNo']) as String?;
    final bankName = (data['bankName'] ?? checkout?['bankName'] ?? checkout?['bankId']) as String?;
    final amount = data['amount'] ?? checkout?['amount'] ?? payment?['amount'];
    final qrUrl = (data['qrUrl'] ?? checkout?['qrUrl'] ?? checkout?['qrCodeUrl']) as String?;
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
              context.t('Thanh toán gói {tier}', {'tier': _tierDisplayName(planSlug)}),
              style: TextStyle(
                color: ctx.appText,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            if (bankName != null)
              _InfoRow(label: context.t('Ngân hàng'), value: bankName),
            if (bankAccount != null)
              _InfoRow(
                label: context.t('Số tài khoản'),
                value: bankAccount,
                copyValue: bankAccount,
              ),
            if (amount != null)
              _InfoRow(
                label: context.t('Số tiền'),
                value: _formatPrice(amount),
                copyValue: amount.toString(),
              ),
            if (transferContent != null)
              _InfoRow(
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
              context.t('Sau khi chuyển khoản, hệ thống sẽ tự xác nhận trong vài phút.'),
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
                  onPressed: () => _confirmPayment(ctx, paymentId, isSepayActive),
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

  Future<void> _confirmPayment(BuildContext sheetCtx, String paymentId, bool isSepayActive) async {
    final parentCtx = context;
    final successMsg = parentCtx.t('Thanh toán thành công! Gói đã được kích hoạt.');
    final confirmDevMsg = parentCtx.t('Đã xác nhận! Gói (DEV) đã được kích hoạt.');
    final errorMsgPrefix = parentCtx.t('Lỗi:');
    final notReceivedMsgTitle = parentCtx.t('Chưa nhận được giao dịch');
    final notReceivedMsgContent = parentCtx.t('Hệ thống chưa ghi nhận được khoản chuyển của bạn. Vui lòng kiểm tra lại số tài khoản, số tiền và nội dung chuyển khoản thô đã đúng chưa.\n\nNếu bạn đã chuyển khoản thành công, vui lòng chờ 1-2 phút hoặc liên hệ với admin để được hỗ trợ.');
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
                    context.t('Đang kiểm tra giao dịch...'),
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
          final res = await RelaxApi.instance.get('/billing/me/payments/$paymentId');
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
              message: successMsg,
              tone: SoftToastTone.success);
          parentCtx.read<AuthState>().refreshUser();
        }
        _load(); // Refresh local screen details
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
                message: confirmDevMsg,
                tone: SoftToastTone.success);
            parentCtx.read<AuthState>().refreshUser();
          }
          _load();
        } else {
          final msg =
              (res.data is Map ? res.data['message'] as String? : null) ??
                  'Chưa xác nhận được — hệ thống sẽ tự kiểm tra.';
          if (parentCtx.mounted) {
            showSoftToast(parentCtx, message: parentCtx.t(msg), tone: SoftToastTone.info);
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
                      _CurrentPlanCard(
                        subscription: _subscription,
                        tierName: _tierDisplayName,
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
                        final isCurrent = _isCurrentPlan(plan);
                        final features =
                            plan['features'] is List ? plan['features'] as List : [];
                        return _PlanCard(
                          name: _tierDisplayName(name),
                          description: context.t(desc),
                          price: _formatPrice(price),
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
                        onPressed: () => _showPaymentHistory(context),
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

  Future<void> _showPaymentHistory(BuildContext ctx) async {
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
                        title: Text(_formatPrice(amount),
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
        showSoftToast(ctx, message: '$errorMsgPrefix $e', tone: SoftToastTone.error);
      }
    }
  }
}

/// Card hiển thị gói hiện tại.
class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({
    required this.subscription,
    required this.tierName,
  });
  final Map<String, dynamic>? subscription;
  final String Function(String?) tierName;

  @override
  Widget build(BuildContext context) {
    final subObj = subscription?['subscription'] as Map?;
    final tier = (subObj?['planName'] ?? subObj?['plan'] ?? subObj?['tier'] ?? subscription?['tier'] ?? subscription?['plan'] ?? 'FREE') as String;
    final isFree = tier.toUpperCase() == 'FREE';
    final expiresAt = (subObj?['endDate'] ?? subObj?['expiresAt'] ?? subscription?['expiresAt'] ?? subscription?['endDate']) as String?;
    final expDate =
        expiresAt != null ? DateTime.tryParse(expiresAt) : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFree
              ? [RelaxColors.slate, const Color(0xFF5a6072)]
              : [RelaxColors.violet, RelaxColors.plum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isFree ? RelaxColors.slate : RelaxColors.violet)
                .withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isFree ? Icons.person_outline : Icons.workspace_premium,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                context.t('Gói hiện tại'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tierName(tier),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
          if (expDate != null) ...[
            const SizedBox(height: 6),
            Text(
              '${context.t('Hết hạn:')} ${expDate.day}/${expDate.month}/${expDate.year}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
          if (isFree) ...[
            const SizedBox(height: 10),
            Text(
              context.t('Nâng cấp để mở khóa toàn bộ tính năng!'),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card gói đăng ký.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.description,
    required this.price,
    required this.isCurrent,
    required this.features,
    required this.onTap,
  });
  final String name;
  final String description;
  final String price;
  final bool isCurrent;
  final List<String> features;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? RelaxColors.violet : context.fieldBorder,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: context.appText,
                  ),
                ),
              ),
              if (isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: RelaxColors.violet.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    context.t('Đang dùng'),
                    style: const TextStyle(
                      color: RelaxColors.violet,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(description,
                style: TextStyle(color: context.mutedText, fontSize: 13)),
          ],
          const SizedBox(height: 12),
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: context.appText,
            ),
          ),
          if (features.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 16, color: RelaxColors.mint),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(f,
                            style: TextStyle(
                                color: context.appText, fontSize: 13)),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCurrent ? context.surfaceAlt : RelaxColors.violet,
                foregroundColor: isCurrent ? context.mutedText : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onTap,
              child: Text(
                isCurrent ? context.t('Gói hiện tại') : context.t('Chọn gói này'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dòng thông tin trong bottom sheet thanh toán.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.copyValue,
  });
  final String label;
  final String value;
  final String? copyValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: context.mutedText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: context.appText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (copyValue != null)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: copyValue!));
                showSoftToast(
                  context,
                  message: context.t('Đã sao chép {label}', {'label': label}),
                  tone: SoftToastTone.success,
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Icon(
                  Icons.copy,
                  size: 16,
                  color: RelaxColors.violet,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
