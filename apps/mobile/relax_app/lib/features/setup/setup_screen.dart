import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/app_copy.dart';
import '../../app/theme.dart';
import '../../core/preferences.dart';
import '../../core/session.dart';
import '../../data/models/app_models.dart';
import '../../data/models/backend_models.dart';
import '../../data/services/device_service.dart';
import '../../data/services/billing_service.dart';
import '../../data/services/mobile_content_service.dart';
import '../../data/services/reminder_service.dart';
import '../../data/services/supabase_storage_service.dart';
import '../../data/services/users_service.dart';
import '../../shared/widgets/charts/mood_line_chart.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_button.dart';
import '../billing/checkout_screen.dart';
import '../legal/legal_screen.dart';
import '../relax/sheets/relax_sheets.dart';
import '../relax/sheets/stats_sheet.dart';

/// Setup screen — khớp đúng mockup hình 4 anh đã thiết kế.
///
/// Cấu trúc dọc:
///   1. Header "Setup ✦" + cat sleeping top-right
///   2. "Trang cá nhân" + profile card (avatar + tên + 4 info lines)
///   3. "Thông báo" + 4 time chips + Âm báo row + hint nhỏ
///   4. "Quy định & sử dụng" tappable row
///   5. "Thống kê tình trạng" với chart + side panel stress %
///   6. "Giao diện" + 3 pills Light/Dark/Customs + theme color
///   7. "Nạp thẻ / Nâng cấp" tappable với chip "Nạp ngay"
///   8. "Xóa tài khoản" red row
///   9. "Đăng xuất" row
///  10. Footer "MỘT SỐ LƯU Ý NHỎ" với 4 hints
class SetupScreen extends StatefulWidget {
  const SetupScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.content,
    required this.loadingContent,
    required this.contentError,
    required this.onRefreshContent,
    this.moodHistory = const [],
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final MobileContentSnapshot content;
  final bool loadingContent;
  final String? contentError;
  final VoidCallback onRefreshContent;
  final List<dynamic> moodHistory; // type kept loose to avoid import cycle

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _deviceService = DeviceCapabilityService();
  final _reminderService = ReminderService();
  final _usersService = UsersService();

  String _selectedTime = '21:00';
  String _themeTab = 'dark';
  String _soundChoice = 'Tiếng mèo con kêu';

  AppPreferences? _prefs;
  DeviceSnapshot? _device;
  bool _deviceLoading = true;
  bool _notificationRequesting = false;

  List<Reminder> _reminders = const [];
  bool _remindersBusy = false;

  @override
  void initState() {
    super.initState();
    _themeTab = widget.themeMode == ThemeMode.light ? 'light' : 'dark';
    _loadDevice();
    _loadPrefsAndReminders();
  }

  Future<void> _loadPrefsAndReminders() async {
    final p = await AppPreferences.instance();
    if (!mounted) return;
    setState(() {
      _prefs = p;
      _selectedTime = p.reminderTime;
      _soundChoice = p.soundChoice;
    });
    await _loadReminders();
  }

  Future<void> _loadReminders() async {
    final session = context.sessionOrNull;
    if (session == null || !session.isLoggedIn) return;
    try {
      final list = await _reminderService.list(
        accessToken: session.accessToken!,
      );
      if (!mounted) return;
      setState(() {
        _reminders = list;
        // sync selectedTime với reminder mới nhất nếu có
        if (list.isNotEmpty) _selectedTime = list.first.time;
      });
    } catch (_) {
      /* ignore — empty stays empty */
    }
  }

  /// Khi user tap chip giờ, POST reminder mới + xóa reminder cùng giờ cũ.
  /// Khi chưa login → chỉ save vào prefs cục bộ.
  Future<void> _selectTime(String time) async {
    final session = context.sessionOrNull;
    setState(() {
      _selectedTime = time;
      _remindersBusy = true;
    });
    await _prefs?.setReminderTime(time);

    if (session != null && session.isLoggedIn) {
      try {
        // Xóa các reminder cũ cùng time để tránh trùng
        for (final r in _reminders.where((r) => r.time == time)) {
          try {
            await _reminderService.delete(
              accessToken: session.accessToken!,
              id: r.id,
            );
          } catch (_) {}
        }
        // Tạo reminder mới
        final created = await _reminderService.create(
          accessToken: session.accessToken!,
          time: time,
        );
        if (!mounted) return;
        setState(() {
          _reminders = [
            created,
            ..._reminders.where((r) => r.id != created.id),
          ];
        });
        _toast(context, 'Đã đặt nhắc lúc $time ✦');
      } catch (e) {
        if (!mounted) return;
        _toast(context, 'Không lưu được nhắc nhở: $e');
      }
    } else {
      if (!mounted) return;
      _toast(context, 'Đã lưu trên thiết bị. Đăng nhập để đồng bộ ✦');
    }

    if (mounted) setState(() => _remindersBusy = false);
  }

  Future<void> _pickSound() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (ctx) => _SoundPicker(current: _soundChoice),
    );
    if (picked == null || !mounted) return;
    setState(() => _soundChoice = picked);
    await _prefs?.setSoundChoice(picked);
    if (!mounted) return;
    _toast(context, 'Đã chọn âm báo: $picked');
  }

  Future<void> _loadDevice() async {
    setState(() => _deviceLoading = true);
    try {
      final device = await _deviceService.load();
      if (!mounted) return;
      setState(() {
        _device = device;
        _deviceLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _deviceLoading = false);
    }
  }

  Future<void> _requestNotifications() async {
    setState(() => _notificationRequesting = true);
    try {
      final device = await _deviceService.requestNotifications();
      if (!mounted) return;
      setState(() => _device = device);
    } finally {
      if (mounted) setState(() => _notificationRequesting = false);
    }
  }

  Future<void> _refreshAll() async {
    widget.onRefreshContent();
    await Future.wait([_loadDevice(), _loadReminders()]);
  }

  Future<void> _saveProfile({
    String? name,
    String? phone,
    String? gender,
    String? socialUrl,
    int? birthYear,
    String? avatar,
  }) async {
    final session = context.sessionOrNull;
    final patch = <String, dynamic>{};
    if (name != null) patch['name'] = name;
    if (phone != null) patch['phone'] = phone;
    if (gender != null) patch['gender'] = gender;
    if (socialUrl != null) patch['socialUrl'] = socialUrl;
    if (birthYear != null) patch['birthYear'] = birthYear;
    if (avatar != null) patch['avatar'] = avatar;
    // Update local cache ngay để UI phản hồi
    await session?.updateCachedUser(patch);

    if (session != null && session.isLoggedIn) {
      try {
        final updated = await _usersService.updateMe(
          accessToken: session.accessToken!,
          name: name,
          phone: phone,
          gender: gender,
          socialUrl: socialUrl,
          birthYear: birthYear,
          avatar: avatar,
        );
        await session.updateCachedUser(updated);
        if (!mounted) return;
        _toast(context, 'Đã đồng bộ hồ sơ ✦');
      } catch (e) {
        if (!mounted) return;
        _toast(context, 'Lưu cục bộ thành công. Lỗi đồng bộ: $e');
      }
    } else {
      if (!mounted) return;
      _toast(context, 'Đã lưu trên thiết bị. Đăng nhập để đồng bộ ~');
    }
  }

  Future<void> _deleteAccount() async {
    final session = context.sessionOrNull;
    if (session == null || !session.isLoggedIn) {
      await session?.logout();
      return;
    }
    try {
      await _usersService.deleteMe(accessToken: session.accessToken!);
      await session.logout();
      if (!mounted) return;
      _toast(context, 'Tài khoản đã được xóa.');
    } catch (e) {
      if (!mounted) return;
      _toast(context, 'Xóa thất bại: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.sessionOrNull;
    final user = session?.user;
    final asset = widget.content.companionAsset;
    final featuredPlan = widget.content.billingPlans.isNotEmpty
        ? widget.content.billingPlans.first
        : null;

    return RefreshIndicator(
      onRefresh: _refreshAll,
      color: RelaxTheme.purple,
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _SetupHeader(onRefresh: _refreshAll),

          const SizedBox(height: 8),
          const _SectionLabel(
            icon: Icons.person_outline,
            label: 'Trang cá nhân',
          ),
          const SizedBox(height: 8),
          _SectionCard(
            child: _ProfileBody(
              user: user,
              assetName: asset?.name,
              avatarUrl: asset?.previewImageUrl ?? (user?['avatar'] as String?),
              onEdit: () =>
                  _showProfileSheet(context, user, onSave: _saveProfile),
            ),
          ),

          const SizedBox(height: 10),
          const _SectionLabel(
            icon: Icons.notifications_none_rounded,
            label: 'Thông báo',
          ),
          const SizedBox(height: 8),
          _SectionCard(
            child: _NotificationBody(
              selected: _selectedTime,
              onSelected: _selectTime,
              soundLabel: _soundChoice,
              onSoundTap: _pickSound,
              busy: _remindersBusy,
            ),
          ),

          const SizedBox(height: 10),
          _SectionCard(
            child: _DevicePermissionBody(
              device: _device,
              loading: _deviceLoading,
              requesting: _notificationRequesting,
              onReload: _loadDevice,
              onRequestNotifications: _requestNotifications,
            ),
          ),

          const SizedBox(height: 10),
          _SectionCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: _TapRow(
              icon: Icons.description_outlined,
              title: 'Quy định & sử dụng',
              subtitle: 'Điều khoản, chính sách & giấy phép',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LegalScreen())),
            ),
          ),

          const SizedBox(height: 10),
          const _SectionLabel(
            icon: Icons.bar_chart_rounded,
            label: 'Thống kê tình trạng',
          ),
          const SizedBox(height: 8),
          _SectionCard(
            child: _StatsBody(
              moodHistory: widget.moodHistory,
              onOpen: () => showStatsSheet(context),
            ),
          ),

          const SizedBox(height: 10),
          const _SectionLabel(icon: Icons.palette_outlined, label: 'Giao diện'),
          const SizedBox(height: 8),
          _SectionCard(
            child: _AppearanceBody(
              tab: _themeTab,
              onTabChanged: (tab) {
                setState(() => _themeTab = tab);
                if (tab == 'light') widget.onThemeChanged(ThemeMode.light);
                if (tab == 'dark') widget.onThemeChanged(ThemeMode.dark);
              },
              appTheme: widget.content.appTheme,
            ),
          ),

          const SizedBox(height: 10),
          _SectionCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: _TapRow(
              icon: Icons.credit_card_rounded,
              title: featuredPlan?.title ?? 'Nạp thẻ / Nâng cấp',
              subtitle: featuredPlan == null
                  ? 'Mở khóa tính năng nâng cao'
                  : featuredPlan.description,
              trailing: _PurpleChip(
                text: featuredPlan?.priceLabel ?? 'Nạp ngay',
              ),
              onTap: () =>
                  _showBillingSheet(context, widget.content.billingPlans),
            ),
          ),

          const SizedBox(height: 10),
          _SectionCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: _TapRow(
              icon: Icons.delete_outline_rounded,
              title: 'Xóa tài khoản',
              subtitle: 'Xóa vĩnh viễn toàn bộ dữ liệu của bạn',
              danger: true,
              onTap: () async {
                final navigator = Navigator.of(context);
                await showConfirmSheet(
                  context,
                  title: 'Xóa tài khoản?',
                  body: 'Mọi dữ liệu sẽ biến mất và không thể khôi phục.',
                  action: 'Xóa vĩnh viễn',
                  danger: true,
                  onConfirm: _deleteAccount,
                );
                if (session?.isLoggedIn == false && navigator.canPop()) {
                  navigator.popUntil((r) => r.isFirst);
                }
              },
            ),
          ),

          const SizedBox(height: 10),
          _SectionCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: _TapRow(
              icon: Icons.logout_rounded,
              title: 'Đăng xuất',
              subtitle: 'Đăng xuất khỏi tài khoản hiện tại',
              onTap: () async {
                final navigator = Navigator.of(context);
                await showConfirmSheet(
                  context,
                  title: 'Đăng xuất?',
                  body: 'Hẹn gặp lại nhé. Nhớ chăm sóc bản thân nha.',
                  action: 'Đăng xuất',
                  onConfirm: () async => session?.logout(),
                );
                if (session?.isLoggedIn == false && navigator.canPop()) {
                  navigator.popUntil((r) => r.isFirst);
                }
              },
            ),
          ),

          const SizedBox(height: 24),
          const _HintsFooter(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

void _toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

/// Tạo checkout session + mở WebView SePay.
Future<void> _startCheckout(
  BuildContext context,
  BackendBillingPlan plan,
) async {
  final session = context.sessionOrNull;
  if (session == null || !session.isLoggedIn) {
    _toast(context, 'Hãy đăng nhập để nâng cấp gói nha 💜');
    return;
  }
  // Đóng bottom sheet billing trước khi mở WebView
  Navigator.of(context).pop();

  CheckoutSession ckt;
  try {
    ckt = await BillingService().createCheckoutSession(
      accessToken: session.accessToken!,
      planName: plan.name,
      provider: 'MANUAL', // SePay default — backend sẽ trả URL nếu wire
    );
  } catch (e) {
    _toast(context, 'Không tạo được phiên thanh toán: $e');
    return;
  }
  if (!context.mounted) return;
  final ok = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => CheckoutScreen(session: ckt)),
  );
  if (!context.mounted) return;
  if (ok == true) {
    _toast(context, 'Cảm ơn bạn! Gói ${plan.title} đã được kích hoạt ✦');
  }
}

typedef _ProfileSaver =
    Future<void> Function({
      String? name,
      String? phone,
      String? gender,
      String? socialUrl,
      int? birthYear,
      String? avatar,
    });

Future<void> _showProfileSheet(
  BuildContext context,
  Map<String, dynamic>? user, {
  required _ProfileSaver onSave,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (sheetContext) => _ProfileSheet(user: user, onSave: onSave),
  );
}

class _ProfileSheet extends StatefulWidget {
  const _ProfileSheet({required this.user, required this.onSave});
  final Map<String, dynamic>? user;
  final _ProfileSaver onSave;

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  late final TextEditingController _nameCtrl = TextEditingController(
    text: (widget.user?['name'] ?? '').toString(),
  );
  late final TextEditingController _phoneCtrl = TextEditingController(
    text: (widget.user?['phone'] ?? '').toString(),
  );
  late final TextEditingController _linkCtrl = TextEditingController(
    text: (widget.user?['socialUrl'] ?? widget.user?['link'] ?? '').toString(),
  );
  late final TextEditingController _yearCtrl = TextEditingController(
    text: widget.user?['birthYear']?.toString() ?? '',
  );
  late String _gender = (widget.user?['gender'] ?? '').toString();
  late String? _avatarUrl = widget.user?['avatar'] as String?;
  bool _saving = false;
  bool _uploadingAvatar = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _linkCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final storage = SupabaseStorageService();
    if (!storage.configured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Supabase chưa được cấu hình — anh build với --dart-define=SUPABASE_URL=... và SUPABASE_ANON_KEY=...',
          ),
        ),
      );
      return;
    }
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (file == null || !mounted) return;

    setState(() => _uploadingAvatar = true);
    try {
      final bytes = await file.readAsBytes();
      final session = context.sessionOrNull;
      final userId = (session?.user?['id'] as String?) ?? 'guest';
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ext = file.name.split('.').last.toLowerCase();
      final url = await storage.upload(
        bucket: 'avatars',
        path: '$userId/avatar-$ts.$ext',
        bytes: bytes,
        contentType: 'image/$ext',
        userAccessToken: session?.accessToken,
      );
      if (!mounted) return;
      setState(() => _avatarUrl = url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã upload avatar mới ✦')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload thất bại: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final yearStr = _yearCtrl.text.trim();
    final year = int.tryParse(yearStr);
    final avatarChanged = _avatarUrl != widget.user?['avatar'];
    await widget.onSave(
      name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      socialUrl: _linkCtrl.text.trim(),
      gender: _gender.isEmpty ? null : _gender,
      birthYear: year,
      avatar: avatarChanged ? _avatarUrl : null,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trang cá nhân',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Cập nhật thông tin hiển thị trong app. Bạn có thể bỏ trống các mục không muốn chia sẻ.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            // Avatar with tap-to-upload
            Center(
              child: GestureDetector(
                onTap: _uploadingAvatar ? null : _pickAvatar,
                child: Stack(
                  children: [
                    CatAvatar(size: 92, imageUrl: _avatarUrl),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: RelaxTheme.purple,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: _uploadingAvatar
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên hiển thị',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yearCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'Năm sinh',
                      counterText: '',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _gender.isEmpty ? null : _gender,
                    decoration: const InputDecoration(
                      labelText: 'Giới tính',
                      prefixIcon: Icon(Icons.wc_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                      DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                      DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                    ],
                    onChanged: (v) => setState(() => _gender = v ?? ''),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                prefixIcon: Icon(Icons.call_outlined),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _linkCtrl,
              decoration: const InputDecoration(
                labelText: 'Liên kết cá nhân (linktr, IG, ...)',
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
            const SizedBox(height: 14),
            PixelButton(
              icon: _saving ? Icons.hourglass_top_rounded : Icons.save_rounded,
              label: _saving ? 'Đang lưu...' : 'Lưu hồ sơ',
              filled: true,
              onPressed: _saving ? () {} : _save,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showBillingSheet(
  BuildContext context,
  List<BackendBillingPlan> plans,
) {
  final paidPlans = plans.where((p) => p.effectivePrice > 0).toList();
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (sheetContext) {
      final height = MediaQuery.of(sheetContext).size.height * .8;
      return SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nâng cấp gói',
                      style: Theme.of(sheetContext).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Chọn một gói để mở khóa tính năng nâng cao. Thanh toán an toàn qua SePay.',
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              if (paidPlans.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Chưa có gói nâng cấp. Vui lòng thử lại sau ~',
                        textAlign: TextAlign.center,
                        style: Theme.of(sheetContext).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: paidPlans.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final plan = paidPlans[i];
                      final isPopular = i == 0;
                      return _PlanCard(plan: plan, popular: isPopular);
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.popular});
  final BackendBillingPlan plan;
  final bool popular;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: popular
            ? RelaxTheme.purple.withValues(alpha: .08)
            : context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: popular
              ? RelaxTheme.purple
              : RelaxTheme.lavender.withValues(alpha: .2),
          width: popular ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              if (popular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: RelaxTheme.purple,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '★ Phổ biến',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            plan.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                plan.priceLabel,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: RelaxTheme.lavender,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ ${plan.billingCycle.toLowerCase() == "annual" ? "năm" : "tháng"}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: context.relax.muted,
                  ),
                ),
              ),
            ],
          ),
          if (plan.features.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final f in plan.features.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: RelaxTheme.lavender,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        f,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: popular ? RelaxTheme.purple : null,
                foregroundColor: popular ? Colors.white : null,
              ),
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: const Text('Chọn gói này'),
              onPressed: () => _startCheckout(context, plan),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SECTIONS
// ════════════════════════════════════════════════════════════════════════════

class _SetupHeader extends StatelessWidget {
  const _SetupHeader({required this.onRefresh});
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Setup',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.auto_awesome,
                      color: RelaxTheme.lavender,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tùy chỉnh không gian của bạn ~',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Tải lại',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, color: RelaxTheme.lavender),
          ),
          const SizedBox(
            width: 86,
            height: 64,
            child: PixelCatScene(scene: CatScene.sleep, height: 64),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: RelaxTheme.lavender),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: RelaxTheme.lavender.withValues(alpha: .14),
          width: 1.2,
        ),
      ),
      child: child,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  PROFILE
// ════════════════════════════════════════════════════════════════════════════

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.user,
    required this.assetName,
    required this.avatarUrl,
    required this.onEdit,
  });

  final Map<String, dynamic>? user;
  final String? assetName;
  final String? avatarUrl;
  final VoidCallback onEdit;

  String get _name {
    final n = (user?['name'] as String?)?.trim();
    if (n != null && n.isNotEmpty) return n;
    return assetName ?? 'Người dùng';
  }

  int? get _age {
    final a = user?['age'] as num?;
    if (a != null) return a.toInt();
    final by = user?['birthYear'] as num?;
    if (by != null) return DateTime.now().year - by.toInt();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final phone = (user?['phone'] as String?)?.trim();
    final email = (user?['email'] as String?)?.trim();
    final social =
        (user?['socialUrl'] as String?)?.trim() ??
        (user?['link'] as String?)?.trim();
    final gender = (user?['gender'] as String?)?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Avatar with camera badge ──────────────────────────────────────
        Stack(
          children: [
            CatAvatar(size: 88, imageUrl: avatarUrl),
            Positioned(
              right: -2,
              bottom: -2,
              child: GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: RelaxTheme.purple,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        // ── Info column ───────────────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onEdit,
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: context.relax.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (_age != null || (gender != null && gender.isNotEmpty))
                _ProfileLine(
                  icon: Icons.cake_outlined,
                  text: [
                    if (_age != null) 'Tuổi: $_age',
                    if (gender != null && gender.isNotEmpty) gender,
                  ].join('   |   '),
                ),
              if (phone != null && phone.isNotEmpty)
                _ProfileLine(icon: Icons.call_outlined, text: phone),
              if (email != null && email.isNotEmpty)
                _ProfileLine(icon: Icons.mail_outline_rounded, text: email),
              if (social != null && social.isNotEmpty)
                _ProfileLine(icon: Icons.link_rounded, text: social),
              if ((_age == null) &&
                  (phone == null || phone.isEmpty) &&
                  (email == null || email.isEmpty) &&
                  (social == null || social.isEmpty))
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Bấm bút chì để thêm thông tin ~',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: context.relax.muted),
      ],
    );
  }
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: RelaxTheme.lavender),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  NOTIFICATION
// ════════════════════════════════════════════════════════════════════════════

class _NotificationBody extends StatelessWidget {
  const _NotificationBody({
    required this.selected,
    required this.onSelected,
    required this.soundLabel,
    required this.onSoundTap,
    this.busy = false,
  });

  final String selected;
  final ValueChanged<String> onSelected;
  final String soundLabel;
  final VoidCallback onSoundTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn khung giờ bạn muốn nhận thông báo nhé ~',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TimeChip(
                time: '17:00',
                selected: selected == '17:00',
                onTap: () => onSelected('17:00'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TimeChip(
                time: '19:00',
                selected: selected == '19:00',
                onTap: () => onSelected('19:00'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TimeChip(
                time: '21:00',
                selected: selected == '21:00',
                onTap: () => onSelected('21:00'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ExpandChip(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 21, minute: 0),
                  );
                  if (picked == null) return;
                  onSelected(
                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                  );
                },
              ),
            ),
          ],
        ),
        if (busy)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Đang lưu nhắc nhở...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: context.relax.muted,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        _SoundRow(soundLabel: soundLabel, onTap: onSoundTap),
        const SizedBox(height: 8),
        Text(
          '✦ Bạn ≤ 32 tuổi mới có thể chọn khung giờ sau 21:00',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: context.relax.muted,
          ),
        ),
      ],
    );
  }
}

class _DevicePermissionBody extends StatelessWidget {
  const _DevicePermissionBody({
    required this.device,
    required this.loading,
    required this.requesting,
    required this.onReload,
    required this.onRequestNotifications,
  });

  final DeviceSnapshot? device;
  final bool loading;
  final bool requesting;
  final VoidCallback onReload;
  final VoidCallback onRequestNotifications;

  @override
  Widget build(BuildContext context) {
    final status = device?.notificationLabel ?? 'Đang kiểm tra';
    final allowed = device?.notificationsAllowed == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.devices_other_rounded,
              color: RelaxTheme.lavender,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Thiết bị & quyền thông báo',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Tải lại',
              onPressed: loading ? null : onReload,
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _MiniInfoGrid(
          items: [
            _MiniInfoItem(
              icon: allowed
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_outlined,
              label: 'Thông báo',
              value: status,
              highlight: allowed,
            ),
            _MiniInfoItem(
              icon: Icons.smartphone_rounded,
              label: 'Thiết bị',
              value: device?.deviceName ?? 'Đang đọc thông tin',
            ),
            _MiniInfoItem(
              icon: Icons.memory_rounded,
              label: 'Nền tảng',
              value: device == null
                  ? 'Đang kiểm tra'
                  : '${device!.platform} · ${device!.osVersion}',
            ),
            _MiniInfoItem(
              icon: Icons.new_releases_outlined,
              label: 'Phiên bản app',
              value: device?.appLabel ?? 'Đang kiểm tra',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PixelButton(
                icon: Icons.notifications_active_outlined,
                label: requesting ? 'Đang xin quyền...' : 'Cho phép thông báo',
                filled: !allowed,
                onPressed: requesting ? () {} : onRequestNotifications,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniInfoGrid extends StatelessWidget {
  const _MiniInfoGrid({required this.items});

  final List<_MiniInfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _MiniInfoCard(item: items[row * 2])),
              const SizedBox(width: 8),
              Expanded(child: _MiniInfoCard(item: items[row * 2 + 1])),
            ],
          ),
        ],
      ],
    );
  }
}

class _MiniInfoItem {
  const _MiniInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
}

class _MiniInfoCard extends StatelessWidget {
  const _MiniInfoCard({required this.item});

  final _MiniInfoItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.highlight
        ? const Color(0xFF48D3A8)
        : RelaxTheme.lavender;
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: item.highlight
              ? color.withValues(alpha: .55)
              : context.relax.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: color, size: 18),
          const Spacer(),
          Text(
            item.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            item.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.time,
    required this.selected,
    required this.onTap,
  });
  final String time;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? RelaxTheme.purple : context.relax.surfaceSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? RelaxTheme.purple : context.relax.border,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: selected ? Colors.white : null,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ],
            ),
            Text(
              time,
              style: TextStyle(
                color: selected
                    ? Colors.white.withValues(alpha: .7)
                    : context.relax.muted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandChip extends StatelessWidget {
  const _ExpandChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: context.relax.surfaceSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: RelaxTheme.lavender.withValues(alpha: .4),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: const [
            Icon(Icons.add, size: 16, color: RelaxTheme.lavender),
            Text(
              'Mở rộng',
              style: TextStyle(
                color: RelaxTheme.lavender,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundRow extends StatelessWidget {
  const _SoundRow({required this.soundLabel, required this.onTap});
  final String soundLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: context.relax.surfaceSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.volume_up_outlined,
                size: 18,
                color: RelaxTheme.lavender,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Âm báo: $soundLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.relax.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet chọn âm báo. Trả về sound name khi user chọn.
class _SoundPicker extends StatelessWidget {
  const _SoundPicker({required this.current});
  final String current;

  static const _sounds = <(String, IconData)>[
    ('Tiếng mèo con kêu', Icons.pets_rounded),
    ('Tiếng chim hót', Icons.flutter_dash_rounded),
    ('Tiếng nước chảy', Icons.water_drop_rounded),
    ('Tiếng chuông gió', Icons.notifications_active_rounded),
    ('Tiếng đàn nhẹ', Icons.music_note_rounded),
    ('Im lặng', Icons.volume_off_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chọn âm báo', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Âm thanh nhẹ nhàng để nhắc bạn ~',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          for (final s in _sounds)
            _SoundOption(
              icon: s.$2,
              label: s.$1,
              selected: s.$1 == current,
              onTap: () => Navigator.of(context).pop(s.$1),
            ),
        ],
      ),
    );
  }
}

class _SoundOption extends StatelessWidget {
  const _SoundOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? RelaxTheme.purple.withValues(alpha: .12)
              : context.relax.surfaceSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? RelaxTheme.purple
                : RelaxTheme.lavender.withValues(alpha: .14),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: RelaxTheme.lavender),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: RelaxTheme.purple,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  STATS BODY (inline chart + side panel)
// ════════════════════════════════════════════════════════════════════════════

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.moodHistory, required this.onOpen});
  final List<dynamic> moodHistory;
  final VoidCallback onOpen;

  /// Chuẩn hóa 7 ngày cuối thành danh sách giá trị từ 0 đến 1.
  List<double> get _chartData {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final counts = List<int>.filled(7, 0);
    for (final c in moodHistory) {
      try {
        final createdAt = c.createdAt as DateTime;
        final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
        final diff = today.difference(day).inDays;
        if (diff >= 0 && diff < 7) counts[6 - diff]++;
      } catch (_) {}
    }
    final max = counts.fold<int>(0, (a, b) => a > b ? a : b);
    if (max == 0) return List.filled(7, 0.0);
    return counts.map((c) => c / max).toList();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Xem lại hành trình cảm xúc của bạn',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: RelaxTheme.purple.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Theo tuần',
                      style: TextStyle(
                        color: RelaxTheme.lavender,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 14,
                      color: RelaxTheme.lavender,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: MoodLineChart(compact: true, data: _chartData),
              ),
              if (moodHistory.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _StressDropPanel()),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Side panel "Tuần này / Giảm stress X% / So với tuần trước".
class _StressDropPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: RelaxTheme.purple.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tuần này',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bấm xem chi tiết',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 10,
              color: context.relax.muted,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                size: 14,
                color: RelaxTheme.lavender,
              ),
              const SizedBox(width: 4),
              Text(
                'Mở rộng',
                style: TextStyle(
                  color: RelaxTheme.lavender,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  APPEARANCE (3 pills)
// ════════════════════════════════════════════════════════════════════════════

class _AppearanceBody extends StatelessWidget {
  const _AppearanceBody({
    required this.tab,
    required this.onTabChanged,
    required this.appTheme,
  });
  final String tab;
  final ValueChanged<String> onTabChanged;
  final BackendAppTheme? appTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thay đổi màu sắc của app',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ThemePill(
                icon: Icons.light_mode_rounded,
                label: 'Light',
                selected: tab == 'light',
                onTap: () => onTabChanged('light'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ThemePill(
                icon: Icons.dark_mode_rounded,
                label: 'Dark',
                selected: tab == 'dark',
                onTap: () => onTabChanged('dark'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ThemePill(
                icon: Icons.auto_awesome,
                label: 'Customs',
                selected: tab == 'custom',
                onTap: () => onTabChanged('custom'),
              ),
            ),
          ],
        ),
        if (appTheme != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ColorSwatch(
                  color: _hex(appTheme!.primaryColor, RelaxTheme.purple),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ColorSwatch(
                  color: _hex(appTheme!.accentColor, RelaxTheme.lavender),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ThemePill extends StatelessWidget {
  const _ThemePill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? RelaxTheme.purple : context.relax.surfaceSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? RelaxTheme.purple : context.relax.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? Colors.white : context.relax.muted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : context.relax.muted,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TAP ROW & CHIPS
// ════════════════════════════════════════════════════════════════════════════

class _TapRow extends StatelessWidget {
  const _TapRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.danger = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? context.relax.danger : RelaxTheme.lavender;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: danger ? color : null,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 11.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.relax.muted,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}

class _PurpleChip extends StatelessWidget {
  const _PurpleChip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: RelaxTheme.purple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  FOOTER HINTS
// ════════════════════════════════════════════════════════════════════════════

class _HintsFooter extends StatelessWidget {
  const _HintsFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Divider(color: context.relax.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '✦ MỘT SỐ LƯU Ý NHỎ ✦',
                  style: TextStyle(
                    fontSize: 11,
                    color: RelaxTheme.lavender,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Expanded(child: Divider(color: context.relax.border)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: _HintCol(
                  icon: Icons.notifications_active_outlined,
                  title: 'Thông báo\nthông minh',
                  body: 'Sau 21:00 sẽ hạn chế thông báo nếu bạn ≤ 32 tuổi ~',
                ),
              ),
              Expanded(
                child: _HintCol(
                  icon: Icons.volume_up_outlined,
                  title: 'Âm thanh\ndễ thương',
                  body:
                      'Chỉ dùng tiếng mèo con kêu để thông báo, nhẹ nhàng và không gây khó chịu.',
                ),
              ),
              Expanded(
                child: _HintCol(
                  icon: Icons.bar_chart_rounded,
                  title: 'Thống kê\ntrực quan',
                  body:
                      'Theo dõi cảm xúc theo ngày, tuần, tháng để bạn hiểu bản thân mình hơn mỗi ngày.',
                ),
              ),
              Expanded(
                child: _HintCol(
                  icon: Icons.lock_outline_rounded,
                  title: 'Quyền\nriêng tư',
                  body:
                      'Dữ liệu của bạn được bảo mật an toàn. Bạn toàn quyền kiểm soát tài khoản của mình.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HintCol extends StatelessWidget {
  const _HintCol({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: RelaxTheme.purple.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: RelaxTheme.lavender),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              color: RelaxTheme.lavender,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 9.5, height: 1.3),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ════════════════════════════════════════════════════════════════════════════

Color _hex(String s, Color fb) {
  final v = s.replaceFirst('#', '').trim();
  if (v.length != 6) return fb;
  final n = int.tryParse('FF$v', radix: 16);
  return n == null ? fb : Color(n);
}
