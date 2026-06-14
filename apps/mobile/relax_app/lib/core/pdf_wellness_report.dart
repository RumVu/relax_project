import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfWellnessReport {
  static Future<File> generateReport(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pw.Font? customFont;
    try {
      final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      customFont = pw.Font.ttf(fontData);
    } catch (_) {
      try {
        final fontFile = File('/System/Library/Fonts/Supplemental/Arial.ttf');
        if (fontFile.existsSync()) {
          final rawBytes = await fontFile.readAsBytes();
          customFont = pw.Font.ttf(rawBytes.buffer.asByteData());
        }
      } catch (_) {}
    }

    final textStyle = pw.TextStyle(
      font: customFont,
      fontSize: 12,
    );
    final headerStyle = pw.TextStyle(
      font: customFont,
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
    );
    final italicStyle = pw.TextStyle(
      font: customFont,
      fontSize: 12,
      fontStyle: pw.FontStyle.italic,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("BÁO CÁO SỨC KHỎE TINH THẦN (WELLNESS REPORT)", style: headerStyle),
                pw.SizedBox(height: 8),
                pw.Text("Ngày xuất: ${DateTime.now().toLocal().toString().substring(0, 19)}", style: textStyle),
                pw.Divider(),
                pw.SizedBox(height: 16),
                pw.Text("Tâm trạng chủ đạo: ${data['dominantMood'] ?? 'Bình thường'}", style: textStyle),
                pw.SizedBox(height: 6),
                pw.Text("Cường độ trung bình: ${data['avgIntensity'] ?? '5/10'}", style: textStyle),
                pw.SizedBox(height: 6),
                pw.Text("Chuỗi ngày check-in liên tiếp: ${data['streak'] ?? '3 ngày'}", style: textStyle),
                pw.SizedBox(height: 20),
                pw.Text("Các hoạt động đã hoàn thành:", style: pw.TextStyle(font: customFont, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                ...((data['activities'] as List? ?? []).map((act) => pw.Bullet(text: act.toString(), style: textStyle))),
                pw.SizedBox(height: 20),
                pw.Text("Khuyến nghị của AI:", style: pw.TextStyle(font: customFont, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(data['aiRecommendation'] ?? "Hãy tiếp tục hít thở sâu và ghi chép cảm xúc hàng ngày để điều hòa căng thẳng.", style: italicStyle),
                pw.SizedBox(height: 40),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("Báo cáo được tạo tự động bởi ứng dụng Relax", style: pw.TextStyle(font: customFont, fontSize: 10, color: PdfColors.grey)),
                ),
              ],
            ),
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/wellness_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
