import '../../../widgets/cat_mascot.dart';

class OnboardingSlide {
  const OnboardingSlide({
    required this.variant,
    required this.title,
    required this.body,
  });

  final CatVariant variant;
  final String title;
  final String body;
}

const kOnboardingSlides = [
  OnboardingSlide(
    variant: CatVariant.sleep,
    title: 'Không gian chill\ndành cho bạn',
    body: 'Thư giãn, hít thở và tận hưởng những khoảnh khắc bình yên.',
  ),
  OnboardingSlide(
    variant: CatVariant.stand,
    title: 'Chọn phương thức\nyêu thích',
    body:
        'Nhạc, thiền, hít thở, viết nhật ký — pick cách bạn thấy dễ chịu nhất.',
  ),
  OnboardingSlide(
    variant: CatVariant.sleep,
    title: 'Theo dõi cảm xúc\n& tiến độ',
    body:
        'Mood check-in mỗi ngày, biểu đồ tuần — hiểu rõ nhịp bên trong mình.',
  ),
  OnboardingSlide(
    variant: CatVariant.right,
    title: 'Sẵn sàng\nbắt đầu chưa?',
    body: 'Đăng nhập để Relax Time nâng niu trút bỏ nỗi buồn của bạn nha ~',
  ),
];
