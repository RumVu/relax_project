#!/usr/bin/env node
// Seed 30 new onboarding slides with wellness tips.

const path = require('node:path');
const { config: loadEnv } = require('dotenv');
const { PrismaClient } = require('@prisma/client');

const repoRoot = path.resolve(__dirname, '../../../..');
loadEnv({ path: path.join(repoRoot, '.env'), quiet: true });
loadEnv({ path: path.join(repoRoot, 'apps/backend/.env'), quiet: true });
loadEnv({ path: path.join(repoRoot, 'apps/backend/.env.local'), quiet: true });

const prisma = new PrismaClient();

const SLIDES = [
  {
    title: 'Hít thở sâu, thở ra nhẹ',
    subtitle: 'Chỉ 1 phút thôi là đủ.',
    description: 'Bài tập thở giúp bạn hạ nhịp tim, giảm lo âu và lấy lại sự bình tĩnh ngay lập tức.',
    displayOrder: 4,
  },
  {
    title: 'Viết nhật ký cảm xúc',
    subtitle: 'Ghi lại — rồi buông bỏ.',
    description: 'Viết ra những suy nghĩ của bạn mỗi ngày. Không cần hay, chỉ cần thật.',
    displayOrder: 5,
  },
  {
    title: 'Nghe nhạc thư giãn',
    subtitle: 'Âm nhạc chữa lành từ bên trong.',
    description: 'Kho nhạc lo-fi, thiên nhiên và thiền định được tuyển chọn cho giấc ngủ ngon và tập trung.',
    displayOrder: 6,
  },
  {
    title: 'Theo dõi giấc ngủ',
    subtitle: 'Ngủ ngon là nền tảng mọi thứ.',
    description: 'Ghi nhận giờ ngủ, chất lượng giấc ngủ và nhận gợi ý cải thiện.',
    displayOrder: 7,
  },
  {
    title: 'Đặt nhắc nhở check-in',
    subtitle: 'Để không quên chăm sóc mình.',
    description: 'Cài thông báo hàng ngày để nhắc bạn dừng lại, hít thở và ghi nhận cảm xúc.',
    displayOrder: 8,
  },
  {
    title: 'Khám phá biểu đồ cảm xúc',
    subtitle: 'Nhìn lại hành trình của bạn.',
    description: 'Biểu đồ phân tích mood theo tuần, tháng — giúp bạn nhận ra các xu hướng cảm xúc.',
    displayOrder: 9,
  },
  {
    title: 'Thử thiền 5 phút',
    subtitle: 'Không cần kinh nghiệm.',
    description: 'Các bài thiền ngắn có hướng dẫn, phù hợp cho người mới bắt đầu.',
    displayOrder: 10,
  },
  {
    title: 'Tạo thói quen tốt',
    subtitle: 'Nhỏ thôi — nhưng đều đặn.',
    description: 'Uống nước, đi bộ 10 phút, đọc sách — bắt đầu từ 1 thói quen mỗi ngày.',
    displayOrder: 11,
  },
  {
    title: 'Ghi nhận điều biết ơn',
    subtitle: '3 điều nhỏ mỗi ngày.',
    description: 'Nghiên cứu cho thấy lòng biết ơn giúp tăng hạnh phúc và giảm stress đáng kể.',
    displayOrder: 12,
  },
  {
    title: 'Đừng so sánh với ai',
    subtitle: 'Hành trình của bạn là duy nhất.',
    description: 'Mỗi người có nhịp độ riêng. Relax giúp bạn tập trung vào sự tiến bộ của chính mình.',
    displayOrder: 13,
  },
  {
    title: 'Dành thời gian cho thiên nhiên',
    subtitle: 'Ra ngoài, ngắm trời một chút.',
    description: 'Chỉ 15 phút tiếp xúc thiên nhiên mỗi ngày cũng giúp giảm cortisol rõ rệt.',
    displayOrder: 14,
  },
  {
    title: 'Cắt giảm thời gian màn hình',
    subtitle: 'Mắt và tâm trí cần nghỉ.',
    description: 'Thử quy tắc 20-20-20: mỗi 20 phút, nhìn xa 20 feet trong 20 giây.',
    displayOrder: 15,
  },
  {
    title: 'Chia sẻ cảm xúc với ai đó',
    subtitle: 'Nói ra — nhẹ lòng hơn nhiều.',
    description: 'Không cần giải pháp, đôi khi chỉ cần được lắng nghe là đủ chữa lành.',
    displayOrder: 16,
  },
  {
    title: 'Uống đủ nước mỗi ngày',
    subtitle: 'Cơ thể khỏe, tinh thần sáng.',
    description: 'Mất nước nhẹ cũng ảnh hưởng tâm trạng và khả năng tập trung.',
    displayOrder: 17,
  },
  {
    title: 'Tập thể dục nhẹ nhàng',
    subtitle: 'Yoga, đi bộ hoặc giãn cơ.',
    description: 'Vận động giải phóng endorphin — hormone hạnh phúc tự nhiên của cơ thể.',
    displayOrder: 18,
  },
  {
    title: 'Học cách nói "không"',
    subtitle: 'Bảo vệ năng lượng của bạn.',
    description: 'Từ chối không có nghĩa là ích kỷ — mà là biết giới hạn của bản thân.',
    displayOrder: 19,
  },
  {
    title: 'Nghỉ ngơi khỏi mạng xã hội',
    subtitle: 'Digital detox cho tâm hồn.',
    description: 'Thử 1 giờ không điện thoại mỗi tối trước khi ngủ để cải thiện giấc ngủ.',
    displayOrder: 20,
  },
  {
    title: 'Ăn chậm, thưởng thức',
    subtitle: 'Mindful eating — ăn có ý thức.',
    description: 'Tập trung vào bữa ăn giúp bạn thưởng thức hơn và ăn vừa đủ.',
    displayOrder: 21,
  },
  {
    title: 'Dọn dẹp không gian sống',
    subtitle: 'Không gian gọn = đầu óc thoáng.',
    description: 'Môi trường xung quanh ảnh hưởng trực tiếp đến tâm trạng và hiệu suất.',
    displayOrder: 22,
  },
  {
    title: 'Đọc sách trước khi ngủ',
    subtitle: 'Thay điện thoại bằng trang sách.',
    description: 'Chỉ 15 phút đọc sách giúp giảm stress 68% — hiệu quả hơn cả nghe nhạc.',
    displayOrder: 23,
  },
  {
    title: 'Ôm ai đó thật chặt',
    subtitle: 'Oxytocin — thuốc giảm stress tốt nhất.',
    description: 'Một cái ôm 20 giây giúp giải phóng oxytocin và giảm huyết áp.',
    displayOrder: 24,
  },
  {
    title: 'Cười nhiều hơn mỗi ngày',
    subtitle: 'Cười là liều thuốc miễn phí.',
    description: 'Cười giúp thư giãn cơ bắp, tăng miễn dịch và cải thiện tâm trạng ngay lập tức.',
    displayOrder: 25,
  },
  {
    title: 'Đặt mục tiêu nhỏ mỗi ngày',
    subtitle: 'Mỗi bước nhỏ đều đáng mừng.',
    description: 'Chia mục tiêu lớn thành nhiều bước nhỏ — mỗi lần hoàn thành là một phần thưởng.',
    displayOrder: 26,
  },
  {
    title: 'Tắm nước ấm trước khi ngủ',
    subtitle: 'Nghi thức nhỏ, hiệu quả lớn.',
    description: 'Nước ấm giúp hạ nhiệt cơ thể sau đó, kích hoạt cơ chế buồn ngủ tự nhiên.',
    displayOrder: 27,
  },
  {
    title: 'Nghe podcast chữa lành',
    subtitle: 'Kiến thức + thư giãn.',
    description: 'Relax có bộ sưu tập podcast về tâm lý, wellness và phát triển bản thân.',
    displayOrder: 28,
  },
  {
    title: 'Chấp nhận ngày không hoàn hảo',
    subtitle: 'Không sao cả — ai cũng có.',
    description: 'Cho phép mình có ngày tệ là một phần quan trọng của sức khỏe tinh thần.',
    displayOrder: 29,
  },
  {
    title: 'Tập trung vào hiện tại',
    subtitle: 'Quá khứ đã qua, tương lai chưa đến.',
    description: 'Mindfulness — sống trọn vẹn khoảnh khắc này giúp giảm lo âu hiệu quả.',
    displayOrder: 30,
  },
  {
    title: 'Cho bản thân một lời khen',
    subtitle: 'Bạn đang làm tốt lắm rồi.',
    description: 'Self-affirmation giúp tăng lòng tự trọng và khả năng đối phó với stress.',
    displayOrder: 31,
  },
  {
    title: 'Hạn chế caffeine buổi chiều',
    subtitle: 'Trà thảo mộc thay cà phê.',
    description: 'Caffeine sau 2 giờ chiều có thể ảnh hưởng giấc ngủ dù bạn không nhận ra.',
    displayOrder: 32,
  },
  {
    title: 'Bạn không đi một mình',
    subtitle: 'Kết nối với cộng đồng.',
    description: 'Tham gia các hoạt động cộng đồng giúp giảm cô đơn và tăng cảm giác thuộc về.',
    displayOrder: 33,
  },
];

async function main() {
  console.log(`Seeding ${SLIDES.length} new onboarding slides...`);

  for (const slide of SLIDES) {
    await prisma.onboardingSlide.create({
      data: {
        title: slide.title,
        subtitle: slide.subtitle,
        description: slide.description,
        displayOrder: slide.displayOrder,
        isActive: true,
      },
    });
    console.log(`  ✓ #${slide.displayOrder} ${slide.title}`);
  }

  const total = await prisma.onboardingSlide.count();
  console.log(`\nDone! Total onboarding slides: ${total}`);
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(() => prisma.$disconnect());
