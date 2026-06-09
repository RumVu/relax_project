import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/locale_controller.dart';
import '../core/theme.dart';
import '../widgets/cat_mascot.dart';

/// Trang thủ tục pháp lý & bản quyền: điều khoản, quyền riêng tư, giấy phép
/// nguồn mở, kèm câu chúc cho người dùng. Mở dạng route push từ Setup.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  static const _terms = [
    (
      'Điều khoản sử dụng',
      'Relax là ứng dụng chăm sóc tinh thần, không thay thế cho tư vấn y tế '
          'chuyên nghiệp. Khi bạn căng thẳng kéo dài, hãy tìm tới người thân '
          'hoặc chuyên gia tâm lý. Bạn đồng ý sử dụng ứng dụng một cách lành '
          'mạnh và tự chịu trách nhiệm với nội dung mình tạo ra (nhật ký, ghi '
          'chú cảm xúc).',
    ),
    (
      'Quyền riêng tư',
      'Dữ liệu cảm xúc, nhật ký và vị trí của bạn được dùng để cá nhân hoá '
          'trải nghiệm và chỉ bạn mới xem được. Chúng tôi không bán dữ liệu cho '
          'bên thứ ba. Bạn có thể xoá tài khoản bất cứ lúc nào để xoá vĩnh viễn '
          'toàn bộ dữ liệu.',
    ),
    (
      'Thanh toán & hoàn tiền',
      'Gói hội viên được thanh toán qua cổng SePay. Khi nâng cấp, tính năng '
          'mở khoá ngay sau khi giao dịch thành công. Mọi thắc mắc về giao dịch '
          'vui lòng liên hệ bộ phận hỗ trợ kèm mã giao dịch.',
    ),
  ];

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
            ..._terms.map((t) => _Section(title: context.t(t.$1), body: context.t(t.$2))),
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
                  applicationName: 'Relax',
                  applicationVersion: '1.0.0',
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
                    context.t('Chúc các stress-er có những trải nghiệm tốt ở sản phẩm của chúng tôi 💜'),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: context.mutedText,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
