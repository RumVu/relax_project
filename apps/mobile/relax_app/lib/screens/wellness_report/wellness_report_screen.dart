import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/premium_blur.dart';
import '../../widgets/soft_toast.dart';

class WellnessReportScreen extends StatefulWidget {
  const WellnessReportScreen({super.key});

  @override
  State<WellnessReportScreen> createState() => _WellnessReportScreenState();
}

class _WellnessReportScreenState extends State<WellnessReportScreen> {
  bool _loading = true;
  bool _generating = false;
  Map<String, dynamic>? _overview;
  List<Map<String, dynamic>> _moodTimeline = [];
  String? _pdfPath;
  String _period = '30';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        RelaxApi.instance.get('/analytics/me/overview?days=$_period'),
        RelaxApi.instance.get('/analytics/me/mood-calendar'),
      ]);
      setState(() {
        _overview = results[0].data as Map<String, dynamic>?;
        _moodTimeline = (results[1].data as List?)
                ?.cast<Map<String, dynamic>>() ??
            [];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _generatePdf() async {
    setState(() => _generating = true);
    try {
      final pdf = pw.Document();
      final summaryCards =
          _overview?['summaryCards'] as Map<String, dynamic>? ?? {};
      final mood = _overview?['mood'] as Map<String, dynamic>? ?? {};
      final moodSummary = mood['summary'] as Map<String, dynamic>? ?? {};

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (ctx) => [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Thi Ai - Bao cao suc khoe tinh than',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Ky bao cao: $_period ngay gan nhat | Ngay tao: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary section
            pw.Header(level: 1, text: 'Tong quan'),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ['Chi so', 'Gia tri'],
              data: [
                ['Chuoi ngay lien tiep', '${summaryCards['currentStreak'] ?? 0}'],
                ['Tong thoi gian thu gian', '${summaryCards['totalRelaxTime'] ?? '0m'}'],
                ['Tong nhat ky', '${summaryCards['totalJournals'] ?? 0}'],
                ['Do than thiet companion', '${summaryCards['companionAffection'] ?? 0}%'],
                ['Giam stress', '${summaryCards['stressReduction'] ?? 0}%'],
              ],
            ),
            pw.SizedBox(height: 20),

            // Mood summary
            pw.Header(level: 1, text: 'Cam xuc'),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ['Chi so', 'Gia tri'],
              data: [
                ['Cam xuc hien tai', '${mood['currentMood'] ?? 'N/A'}'],
                ['Cuong do trung binh', '${moodSummary['averageIntensity'] ?? 'N/A'}'],
                ['Tong check-in', '${moodSummary['totalCheckins'] ?? 0}'],
              ],
            ),
            pw.SizedBox(height: 20),

            // Calendar overview
            if (_moodTimeline.isNotEmpty) ...[
              pw.Header(level: 1, text: 'Lich cam xuc (30 ngay gan nhat)'),
              pw.Wrap(
                spacing: 4,
                runSpacing: 4,
                children: _moodTimeline.take(30).map((day) {
                  final moods = day['moods'] as List<dynamic>? ?? [];
                  final dateStr = day['date'] as String? ?? '';
                  final d = DateTime.tryParse(dateStr);
                  final dayNum = d?.day ?? 0;
                  final moodStr = moods.isNotEmpty ? _moodAbbr(moods.first as String) : '--';

                  return pw.Container(
                    width: 42,
                    height: 32,
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('$dayNum',
                            style: const pw.TextStyle(fontSize: 8)),
                        pw.Text(moodStr,
                            style: pw.TextStyle(
                                fontSize: 7,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            pw.SizedBox(height: 30),

            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'Bao cao nay duoc tao tu dong boi ung dung Thi Ai. '
                'Day khong phai la chan doan y khoa. Neu ban can ho tro chuyen sau, '
                'hay lien he chuyen gia suc khoe tinh than.',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ),
          ],
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/wellness_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      setState(() {
        _pdfPath = file.path;
        _generating = false;
      });

      if (mounted) {
        showSoftToast(context,
            message: context.t('PDF đã được tạo!'),
            tone: SoftToastTone.success);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _generating = false);
        showSoftToast(context,
            message: context.t('Không thể tạo PDF'),
            tone: SoftToastTone.error);
      }
    }
  }

  String _moodAbbr(String mood) {
    switch (mood) {
      case 'HAPPY': return 'VU';
      case 'CALM': return 'BT';
      case 'TIRED': return 'ME';
      case 'SAD': return 'BU';
      case 'ANXIOUS': return 'LO';
      case 'STRESSED': return 'ST';
      case 'ANGRY': return 'GI';
      case 'POOPING': return 'IA';
      default: return '--';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          context.isDark ? const Color(0xFF0d1117) : RelaxColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Báo cáo sức khoẻ'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: RelaxColors.violet))
            : ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // Header card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text('📊', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 8),
                        Text(
                          context.t('Xuất báo cáo PDF'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.t(
                              'Tổng hợp sức khoẻ tinh thần để chia sẻ hoặc lưu trữ'),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  PremiumBlur(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  // Period selector
                  Text(
                    context.t('Kỳ báo cáo'),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: context.appText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: ['7', '14', '30', '90'].map((p) {
                      final selected = _period == p;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _period = p);
                            _load();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? RelaxColors.violet
                                  : context.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? RelaxColors.violet
                                    : context.fieldBorder,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$p ${context.t('ngày')}',
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : context.appText,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Preview
                  if (_overview != null) _buildPreview(context),
                  const SizedBox(height: 20),

                  // Generate button
                  ElevatedButton.icon(
                    onPressed: _generating ? null : _generatePdf,
                    icon: _generating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf),
                    label: Text(_generating
                        ? context.t('Đang tạo...')
                        : context.t('Tạo báo cáo PDF')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RelaxColors.violet,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  // Share/open
                  if (_pdfPath != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: RelaxColors.mint.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: RelaxColors.mint.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: RelaxColors.mint, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.t('PDF đã sẵn sàng!'),
                                  style: TextStyle(
                                    color: context.appText,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _pdfPath!.split('/').last,
                                  style: TextStyle(
                                    color: context.mutedText,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Share.shareXFiles(
                          [XFile(_pdfPath!)],
                          text: 'Báo cáo sức khoẻ tinh thần - Thi Ái',
                        ),
                        icon: const Icon(Icons.share_outlined),
                        label: Text(context.t('Chia sẻ PDF')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: RelaxColors.violet,
                          side: const BorderSide(color: RelaxColors.violet),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    final cards = _overview?['summaryCards'] as Map<String, dynamic>? ?? {};
    final mood = _overview?['mood'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('Xem trước dữ liệu'),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 12),
          _previewRow(
              context, 'Cảm xúc hiện tại', mood['currentMood'] ?? 'N/A'),
          _previewRow(
              context, 'Chuỗi liên tiếp', '${cards['currentStreak'] ?? 0} ngày'),
          _previewRow(
              context, 'Thời gian thư giãn', cards['totalRelaxTime'] ?? '0m'),
          _previewRow(
              context, 'Nhật ký', '${cards['totalJournals'] ?? 0} bài'),
          _previewRow(
              context, 'Giảm stress', '${cards['stressReduction'] ?? 0}%'),
        ],
      ),
    );
  }

  Widget _previewRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(context.t(label),
              style: TextStyle(color: context.mutedText, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: context.appText,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
