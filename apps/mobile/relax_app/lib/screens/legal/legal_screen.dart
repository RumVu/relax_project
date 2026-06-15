import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/cat_mascot.dart';
import 'models/legal_terms.dart';
import 'widgets/legal_section.dart';

// Trang thu tuc phap ly & ban quyen: dieu khoan, quyen rieng tu, giay phep
// nguon mo, kem cau chuc cho nguoi dung. Mo dang route push tu Setup.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

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
          context.t('Quy định & bản quyền'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            ...kLegalTerms.map(
                (t) => LegalSection(title: context.t(t.$1), body: context.t(t.$2))),
            const SizedBox(height: 8),
            // Medical disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RelaxColors.coral.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: RelaxColors.coral.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medical_information_outlined, color: RelaxColors.coral, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        context.t('Miễn trừ trách nhiệm y tế'),
                        style: TextStyle(
                          color: context.appText,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.t('Thi Ái không phải là thiết bị y tế và không cung cấp '
                        'chẩn đoán, điều trị hoặc dịch vụ cấp cứu. Ứng dụng chỉ hỗ trợ '
                        'bạn theo dõi cảm xúc cá nhân, xây dựng thói quen thư giãn và '
                        'ghi chép nhật ký sức khoẻ tinh thần.'),
                    style: TextStyle(color: context.mutedText, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.t('Nếu bạn đang gặp vấn đề sức khoẻ tâm thần nghiêm trọng, '
                        'hãy liên hệ chuyên gia sức khoẻ tâm thần hoặc gọi đường dây nóng '
                        '1800 599 920. Trong trường hợp khẩn cấp, gọi 115.'),
                    style: TextStyle(
                      color: context.appText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Giấy phép nguồn mở — dùng trang built-in của Flutter.
            Container(
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.fieldBorder),
              ),
              child: ListTile(
                leading: const Icon(Icons.code, color: RelaxColors.violet),
                title: Text(
                  context.t('Giấy phép nguồn mở'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.appText,
                  ),
                ),
                subtitle: Text(
                  context.t('Các thư viện được dùng trong ứng dụng'),
                  style: TextStyle(color: context.mutedText, fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right, color: context.mutedText),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Thi Ái',
                  applicationVersion: '1.1.1+1',
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Câu chúc + bản quyền.
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [RelaxColors.violet, RelaxColors.plum],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const CatMascot(size: 72, emoji: '😻', glow: false),
                  const SizedBox(height: 12),
                  Text(
                    context.t(
                        'Chúc các stress-er có những trải nghiệm tốt ở sản phẩm của chúng tôi 💜'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.t('© 2026 Relax. Mọi quyền được bảo lưu.'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
