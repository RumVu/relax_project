import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_panel.dart';

/// Trang Giới thiệu — câu chuyện app + triết lý + version.
///
/// Mục đích storytelling: cho user hiểu vì sao Thi Ái Chill tồn tại,
/// nó được làm với tình cảm nào, hứa hẹn nguyên tắc đối xử với dữ liệu.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
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
      setState(
        () => _version = 'v${info.version}+${info.buildNumber}',
      );
    } catch (_) {/* ignore */}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Về Thi Ái Chill'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Hero
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [RelaxTheme.purple, RelaxTheme.lavender],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: RelaxTheme.purple.withValues(alpha: .3),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const PixelCatScene(scene: CatScene.wave, height: 140),
                const SizedBox(height: 14),
                Text(
                  'Thi Ái Chill ✦',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Một nhịp nghỉ mềm trước khi ngày trở nên ồn ào.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: .9),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _version,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _StorySection(
            emoji: '🌿',
            title: 'Câu chuyện',
            body:
                'Thi Ái Chill được tạo ra cho những ngày bạn cảm thấy "nhiều quá". '
                'Không phải để chữa lành thay y khoa, không phải để thay thế '
                'bạn bè — chỉ là một chỗ êm để bạn dừng lại, hít thở, và '
                'lắng nghe chính mình.',
          ),
          _StorySection(
            emoji: '💜',
            title: 'Triết lý',
            body:
                'Mỗi cảm xúc đều xứng đáng được nghe. Không có cảm xúc "xấu" — '
                'chỉ có cảm xúc chưa được gọi tên. Vai trò của mình là giúp '
                'bạn có không gian gọi tên chúng, mà không phán xét.',
          ),
          _StorySection(
            emoji: '🛡',
            title: 'Cam kết với dữ liệu',
            body:
                'Token đăng nhập lưu trong Keychain/Keystore của thiết bị. '
                'Mood, nhật ký, phiên thư giãn chỉ dùng để giúp bạn nhìn '
                'lại hành trình — KHÔNG bán cho ai. Bạn có thể xóa toàn bộ '
                'dữ liệu bất cứ lúc nào ở Setup → Xóa tài khoản.',
          ),
          _StorySection(
            emoji: '🤝',
            title: 'Mình KHÔNG thay thế',
            body:
                'Mình là người bạn nhỏ trong điện thoại. Khi bạn cần một '
                'con người thực sự — bác sĩ, nhà tâm lý, gia đình, bạn '
                'thân — đừng ngại tìm họ. Setup → Hỗ trợ khẩn cấp có '
                'hotline để bạn liên hệ ngay khi cần.',
          ),
          const SizedBox(height: 14),
          PixelPanel(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lời cảm ơn 🌸',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cảm ơn bạn đã chọn Thi Ái Chill làm chỗ nghỉ giữa ngày. '
                  'Mỗi lần bạn mở app, mình thấy mình có ích — và đó là '
                  'điều mình mong muốn nhất.\n\n'
                  'Nếu app giúp bạn một chút, chia sẻ với bạn bè của bạn '
                  'nha. Còn nếu có gì chưa ổn — feedback luôn được lắng '
                  'nghe ở email: hello@thiai-chill.app',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Made with 💜 in Việt Nam',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: context.relax.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorySection extends StatelessWidget {
  const _StorySection({
    required this.emoji,
    required this.title,
    required this.body,
  });
  final String emoji;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: RelaxTheme.lavender,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
