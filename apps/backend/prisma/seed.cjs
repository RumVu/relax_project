// @ts-nocheck
const {
  AchievementType,
  BillingCycle,
  CompanionMood,
  CompanionType,
  MessageTriggerType,
  MoodType,
  PrismaClient,
  ThemeMode,
} = require('@prisma/client');

const prisma = new PrismaClient();
const ASSET_BASE =
  'https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets';

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
  const sounds = [
    {
      title: 'Lo-fi Chill - Pixel Beats',
      description: 'Nhạc nền nhẹ để thả lỏng đầu óc.',
      category: 'music',
      soundUrl: `${ASSET_BASE}/sounds/lofi-chill-pixel-beats.mp3`,
      imageUrl: `${ASSET_BASE}/sounds/lofi-chill-cover.png`,
      duration: 210,
      isActive: true,
    },
    {
      title: 'Rain On Window',
      description: 'Tiếng mưa dịu bên cửa sổ cho lúc cần chậm lại.',
      category: 'rain',
      soundUrl: `${ASSET_BASE}/sounds/rain-on-window.mp3`,
      imageUrl: `${ASSET_BASE}/sounds/rain-window-cover.png`,
      duration: 900,
      isActive: true,
    },
    {
      title: 'Midnight Cafe',
      description: 'Không gian quán nhỏ về đêm, hợp để viết nhật ký.',
      category: 'ambient',
      soundUrl: `${ASSET_BASE}/sounds/midnight-cafe.mp3`,
      imageUrl: `${ASSET_BASE}/sounds/midnight-cafe-cover.png`,
      duration: 1200,
      isActive: true,
    },
  ];

  for (const sound of sounds) {
    await upsertByField(prisma.ambientSound, 'title', sound.title, sound);
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
  ];

  for (const quote of quotes) {
    await upsertByField(prisma.cozyQuote, 'content', quote.content, quote);
  }
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
