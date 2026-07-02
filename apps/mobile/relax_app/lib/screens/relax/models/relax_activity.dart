class RelaxActivity {
  const RelaxActivity({
    required this.no,
    required this.title,
    required this.desc,
    required this.image,
    required this.route,
    required this.type,
  });
  final String no;
  final String title;
  final String desc;
  final String image;
  final String route;
  final String type;
}

const relaxActivities = [
  RelaxActivity(
    no: '01',
    title: 'Nhạc',
    desc: 'Những giai điệu nhẹ nhàng giúp tâm trí bạn thư giãn.',
    image: 'assets/hinh_trang_thu_gian/hinh-nghe-nhac.png',
    route: '/sounds',
    type: 'MUSIC',
  ),
  RelaxActivity(
    no: '02',
    title: 'Podcast',
    desc: 'Lắng nghe những câu chuyện truyền cảm hứng mỗi ngày.',
    image: 'assets/hinh_trang_thu_gian/hinh-nghe-podcast.png',
    route: '/podcast',
    type: 'PODCAST',
  ),
  RelaxActivity(
    no: '03',
    title: 'Viết nhật ký',
    desc: 'Ghi lại cảm xúc và suy nghĩ để nhẹ lòng hơn nhé.',
    image: 'assets/hinh_trang_thu_gian/hinh-viet-nhat-ki.png',
    route: '/journal',
    type: 'JOURNAL',
  ),
  RelaxActivity(
    no: '04',
    title: 'Hít thở không khí',
    desc: 'Hít thở sâu, thả lỏng cơ thể và sống chậm lại nào.',
    image: 'assets/hinh_trang_thu_gian/hinh-hit-tho-khong-khi.png',
    route: '/breathing',
    type: 'BREATHING',
  ),
  RelaxActivity(
    no: '05',
    title: 'Thiền định',
    desc: 'Các bài thiền định có hướng dẫn để giải tỏa căng thẳng lo âu.',
    image: 'assets/hinh_trang_thu_gian/hinh-thien-dinh.png',
    route: '/meditation',
    type: 'MEDITATION',
  ),
  RelaxActivity(
    no: '06',
    title: 'Giấc ngủ',
    desc: 'Theo dõi giấc ngủ và chìm vào giấc ngủ với âm thanh thư giãn.',
    image: 'assets/hinh_trang_thu_gian/hinh-giac-ngu.png',
    route: '/sleep',
    type: 'SLEEP',
  ),
  RelaxActivity(
    no: '07',
    title: 'Bí ẩn',
    desc: 'Để linh thú chọn một hoạt động bất ngờ phù hợp với bạn!',
    image: 'assets/hinh_trang_thu_gian/hinh-bi-an.png',
    route: '__random__',
    type: 'MYSTERY',
  ),
];
