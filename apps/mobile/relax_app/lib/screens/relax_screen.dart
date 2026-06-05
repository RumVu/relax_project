part of 'package:relax_app/main.dart';

class RelaxScreen extends StatelessWidget {
  const RelaxScreen({super.key});

  static const activities = [
    Activity(
      '01. Nhạc',
      'Những giai điệu nhẹ nhàng giúp tâm trí bạn thư giãn.',
      Icons.radio_rounded,
    ),
    Activity(
      '02. Podcast',
      'Lắng nghe những câu chuyện truyền cảm hứng mỗi ngày.',
      Icons.mic_external_on_rounded,
    ),
    Activity(
      '03. Viết nhật kí',
      'Ghi lại cảm xúc và suy nghĩ để nhẹ lòng hơn nhé.',
      Icons.menu_book_rounded,
    ),
    Activity(
      '04. Hít thở không khí',
      'Hít thở sâu, thả lỏng cơ thể và sống chậm lại nào.',
      Icons.cloud_rounded,
    ),
    Activity(
      '05. Bí ẩn',
      'Để Thi Ái chọn một hoạt động bất ngờ phù hợp với bạn!',
      Icons.inventory_2_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScroll(
      child: Column(
        children: [
          HeaderBar(
            icon: Icons.arrow_back_ios_new_rounded,
            title: 'Thư giãn ✦',
            subtitle: 'Chọn một cách để thư giãn nhé ~',
            trailing: const PixelCatScene(scene: CatScene.sleep, height: 66),
          ),
          const SizedBox(height: 12),
          ...activities.map(
            (activity) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ActivityCard(activity: activity),
            ),
          ),
        ],
      ),
    );
  }
}
