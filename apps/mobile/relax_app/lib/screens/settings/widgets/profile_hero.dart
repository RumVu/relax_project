import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../core/api_client.dart';
import '../../../core/auth_state.dart';
import '../../../core/locale_controller.dart';
import '../../../widgets/soft_toast.dart';

class ProfileHero extends StatefulWidget {
  const ProfileHero({
    super.key,
    required this.name,
    required this.email,
    required this.avatar,
    required this.role,
  });
  final String name;
  final String email;
  final String? avatar;
  final String role;

  @override
  State<ProfileHero> createState() => _ProfileHeroState();
}

class _ProfileHeroState extends State<ProfileHero> {
  bool _uploading = false;
  String? _birthday;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await RelaxApi.instance.get('/user-profiles/me/profile');
      if (res.statusCode == 200 && res.data is Map) {
        final birthdayStr = res.data['birthday'] as String?;
        if (mounted) {
          setState(() {
            _birthday = birthdayStr;
            _loadingProfile = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingProfile = false);
      }
    }
  }

  String _formatBirthday(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _editBirthday() async {
    DateTime initial = DateTime.now();
    if (_birthday != null) {
      initial = DateTime.tryParse(_birthday!) ?? DateTime.now();
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: RelaxColors.violet,
              onPrimary: Colors.white,
              surface: context.surface,
              onSurface: context.appText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final res = await RelaxApi.instance.patch(
        '/user-profiles/me/profile',
        body: {'birthday': picked.toUtc().toIso8601String()},
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          setState(() {
            _birthday = picked.toUtc().toIso8601String();
          });
          showSoftToast(context,
              message: context.t('Cập nhật ngày sinh thành công!'),
              tone: SoftToastTone.success);
        }
      } else {
        if (mounted) {
          showSoftToast(context,
              message: context.t('Cập nhật ngày sinh thất bại.'),
              tone: SoftToastTone.error);
        }
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: '${context.t('Lỗi:')} $e', tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (file == null) return;

      setState(() => _uploading = true);

      if (!mounted) return;
      final auth = context.read<AuthState>();
      final success = await auth.updateAvatar(file.path);

      if (mounted) {
        setState(() => _uploading = false);
        if (success) {
          showSoftToast(context,
              message: context.t('Cập nhật ảnh đại diện thành công!'),
              tone: SoftToastTone.success);
        } else {
          showSoftToast(context,
              message: context.t('Cập nhật ảnh đại diện thất bại.'),
              tone: SoftToastTone.error);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        showSoftToast(context,
            message: '${context.t('Lỗi:')} $e', tone: SoftToastTone.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [RelaxColors.violet, RelaxColors.plum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: RelaxColors.violet.withValues(alpha: 0.3),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _uploading ? null : _pickAndUploadAvatar,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  foregroundImage:
                      widget.avatar != null ? NetworkImage(widget.avatar!) : null,
                  child: Text(
                    widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: RelaxColors.violet,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                ),
                if (_uploading)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 12,
                        color: RelaxColors.violet,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _editName(context, widget.name),
                      child: const Icon(Icons.edit_outlined,
                          color: Colors.white70, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _loadingProfile
                    ? const SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Colors.white70,
                        ),
                      )
                    : GestureDetector(
                        onTap: _uploading ? null : _editBirthday,
                        child: Row(
                          children: [
                            const Icon(Icons.cake_outlined,
                                color: Colors.white70, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              _birthday != null
                                  ? _formatBirthday(_birthday!)
                                  : context.t('Thiết lập ngày sinh 🎂'),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.role,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    (() {
                      final auth = context.watch<AuthState>();
                      final user = auth.user;
                      final subs = user?['subscriptions'] as List?;
                      final sub = (subs != null && subs.isNotEmpty) ? subs.first as Map? : null;
                      final planName = (sub?['planName'] as String?) ?? 'FREE';
                      final subStatus = (sub?['status'] as String?) ?? 'ACTIVE';
                      final isPremium = planName.toUpperCase() != 'FREE' && subStatus.toUpperCase() == 'ACTIVE';

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPremium
                              ? RelaxColors.sun.withValues(alpha: 0.8)
                              : Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPremium) ...[
                              const Icon(Icons.star, color: Colors.white, size: 10),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              isPremium ? planName.toUpperCase().replaceAll('_', ' ') : 'GÓI FREE',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      );
                    })(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context, String current) async {
    final ctrl = TextEditingController(text: current);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t('Đổi tên hiển thị')),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 50,
          decoration: InputDecoration(hintText: context.t('Tên hiển thị')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.t('Hủy')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(context.t('Lưu')),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == current) return;
    if (!context.mounted) return;
    final ok = await context.read<AuthState>().updateDisplayName(newName);
    if (!context.mounted) return;
    showSoftToast(context,
        message: ok ? context.t('Đã đổi tên hiển thị') : context.t('Không đổi được tên'),
        tone: ok ? SoftToastTone.success : SoftToastTone.error);
  }
}
