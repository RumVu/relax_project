// Data class for an onboarding slide.
class OnboardingSlide {
  const OnboardingSlide({
    required this.emoji,
    required this.title,
    required this.body,
  });

  final String emoji;
  final String title;
  final String body;
}

const kOnboardingSlides = [
  OnboardingSlide(
    emoji: '🌙',
    title: 'Không gian chill\ndành cho bạn',
    body: 'Thư giãn, hít thở và tận hưởng những khoảnh khắc bình yên.',
  ),
  OnboardingSlide(
    emoji: '🫶',
    title: 'Chọn phương thức\nyêu thích',
    body:
        'Nhạc, thiền, hít thở, viết nhật ký — pick cách bạn thấy dễ chịu nhất.',
  ),
  OnboardingSlide(
    emoji: '📈',
    title: 'Theo dõi cảm xúc\n& tiến độ',
    body:
        'Mood check-in mỗi ngày, biểu đồ tuần — hiểu rõ nhịp bên trong mình.',
  ),
  OnboardingSlide(
    emoji: '✦',
    title: 'Sẵn sàng\nbắt đầu chưa?',
    body: 'Đăng nhập để Thi Ái nâng niu trút bỏ nỗi buồn của bạn nha ~',
  ),
];
