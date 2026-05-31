/* eslint-disable @typescript-eslint/no-require-imports */
/**
 * Mass-seed nội dung: 50 quotes, 50 breathing exercises, 25 onboarding,
 * 50 companion messages. Idempotent — dùng deterministic key (content/
 * name/title) để re-run update in-place thay vì duplicate.
 *
 * Usage:
 *   docker exec digital-cigarette-backend node scripts/seed-content.cjs
 * Hoặc copy script vào container rồi chạy.
 *
 * Run locally:
 *   DATABASE_URL=postgresql://postgres:123456@localhost:5555/digital_cigarette_break \
 *     node scripts/seed-content.cjs
 */
const { PrismaClient, MoodType, CompanionMood, MessageTriggerType } =
  require('@prisma/client');

const prisma = new PrismaClient();

// =============================================================================
// 50 COZY QUOTES — tiếng Việt, không pha tiếng Anh, đa dạng tone.
// =============================================================================
const QUOTES = [
  { mood: 'STRESSED', content: 'Hôm nay đã đủ rồi. Bạn xứng đáng một khoảng nghỉ.' },
  { mood: 'STRESSED', content: 'Bạn không phải hoàn hảo. Chỉ cần hôm nay, là đủ.' },
  { mood: 'STRESSED', content: 'Mọi thứ rồi sẽ qua. Hít thở thêm một nhịp nữa nha.' },
  { mood: 'STRESSED', content: 'Đặt áp lực xuống một chút. Mình sẽ quay lại sau.' },
  { mood: 'STRESSED', content: 'Bạn không cần giải quyết hết mọi việc ngay bây giờ.' },
  { mood: 'ANXIOUS', content: 'Hít vào 4, giữ 4, thở ra 4. Cơ thể sẽ tin não lại.' },
  { mood: 'ANXIOUS', content: 'Lo lắng không xấu. Nó nhắc bạn đang quan tâm.' },
  { mood: 'ANXIOUS', content: 'Bạn đang an toàn ngay phút này. Cứ ở yên một lát.' },
  { mood: 'ANXIOUS', content: 'Cảm xúc đến rồi đi như mây. Đừng giữ chúng lại.' },
  { mood: 'ANXIOUS', content: 'Mỗi hơi thở ra là một lần buông một chút.' },
  { mood: 'SAD', content: 'Buồn cũng là một phần của bạn. Nó không định nghĩa bạn.' },
  { mood: 'SAD', content: 'Khóc cũng được. Cứ để nước mắt chảy nếu cần.' },
  { mood: 'SAD', content: 'Ngày mai sẽ khác. Hôm nay cứ tử tế với chính mình.' },
  { mood: 'SAD', content: 'Bạn không cô đơn. Có nhiều người cũng đang cảm thấy giống bạn.' },
  { mood: 'SAD', content: 'Cho phép bản thân chậm lại một nhịp.' },
  { mood: 'TIRED', content: 'Nghỉ ngơi không phải lười. Đó là sạc lại.' },
  { mood: 'TIRED', content: 'Cơ thể đang xin một ly nước. Uống một ngụm nhé.' },
  { mood: 'TIRED', content: 'Đi ngủ sớm hơn 30 phút cũng là chăm sóc bản thân.' },
  { mood: 'TIRED', content: 'Bạn đã cố gắng hôm nay. Mai làm tiếp cũng được.' },
  { mood: 'TIRED', content: 'Mệt nói cho mình nghe: nó muốn được nghỉ.' },
  { mood: 'LONELY', content: 'Một mình không có nghĩa là cô đơn.' },
  { mood: 'LONELY', content: 'Người bạn đồng hành nhỏ vẫn ở đây với bạn.' },
  { mood: 'LONELY', content: 'Gửi tin nhắn cho ai đó bạn nhớ — họ cũng đang chờ.' },
  { mood: 'LONELY', content: 'Hãy ôm chính mình. Đôi khi đó là cái ôm cần nhất.' },
  { mood: 'LONELY', content: 'Bạn xứng đáng được lắng nghe — bắt đầu bằng chính bạn.' },
  { mood: 'NEUTRAL', content: 'Bình thường cũng là một cảm xúc đẹp.' },
  { mood: 'NEUTRAL', content: 'Không có gì đặc biệt hôm nay — và điều đó hoàn toàn ổn.' },
  { mood: 'NEUTRAL', content: 'Một ngày yên lặng cũng là một ngày tốt.' },
  { mood: 'NEUTRAL', content: 'Bạn không cần phải làm gì lớn lao. Cứ ở đây thôi.' },
  { mood: 'NEUTRAL', content: 'Bình yên thường đến từ những phút giây không tên.' },
  { mood: 'HAPPY', content: 'Niềm vui hôm nay đáng được ghi lại.' },
  { mood: 'HAPPY', content: 'Hãy chia sẻ niềm vui — nó sẽ nhân đôi.' },
  { mood: 'HAPPY', content: 'Tận hưởng khoảnh khắc này. Bạn xứng đáng có nó.' },
  { mood: 'HAPPY', content: 'Cười cho mình nghe đã. Cười cho người khác nghe sau.' },
  { mood: 'HAPPY', content: 'Hôm nay là một ngày tốt — và bạn là một phần của nó.' },
  { mood: 'CALM', content: 'Bình yên ở bên trong, không phải bên ngoài.' },
  { mood: 'CALM', content: 'Tĩnh lặng là một loại sức mạnh.' },
  { mood: 'CALM', content: 'Cứ chậm rãi. Không ai đuổi bạn cả.' },
  { mood: 'CALM', content: 'Một tách trà ấm cũng đủ để cảm thấy ổn.' },
  { mood: 'CALM', content: 'Hơi thở chậm là quà bạn tặng não bộ.' },
  { mood: 'EXCITED', content: 'Năng lượng này — giữ lại cho việc bạn yêu.' },
  { mood: 'EXCITED', content: 'Làm điều bạn muốn làm. Bây giờ là đúng lúc.' },
  { mood: 'EXCITED', content: 'Hào hứng là dấu hiệu của một điều quan trọng.' },
  { mood: 'GRATEFUL', content: 'Ghi lại ba điều bạn biết ơn hôm nay.' },
  { mood: 'GRATEFUL', content: 'Biết ơn người nhỏ — họ chăm sóc bạn nhiều nhất.' },
  { mood: 'GRATEFUL', content: 'Cảm ơn cơ thể đã đi cùng bạn ngày hôm nay.' },
  { mood: null, content: 'Mỗi ngày là một bản thảo mới. Không cần viết hoàn hảo.' },
  { mood: null, content: 'Bạn không bị bể. Bạn chỉ đang được sắp xếp lại.' },
  { mood: null, content: 'Chăm sóc bản thân là việc dài hạn, không phải một lần.' },
  { mood: null, content: 'Hôm nay khó? Ngày mai khác. Cứ đi tiếp.' },
];

// =============================================================================
// 50 BREATHING EXERCISES
// Schema: { title, description, inhaleSeconds, holdSeconds, exhaleSeconds,
//   cycles, duration }. Box breathing (4-4-4-4) collapses to inhale/hold/
//   exhale (4-4-4) since schema lacks postHold.
// =============================================================================
const BREATHING = [
  { title: 'Hộp thở cổ điển 4-4-4', inhale: 4, hold: 4, exhale: 4, cycles: 6, description: 'Hộp thở: vào 4, giữ 4, ra 4. Phù hợp người mới.' },
  { title: 'Hộp thở nhẹ 5-5-5', inhale: 5, hold: 5, exhale: 5, cycles: 6, description: 'Nâng nhẹ lên 5 giây mỗi pha.' },
  { title: 'Hộp thở sâu 6-6-6', inhale: 6, hold: 6, exhale: 6, cycles: 5, description: 'Pha 6 giây giúp dịu sâu hơn.' },
  { title: 'Hộp thở cường độ cao 8-8-8', inhale: 8, hold: 8, exhale: 8, cycles: 4, description: 'Pha 8 giây — cần luyện tập.' },
  { title: 'Thở 4-7-8 cơ bản', inhale: 4, hold: 7, exhale: 8, cycles: 4, description: 'Kỹ thuật Dr. Weil — hạ lo âu nhanh.' },
  { title: 'Thở 4-7-8 mở rộng', inhale: 4, hold: 7, exhale: 8, cycles: 8, description: 'Nhiều chu kỳ hơn để dịu sâu.' },
  { title: 'Thở 4-7-8 trước khi ngủ', inhale: 4, hold: 7, exhale: 8, cycles: 6, description: 'Nằm xuống, làm trước khi tắt đèn.' },
  { title: 'Thở mạch lạc 5-0-5', inhale: 5, hold: 0, exhale: 5, cycles: 10, description: 'Hít 5, thở 5 — đồng bộ nhịp tim.' },
  { title: 'Thở mạch lạc 6-0-6', inhale: 6, hold: 0, exhale: 6, cycles: 10, description: 'Mỗi phút 5 nhịp — tối ưu cho HRV.' },
  { title: 'Thở mạch lạc 7-0-7', inhale: 7, hold: 0, exhale: 7, cycles: 8, description: 'Chậm hơn — tốt cho người luyện lâu.' },
  { title: 'Tam giác 3-3-3', inhale: 3, hold: 3, exhale: 3, cycles: 10, description: 'Nhanh và dễ — phù hợp người mới.' },
  { title: 'Tam giác 4-4-4', inhale: 4, hold: 4, exhale: 4, cycles: 8, description: 'Vào, giữ, ra — đều nhau.' },
  { title: 'Vào dài 7-4-7', inhale: 7, hold: 4, exhale: 7, cycles: 5, description: 'Vào dài giúp tỉnh táo nhẹ.' },
  { title: 'Thở bụng 4-0-4', inhale: 4, hold: 0, exhale: 4, cycles: 12, description: 'Đặt tay lên bụng, cảm nhận bụng phồng xẹp.' },
  { title: 'Thở bụng 5-0-5', inhale: 5, hold: 0, exhale: 5, cycles: 10, description: 'Thở bằng cơ hoành, không bằng ngực.' },
  { title: 'Thở luân phiên mũi 4-0-4', inhale: 4, hold: 0, exhale: 4, cycles: 8, description: 'Bịt một lỗ mũi luân phiên — kỹ thuật Yoga.' },
  { title: 'Thở sư tử 3-0-3', inhale: 3, hold: 0, exhale: 3, cycles: 6, description: 'Vào mũi, ra miệng cùng tiếng "haa". Giải tỏa nhanh.' },
  { title: 'Thở lửa nhanh 1-0-1', inhale: 1, hold: 0, exhale: 1, cycles: 30, description: 'Thở nhanh và mạnh — tăng năng lượng.' },
  { title: 'Thở mạnh ngực 2-0-4', inhale: 2, hold: 0, exhale: 4, cycles: 10, description: 'Hít sâu vào ngực 2, ra chậm 4.' },
  { title: 'Thở như mưa rơi 3-0-6', inhale: 3, hold: 0, exhale: 6, cycles: 8, description: 'Vào nhanh, ra dài như mưa rơi.' },
  { title: 'Thở núi cao 6-2-6', inhale: 6, hold: 2, exhale: 6, cycles: 6, description: 'Giữ ngắn giữa các nhịp — vững như núi.' },
  { title: 'Thở sóng biển 4-2-6', inhale: 4, hold: 2, exhale: 6, cycles: 8, description: 'Ra dài hơn vào — như sóng vỗ.' },
  { title: 'Thở trước cuộc họp 4-4-4', inhale: 4, hold: 4, exhale: 4, cycles: 4, description: 'Dùng 1 phút trước cuộc họp căng.' },
  { title: 'Thở hồi phục nhanh 2-1-4', inhale: 2, hold: 1, exhale: 4, cycles: 10, description: 'Sau công việc gấp — hồi sức nhanh.' },
  { title: 'Thở buổi sáng đánh thức', inhale: 1, hold: 0, exhale: 1, cycles: 20, description: 'Vài chu kỳ thở lửa để tỉnh táo buổi sáng.' },
  { title: 'Thở buổi trưa nạp lại', inhale: 5, hold: 0, exhale: 5, cycles: 8, description: 'Nạp lại năng lượng giữa ngày.' },
  { title: 'Thở buổi tối thư giãn', inhale: 5, hold: 5, exhale: 5, cycles: 6, description: 'Box breathing chậm để chuyển sang nghỉ.' },
  { title: 'Thở sau tập thể dục', inhale: 4, hold: 0, exhale: 6, cycles: 10, description: 'Giúp nhịp tim chậm lại.' },
  { title: 'Thở khi đau đầu', inhale: 4, hold: 7, exhale: 8, cycles: 6, description: 'Giảm căng cơ vùng đầu cổ.' },
  { title: 'Thở khi lo âu', inhale: 4, hold: 7, exhale: 8, cycles: 8, description: 'Kích hoạt dây thần kinh phế vị, hạ lo âu.' },
  { title: 'Thở khi tức giận 4-2-8', inhale: 4, hold: 2, exhale: 8, cycles: 6, description: 'Ra rất dài để xả áp lực.' },
  { title: 'Thở khi hoang mang', inhale: 5, hold: 5, exhale: 5, cycles: 5, description: 'Box breathing — neo lại tâm trí.' },
  { title: 'Thở khi mất ngủ', inhale: 4, hold: 7, exhale: 8, cycles: 4, description: 'Lặp 4 chu kỳ nằm trên giường.' },
  { title: 'Thở khi buồn 5-3-5', inhale: 5, hold: 3, exhale: 5, cycles: 8, description: 'Cho phép cảm xúc đi qua.' },
  { title: 'Thở khi vui quá mức', inhale: 4, hold: 0, exhale: 4, cycles: 10, description: 'Giữ năng lượng ở mức cân bằng.' },
  { title: 'Thở trước bữa ăn', inhale: 5, hold: 0, exhale: 5, cycles: 6, description: 'Vài phút trước bữa ăn — tiêu hoá tốt hơn.' },
  { title: 'Thở khi lái xe mệt', inhale: 4, hold: 4, exhale: 4, cycles: 4, description: 'Tại đèn đỏ — phục hồi sự chú ý.' },
  { title: 'Thở khi ngồi lâu', inhale: 5, hold: 5, exhale: 5, cycles: 6, description: 'Kết hợp duỗi vai, cổ.' },
  { title: 'Thở khi nhìn màn hình', inhale: 4, hold: 2, exhale: 6, cycles: 5, description: 'Mỗi 20 phút — nghỉ mắt cùng nhịp thở.' },
  { title: 'Thở 4-7-8 cường độ cao', inhale: 4, hold: 7, exhale: 8, cycles: 12, description: '12 chu kỳ liên tục — chỉ làm khi quen.' },
  { title: 'Hộp thở dài 10-10-10', inhale: 10, hold: 10, exhale: 10, cycles: 3, description: 'Box dài — cho người luyện chuyên sâu.' },
  { title: 'Thở 4-7-8 hai vòng', inhale: 4, hold: 7, exhale: 8, cycles: 2, description: 'Phiên ngắn — khi không có thời gian.' },
  { title: 'Thở 4-4-4 hai phút', inhale: 4, hold: 4, exhale: 4, cycles: 10, description: 'Bài 2 phút đều đặn.' },
  { title: 'Thở yêu bản thân 5-0-5', inhale: 5, hold: 0, exhale: 5, cycles: 8, description: 'Mỗi nhịp thở ra, nhắc một điều bạn yêu ở mình.' },
  { title: 'Thở mở lòng 5-3-5', inhale: 5, hold: 3, exhale: 5, cycles: 6, description: 'Ra dài hơn để mở ngực, vai.' },
  { title: 'Thở tập trung 4-0-4', inhale: 4, hold: 0, exhale: 4, cycles: 12, description: 'Trước khi làm việc đòi hỏi tập trung.' },
  { title: 'Thở tỉnh táo sáng', inhale: 1, hold: 0, exhale: 1, cycles: 15, description: '15 chu kỳ thở lửa — đánh thức cơ thể.' },
  { title: 'Thở chánh niệm 5 phút', inhale: 4, hold: 4, exhale: 6, cycles: 15, description: 'Bài 5 phút trước khi bắt đầu thiền.' },
  { title: 'Thở 478 thư giãn cuối ngày', inhale: 4, hold: 7, exhale: 8, cycles: 5, description: 'Vừa đủ trước khi đi ngủ.' },
  { title: 'Thở tự nhiên một phút', inhale: 4, hold: 0, exhale: 4, cycles: 7, description: 'Không pattern phức tạp — chỉ chú ý hơi thở tự nhiên.' },
];

// =============================================================================
// 25 ONBOARDING SLIDES
// =============================================================================
const ONBOARDING = [
  { title: 'Chào mừng đến với Digital Break', subtitle: 'Một góc nhỏ để bạn nghỉ nhẹ.', order: 1 },
  { title: 'Theo dõi cảm xúc hàng ngày', subtitle: 'Vài giây mỗi ngày để biết mình đang ở đâu.', order: 2 },
  { title: 'Bài thở ngắn cho mọi tình huống', subtitle: '50+ bài hít thở từ 30 giây đến 4 phút.', order: 3 },
  { title: 'Nghe âm thanh thư giãn', subtitle: 'Mưa, biển, mèo, café — chọn cái phù hợp mood.', order: 4 },
  { title: 'Viết nhật ký nhỏ', subtitle: 'Một vài dòng cũng đủ để hiểu mình hơn.', order: 5 },
  { title: 'Người bạn đồng hành nhỏ', subtitle: 'Pet sẽ học theo cảm xúc của bạn theo thời gian.', order: 6 },
  { title: 'Phân tích xu hướng cảm xúc', subtitle: 'Xem chuỗi ngày, đỉnh và đáy của tuần.', order: 7 },
  { title: 'Thời tiết theo vị trí', subtitle: 'Cập nhật nhẹ nhàng theo trời nơi bạn ở.', order: 8 },
  { title: 'Đặt nhắc nhở chăm sóc', subtitle: 'Vài lần một ngày — không quấy rầy.', order: 9 },
  { title: 'Chuỗi ngày liên tiếp', subtitle: 'Mỗi ngày check-in là một viên gạch xây thói quen.', order: 10 },
  { title: 'Đăng nhập an toàn', subtitle: 'Hỗ trợ Google Sign-In + mật khẩu cổ điển.', order: 11 },
  { title: 'Xem lịch sử thiết bị', subtitle: 'Biết ai đang đăng nhập tài khoản bạn.', order: 12 },
  { title: 'Đổi giao diện theo ý thích', subtitle: 'Sáng, tối hoặc theo hệ thống — tuỳ bạn.', order: 13 },
  { title: 'Hai ngôn ngữ', subtitle: 'Tiếng Việt và Tiếng Anh — đổi bất cứ lúc nào.', order: 14 },
  { title: 'Đồng bộ trên nhiều thiết bị', subtitle: 'Bắt đầu trên điện thoại, tiếp tục trên laptop.', order: 15 },
  { title: 'Xuất dữ liệu bất cứ lúc nào', subtitle: 'Dữ liệu của bạn — bạn sở hữu.', order: 16 },
  { title: 'Không quảng cáo, không bán dữ liệu', subtitle: 'Chúng tôi tôn trọng sự yên tĩnh của bạn.', order: 17 },
  { title: 'Nghỉ ngơi không phải lười', subtitle: 'Đó là cách bộ não tái tạo.', order: 18 },
  { title: 'Một chuỗi nhỏ mỗi ngày', subtitle: 'Tích góp dần — không cần hoàn hảo.', order: 19 },
  { title: 'Mọi cảm xúc đều có chỗ', subtitle: 'Vui, buồn, lo, mệt — đều được lắng nghe.', order: 20 },
  { title: 'Người bạn pixel của bạn', subtitle: 'Pet sẽ nhớ những lúc bạn cần.', order: 21 },
  { title: 'Phiên thư giãn ngắn', subtitle: 'Từ 1 phút đến 30 phút — bất cứ khi nào cần.', order: 22 },
  { title: 'Câu trích dẫn dịu nhẹ', subtitle: 'Một câu chữ phù hợp mood mỗi ngày.', order: 23 },
  { title: 'Hỗ trợ tiếng Việt đầy đủ', subtitle: 'Không viết tắt, không chêm tiếng Anh.', order: 24 },
  { title: 'Bắt đầu thôi', subtitle: 'Hít một hơi sâu — và mình cùng đi.', order: 25 },
];

// =============================================================================
// 50 COMPANION MESSAGES
// =============================================================================
const COMPANION_MESSAGES = [
  // RANDOM (10)
  { triggerType: 'RANDOM', message: 'Bạn đang làm tốt lắm. Cứ tiếp tục nha.' },
  { triggerType: 'RANDOM', message: 'Có gì uống một ngụm nước không?' },
  { triggerType: 'RANDOM', message: 'Nhớ duỗi vai một chút nhé.' },
  { triggerType: 'RANDOM', message: 'Hôm nay bạn đã cố gắng rồi.' },
  { triggerType: 'RANDOM', message: 'Một nụ cười nhỏ cho chính mình nha.' },
  { triggerType: 'RANDOM', message: 'Đôi mắt của bạn cũng cần nghỉ.' },
  { triggerType: 'RANDOM', message: 'Đứng dậy đi một vòng được không?' },
  { triggerType: 'RANDOM', message: 'Bạn không cần phải vội.' },
  { triggerType: 'RANDOM', message: 'Hít thở sâu một nhịp — mình ở đây.' },
  { triggerType: 'RANDOM', message: 'Lát nữa ăn gì ngon ngon nha.' },
  // MOOD_BASED (15)
  { triggerType: 'MOOD_BASED', userMood: 'STRESSED', message: 'Căng quá thì mình bật chế độ mèo nằm dài: không phán xét, chỉ thở.' },
  { triggerType: 'MOOD_BASED', userMood: 'STRESSED', message: 'Một việc một lúc thôi. Việc đầu tiên là hít một hơi.' },
  { triggerType: 'MOOD_BASED', userMood: 'STRESSED', message: 'Áp lực hôm nay sẽ qua. Bạn đã qua bao lần rồi.' },
  { triggerType: 'MOOD_BASED', userMood: 'ANXIOUS', message: 'Đếm 5 thứ bạn thấy quanh mình. Mình ở thực tại nha.' },
  { triggerType: 'MOOD_BASED', userMood: 'ANXIOUS', message: 'Lo lắng là tin nhắn, không phải sự thật.' },
  { triggerType: 'MOOD_BASED', userMood: 'ANXIOUS', message: 'Hít vào 4, giữ 7, ra 8 — thử một lần xem nha.' },
  { triggerType: 'MOOD_BASED', userMood: 'SAD', message: 'Có chuyện gì thì mình nghe từng chút. Không cần kể phiên bản hoàn hảo.' },
  { triggerType: 'MOOD_BASED', userMood: 'SAD', message: 'Bạn được phép buồn. Cảm xúc nào cũng quan trọng.' },
  { triggerType: 'MOOD_BASED', userMood: 'TIRED', message: 'Mệt là cơ thể nói chuyện. Mình lắng nghe nhé.' },
  { triggerType: 'MOOD_BASED', userMood: 'TIRED', message: 'Nằm xuống 10 phút cũng được. Không sao cả.' },
  { triggerType: 'MOOD_BASED', userMood: 'LONELY', message: 'Mình vẫn ở đây. Không xa đâu.' },
  { triggerType: 'MOOD_BASED', userMood: 'HAPPY', message: 'Vui như vầy hay quá! Ghi lại để nhớ nha.' },
  { triggerType: 'MOOD_BASED', userMood: 'CALM', message: 'Tĩnh lặng đẹp lắm. Tận hưởng đi.' },
  { triggerType: 'MOOD_BASED', userMood: 'GRATEFUL', message: 'Lòng biết ơn là vitamin cho não đó.' },
  { triggerType: 'MOOD_BASED', userMood: 'EXCITED', message: 'Năng lượng này — dùng cho việc bạn yêu nha.' },
  // TIME_BASED (10)
  { triggerType: 'TIME_BASED', hourOfDay: 6, message: 'Chào buổi sáng. Một ngày mới — mình bắt đầu nhẹ thôi.' },
  { triggerType: 'TIME_BASED', hourOfDay: 8, message: 'Uống nước trước khi check email nha.' },
  { triggerType: 'TIME_BASED', hourOfDay: 10, message: 'Giữa sáng rồi — đứng lên một chút.' },
  { triggerType: 'TIME_BASED', hourOfDay: 12, message: 'Trưa rồi nè — ăn gì ấm bụng nha.' },
  { triggerType: 'TIME_BASED', hourOfDay: 14, message: 'Sau bữa trưa hay buồn ngủ. Vài bước đi giúp tỉnh táo.' },
  { triggerType: 'TIME_BASED', hourOfDay: 16, message: 'Chiều rồi nè. Mục tiêu hôm nay xong tới đâu?' },
  { triggerType: 'TIME_BASED', hourOfDay: 18, message: 'Tan ca giờ này hay chưa? Nghỉ trước khi nghĩ tiếp.' },
  { triggerType: 'TIME_BASED', hourOfDay: 20, message: 'Tối rồi. Hôm nay nhớ điều gì làm bạn cười?' },
  { triggerType: 'TIME_BASED', hourOfDay: 22, message: 'Khuya rồi — mình dần chuyển sang nghỉ nha.' },
  { triggerType: 'TIME_BASED', hourOfDay: 0, message: 'Đêm muộn — đi ngủ giúp não bộ phục hồi.' },
  // RETURNING_USER (5)
  { triggerType: 'RETURNING_USER', message: 'Bạn đã quay về với mình. Đó là một động tác chăm sóc bản thân rất đẹp.' },
  { triggerType: 'RETURNING_USER', message: 'Mừng quá! Mình nhớ bạn.' },
  { triggerType: 'RETURNING_USER', message: 'Vắng bạn vài hôm rồi. Mọi thứ ổn chứ?' },
  { triggerType: 'RETURNING_USER', message: 'Quay lại là một thành công. Không cần giải thích vì sao đi.' },
  { triggerType: 'RETURNING_USER', message: 'Mình ở đây. Bạn không cần làm gì cả.' },
  // STREAK_MILESTONE (5)
  { triggerType: 'RANDOM', message: '7 ngày liên tiếp! Chuỗi nhỏ này lớn hơn bạn nghĩ.' },
  { triggerType: 'RANDOM', message: '14 ngày — bạn đang xây thói quen rất đẹp.' },
  { triggerType: 'RANDOM', message: '21 ngày — đủ để não bộ ghi nhận thành nhịp.' },
  { triggerType: 'RANDOM', message: '30 ngày! Mình tự hào về bạn ghê.' },
  { triggerType: 'RANDOM', message: '100 ngày — đây là phiên bản hết sảy của bạn.' },
  // CHECKIN_REMINDER (5)
  { triggerType: 'RANDOM', message: 'Hôm nay bạn cảm thấy thế nào? Vài giây là đủ.' },
  { triggerType: 'RANDOM', message: 'Một check-in nhanh nhé — không cần dài.' },
  { triggerType: 'RANDOM', message: 'Ghi lại cảm xúc giờ này — mai bạn sẽ cảm ơn.' },
  { triggerType: 'RANDOM', message: 'Mood hiện tại là gì? Chia sẻ với mình nha.' },
  { triggerType: 'RANDOM', message: 'Cảm xúc đến rồi đi. Ghi nhận giúp ta hiểu mình hơn.' },
];

// =============================================================================
async function seedQuotes() {
  console.log(`→ Seeding ${QUOTES.length} cozy quotes…`);
  let inserted = 0, updated = 0;
  for (const q of QUOTES) {
    const existing = await prisma.cozyQuote.findFirst({
      where: { content: q.content },
      select: { id: true },
    });
    // Schema: { content, author?, mood?, imageUrl?, isActive }. No `weight`.
    const data = {
      content: q.content,
      mood: q.mood,
      isActive: true,
    };
    if (existing) {
      await prisma.cozyQuote.update({ where: { id: existing.id }, data });
      updated++;
    } else {
      await prisma.cozyQuote.create({ data });
      inserted++;
    }
  }
  console.log(`  ✓ ${inserted} new, ${updated} updated`);
}

async function seedBreathing() {
  console.log(`→ Seeding ${BREATHING.length} breathing exercises…`);
  let inserted = 0, updated = 0;
  for (const b of BREATHING) {
    const existing = await prisma.breathingExercise.findFirst({
      where: { title: b.title },
      select: { id: true },
    });
    // Schema: { title, description?, inhaleSeconds, holdSeconds,
    //   exhaleSeconds, cycles, duration?, imageUrl?, isActive }
    const duration = (b.inhale + b.hold + b.exhale) * b.cycles;
    const data = {
      title: b.title,
      description: b.description,
      inhaleSeconds: b.inhale,
      holdSeconds: b.hold,
      exhaleSeconds: b.exhale,
      cycles: b.cycles,
      duration,
      isActive: true,
    };
    if (existing) {
      await prisma.breathingExercise.update({ where: { id: existing.id }, data });
      updated++;
    } else {
      await prisma.breathingExercise.create({ data });
      inserted++;
    }
  }
  console.log(`  ✓ ${inserted} new, ${updated} updated`);
}

async function seedOnboarding() {
  console.log(`→ Seeding ${ONBOARDING.length} onboarding slides…`);
  let inserted = 0, updated = 0;
  for (const o of ONBOARDING) {
    const existing = await prisma.onboardingSlide.findFirst({
      where: { title: o.title },
      select: { id: true },
    });
    // Schema: { title, subtitle?, description?, imageUrl?, animationUrl?,
    //   displayOrder, isActive }
    const data = {
      title: o.title,
      subtitle: o.subtitle,
      displayOrder: o.order,
      isActive: true,
    };
    if (existing) {
      await prisma.onboardingSlide.update({ where: { id: existing.id }, data });
      updated++;
    } else {
      await prisma.onboardingSlide.create({ data });
      inserted++;
    }
  }
  console.log(`  ✓ ${inserted} new, ${updated} updated`);
}

async function seedCompanionMessages() {
  console.log(`→ Seeding ${COMPANION_MESSAGES.length} companion messages…`);
  let inserted = 0, updated = 0;
  for (const m of COMPANION_MESSAGES) {
    const existing = await prisma.companionMessage.findFirst({
      where: { content: m.message },
      select: { id: true },
    });
    // Schema: { content, triggerType, mood?, companionMood?, minHour?,
    //   maxHour?, weight, isActive }
    const data = {
      content: m.message,
      triggerType: m.triggerType,
      mood: m.userMood ?? null,
      companionMood: null,
      // TIME_BASED: anchor to a 2-hour window around the target hour.
      minHour: m.hourOfDay != null ? m.hourOfDay : null,
      maxHour: m.hourOfDay != null ? (m.hourOfDay + 1) % 24 : null,
      weight: 1,
      isActive: true,
    };
    if (existing) {
      await prisma.companionMessage.update({ where: { id: existing.id }, data });
      updated++;
    } else {
      await prisma.companionMessage.create({ data });
      inserted++;
    }
  }
  console.log(`  ✓ ${inserted} new, ${updated} updated`);
}

async function main() {
  await seedQuotes();
  await seedBreathing();
  await seedOnboarding();
  await seedCompanionMessages();
  console.log('\n✓ Done.');
}

main()
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
