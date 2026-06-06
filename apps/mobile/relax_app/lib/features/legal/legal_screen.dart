import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/theme.dart';

/// Trang Quy định & sử dụng — Điều khoản / Chính sách / Giấy phép.
class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _version = 'Version ${info.version} — Build ${info.buildNumber}');
    } catch (_) {
      if (!mounted) return;
      setState(() => _version = 'Version chưa xác định');
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Quy định & sử dụng'),
        bottom: TabBar(
          controller: _tab,
          labelColor: RelaxTheme.lavender,
          unselectedLabelColor: context.relax.muted,
          indicatorColor: RelaxTheme.lavender,
          tabs: const [
            Tab(text: 'Điều khoản'),
            Tab(text: 'Chính sách'),
            Tab(text: 'Giấy phép'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          const _LegalBody(
            title: 'Điều khoản sử dụng',
            sections: [
              _Section(
                heading: '1. Chấp nhận điều khoản',
                body:
                    'Khi sử dụng ứng dụng Thi Ai Chill, bạn đồng ý tuân theo các điều khoản dưới đây. Nếu không đồng ý, vui lòng không tiếp tục sử dụng.',
              ),
              _Section(
                heading: '2. Mục đích sử dụng',
                body:
                    'Ứng dụng được thiết kế để hỗ trợ chăm sóc sức khỏe tinh thần thông qua các hoạt động thư giãn nhẹ nhàng, KHÔNG thay thế tư vấn y tế chuyên nghiệp.',
              ),
              _Section(
                heading: '3. Tài khoản người dùng',
                body:
                    'Bạn chịu trách nhiệm bảo mật thông tin đăng nhập. Mọi hoạt động dưới tài khoản của bạn được xem là do bạn thực hiện.',
              ),
              _Section(
                heading: '4. Nội dung',
                body:
                    'Toàn bộ nội dung trong ứng dụng (âm thanh, hình ảnh, văn bản) thuộc bản quyền của chúng tôi hoặc đối tác. Không sao chép, phân phối khi chưa được phép.',
              ),
              _Section(
                heading: '5. Thay đổi điều khoản',
                body:
                    'Chúng tôi có thể cập nhật điều khoản bất kỳ lúc nào. Việc tiếp tục sử dụng sau khi cập nhật đồng nghĩa với việc bạn chấp nhận điều khoản mới.',
              ),
            ],
          ),
          const _LegalBody(
            title: 'Chính sách bảo mật',
            sections: [
              _Section(
                heading: 'Dữ liệu thu thập',
                body:
                    'Chúng tôi thu thập email, tên, cảm xúc bạn ghi nhận, và lịch sử phiên thư giãn để phục vụ trải nghiệm cá nhân hóa.',
              ),
              _Section(
                heading: 'Lưu trữ & bảo mật',
                body:
                    'Dữ liệu được mã hóa khi truyền và lưu trữ. Token đăng nhập được bảo vệ trong Keychain (iOS) / Keystore (Android).',
              ),
              _Section(
                heading: 'Vị trí địa lý',
                body:
                    'Chúng tôi chỉ truy cập vị trí của bạn khi bạn cho phép, và chỉ dùng để hiển thị thời tiết phù hợp với khu vực bạn đang ở.',
              ),
              _Section(
                heading: 'Quyền của bạn',
                body:
                    'Bạn có toàn quyền xem, sửa, hoặc xóa dữ liệu cá nhân. Sử dụng tính năng "Xóa tài khoản" trong Setup để xóa vĩnh viễn.',
              ),
              _Section(
                heading: 'Liên hệ',
                body:
                    'Có câu hỏi về bảo mật? Liên hệ qua: privacy@thiai-chill.app',
              ),
            ],
          ),
          _LegalBody(
            title: 'Giấy phép & ghi nhận',
            sections: [
              const _Section(
                heading: 'Open source',
                body:
                    'Ứng dụng sử dụng các thư viện mã nguồn mở: Flutter, just_audio, geolocator, http, shared_preferences, google_sign_in, flutter_secure_storage.',
              ),
              const _Section(
                heading: 'Thời tiết',
                body:
                    'Dữ liệu thời tiết được cung cấp bởi Open-Meteo (open-meteo.com) — dịch vụ miễn phí cho mục đích phi thương mại.',
              ),
              const _Section(
                heading: 'Hình ảnh',
                body:
                    'Các minh họa pixel art được tạo riêng cho ứng dụng. Vui lòng không sao chép sử dụng bên ngoài app.',
              ),
              _Section(heading: 'Phiên bản', body: _version),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegalBody extends StatelessWidget {
  const _LegalBody({required this.title, required this.sections});
  final String title;
  final List<_Section> sections;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 18),
        for (final s in sections) ...[
          Text(
            s.heading,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: RelaxTheme.lavender,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            s.body,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _Section {
  const _Section({required this.heading, required this.body});
  final String heading;
  final String body;
}
