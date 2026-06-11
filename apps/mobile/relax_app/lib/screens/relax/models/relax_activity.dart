import 'package:flutter/material.dart';

class RelaxActivity {
  const RelaxActivity({
    required this.no,
    required this.title,
    required this.desc,
    required this.icon,
    required this.route,
    required this.type,
  });
  final String no;
  final String title;
  final String desc;
  final IconData icon;
  final String route;
  final String type;
}

const relaxActivities = [
  RelaxActivity(
    no: '01',
    title: 'Nhạc',
    desc: 'Những giai điệu nhẹ nhàng giúp tâm trí bạn thư giãn.',
    icon: Icons.headphones,
    route: '/sounds',
    type: 'MUSIC',
  ),
  RelaxActivity(
    no: '02',
    title: 'Podcast',
    desc: 'Lắng nghe những câu chuyện truyền cảm hứng mỗi ngày.',
    icon: Icons.mic_none,
    route: '/podcast',
    type: 'PODCAST',
  ),
  RelaxActivity(
    no: '03',
    title: 'Viết nhật ký',
    desc: 'Ghi lại cảm xúc và suy nghĩ để nhẹ lòng hơn nhé.',
    icon: Icons.menu_book_outlined,
    route: '/journal',
    type: 'JOURNAL',
  ),
  RelaxActivity(
    no: '04',
    title: 'Hít thở không khí',
    desc: 'Hít thở sâu, thả lỏng cơ thể và sống chậm lại nào.',
    icon: Icons.cloud_outlined,
    route: '/breathing',
    type: 'BREATHING',
  ),
  RelaxActivity(
    no: '05',
    title: 'Thiền định',
    desc: 'Các bài thiền định có hướng dẫn để giải tỏa căng thẳng lo âu.',
    icon: Icons.spa_outlined,
    route: '/meditation',
    type: 'MEDITATION',
  ),
  RelaxActivity(
    no: '06',
    title: 'Giấc ngủ',
    desc: 'Theo dõi giấc ngủ và chìm vào giấc ngủ với âm thanh thư giãn.',
    icon: Icons.nights_stay_outlined,
    route: '/sleep',
    type: 'SLEEP',
  ),
  RelaxActivity(
    no: '07',
    title: 'Bí ẩn',
    desc: 'Để linh thú chọn một hoạt động bất ngờ phù hợp với bạn!',
    icon: Icons.help_outline,
    route: '__random__',
    type: 'MYSTERY',
  ),
];
