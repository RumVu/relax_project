import { RelaxActivityType } from '@prisma/client';

export { RelaxActivityType };

export interface RelaxActivityOption {
  type: RelaxActivityType;
  title: string;
  subtitle: string;
  description: string;
  iconKey: string;
  sortOrder: number;
  defaultDurationMinutes: number;
  deepLink: string;
  finishPrompt: string;
}

export const RELAX_ACTIVITY_OPTIONS = [
  {
    type: RelaxActivityType.MUSIC,
    title: 'Nhạc',
    subtitle: 'Những giai điệu nhẹ nhàng giúp tâm trí bạn thư giãn.',
    description: 'Nghe nhạc hoặc âm thanh nền để dịu nhịp cảm xúc.',
    iconKey: 'pixel-boombox',
    sortOrder: 10,
    defaultDurationMinutes: 25,
    deepLink: 'relax://ambient-sounds',
    finishPrompt: 'Âm thanh vừa rồi giúp bạn thế nào?',
  },
  {
    type: RelaxActivityType.PODCAST,
    title: 'Podcast',
    subtitle: 'Lắng nghe những câu chuyện truyền cảm hứng mỗi ngày.',
    description: 'Một nội dung ngắn để kéo tâm trí khỏi vòng căng thẳng.',
    iconKey: 'pixel-microphone',
    sortOrder: 20,
    defaultDurationMinutes: 20,
    deepLink: 'relax://podcasts',
    finishPrompt: 'Câu chuyện vừa rồi có làm lòng bạn nhẹ hơn không?',
  },
  {
    type: RelaxActivityType.JOURNAL,
    title: 'Viết nhật kí',
    subtitle: 'Ghi lại cảm xúc và suy nghĩ để nhẹ lòng hơn nhé.',
    description: 'Viết vài dòng để gọi tên điều đang diễn ra bên trong.',
    iconKey: 'pixel-journal',
    sortOrder: 30,
    defaultDurationMinutes: 15,
    deepLink: 'relax://journals/new',
    finishPrompt: 'Viết ra rồi, lòng bạn đang thế nào?',
  },
  {
    type: RelaxActivityType.BREATHING,
    title: 'Hít thở không khí',
    subtitle: 'Hít thở sâu, thả lỏng cơ thể và sống chậm lại nào.',
    description: 'Một bài thở ngắn để giảm tải cơ thể.',
    iconKey: 'pixel-breath-cloud',
    sortOrder: 40,
    defaultDurationMinutes: 10,
    deepLink: 'relax://breathing-exercises',
    finishPrompt: 'Nhịp thở vừa rồi giúp bạn giảm tải bao nhiêu?',
  },
  {
    type: RelaxActivityType.MEDITATION,
    title: 'Thiền định',
    subtitle: 'Ngồi yên một chút để tâm trí có chỗ thở.',
    description: 'Một phiên thiền ngắn giúp hạ tải và quay về với mình.',
    iconKey: 'pixel-lotus',
    sortOrder: 45,
    defaultDurationMinutes: 12,
    deepLink: 'relax://meditation',
    finishPrompt: 'Khoảng lặng vừa rồi giúp bạn dịu xuống bao nhiêu?',
  },
  {
    type: RelaxActivityType.MYSTERY,
    title: 'Bí ẩn',
    subtitle: 'Để mình chọn một hoạt động bất ngờ phù hợp với bạn!',
    description: 'Một lựa chọn ngẫu nhiên dựa trên dữ liệu mood gần đây.',
    iconKey: 'pixel-mystery-box',
    sortOrder: 50,
    defaultDurationMinutes: 12,
    deepLink: 'relax://surprise',
    finishPrompt: 'Hoạt động bất ngờ này hợp với bạn chứ?',
  },
] satisfies RelaxActivityOption[];

export function getRelaxActivityOption(type: RelaxActivityType) {
  return RELAX_ACTIVITY_OPTIONS.find((option) => option.type === type);
}
