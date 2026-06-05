part of 'package:relax_app/main.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBar(
            icon: Icons.emoji_events_outlined,
            title: 'Challenger',
            subtitle: 'Thử thách nhỏ mỗi ngày để chăm sóc bản thân.',
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                child: StatCard(
                  title: 'Streak',
                  value: '12',
                  caption: 'ngày liên tiếp',
                  icon: Icons.local_fire_department_rounded,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  title: 'Tổng thời gian',
                  value: '8h 42m',
                  caption: 'thư giãn cùng Thi Ái',
                  icon: Icons.timer_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const StatCard(
            title: 'Hôm nay',
            value: '19:42',
            caption: '24/05/2024',
            icon: Icons.calendar_month_outlined,
          ),
          const SizedBox(height: 14),
          PixelPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: 'Biểu đồ cảm xúc (7 ngày qua)',
                  icon: Icons.show_chart_rounded,
                ),
                const SizedBox(height: 12),
                const MoodLineChart(),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PixelPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: 'Hoạt động yêu thích',
                  icon: Icons.star_border_rounded,
                ),
                const SizedBox(height: 12),
                const FavoriteActivity(
                  label: 'Nhạc',
                  value: '3h 20m',
                  amount: .82,
                ),
                const FavoriteActivity(
                  label: 'Podcast',
                  value: '2h 10m',
                  amount: .62,
                ),
                const FavoriteActivity(
                  label: 'Hít thở',
                  value: '1h 15m',
                  amount: .42,
                ),
                const FavoriteActivity(
                  label: 'Viết nhật kí',
                  value: '1h 00m',
                  amount: .36,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionTitle(
            title: 'Khoảnh khắc thư giãn gần đây',
            icon: Icons.history_rounded,
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(
                child: MiniMoment(
                  title: 'Nhạc',
                  time: '24/05 · 22:15',
                  minutes: '25 phút',
                  icon: Icons.radio_rounded,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: MiniMoment(
                  title: 'Hít thở',
                  time: '24/05 · 21:30',
                  minutes: '10 phút',
                  icon: Icons.cloud_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
