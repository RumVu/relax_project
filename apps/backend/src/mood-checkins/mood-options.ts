import { MoodType } from '@prisma/client';

export type MoodActionType = 'MEDITATION' | 'BREATHING' | 'JOURNAL' | 'MUSIC';

export interface MoodOption {
  mood: MoodType;
  label: string;
  shortLabel: string;
  description: string;
  companionLine: string;
  iconKey: string;
  color: string;
  darkColor: string;
  sortOrder: number;
  recommendedActions: MoodActionType[];
}

export const MOOD_OPTIONS = [
  {
    mood: MoodType.HAPPY,
    label: 'Vui vẻ',
    shortLabel: 'Vui',
    description: 'Năng lượng đang sáng và nhẹ nhàng.',
    companionLine: 'Giữ lại khoảnh khắc vui này nha ~',
    iconKey: 'cat-happy',
    color: '#f6c453',
    darkColor: '#fbbf24',
    sortOrder: 10,
    recommendedActions: ['JOURNAL', 'MUSIC', 'MEDITATION'],
  },
  {
    mood: MoodType.SAD,
    label: 'Buồn',
    shortLabel: 'Buồn',
    description: 'Có chút nặng lòng, cần được lắng nghe.',
    companionLine: 'Buồn thì ngồi xuống đây, kể tui nghe nè.',
    iconKey: 'cat-sad',
    color: '#7c9df2',
    darkColor: '#818cf8',
    sortOrder: 20,
    recommendedActions: ['JOURNAL', 'BREATHING', 'MUSIC'],
  },
  {
    mood: MoodType.STRESSED,
    label: 'Stress',
    shortLabel: 'Stress',
    description: 'Đầu hơi căng, cơ thể cần được thả lỏng.',
    companionLine: 'Stress quá mới tìm đến tui hở? Bạn kể tui nghe đi nè!',
    iconKey: 'cat-stressed',
    color: '#dd78d6',
    darkColor: '#e879f9',
    sortOrder: 30,
    recommendedActions: ['BREATHING', 'MEDITATION', 'MUSIC'],
  },
  {
    mood: MoodType.TIRED,
    label: 'Chán nản',
    shortLabel: 'Chán',
    description: 'Năng lượng xuống thấp, cần một nhịp nghỉ mềm.',
    companionLine: 'Mệt rồi thì mình chậm lại một xíu nha.',
    iconKey: 'cat-tired',
    color: '#a78bfa',
    darkColor: '#c4b5fd',
    sortOrder: 40,
    recommendedActions: ['MUSIC', 'BREATHING', 'MEDITATION'],
  },
  {
    mood: MoodType.ANXIOUS,
    label: 'Mất động lực',
    shortLabel: 'Lo',
    description: 'Tâm trí hơi rối, cần một điểm tựa nhỏ.',
    companionLine: 'Không cần giải quyết hết liền đâu, mình gỡ từng chút thôi.',
    iconKey: 'cat-anxious',
    color: '#7775d6',
    darkColor: '#8b8cf6',
    sortOrder: 50,
    recommendedActions: ['BREATHING', 'JOURNAL', 'MEDITATION'],
  },
  {
    mood: MoodType.NEUTRAL,
    label: 'Bình thường',
    shortLabel: 'Ổn',
    description: 'Trạng thái cân bằng, không quá lên hay xuống.',
    companionLine: 'Ổn cũng là một dạng rất đáng quý đó nha.',
    iconKey: 'cat-neutral',
    color: '#9c8edb',
    darkColor: '#a5b4fc',
    sortOrder: 60,
    recommendedActions: ['MEDITATION', 'JOURNAL', 'MUSIC'],
  },
  {
    mood: MoodType.CALM,
    label: 'Bình yên',
    shortLabel: 'Yên',
    description: 'Tâm trí đang dịu, hợp để giữ nhịp chăm sóc bản thân.',
    companionLine: 'Êm vậy thì mình giữ mood này thêm chút nữa nha.',
    iconKey: 'cat-calm',
    color: '#6cc8b8',
    darkColor: '#5eead4',
    sortOrder: 70,
    recommendedActions: ['MEDITATION', 'MUSIC', 'JOURNAL'],
  },
  {
    mood: MoodType.EXCITED,
    label: 'Hào hứng',
    shortLabel: 'Hứng',
    description: 'Nhiều năng lượng, dễ bắt đầu một việc tích cực.',
    companionLine: 'Có năng lượng rồi thì mình dùng nó thật đẹp nha!',
    iconKey: 'cat-excited',
    color: '#fb923c',
    darkColor: '#fdba74',
    sortOrder: 80,
    recommendedActions: ['JOURNAL', 'MUSIC', 'MEDITATION'],
  },
  {
    mood: MoodType.LONELY,
    label: 'Cô đơn',
    shortLabel: 'Cô đơn',
    description: 'Cần cảm giác được ở cạnh và được nhìn thấy.',
    companionLine: 'Có tui ở đây nè, không cần một mình quá lâu đâu.',
    iconKey: 'cat-lonely',
    color: '#94a3b8',
    darkColor: '#cbd5e1',
    sortOrder: 90,
    recommendedActions: ['JOURNAL', 'MUSIC', 'BREATHING'],
  },
  {
    mood: MoodType.GRATEFUL,
    label: 'Biết ơn',
    shortLabel: 'Biết ơn',
    description: 'Có điều gì đó đáng trân trọng trong ngày.',
    companionLine: 'Nhớ ghi lại điều đẹp đó nha, để mai còn mỉm cười.',
    iconKey: 'cat-grateful',
    color: '#f59e0b',
    darkColor: '#facc15',
    sortOrder: 100,
    recommendedActions: ['JOURNAL', 'MEDITATION', 'MUSIC'],
  },
] satisfies MoodOption[];

export const DEFAULT_MOOD_OPTION = MOOD_OPTIONS.find(
  (option) => option.mood === MoodType.NEUTRAL,
)!;

export function getMoodOption(mood?: MoodType | null) {
  return (
    MOOD_OPTIONS.find((option) => option.mood === mood) ?? DEFAULT_MOOD_OPTION
  );
}
