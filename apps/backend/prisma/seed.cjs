// @ts-nocheck
const {
  AchievementType,
  AuthProvider,
  BillingCycle,
  CompanionMood,
  CompanionPersonalizationMode,
  CompanionType,
  NotificationType,
  MessageTriggerType,
  MoodType,
  PrismaClient,
  RelaxActivityType,
  RelaxSessionStatus,
  ReminderType,
  SubscriptionStatus,
  ThemeMode,
  UserRole,
} = require('@prisma/client');
const bcrypt = require('bcrypt');
const {
  AMBIENT_SOUND_CATALOG,
} = require('./ambient-sounds.catalog.cjs');
const { EXTRA_COZY_QUOTES } = require('./cozy-quotes.extra.cjs');
const { ENGLISH_COZY_QUOTES } = require('./cozy-quotes.en-seed.cjs');

const prisma = new PrismaClient();
const supabaseAssetUrl =
  process.env.SUPABASE_URL ?? process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAssetBucket = process.env.SUPABASE_BUCKET ?? 'public-assets';
const ASSET_BASE =
  supabaseAssetUrl
    ? `${supabaseAssetUrl}/storage/v1/object/public/${supabaseAssetBucket}`
    : 'https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets';

async function upsertByField(model, field, value, data) {
  const existing = await model.findFirst({
    where: { [field]: value },
    select: { id: true },
  });

  if (existing) {
    return model.update({
      where: { id: existing.id },
      data,
    });
  }

  return model.create({ data });
}

async function upsertSearchIndex({ entityType, entityId, title, content, tags }) {
  await prisma.searchIndex.upsert({
    where: {
      entityType_entityId: {
        entityType,
        entityId,
      },
    },
    update: {
      title: clip(title, 96),
      content,
      tags: normalizeTags(tags),
    },
    create: {
      entityType,
      entityId,
      title: clip(title, 96),
      content,
      tags: normalizeTags(tags),
    },
  });
}

function normalizeTags(tags) {
  return [...new Set(tags.filter(Boolean).map((tag) => String(tag).toLowerCase()))];
}

function compactText(parts) {
  return parts.filter(Boolean).join(' ');
}

function clip(value, length) {
  const text = String(value ?? '').trim();
  return text.length <= length ? text : `${text.slice(0, length - 1)}...`;
}

async function seedSubscriptionTiers() {
  const tiers = [
    {
      name: 'FREE',
      description: 'Gói miễn phí cho người mới bắt đầu.',
      price: 0,
      currency: 'VND',
      billingCycle: BillingCycle.MONTHLY,
      displayOrder: 0,
      isActive: true,
      features: [
        ['mood_tracking', true, 'Theo dõi mood hằng ngày.'],
        ['journal_entries', true, 'Viết nhật ký cá nhân.'],
      ],
      limits: [
        ['moods_per_day', 5, 'count'],
        ['reminders', 3, 'count'],
      ],
    },
    {
      name: 'CHILL_PLUS',
      description: 'Gói mở rộng cho thống kê sâu và companion custom.',
      price: 49000,
      currency: 'VND',
      billingCycle: BillingCycle.MONTHLY,
      displayOrder: 1,
      isActive: true,
      features: [
        ['mood_tracking', true, 'Theo dõi mood không giới hạn.'],
        ['advanced_analytics', true, 'Thống kê cảm xúc nâng cao.'],
        ['companion_custom', true, 'Tùy chỉnh linh thú đồng hành.'],
        ['smart_reminders', true, 'Nhắc nhở chăm sóc bản thân thông minh.'],
      ],
      limits: [
        ['moods_per_day', 100, 'count'],
        ['reminders', 25, 'count'],
      ],
    },
    {
      name: 'CHILL_PLUS_ANNUAL',
      description: 'Gói năm tiết kiệm cho người dùng lâu dài.',
      price: 490000,
      currency: 'VND',
      billingCycle: BillingCycle.ANNUAL,
      displayOrder: 2,
      isActive: true,
      features: [
        ['mood_tracking', true, 'Theo dõi mood không giới hạn.'],
        ['advanced_analytics', true, 'Thống kê cảm xúc nâng cao.'],
        ['companion_custom', true, 'Tùy chỉnh linh thú đồng hành.'],
        ['priority_support', true, 'Ưu tiên hỗ trợ khi cần.'],
      ],
      limits: [
        ['moods_per_day', 100, 'count'],
        ['reminders', 50, 'count'],
      ],
    },
  ];

  for (const tierData of tiers) {
    const { features, limits, ...tier } = tierData;
    const savedTier = await prisma.subscriptionTier.upsert({
      where: { name: tier.name },
      update: tier,
      create: tier,
    });

    for (const [name, included, description] of features) {
      await prisma.tierFeature.upsert({
        where: { tierId_name: { tierId: savedTier.id, name } },
        update: { included, description },
        create: { tierId: savedTier.id, name, included, description },
      });
    }

    for (const [name, value, unit] of limits) {
      await prisma.tierLimit.upsert({
        where: { tierId_name: { tierId: savedTier.id, name } },
        update: { value, unit },
        create: { tierId: savedTier.id, name, value, unit },
      });
    }
  }
}

async function seedAchievements() {
  const achievements = [
    {
      title: 'First Check-In',
      description: 'Ghi nhận mood đầu tiên.',
      type: AchievementType.EXPLORATION,
      icon: 'spark',
      points: 10,
      condition: { event: 'MOOD_CREATED', count: 1 },
      isActive: true,
    },
    {
      title: 'Mindful Week',
      description: 'Hoàn thành 7 hoạt động chăm sóc bản thân.',
      type: AchievementType.CONSISTENCY,
      icon: 'calendar-heart',
      points: 25,
      condition: { event: 'SESSION_COMPLETED', count: 7 },
      isActive: true,
    },
    {
      title: 'Calm Builder',
      description: 'Hoàn thành 10 phiên thiền hoặc thở.',
      type: AchievementType.WELLNESS,
      icon: 'lotus',
      points: 50,
      condition: { event: 'RELAX_ACTIVITY_COMPLETED', count: 10 },
      isActive: true,
    },
  ];

  for (const achievement of achievements) {
    await upsertByField(
      prisma.achievement,
      'title',
      achievement.title,
      achievement,
    );
  }
}

async function seedBadges() {
  const badges = [
    {
      title: 'Starter',
      description: 'Hoàn thành hoạt động đầu tiên.',
      icon: 'spark',
      category: 'BEGINNER',
      rarity: 'COMMON',
      isActive: true,
    },
    {
      title: 'Focused',
      description: 'Duy trì routine chăm sóc bản thân ổn định.',
      icon: 'target',
      category: 'ACTIVE',
      rarity: 'RARE',
      isActive: true,
    },
    {
      title: 'Zen Master',
      description: 'Chạm mốc chăm sóc tinh thần nâng cao.',
      icon: 'lotus',
      category: 'MASTER',
      rarity: 'EPIC',
      isActive: true,
    },
  ];

  for (const badge of badges) {
    await upsertByField(prisma.badge, 'title', badge.title, badge);
  }
}

async function seedThemes() {
  const themes = [
    {
      name: 'Pixel Lavender Light',
      mode: ThemeMode.LIGHT,
      backgroundColor: '#F8F6FF',
      surfaceColor: '#FFFFFF',
      primaryColor: '#6D5DFB',
      secondaryColor: '#BCA8FF',
      accentColor: '#FFB4A8',
      textColor: '#261D55',
      mutedTextColor: '#7E76A6',
      isDefault: true,
      isActive: true,
    },
    {
      name: 'Midnight Pixel Calm',
      mode: ThemeMode.DARK,
      backgroundColor: '#101326',
      surfaceColor: '#181D38',
      primaryColor: '#8B7CFF',
      secondaryColor: '#6ED3D1',
      accentColor: '#FF9E8A',
      textColor: '#F4F1FF',
      mutedTextColor: '#A9A2CF',
      isDefault: false,
      isActive: true,
    },
    {
      name: 'Soft Garden Focus',
      mode: ThemeMode.LIGHT,
      backgroundColor: '#F3FAF6',
      surfaceColor: '#FFFFFF',
      primaryColor: '#3A8F73',
      secondaryColor: '#7BC8A4',
      accentColor: '#F2B66D',
      textColor: '#17382F',
      mutedTextColor: '#6D8179',
      isDefault: false,
      isActive: true,
    },
    {
      name: 'Peach Tea Afternoon',
      mode: ThemeMode.LIGHT,
      backgroundColor: '#FFF6EC',
      surfaceColor: '#FFFFFF',
      primaryColor: '#C76E4B',
      secondaryColor: '#FFD8B5',
      accentColor: '#7AB8A8',
      textColor: '#3E2419',
      mutedTextColor: '#8B6F61',
      isDefault: false,
      isActive: true,
    },
    {
      name: 'Forest Rain Reset',
      mode: ThemeMode.DARK,
      backgroundColor: '#0E1F1A',
      surfaceColor: '#153129',
      primaryColor: '#78D6A3',
      secondaryColor: '#30594C',
      accentColor: '#F0C987',
      textColor: '#EAF8F0',
      mutedTextColor: '#A7C8B6',
      isDefault: false,
      isActive: true,
    },
    {
      name: 'Ocean Nap',
      mode: ThemeMode.LIGHT,
      backgroundColor: '#EFF9FF',
      surfaceColor: '#FFFFFF',
      primaryColor: '#2E7AAE',
      secondaryColor: '#A8D8F0',
      accentColor: '#F7B267',
      textColor: '#14324A',
      mutedTextColor: '#5E7A90',
      isDefault: false,
      isActive: true,
    },
    {
      name: 'Cozy Ember Night',
      mode: ThemeMode.DARK,
      backgroundColor: '#17100F',
      surfaceColor: '#241817',
      primaryColor: '#FF9F6E',
      secondaryColor: '#5B3430',
      accentColor: '#FFD166',
      textColor: '#FFF4EC',
      mutedTextColor: '#D2B6A8',
      isDefault: false,
      isActive: true,
    },
    {
      name: 'Matcha Desk Light',
      mode: ThemeMode.LIGHT,
      backgroundColor: '#F7FAEF',
      surfaceColor: '#FFFFFF',
      primaryColor: '#5F8F3E',
      secondaryColor: '#DDEBCB',
      accentColor: '#E7A977',
      textColor: '#243619',
      mutedTextColor: '#6E7D60',
      isDefault: false,
      isActive: true,
    },
    {
      name: 'Sky Pillow',
      mode: ThemeMode.LIGHT,
      backgroundColor: '#F2F7FF',
      surfaceColor: '#FFFFFF',
      primaryColor: '#5D7CFB',
      secondaryColor: '#C8D7FF',
      accentColor: '#F5B7C8',
      textColor: '#1C2D5A',
      mutedTextColor: '#65759B',
      isDefault: false,
      isActive: true,
    },
    {
      name: 'Night Train Soft',
      mode: ThemeMode.DARK,
      backgroundColor: '#111827',
      surfaceColor: '#1F2937',
      primaryColor: '#9CC9FF',
      secondaryColor: '#35465F',
      accentColor: '#F4B860',
      textColor: '#F8FAFC',
      mutedTextColor: '#C7D2E1',
      isDefault: false,
      isActive: true,
    },
  ];

  for (const theme of themes) {
    await prisma.appTheme.upsert({
      where: { name: theme.name },
      update: theme,
      create: theme,
    });
  }
}

async function seedOnboardingSlides() {
  const slides = [
    {
      title: 'Chào mừng quay lại',
      subtitle: 'Một góc nhỏ để bạn nghỉ nhẹ.',
      description:
        'Check-in cảm xúc, chọn hoạt động thư giãn và theo dõi tiến trình mỗi ngày.',
      imageUrl: `${ASSET_BASE}/onboarding/welcome-pixel-room.png`,
      animationUrl: `${ASSET_BASE}/onboarding/welcome-pixel-room.json`,
      displayOrder: 1,
      isActive: true,
    },
    {
      title: 'Nghe cảm xúc của mình',
      subtitle: 'Không cần phán xét, chỉ cần ghi nhận.',
      description:
        'Mỗi check-in sẽ giúp app hiểu mood, điểm stress và gợi ý hoạt động phù hợp hơn.',
      imageUrl: `${ASSET_BASE}/onboarding/mood-checkin.png`,
      animationUrl: `${ASSET_BASE}/onboarding/mood-checkin.json`,
      displayOrder: 2,
      isActive: true,
    },
    {
      title: 'Có một linh thú ở cạnh',
      subtitle: 'Pet nhỏ sẽ đồng hành theo nhịp cảm xúc của bạn.',
      description:
        'Bạn có thể chọn pet mặc định, theo cung hoàng đạo, theo 12 con giáp hoặc tự chọn.',
      imageUrl: `${ASSET_BASE}/onboarding/companion-choice.png`,
      animationUrl: `${ASSET_BASE}/onboarding/companion-choice.json`,
      displayOrder: 3,
      isActive: true,
    },
  ];

  for (const slide of slides) {
    await upsertByField(prisma.onboardingSlide, 'title', slide.title, slide);
  }
}

async function seedCompanionAssets() {
  const baseAssets = [
    {
      name: 'Pixel Cat Default',
      type: CompanionType.CAT,
      description: 'Linh thú mèo pixel mặc định cho màn hình home.',
      key: 'pixel-cat-default',
      primaryColor: '#7C5CFF',
      secondaryColor: '#BCA8FF',
      accentColor: '#FFB4A8',
      isDefault: true,
    },
    {
      name: 'Cloud Rabbit Calm',
      type: CompanionType.RABBIT,
      description: 'Linh thú thỏ mây dịu nhẹ cho custom mode.',
      key: 'cloud-rabbit-calm',
      primaryColor: '#6ED3D1',
      secondaryColor: '#D7FFFA',
      accentColor: '#F2B66D',
      isDefault: false,
    },
  ];

  const zodiacAssets = [
    ['Aries', 'Ram Spark'],
    ['Taurus', 'Tea Bull'],
    ['Gemini', 'Twin Star'],
    ['Cancer', 'Moon Crab'],
    ['Leo', 'Sun Cub'],
    ['Virgo', 'Leaf Fox'],
    ['Libra', 'Balance Swan'],
    ['Scorpio', 'Night Scorpion'],
    ['Sagittarius', 'Arrow Deer'],
    ['Capricorn', 'Mountain Goat'],
    ['Aquarius', 'Cloud Otter'],
    ['Pisces', 'Dream Fish'],
  ].map(([zodiacSign, label]) => ({
    name: `Zodiac ${label}`,
    type: CompanionType.CUSTOM,
    description: `Linh thú cá nhân hoá theo cung ${zodiacSign}.`,
    key: `zodiac-${zodiacSign.toLowerCase()}`,
    zodiacSign,
    primaryColor: '#6D5DFB',
    secondaryColor: '#A9D8FF',
    accentColor: '#FFD166',
    isDefault: false,
  }));

  const chineseAssets = [
    ['Rat', 'Pocket Rat'],
    ['Ox', 'Calm Ox'],
    ['Tiger', 'Soft Tiger'],
    ['Rabbit', 'Moon Rabbit'],
    ['Dragon', 'Tiny Dragon'],
    ['Snake', 'Silk Snake'],
    ['Horse', 'Wind Horse'],
    ['Goat', 'Cozy Goat'],
    ['Monkey', 'Spark Monkey'],
    ['Rooster', 'Morning Rooster'],
    ['Dog', 'Loyal Dog'],
    ['Pig', 'Lucky Pig'],
  ].map(([chineseZodiac, label]) => ({
    name: `Chinese Zodiac ${label}`,
    type: CompanionType.CUSTOM,
    description: `Linh thú cá nhân hoá theo con giáp ${chineseZodiac}.`,
    key: `chinese-${chineseZodiac.toLowerCase()}`,
    chineseZodiac,
    primaryColor: '#3A8F73',
    secondaryColor: '#B8E6D3',
    accentColor: '#FF9E8A',
    isDefault: false,
  }));

  for (const asset of [...baseAssets, ...zodiacAssets, ...chineseAssets]) {
    const data = {
      name: asset.name,
      type: asset.type,
      description: asset.description,
      previewImageUrl: `${ASSET_BASE}/companions/${asset.key}/preview.png`,
      spriteSheetUrl: `${ASSET_BASE}/companions/${asset.key}/sprite.png`,
      idleAnimationUrl: `${ASSET_BASE}/companions/${asset.key}/idle.gif`,
      sleepAnimationUrl: `${ASSET_BASE}/companions/${asset.key}/sleep.gif`,
      walkAnimationUrl: `${ASSET_BASE}/companions/${asset.key}/walk.gif`,
      primaryColor: asset.primaryColor,
      secondaryColor: asset.secondaryColor,
      accentColor: asset.accentColor,
      zodiacSign: asset.zodiacSign,
      chineseZodiac: asset.chineseZodiac,
      isDefault: asset.isDefault,
      isActive: true,
    };

    await upsertByField(prisma.companionAsset, 'name', data.name, data);
  }
}

async function seedCompanionMessages() {
  const messages = [
    {
      content: 'Mình ở đây nè. Hít một hơi nhỏ trước nha.',
      triggerType: MessageTriggerType.FIRST_OPEN,
      companionMood: CompanionMood.CALM,
      weight: 10,
      isActive: true,
    },
    {
      content: 'Stress quá mới tìm đến mình hở? Kể mình nghe một chút đi.',
      triggerType: MessageTriggerType.MOOD_BASED,
      mood: MoodType.STRESSED,
      companionMood: CompanionMood.CURIOUS,
      weight: 10,
      isActive: true,
    },
    {
      content: 'Khuya rồi đó, mình hạ âm lượng trong đầu xuống một xíu nha.',
      triggerType: MessageTriggerType.NIGHT_TIME,
      minHour: 21,
      maxHour: 23,
      companionMood: CompanionMood.SLEEPY,
      weight: 8,
      isActive: true,
    },
    {
      content: 'Bạn vừa check-in rồi, vậy là đã chăm sóc mình thêm một chút.',
      triggerType: MessageTriggerType.AFTER_CHECKIN,
      companionMood: CompanionMood.HAPPY,
      weight: 7,
      isActive: true,
    },
    {
      content: 'Ở lại lâu rồi nè. Uống nước, duỗi vai, rồi quay lại cũng được.',
      triggerType: MessageTriggerType.LONG_SESSION,
      companionMood: CompanionMood.CHILL,
      weight: 6,
      isActive: true,
    },
    {
      content: 'Não đang mở 47 tab rồi đó. Mình đóng giùm tab "tự trách" nha?',
      triggerType: MessageTriggerType.RANDOM,
      companionMood: CompanionMood.PLAYFUL,
      weight: 6,
      isActive: true,
    },
    {
      content: 'Buồn thì mình ngồi cạnh thôi, chưa cần nói gì cũng được.',
      triggerType: MessageTriggerType.MOOD_BASED,
      mood: MoodType.SAD,
      companionMood: CompanionMood.SAD,
      weight: 9,
      isActive: true,
    },
    {
      content: 'Lo lắng là chuông báo, không phải bản án. Mình nghe nó rồi thở chậm lại nha.',
      triggerType: MessageTriggerType.MOOD_BASED,
      mood: MoodType.ANXIOUS,
      companionMood: CompanionMood.CALM,
      weight: 9,
      isActive: true,
    },
    {
      content: 'Mệt thì được phép tiết kiệm pin. Linh thú cũng có chế độ ngủ mà.',
      triggerType: MessageTriggerType.MOOD_BASED,
      mood: MoodType.TIRED,
      companionMood: CompanionMood.SLEEPY,
      weight: 8,
      isActive: true,
    },
    {
      content: 'Hôm nay vui hả? Mình xin một miếng năng lượng long lanh đó nha.',
      triggerType: MessageTriggerType.MOOD_BASED,
      mood: MoodType.HAPPY,
      companionMood: CompanionMood.HAPPY,
      weight: 7,
      isActive: true,
    },
    {
      content: 'Biết ơn là một cái chăn nhỏ. Đắp lên tim một chút nè.',
      triggerType: MessageTriggerType.MOOD_BASED,
      mood: MoodType.GRATEFUL,
      companionMood: CompanionMood.CALM,
      weight: 7,
      isActive: true,
    },
    {
      content: 'Sáng rồi. Mình không cần thắng ngày hôm nay ngay từ phút đầu đâu.',
      triggerType: MessageTriggerType.MORNING,
      minHour: 5,
      maxHour: 10,
      companionMood: CompanionMood.CURIOUS,
      weight: 8,
      isActive: true,
    },
    {
      content: 'Trưa ghé ngang: uống nước đi, đừng cosplay cây xương rồng nữa.',
      triggerType: MessageTriggerType.TIME_BASED,
      minHour: 11,
      maxHour: 14,
      companionMood: CompanionMood.HUNGRY,
      weight: 7,
      isActive: true,
    },
    {
      content: 'Chiều xuống rồi, vai có đang gồng như đang ôm deadline không?',
      triggerType: MessageTriggerType.TIME_BASED,
      minHour: 15,
      maxHour: 18,
      companionMood: CompanionMood.CURIOUS,
      weight: 7,
      isActive: true,
    },
    {
      content: 'Tối nay mình chỉ cần nhẹ hơn hôm qua một chút là thắng rồi.',
      triggerType: MessageTriggerType.NIGHT_TIME,
      minHour: 19,
      maxHour: 23,
      companionMood: CompanionMood.CHILL,
      weight: 8,
      isActive: true,
    },
    {
      content: 'Bạn quay lại là tốt rồi. App không chấm công cảm xúc đâu.',
      triggerType: MessageTriggerType.RETURNING_USER,
      companionMood: CompanionMood.HAPPY,
      weight: 8,
      isActive: true,
    },
    {
      content: 'Check-in xong rồi đó. Một tick nhỏ, một cái ôm to.',
      triggerType: MessageTriggerType.AFTER_CHECKIN,
      companionMood: CompanionMood.HAPPY,
      weight: 8,
      isActive: true,
    },
    {
      content: 'Ở đây lâu quá là mình phát hiện nha. Đứng dậy duỗi vai 20 giây đi.',
      triggerType: MessageTriggerType.LONG_SESSION,
      companionMood: CompanionMood.CURIOUS,
      weight: 6,
      isActive: true,
    },
    {
      content: 'Không cần làm người lớn quá lâu. Nghỉ 1 phút cũng hợp pháp.',
      triggerType: MessageTriggerType.RANDOM,
      companionMood: CompanionMood.CHILL,
      weight: 6,
      isActive: true,
    },
    {
      content: 'Nếu tim đang chạy sprint, mình chuyển nó về đi bộ cùng nhau nha.',
      triggerType: MessageTriggerType.MOOD_BASED,
      mood: MoodType.STRESSED,
      companionMood: CompanionMood.CALM,
      weight: 10,
      isActive: true,
    },
    {
      content: 'Cô đơn không có nghĩa là bị bỏ lại. Mình canh góc nhỏ này với bạn.',
      triggerType: MessageTriggerType.MOOD_BASED,
      mood: MoodType.LONELY,
      companionMood: CompanionMood.SAD,
      weight: 8,
      isActive: true,
    },
    {
      content: 'Bình thường cũng là một mood rất xịn. Không drama là phước báu.',
      triggerType: MessageTriggerType.MOOD_BASED,
      mood: MoodType.NEUTRAL,
      companionMood: CompanionMood.CHILL,
      weight: 6,
      isActive: true,
    },
    {
      content: 'Hào hứng thì tốt, nhưng nhớ để dành chút pin cho tối nha đại ca.',
      triggerType: MessageTriggerType.MOOD_BASED,
      mood: MoodType.EXCITED,
      companionMood: CompanionMood.PLAYFUL,
      weight: 6,
      isActive: true,
    },
    {
      content: 'Mình đề xuất một nghi thức: hít vào "được rồi", thở ra "từ từ".',
      triggerType: MessageTriggerType.RANDOM,
      companionMood: CompanionMood.CALM,
      weight: 7,
      isActive: true,
    },
    {
      content: 'Nếu hôm nay chỉ sống sót thôi cũng được. Mai tính tiếp, mình giữ ghế cho.',
      triggerType: MessageTriggerType.NIGHT_TIME,
      minHour: 20,
      maxHour: 23,
      companionMood: CompanionMood.SLEEPY,
      weight: 8,
      isActive: true,
    },
    {
      content: 'Bạn không phải sửa mình để xứng đáng được nghỉ.',
      triggerType: MessageTriggerType.RANDOM,
      companionMood: CompanionMood.CALM,
      weight: 8,
      isActive: true,
    },
    {
      content: 'Một ngụm nước, một hơi thở, một dòng nhật ký. Combo hồi máu nhẹ.',
      triggerType: MessageTriggerType.TIME_BASED,
      minHour: 8,
      maxHour: 22,
      companionMood: CompanionMood.PLAYFUL,
      weight: 7,
      isActive: true,
    },
    {
      content: 'Tạm dừng không phải bỏ cuộc. Nó là nút save game của cơ thể.',
      triggerType: MessageTriggerType.RANDOM,
      companionMood: CompanionMood.CHILL,
      weight: 7,
      isActive: true,
    },
    {
      content: 'Mình vừa phủ một lớp bình tĩnh lên màn hình. Bạn thử chạm vào hơi thở xem.',
      triggerType: MessageTriggerType.FIRST_OPEN,
      companionMood: CompanionMood.CALM,
      weight: 7,
      isActive: true,
    },
    {
      content: 'Nếu không biết bắt đầu từ đâu, bắt đầu từ vai: thả nó xuống trước.',
      triggerType: MessageTriggerType.RANDOM,
      companionMood: CompanionMood.CURIOUS,
      weight: 6,
      isActive: true,
    },
    {
      content: 'Deadline dữ ha. Nhưng mình không cho nó ăn hết bữa tối của bạn đâu.',
      triggerType: MessageTriggerType.TIME_BASED,
      minHour: 18,
      maxHour: 21,
      companionMood: CompanionMood.PLAYFUL,
      weight: 5,
      isActive: true,
    },
    {
      content: 'Có chuyện gì thì mình nghe từng chút. Không cần kể phiên bản hoàn hảo.',
      triggerType: MessageTriggerType.MOOD_BASED,
      mood: MoodType.SAD,
      companionMood: CompanionMood.CALM,
      weight: 8,
      isActive: true,
    },
    {
      content: 'Bạn đã quay về với mình. Đó là một động tác chăm sóc bản thân rồi.',
      triggerType: MessageTriggerType.RETURNING_USER,
      companionMood: CompanionMood.HAPPY,
      weight: 7,
      isActive: true,
    },
    {
      content: 'Căng quá thì mình bật chế độ mèo nằm dài: không phán xét, chỉ thở.',
      triggerType: MessageTriggerType.MOOD_BASED,
      mood: MoodType.STRESSED,
      companionMood: CompanionMood.SLEEPY,
      weight: 9,
      isActive: true,
    },
  ];

  for (const message of messages) {
    await upsertByField(
      prisma.companionMessage,
      'content',
      message.content,
      message,
    );
  }
}

async function seedAmbientSounds() {
  for (const sound of AMBIENT_SOUND_CATALOG) {
    await upsertByField(prisma.ambientSound, 'title', sound.title, {
      title: sound.title,
      description: sound.description,
      category: sound.category,
      soundUrl: `${ASSET_BASE}/ambient-sounds/${sound.key}.mp3`,
      imageUrl: sound.imageUrl,
      duration: sound.duration,
      isActive: sound.isActive,
    });
  }
}

async function seedBreathingExercises() {
  const exercises = [
    {
      title: 'Box Breathing 4-4-4',
      description: 'Hít vào, giữ, thở ra đều nhịp để cơ thể dịu xuống.',
      inhaleSeconds: 4,
      holdSeconds: 4,
      exhaleSeconds: 4,
      cycles: 6,
      duration: 72,
      imageUrl: `${ASSET_BASE}/breathing/box-breathing.png`,
      isActive: true,
    },
    {
      title: 'Long Exhale Reset',
      description: 'Thở ra dài hơn để giảm căng và chậm nhịp lại.',
      inhaleSeconds: 4,
      holdSeconds: 2,
      exhaleSeconds: 8,
      cycles: 8,
      duration: 112,
      imageUrl: `${ASSET_BASE}/breathing/long-exhale-reset.png`,
      isActive: true,
    },
    {
      title: '4-7-8 Sleepy Cat',
      description: 'Nhịp thở ru cơ thể xuống chế độ ngủ, hợp cuối ngày.',
      inhaleSeconds: 4,
      holdSeconds: 7,
      exhaleSeconds: 8,
      cycles: 4,
      duration: 76,
      imageUrl: `${ASSET_BASE}/breathing/478-sleepy-cat.png`,
      isActive: true,
    },
    {
      title: 'Physiological Sigh Mini Reset',
      description: 'Hai lần hít ngắn rồi thở dài để xả căng nhanh.',
      inhaleSeconds: 2,
      holdSeconds: 1,
      exhaleSeconds: 6,
      cycles: 8,
      duration: 72,
      imageUrl: `${ASSET_BASE}/breathing/physiological-sigh.png`,
      isActive: true,
    },
    {
      title: 'Anxiety Downshift 3-3-6',
      description: 'Thở ra gấp đôi để báo cho hệ thần kinh rằng mình an toàn.',
      inhaleSeconds: 3,
      holdSeconds: 3,
      exhaleSeconds: 6,
      cycles: 8,
      duration: 96,
      imageUrl: `${ASSET_BASE}/breathing/anxiety-downshift.png`,
      isActive: true,
    },
    {
      title: 'Coherent Breath 5-5',
      description: 'Nhịp đều giúp ổn định năng lượng trước khi làm việc.',
      inhaleSeconds: 5,
      holdSeconds: 0,
      exhaleSeconds: 5,
      cycles: 12,
      duration: 120,
      imageUrl: `${ASSET_BASE}/breathing/coherent-5-5.png`,
      isActive: true,
    },
    {
      title: 'Shoulder Drop Breath',
      description: 'Mỗi hơi thở ra thả lỏng vai, gáy và hàm.',
      inhaleSeconds: 4,
      holdSeconds: 1,
      exhaleSeconds: 7,
      cycles: 6,
      duration: 72,
      imageUrl: `${ASSET_BASE}/breathing/shoulder-drop.png`,
      isActive: true,
    },
    {
      title: 'Counting Clouds',
      description: 'Đếm mây tưởng tượng để kéo tâm trí khỏi vòng lặp.',
      inhaleSeconds: 4,
      holdSeconds: 2,
      exhaleSeconds: 6,
      cycles: 10,
      duration: 120,
      imageUrl: `${ASSET_BASE}/breathing/counting-clouds.png`,
      isActive: true,
    },
    {
      title: 'Morning Soft Start',
      description: 'Một bài thở nhẹ trước khi mở ngày, không ép năng suất.',
      inhaleSeconds: 4,
      holdSeconds: 2,
      exhaleSeconds: 5,
      cycles: 8,
      duration: 88,
      imageUrl: `${ASSET_BASE}/breathing/morning-soft-start.png`,
      isActive: true,
    },
    {
      title: 'Panic Grounding Breath',
      description: 'Nhịp ngắn, chắc, kèm cảm giác đặt chân xuống đất.',
      inhaleSeconds: 3,
      holdSeconds: 2,
      exhaleSeconds: 5,
      cycles: 12,
      duration: 120,
      imageUrl: `${ASSET_BASE}/breathing/panic-grounding.png`,
      isActive: true,
    },
    {
      title: 'One Minute Micro Break',
      description: 'Một phút reset nhanh giữa hai tác vụ.',
      inhaleSeconds: 3,
      holdSeconds: 1,
      exhaleSeconds: 4,
      cycles: 8,
      duration: 64,
      imageUrl: `${ASSET_BASE}/breathing/one-minute-break.png`,
      isActive: true,
    },
    {
      title: 'Gratitude Exhale',
      description: 'Gắn mỗi hơi thở ra với một điều nhỏ còn ổn.',
      inhaleSeconds: 4,
      holdSeconds: 2,
      exhaleSeconds: 6,
      cycles: 6,
      duration: 72,
      imageUrl: `${ASSET_BASE}/breathing/gratitude-exhale.png`,
      isActive: true,
    },
    {
      title: 'Ocean Wave Breath',
      description: 'Hít vào như sóng lên, thở ra như sóng rút.',
      inhaleSeconds: 5,
      holdSeconds: 1,
      exhaleSeconds: 7,
      cycles: 8,
      duration: 104,
      imageUrl: `${ASSET_BASE}/breathing/ocean-wave.png`,
      isActive: true,
    },
    {
      title: 'Anger Cooldown',
      description: 'Kéo nhiệt trong người xuống trước khi phản hồi ai đó.',
      inhaleSeconds: 4,
      holdSeconds: 4,
      exhaleSeconds: 8,
      cycles: 7,
      duration: 112,
      imageUrl: `${ASSET_BASE}/breathing/anger-cooldown.png`,
      isActive: true,
    },
  ];

  for (const exercise of exercises) {
    await upsertByField(
      prisma.breathingExercise,
      'title',
      exercise.title,
      exercise,
    );
  }
}

async function seedCozyQuotes() {
  const quotes = [
    {
      content:
        'Không cần phải ổn hết mọi ngày, chỉ cần dịu hơn một chút so với lúc nãy.',
      author: 'Thì Ai Chill',
      mood: MoodType.CALM,
      imageUrl: `${ASSET_BASE}/quotes/calm-soft.png`,
      isActive: true,
    },
    {
      content: 'Cảm xúc không cần bị sửa ngay. Nó cần được nghe trước.',
      author: 'Thì Ai Chill',
      mood: MoodType.SAD,
      imageUrl: `${ASSET_BASE}/quotes/listen-first.png`,
      isActive: true,
    },
    {
      content: 'Khi mọi thứ quá ồn, mình chỉ cần bắt đầu bằng một hơi thở.',
      author: 'Thì Ai Chill',
      mood: MoodType.STRESSED,
      imageUrl: `${ASSET_BASE}/quotes/one-breath.png`,
      isActive: true,
    },
    {
      content: 'Nghỉ không làm bạn yếu đi. Nghỉ là cách cơ thể nói: mình vẫn muốn đi tiếp.',
      author: 'Thì Ai Chill',
      mood: MoodType.TIRED,
      imageUrl: `${ASSET_BASE}/quotes/rest-to-continue.png`,
      isActive: true,
    },
    {
      content: 'Không phải suy nghĩ nào ghé qua cũng cần được mời ngồi uống trà.',
      author: 'Thì Ai Chill',
      mood: MoodType.ANXIOUS,
      imageUrl: `${ASSET_BASE}/quotes/thoughts-pass-by.png`,
      isActive: true,
    },
    {
      content: 'Bạn được phép làm chậm. Đời không phải lúc nào cũng cần chạy deadline mode.',
      author: 'Thì Ai Chill',
      mood: MoodType.STRESSED,
      imageUrl: `${ASSET_BASE}/quotes/slow-permission.png`,
      isActive: true,
    },
    {
      content: 'Nếu hôm nay chỉ còn 20% pin, dùng 20% đó thật hiền với mình.',
      author: 'Thì Ai Chill',
      mood: MoodType.TIRED,
      imageUrl: `${ASSET_BASE}/quotes/twenty-percent.png`,
      isActive: true,
    },
    {
      content: 'Có những ngày không cần rực rỡ. Chỉ cần không bỏ mình lại phía sau.',
      author: 'Thì Ai Chill',
      mood: MoodType.SAD,
      imageUrl: `${ASSET_BASE}/quotes/do-not-leave-yourself.png`,
      isActive: true,
    },
    {
      content: 'Một hơi thở không giải quyết hết mọi thứ, nhưng nó mở cửa cho hơi thở tiếp theo.',
      author: 'Thì Ai Chill',
      mood: MoodType.CALM,
      imageUrl: `${ASSET_BASE}/quotes/next-breath.png`,
      isActive: true,
    },
    {
      content: 'Mình không cần thắng cảm xúc. Mình chỉ cần ngồi cạnh nó đủ lâu để nó dịu xuống.',
      author: 'Thì Ai Chill',
      mood: MoodType.NEUTRAL,
      imageUrl: `${ASSET_BASE}/quotes/sit-with-feelings.png`,
      isActive: true,
    },
    {
      content: 'Tự thương mình không phải phần thưởng sau khi hoàn hảo. Nó là điều kiện để mình bền hơn.',
      author: 'Thì Ai Chill',
      mood: MoodType.GRATEFUL,
      imageUrl: `${ASSET_BASE}/quotes/self-kindness.png`,
      isActive: true,
    },
    {
      content: 'Căng quá thì bỏ cái vai xuống trước. Chuyện lớn tính sau, cái vai cứu trước.',
      author: 'Mồn Lèo',
      mood: MoodType.STRESSED,
      imageUrl: `${ASSET_BASE}/quotes/drop-shoulders.png`,
      isActive: true,
    },
    {
      content: 'Có thể hôm nay chưa tốt. Nhưng bạn đã nhận ra mình đang không ổn, vậy là đã quay về rồi.',
      author: 'Thì Ai Chill',
      mood: MoodType.SAD,
      imageUrl: `${ASSET_BASE}/quotes/you-returned.png`,
      isActive: true,
    },
    {
      content: 'Đừng tin deadline khi nó nói bạn không được nghỉ. Deadline không có bằng tâm lý học.',
      author: 'Mồn Lèo',
      mood: MoodType.STRESSED,
      imageUrl: `${ASSET_BASE}/quotes/deadline-no-degree.png`,
      isActive: true,
    },
    {
      content: 'Niềm vui nhỏ vẫn là niềm vui thật. Đừng bắt nó phải hoành tráng mới được ghi nhận.',
      author: 'Thì Ai Chill',
      mood: MoodType.HAPPY,
      imageUrl: `${ASSET_BASE}/quotes/small-joy.png`,
      isActive: true,
    },
    {
      content: 'Biết ơn không xoá khó khăn, nhưng nó thắp một cái đèn nhỏ trong phòng.',
      author: 'Thì Ai Chill',
      mood: MoodType.GRATEFUL,
      imageUrl: `${ASSET_BASE}/quotes/gratitude-lamp.png`,
      isActive: true,
    },
    {
      content: 'Nếu lòng đang mưa, mình không cần tạnh ngay. Chỉ cần có mái hiên.',
      author: 'Thì Ai Chill',
      mood: MoodType.SAD,
      imageUrl: `${ASSET_BASE}/quotes/rain-shelter.png`,
      isActive: true,
    },
    {
      content: 'Bình yên không phải im lặng tuyệt đối. Nó là biết quay về dù ngoài kia còn ồn.',
      author: 'Thì Ai Chill',
      mood: MoodType.CALM,
      imageUrl: `${ASSET_BASE}/quotes/return-calm.png`,
      isActive: true,
    },
    {
      content: 'Một ngày bình thường cũng đáng được lưu lại. Không phải chương nào cũng cần plot twist.',
      author: 'Mồn Lèo',
      mood: MoodType.NEUTRAL,
      imageUrl: `${ASSET_BASE}/quotes/no-plot-twist.png`,
      isActive: true,
    },
    {
      content: 'Lo lắng thích nói to. Mình đáp nhỏ thôi: cảm ơn, mình đã nghe.',
      author: 'Thì Ai Chill',
      mood: MoodType.ANXIOUS,
      imageUrl: `${ASSET_BASE}/quotes/thank-anxiety.png`,
      isActive: true,
    },
    {
      content: 'Bạn không lười. Có thể hệ thần kinh của bạn đang cần được thuyết phục rằng nó an toàn.',
      author: 'Thì Ai Chill',
      mood: MoodType.TIRED,
      imageUrl: `${ASSET_BASE}/quotes/not-lazy.png`,
      isActive: true,
    },
    {
      content: 'Vui thì cứ vui cho trọn. Đừng mở họp kiểm điểm niềm vui quá sớm.',
      author: 'Mồn Lèo',
      mood: MoodType.EXCITED,
      imageUrl: `${ASSET_BASE}/quotes/dont-audit-joy.png`,
      isActive: true,
    },
    {
      content: 'Cô đơn là một tín hiệu cần kết nối, không phải bằng chứng rằng bạn không đáng yêu.',
      author: 'Thì Ai Chill',
      mood: MoodType.LONELY,
      imageUrl: `${ASSET_BASE}/quotes/lonely-signal.png`,
      isActive: true,
    },
    {
      content: 'Hôm nay nếu chưa làm được nhiều, hãy làm được nhẹ.',
      author: 'Thì Ai Chill',
      mood: MoodType.NEUTRAL,
      imageUrl: `${ASSET_BASE}/quotes/do-gently.png`,
      isActive: true,
    },
    {
      content: 'Không cần tự biến mình thành dự án cần sửa. Bạn là người cần được chăm.',
      author: 'Thì Ai Chill',
      mood: MoodType.SAD,
      imageUrl: `${ASSET_BASE}/quotes/not-a-project.png`,
      isActive: true,
    },
    {
      content: 'Một ly nước không cứu thế giới, nhưng cứu cái đầu đang khô như sa mạc của mình đó.',
      author: 'Mồn Lèo',
      mood: MoodType.TIRED,
      imageUrl: `${ASSET_BASE}/quotes/water-desert-brain.png`,
      isActive: true,
    },
    {
      content: 'Khi mọi thứ rối, hãy làm một việc có mép: gấp chăn, rửa ly, viết một dòng.',
      author: 'Thì Ai Chill',
      mood: MoodType.ANXIOUS,
      imageUrl: `${ASSET_BASE}/quotes/one-edged-task.png`,
      isActive: true,
    },
    {
      content: 'Bạn có quyền chọn một buổi tối không tối ưu, chỉ ấm áp thôi.',
      author: 'Thì Ai Chill',
      mood: MoodType.CALM,
      imageUrl: `${ASSET_BASE}/quotes/warm-evening.png`,
      isActive: true,
    },
    {
      content: 'Cái gì chưa xong vẫn có thể nằm yên tới mai. Não mình không phải kho chứa hàng 24/7.',
      author: 'Mồn Lèo',
      mood: MoodType.STRESSED,
      imageUrl: `${ASSET_BASE}/quotes/not-warehouse.png`,
      isActive: true,
    },
    {
      content: 'Nếu đang run trong lòng, đặt tay lên ngực. Mình ở đây, cơ thể cũng ở đây.',
      author: 'Thì Ai Chill',
      mood: MoodType.ANXIOUS,
      imageUrl: `${ASSET_BASE}/quotes/hand-on-chest.png`,
      isActive: true,
    },
    {
      content: 'Một điều tốt nhỏ hôm nay vẫn tính. Hệ thống đã ghi nhận, linh thú đã vỗ tay.',
      author: 'Mồn Lèo',
      mood: MoodType.HAPPY,
      imageUrl: `${ASSET_BASE}/quotes/pet-applause.png`,
      isActive: true,
    },
    {
      content: 'Dịu dàng với mình không làm bạn kém mạnh mẽ. Nó làm bạn ít phải gồng hơn.',
      author: 'Thì Ai Chill',
      mood: MoodType.CALM,
      imageUrl: `${ASSET_BASE}/quotes/less-bracing.png`,
      isActive: true,
    },
    {
      content: 'Cảm xúc đến rồi đi. Bạn là căn nhà, không phải cơn gió.',
      author: 'Thì Ai Chill',
      mood: MoodType.NEUTRAL,
      imageUrl: `${ASSET_BASE}/quotes/house-not-wind.png`,
      isActive: true,
    },
    {
      content: 'Khi bạn hít vào, không cần kéo cả tương lai vào theo.',
      author: 'Thì Ai Chill',
      mood: MoodType.STRESSED,
      imageUrl: `${ASSET_BASE}/quotes/no-future-inhale.png`,
      isActive: true,
    },
    {
      content: 'Nếu chưa biết mình cần gì, thử hỏi: cơ thể mình đang xin điều gì nhỏ nhất?',
      author: 'Thì Ai Chill',
      mood: MoodType.TIRED,
      imageUrl: `${ASSET_BASE}/quotes/body-small-ask.png`,
      isActive: true,
    },
    {
      content: 'Có những ngày chỉ cần sạch mặt, uống nước, ngủ sớm. Đơn giản mà anh hùng.',
      author: 'Mồn Lèo',
      mood: MoodType.NEUTRAL,
      imageUrl: `${ASSET_BASE}/quotes/simple-hero.png`,
      isActive: true,
    },
    {
      content: 'Hạnh phúc không cần xin lỗi vì nó bé. Bé cũng sáng.',
      author: 'Thì Ai Chill',
      mood: MoodType.HAPPY,
      imageUrl: `${ASSET_BASE}/quotes/tiny-bright.png`,
      isActive: true,
    },
    {
      content: 'Bạn không bị trễ so với đời mình. Bạn đang ở đúng đoạn cần được thở.',
      author: 'Thì Ai Chill',
      mood: MoodType.LONELY,
      imageUrl: `${ASSET_BASE}/quotes/not-late.png`,
      isActive: true,
    },
    {
      content: 'Bớt gồng một chút không làm sập vũ trụ. Vũ trụ tự chống đỡ được mà.',
      author: 'Mồn Lèo',
      mood: MoodType.STRESSED,
      imageUrl: `${ASSET_BASE}/quotes/universe-can-stand.png`,
      isActive: true,
    },
    {
      content: 'Mỗi lần quay lại check-in là một lần bạn nói với mình: mình vẫn quan trọng.',
      author: 'Thì Ai Chill',
      mood: MoodType.GRATEFUL,
      imageUrl: `${ASSET_BASE}/quotes/i-matter.png`,
      isActive: true,
    },
  ];

  const extraQuotes = EXTRA_COZY_QUOTES.map(([content, mood], index) => ({
    content,
    author: index % 5 === 0 ? 'Mồn Lèo' : 'Thì Ai Chill',
    mood: MoodType[mood] ?? MoodType.NEUTRAL,
    imageUrl: `${ASSET_BASE}/quotes/extra-${String(index + 1).padStart(2, '0')}.png`,
    isActive: true,
  }));  const englishQuotes = ENGLISH_COZY_QUOTES.map(([content, mood], index) => ({
    content,
    author: index % 5 === 0 ? 'Mồn Lèo' : 'Thì Ai Chill',
    mood: MoodType[mood] ?? MoodType.NEUTRAL,
    imageUrl: `${ASSET_BASE}/quotes/en-${String(index + 1).padStart(2, '0')}.png`,
    isActive: true,
  }));

  for (const quote of [...quotes, ...extraQuotes, ...englishQuotes]) {
    await upsertByField(prisma.cozyQuote, 'content', quote.content, quote);
  }
}

async function seedSearchIndex() {
  const [
    quotes,
    sounds,
    exercises,
    themes,
    onboardingSlides,
    companionAssets,
    companionMessages,
  ] = await Promise.all([
    prisma.cozyQuote.findMany(),
    prisma.ambientSound.findMany(),
    prisma.breathingExercise.findMany(),
    prisma.appTheme.findMany(),
    prisma.onboardingSlide.findMany(),
    prisma.companionAsset.findMany(),
    prisma.companionMessage.findMany(),
  ]);

  const entries = [
    ...quotes.map((quote) => ({
      entityType: 'COZY_QUOTE',
      entityId: quote.id,
      title: quote.content,
      content: compactText([
        quote.content,
        quote.author,
        quote.mood,
        quote.imageUrl,
        quote.isActive ? 'active' : 'draft',
      ]),
      tags: ['quote', 'cozy', quote.mood, quote.author, quote.isActive ? 'active' : 'draft'],
    })),
    ...sounds.map((sound) => ({
      entityType: 'AMBIENT_SOUND',
      entityId: sound.id,
      title: sound.title,
      content: compactText([
        sound.title,
        sound.description,
        sound.category,
        sound.soundUrl,
        sound.duration ? `${sound.duration}s` : null,
        sound.isActive ? 'active' : 'draft',
      ]),
      tags: ['sound', 'ambient', sound.category, sound.isActive ? 'active' : 'draft'],
    })),
    ...exercises.map((exercise) => ({
      entityType: 'BREATHING_EXERCISE',
      entityId: exercise.id,
      title: exercise.title,
      content: compactText([
        exercise.title,
        exercise.description,
        `inhale ${exercise.inhaleSeconds}`,
        `hold ${exercise.holdSeconds}`,
        `exhale ${exercise.exhaleSeconds}`,
        `cycles ${exercise.cycles}`,
        exercise.isActive ? 'active' : 'draft',
      ]),
      tags: [
        'breathing',
        'exercise',
        `${exercise.inhaleSeconds}-${exercise.holdSeconds}-${exercise.exhaleSeconds}`,
        exercise.isActive ? 'active' : 'draft',
      ],
    })),
    ...themes.map((theme) => ({
      entityType: 'APP_THEME',
      entityId: theme.id,
      title: theme.name,
      content: compactText([
        theme.name,
        theme.mode,
        theme.backgroundColor,
        theme.surfaceColor,
        theme.primaryColor,
        theme.secondaryColor,
        theme.accentColor,
        theme.isDefault ? 'default' : null,
        theme.isActive ? 'active' : 'draft',
      ]),
      tags: [
        'theme',
        theme.mode,
        theme.isDefault ? 'default' : null,
        theme.isActive ? 'active' : 'draft',
      ],
    })),
    ...onboardingSlides.map((slide) => ({
      entityType: 'ONBOARDING_SLIDE',
      entityId: slide.id,
      title: slide.title,
      content: compactText([
        slide.title,
        slide.subtitle,
        slide.description,
        slide.imageUrl,
        slide.animationUrl,
        `order ${slide.displayOrder}`,
        slide.isActive ? 'active' : 'draft',
      ]),
      tags: [
        'onboarding',
        'slide',
        `order-${slide.displayOrder}`,
        slide.isActive ? 'active' : 'draft',
      ],
    })),
    ...companionAssets.map((asset) => ({
      entityType: 'COMPANION_ASSET',
      entityId: asset.id,
      title: asset.name,
      content: compactText([
        asset.name,
        asset.type,
        asset.description,
        asset.previewImageUrl,
        asset.primaryColor,
        asset.secondaryColor,
        asset.accentColor,
        asset.isDefault ? 'default' : null,
        asset.isActive ? 'active' : 'draft',
      ]),
      tags: [
        'companion',
        'asset',
        asset.type,
        asset.isDefault ? 'default' : null,
        asset.isActive ? 'active' : 'draft',
      ],
    })),
    ...companionMessages.map((message) => {
      const hourRange =
        message.minHour === null && message.maxHour === null
          ? 'all-day'
          : `${message.minHour ?? 0}-${message.maxHour ?? 23}`;

      return {
        entityType: 'COMPANION_MESSAGE',
        entityId: message.id,
        title: message.content,
        content: compactText([
          message.content,
          message.triggerType,
          message.mood,
          message.companionMood,
          hourRange,
          `weight ${message.weight}`,
          message.isActive ? 'active' : 'draft',
        ]),
        tags: [
          'companion',
          'message',
          message.triggerType,
          message.mood,
          message.companionMood,
          hourRange,
          message.isActive ? 'active' : 'draft',
        ],
      };
    }),
  ];

  for (const entry of entries) {
    await upsertSearchIndex(entry);
  }

  console.log(`Seeded ${entries.length} search index entries`);
}

const DEMO_USER_EMAIL = 'demo@digital-break.local';
const DEMO_USER_PASSWORD = 'Demo123456!';
const ADMIN_USER_EMAIL = 'dashboard.demo@relax.local';
const ADMIN_USER_PASSWORD = 'Relax123!@#';

function daysAgo(days, hour = 20, minute = 30) {
  const date = new Date();
  date.setHours(hour, minute, 0, 0);
  date.setDate(date.getDate() - days);
  return date;
}

function getStressScore(mood) {
  const scores = {
    [MoodType.STRESSED]: 90,
    [MoodType.ANXIOUS]: 80,
    [MoodType.SAD]: 65,
    [MoodType.TIRED]: 60,
    [MoodType.LONELY]: 55,
    [MoodType.NEUTRAL]: 40,
    [MoodType.EXCITED]: 30,
    [MoodType.GRATEFUL]: 20,
    [MoodType.HAPPY]: 15,
    [MoodType.CALM]: 10,
  };

  return scores[mood] ?? 40;
}

function getWeekStart(date) {
  const cursor = new Date(
    Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()),
  );
  const day = cursor.getUTCDay();
  const diff = day === 0 ? -6 : 1 - day;
  cursor.setUTCDate(cursor.getUTCDate() + diff);
  return cursor;
}

function summarizeWeeklyStats(checkins) {
  const grouped = new Map();

  for (const checkin of checkins) {
    const weekStart = getWeekStart(checkin.scoredAt).toISOString();
    const bucket = grouped.get(weekStart) ?? [];
    bucket.push(checkin);
    grouped.set(weekStart, bucket);
  }

  const weeks = Array.from(grouped.entries())
    .map(([weekStart, rows]) => {
      const avgScore =
        rows.reduce((sum, row) => sum + row.finalScore, 0) / rows.length;
      const moodCounts = rows.reduce((acc, row) => {
        acc[row.mood] = (acc[row.mood] ?? 0) + 1;
        return acc;
      }, {});
      const dominantMood = Object.entries(moodCounts).sort(
        (left, right) => right[1] - left[1],
      )[0]?.[0];

      return {
        weekStart: new Date(weekStart),
        avgScore,
        stressReducePct: 0,
        streakDays: rows.length,
        dominantMood,
      };
    })
    .sort(
      (left, right) => left.weekStart.getTime() - right.weekStart.getTime(),
    );

  return weeks.map((week, index) => {
    const previous = weeks[index - 1];
    const stressReducePct = previous
      ? Math.max(
          -100,
          Math.min(
            100,
            Math.round(
              ((previous.avgScore - week.avgScore) / previous.avgScore) * 100,
            ),
          ),
        )
      : 0;

    return {
      ...week,
      stressReducePct,
    };
  });
}

async function seedDemoUserData() {
  const existing = await prisma.user.findUnique({
    where: { email: DEMO_USER_EMAIL },
    select: { id: true },
  });

  if (existing) {
    await prisma.user.delete({ where: { id: existing.id } });
  }

  const defaultAsset = await prisma.companionAsset.findFirst({
    where: { isDefault: true, isActive: true },
    orderBy: { createdAt: 'asc' },
  });
  const freeTier = await prisma.subscriptionTier.findUnique({
    where: { name: 'FREE' },
  });
  const password = await bcrypt.hash(DEMO_USER_PASSWORD, 12);

  const demoUser = await prisma.user.create({
    data: {
      email: DEMO_USER_EMAIL,
      name: 'Thi Ái Demo',
      avatar: `${ASSET_BASE}/avatars/demo-thi-ai.png`,
      password,
      role: UserRole.USER,
      authProvider: AuthProvider.LOCAL,
      emailVerified: true,
      isActive: true,
      lastLoginAt: daysAgo(0, 9, 15),
      profile: {
        create: {
          displayName: 'Thi Ái',
          bio: 'Tài khoản demo có dữ liệu mood, journal và relax để dựng dashboard.',
          birthday: new Date('2002-05-14T00:00:00.000Z'),
          zodiacSign: 'Taurus',
          chineseZodiac: 'Horse',
          totalMoodCheckins: 24,
          totalJournalPosts: 7,
          currentStreak: 8,
          longestStreak: 12,
        },
      },
      preferences: {
        create: {
          language: 'vi',
          timezone: 'Asia/Ho_Chi_Minh',
          latitude: 10.7769,
          longitude: 106.7009,
          locationName: 'Ho Chi Minh City',
          weatherEnabled: true,
          themeMode: ThemeMode.SYSTEM,
          enableCompanionBubble: true,
          enableSound: true,
          pushNotificationsEnabled: true,
          emailNotificationsEnabled: false,
        },
      },
      companion: {
        create: {
          assetId: defaultAsset?.id,
          name: 'Mochi',
          type: CompanionType.CAT,
          personalizationMode: CompanionPersonalizationMode.DEFAULT,
          mood: CompanionMood.CHILL,
          level: 4,
          affection: 72,
          energy: 88,
          lastSeenAt: daysAgo(0, 9, 20),
          lastFedAt: daysAgo(0, 8, 45),
          lastMoodAt: daysAgo(0, 9, 5),
        },
      },
    },
  });

  const moodPattern = [
    MoodType.STRESSED,
    MoodType.ANXIOUS,
    MoodType.TIRED,
    MoodType.NEUTRAL,
    MoodType.CALM,
    MoodType.HAPPY,
    MoodType.GRATEFUL,
    MoodType.STRESSED,
    MoodType.SAD,
    MoodType.NEUTRAL,
    MoodType.CALM,
    MoodType.HAPPY,
    MoodType.EXCITED,
    MoodType.GRATEFUL,
    MoodType.TIRED,
    MoodType.LONELY,
    MoodType.ANXIOUS,
    MoodType.NEUTRAL,
    MoodType.CALM,
    MoodType.HAPPY,
    MoodType.GRATEFUL,
    MoodType.CALM,
    MoodType.HAPPY,
    MoodType.GRATEFUL,
  ];
  const moodCheckins = moodPattern.map((mood, index) => {
    const createdAt = daysAgo(moodPattern.length - index - 1, 20, 15);
    const rawScore = getStressScore(mood);
    const relief = index % 4 === 0 ? 12 : index % 5 === 0 ? 8 : 0;
    const finalScore = Math.max(0, rawScore - relief);

    return {
      userId: demoUser.id,
      mood,
      intensity: Math.max(1, Math.min(5, Math.round(rawScore / 20))),
      rawScore,
      finalScore,
      scoredAt: createdAt,
      note:
        index % 3 === 0
          ? 'Demo note: hôm nay có chút biến động nhưng đã dịu hơn.'
          : null,
      tags: index % 2 === 0 ? ['demo', 'dashboard'] : ['demo'],
      createdAt,
      updatedAt: createdAt,
    };
  });

  await prisma.moodCheckin.createMany({ data: moodCheckins });

  const weeklyStats = summarizeWeeklyStats(moodCheckins);
  await prisma.weeklyMoodStat.createMany({
    data: weeklyStats.map((stat) => ({
      userId: demoUser.id,
      weekStart: stat.weekStart,
      avgScore: stat.avgScore,
      stressReducePct: stat.stressReducePct,
      streakDays: stat.streakDays,
      dominantMood: stat.dominantMood,
    })),
  });

  await prisma.journal.createMany({
    data: [
      ['Reset nhẹ buổi tối', MoodType.CALM, ['sleep', 'demo'], true],
      ['Một ngày hơi quá tải', MoodType.STRESSED, ['work', 'demo'], false],
      [
        'Biết ơn vì đã nghỉ đúng lúc',
        MoodType.GRATEFUL,
        ['gratitude', 'demo'],
        true,
      ],
      [
        'Viết vài dòng sau khi thở',
        MoodType.NEUTRAL,
        ['breathing', 'demo'],
        false,
      ],
      ['Mình đã quay lại được', MoodType.HAPPY, ['reflection', 'demo'], true],
      ['Ngày chậm hơn một chút', MoodType.CALM, ['slow', 'demo'], false],
      ['Có lúc buồn nhưng không sao', MoodType.SAD, ['feeling', 'demo'], false],
    ].map(([title, mood, tags, isFavorite], index) => ({
      userId: demoUser.id,
      title,
      content:
        'Đây là journal demo để dashboard có dữ liệu lọc theo mood, tag và yêu thích.',
      mood,
      tags,
      isPrivate: true,
      isFavorite,
      createdAt: daysAgo(index * 3, 21, 10),
    })),
  });

  await prisma.relaxSession.createMany({
    data: [
      [RelaxActivityType.MUSIC, MoodType.STRESSED, MoodType.CALM, 1260, 42],
      [
        RelaxActivityType.BREATHING,
        MoodType.ANXIOUS,
        MoodType.NEUTRAL,
        420,
        35,
      ],
      [RelaxActivityType.JOURNAL, MoodType.SAD, MoodType.CALM, 900, 28],
      [RelaxActivityType.MEDITATION, MoodType.TIRED, MoodType.CALM, 960, 33],
      [RelaxActivityType.PODCAST, MoodType.NEUTRAL, MoodType.HAPPY, 1500, 18],
      [RelaxActivityType.MYSTERY, MoodType.STRESSED, MoodType.NEUTRAL, 600, 22],
      [RelaxActivityType.MUSIC, MoodType.CALM, MoodType.HAPPY, 1320, 16],
      [RelaxActivityType.BREATHING, MoodType.ANXIOUS, MoodType.CALM, 360, 40],
    ].map(([activityType, moodBefore, moodAfter, duration, relief], index) => {
      const startedAt = daysAgo(index * 2, 19, 30);
      const endedAt = new Date(startedAt.getTime() + duration * 1000);

      return {
        userId: demoUser.id,
        activityType,
        status: RelaxSessionStatus.FINISHED,
        title: `${activityType.toLowerCase()} demo`,
        startedAt,
        endedAt,
        duration,
        moodBefore,
        moodAfter,
        reliefLevel: Math.max(1, Math.min(5, Math.round(relief / 20))),
        stressReliefPercent: relief,
        note: 'Phiên demo cho biểu đồ relax và recent moments.',
        nextActionAccepted: index % 2 === 0 ? 'continue' : 'back_to_work',
        createdAt: startedAt,
      };
    }),
  });

  await prisma.reminder.createMany({
    data: [
      [ReminderType.WATER, 'Uống nước một chút nha', '0 9 * * *', 9],
      [ReminderType.REST, 'Đứng dậy duỗi vai', '0 15 * * 1-5', 15],
      [ReminderType.JOURNAL, 'Viết vài dòng cuối ngày', '0 21 * * *', 21],
    ].map(([type, title, repeatRule, hour]) => ({
      userId: demoUser.id,
      type,
      title,
      message: 'Reminder demo để màn settings có dữ liệu.',
      scheduledAt: daysAgo(-1, hour, 0),
      repeatRule,
      isActive: true,
    })),
  });

  await prisma.notification.createMany({
    data: [
      ['Chào mừng quay lại', 'Mochi đang đợi bạn check-in hôm nay.', false],
      [
        'Nhắc nghỉ nhẹ',
        'Một hơi thở ngắn cũng tính là chăm sóc bản thân.',
        true,
      ],
      ['Dashboard demo đã sẵn sàng', 'Có dữ liệu mẫu để test biểu đồ.', false],
    ].map(([title, message, isRead], index) => ({
      userId: demoUser.id,
      title,
      message,
      type: NotificationType.IN_APP,
      isRead,
      readAt: isRead ? daysAgo(index, 10, 0) : null,
      createdAt: daysAgo(index, 10, 0),
    })),
  });

  if (freeTier) {
    await prisma.subscription.create({
      data: {
        userId: demoUser.id,
        tierId: freeTier.id,
        status: SubscriptionStatus.ACTIVE,
        planName: freeTier.name,
        price: freeTier.price,
        currency: freeTier.currency,
        startDate: daysAgo(20, 9, 0),
      },
    });
  }

  await prisma.userStreak.create({
    data: {
      userId: demoUser.id,
      currentStreak: 8,
      longestStreak: 12,
      streakType: 'MOOD_TRACKING',
      lastActivityDate: daysAgo(0, 20, 15),
      startDate: daysAgo(23, 20, 15),
    },
  });
  await prisma.userPoints.create({
    data: {
      userId: demoUser.id,
      totalPoints: 420,
      pointsHistory: {
        create: [
          { amount: 200, reason: 'Demo mood streak' },
          { amount: 220, reason: 'Demo relax sessions' },
        ],
      },
    },
  });
  await prisma.userLevel.create({
    data: {
      userId: demoUser.id,
      level: 4,
      experience: 420,
      nextLevelExp: 600,
    },
  });

  console.log(
    `Seeded demo user ${DEMO_USER_EMAIL} with password ${DEMO_USER_PASSWORD}`,
  );
}

async function seedAdminUser() {
  const password = await bcrypt.hash(ADMIN_USER_PASSWORD, 12);

  const existing = await prisma.user.findUnique({
    where: { email: ADMIN_USER_EMAIL },
    select: { id: true, profile: { select: { id: true } }, preferences: { select: { id: true } } },
  });

  if (existing) {
    await prisma.user.update({
      where: { id: existing.id },
      data: {
        name: 'Dashboard Admin',
        password,
        role: UserRole.ADMIN,
        authProvider: AuthProvider.LOCAL,
        emailVerified: true,
        isActive: true,
      },
    });

    await prisma.userProfile.upsert({
      where: { userId: existing.id },
      update: {
        displayName: 'Dashboard Admin',
        bio: 'Tài khoản admin seed sẵn để kiểm tra dashboard quản trị.',
      },
      create: {
        userId: existing.id,
        displayName: 'Dashboard Admin',
        bio: 'Tài khoản admin seed sẵn để kiểm tra dashboard quản trị.',
      },
    });

    await prisma.userPreference.upsert({
      where: { userId: existing.id },
      update: {
        language: 'vi',
        timezone: 'Asia/Ho_Chi_Minh',
        themeMode: ThemeMode.SYSTEM,
        weatherEnabled: true,
        enableSound: true,
        pushNotificationsEnabled: true,
      },
      create: {
        userId: existing.id,
        language: 'vi',
        timezone: 'Asia/Ho_Chi_Minh',
        themeMode: ThemeMode.SYSTEM,
        weatherEnabled: true,
        enableSound: true,
        pushNotificationsEnabled: true,
      },
    });

    return;
  }

  await prisma.user.create({
    data: {
      email: ADMIN_USER_EMAIL,
      name: 'Dashboard Admin',
      password,
      role: UserRole.ADMIN,
      authProvider: AuthProvider.LOCAL,
      emailVerified: true,
      isActive: true,
      profile: {
        create: {
          displayName: 'Dashboard Admin',
          bio: 'Tài khoản admin seed sẵn để kiểm tra dashboard quản trị.',
        },
      },
      preferences: {
        create: {
          language: 'vi',
          timezone: 'Asia/Ho_Chi_Minh',
          themeMode: ThemeMode.SYSTEM,
          weatherEnabled: true,
          enableSound: true,
          pushNotificationsEnabled: true,
        },
      },
    },
  });

  console.log(
    `Seeded admin user ${ADMIN_USER_EMAIL} with password ${ADMIN_USER_PASSWORD}`,
  );
}

async function main() {
  await seedSubscriptionTiers();
  await seedAchievements();
  await seedBadges();
  await seedThemes();
  await seedOnboardingSlides();
  await seedCompanionAssets();
  await seedCompanionMessages();
  await seedAmbientSounds();
  await seedBreathingExercises();
  await seedCozyQuotes();
  await seedSearchIndex();
  await seedAdminUser();
  await seedDemoUserData();
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
