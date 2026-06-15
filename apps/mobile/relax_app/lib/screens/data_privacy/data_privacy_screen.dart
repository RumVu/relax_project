import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';

class DataPrivacyScreen extends StatefulWidget {
  const DataPrivacyScreen({super.key});

  @override
  State<DataPrivacyScreen> createState() => _DataPrivacyScreenState();
}

class _DataPrivacyScreenState extends State<DataPrivacyScreen> {
  Map<String, dynamic>? _summary;
  bool _loading = true;
  bool _exporting = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final res = await RelaxApi.instance.get('/privacy/summary');
      if (mounted) {
        setState(() {
          _summary = res.data is Map ? Map<String, dynamic>.from(res.data as Map) : {};
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _exportData() async {
    setState(() => _exporting = true);
    try {
      final res = await RelaxApi.instance.get('/privacy/export', query: {'format': 'json'});
      final jsonStr = const JsonEncoder.withIndent('  ').convert(res.data);

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final file = File('${dir.path}/relax_data_export_$timestamp.json');
      await file.writeAsString(jsonStr);

      if (mounted) {
        showSoftToast(context,
            message: context.t('Đã xuất dữ liệu!'), tone: SoftToastTone.success);
        await Share.shareXFiles([XFile(file.path)], text: 'Relax App Data Export');
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: '${context.t('Lỗi:')} $e', tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _deleteCategory(String category, String label) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t('Xóa $label?')),
        content: Text(context.t('Hành động này không thể hoàn tác. Tất cả $label sẽ bị xóa vĩnh viễn.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.t('Hủy')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: RelaxColors.coral),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.t('Xóa'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _deleting = true);
    try {
      await RelaxApi.instance.delete('/privacy/$category');
      if (mounted) {
        showSoftToast(context,
            message: context.t('Đã xóa $label'), tone: SoftToastTone.success);
      }
      await _loadSummary();
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: '${context.t('Lỗi:')} $e', tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
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
          context.t('Dữ liệu & Quyền riêng tư'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: RelaxColors.violet))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                // GDPR notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: RelaxColors.violet.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: RelaxColors.violet.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shield_outlined, color: RelaxColors.violet, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            context.t('Quyền của bạn'),
                            style: TextStyle(
                              color: context.appText,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.t('Bạn có toàn quyền kiểm soát dữ liệu cá nhân. '
                            'Bạn có thể xem, tải xuống hoặc xóa dữ liệu bất cứ lúc nào.'),
                        style: TextStyle(color: context.mutedText, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Data summary
                Text(
                  context.t('Dữ liệu của bạn'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 12),
                if (_summary != null)
                  ..._summary!.entries.map((e) {
                    final label = _categoryLabel(e.key);
                    final count = (e.value as num?)?.toInt() ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: context.surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.fieldBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(_categoryIcon(e.key), color: RelaxColors.violet, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: context.appText,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: RelaxColors.violet.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: RelaxColors.violet,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 24),

                // Export button
                Text(
                  context.t('Xuất dữ liệu'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  context.t('Tải xuống toàn bộ dữ liệu cá nhân dưới dạng JSON.'),
                  style: TextStyle(color: context.mutedText, fontSize: 12),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _exporting ? null : _exportData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RelaxColors.violet,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _exporting
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.download),
                    label: Text(
                      context.t('Tải xuống dữ liệu (JSON)'),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Delete sections
                Text(
                  context.t('Xóa dữ liệu'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: RelaxColors.coral),
                ),
                const SizedBox(height: 8),
                Text(
                  context.t('Xóa từng loại dữ liệu. Hành động không thể hoàn tác.'),
                  style: TextStyle(color: context.mutedText, fontSize: 12),
                ),
                const SizedBox(height: 12),
                _DeleteRow(
                  label: context.t('Nhật ký'),
                  icon: Icons.book_outlined,
                  onDelete: _deleting ? null : () => _deleteCategory('journals', 'nhật ký'),
                ),
                _DeleteRow(
                  label: context.t('Lịch sử mood'),
                  icon: Icons.mood_outlined,
                  onDelete: _deleting ? null : () => _deleteCategory('mood-history', 'lịch sử mood'),
                ),
                _DeleteRow(
                  label: context.t('Phiên thư giãn'),
                  icon: Icons.spa_outlined,
                  onDelete: _deleting ? null : () => _deleteCategory('sessions', 'phiên thư giãn'),
                ),
              ],
            ),
    );
  }

  String _categoryLabel(String key) {
    const labels = {
      'journals': 'Nhật ký',
      'moodCheckins': 'Mood check-in',
      'relaxSessions': 'Phiên thư giãn',
      'meditationSessions': 'Thiền',
      'breathingSessions': 'Bài thở',
      'sleepSessions': 'Giấc ngủ',
      'soundSessions': 'Phiên âm thanh',
      'companionInteractions': 'Tương tác linh thú',
      'notifications': 'Thông báo',
      'feedEntries': 'Bài viết',
    };
    return labels[key] ?? key;
  }

  IconData _categoryIcon(String key) {
    const icons = {
      'journals': Icons.book_outlined,
      'moodCheckins': Icons.mood_outlined,
      'relaxSessions': Icons.spa_outlined,
      'meditationSessions': Icons.self_improvement,
      'breathingSessions': Icons.air,
      'sleepSessions': Icons.bedtime_outlined,
      'soundSessions': Icons.music_note_outlined,
      'companionInteractions': Icons.pets_outlined,
      'notifications': Icons.notifications_outlined,
      'feedEntries': Icons.feed_outlined,
    };
    return icons[key] ?? Icons.data_object;
  }
}

class _DeleteRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onDelete;

  const _DeleteRow({
    required this.label,
    required this.icon,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onDelete,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: RelaxColors.coral.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: RelaxColors.coral, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: context.appText,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Icon(Icons.delete_outline, color: RelaxColors.coral, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
