// @ts-nocheck
const { PrismaClient, BillingCycle, AchievementType } = require('@prisma/client');

const prisma = new PrismaClient();

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
  const freeTier = await prisma.subscriptionTier.upsert({
    where: { name: 'Free' },
    update: {
      description: 'Starter tier for new users',
      price: 0,
      billingCycle: BillingCycle.MONTHLY,
      displayOrder: 0,
      isActive: true,
    },
    create: {
      name: 'Free',
      description: 'Starter tier for new users',
      price: 0,
      billingCycle: BillingCycle.MONTHLY,
      displayOrder: 0,
      isActive: true,
    },
  });

  const premiumTier = await prisma.subscriptionTier.upsert({
    where: { name: 'Premium' },
    update: {
      description: 'Full access for wellness power users',
      price: 9.99,
      billingCycle: BillingCycle.MONTHLY,
      displayOrder: 1,
      isActive: true,
    },
    create: {
      name: 'Premium',
      description: 'Full access for wellness power users',
      price: 9.99,
      billingCycle: BillingCycle.MONTHLY,
      displayOrder: 1,
      isActive: true,
    },
  });

  const annualTier = await prisma.subscriptionTier.upsert({
    where: { name: 'Premium Annual' },
    update: {
      description: 'Discounted annual premium plan',
      price: 99,
      billingCycle: BillingCycle.ANNUAL,
      displayOrder: 2,
      isActive: true,
    },
    create: {
      name: 'Premium Annual',
      description: 'Discounted annual premium plan',
      price: 99,
      billingCycle: BillingCycle.ANNUAL,
      displayOrder: 2,
      isActive: true,
    },
  });

  const tierDefinitions = [
    {
      tierId: freeTier.id,
      features: [
        ['mood_tracking', true, 'Track daily mood check-ins'],
        ['journal_entries', true, 'Write private journal entries'],
      ],
      limits: [
        ['moods_per_day', 5, 'count'],
        ['reminders', 3, 'count'],
      ],
    },
    {
      tierId: premiumTier.id,
      features: [
        ['mood_tracking', true, 'Unlimited mood tracking'],
        ['ai_insights', true, 'AI-generated wellness insights'],
        ['guided_meditation', true, 'Access all meditation guides'],
      ],
      limits: [
        ['moods_per_day', 100, 'count'],
        ['reminders', 25, 'count'],
      ],
    },
    {
      tierId: annualTier.id,
      features: [
        ['mood_tracking', true, 'Unlimited mood tracking'],
        ['ai_insights', true, 'AI-generated wellness insights'],
        ['guided_meditation', true, 'Access all meditation guides'],
        ['priority_support', true, 'Priority customer support'],
      ],
      limits: [
        ['moods_per_day', 100, 'count'],
        ['reminders', 50, 'count'],
      ],
    },
  ];

  for (const tier of tierDefinitions) {
    for (const [name, included, description] of tier.features) {
      await prisma.tierFeature.upsert({
        where: {
          tierId_name: {
            tierId: tier.tierId,
            name,
          },
        },
        update: { included, description },
        create: {
          tierId: tier.tierId,
          name,
          included,
          description,
        },
      });
    }

    for (const [name, value, unit] of tier.limits) {
      await prisma.tierLimit.upsert({
        where: {
          tierId_name: {
            tierId: tier.tierId,
            name,
          },
        },
        update: { value, unit },
        create: {
          tierId: tier.tierId,
          name,
          value,
          unit,
        },
      });
    }
  }
}

async function seedAchievements() {
  const achievements = [
    {
      title: 'First Check-In',
      description: 'Log your first mood entry',
      type: AchievementType.EXPLORATION,
      points: 10,
      condition: '{"event":"MOOD_CREATED","count":1}',
    },
    {
      title: 'Mindful Week',
      description: 'Complete 7 wellness activities',
      type: AchievementType.CONSISTENCY,
      points: 25,
      condition: '{"event":"SESSION_COMPLETED","count":7}',
    },
    {
      title: 'Calm Builder',
      description: 'Finish 10 meditation sessions',
      type: AchievementType.WELLNESS,
      points: 50,
      condition: '{"event":"MEDITATION_COMPLETED","count":10}',
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
      description: 'Completed your first activity',
      category: 'BEGINNER',
      rarity: 'COMMON',
      icon: 'spark',
    },
    {
      title: 'Focused',
      description: 'Maintained a strong routine',
      category: 'ACTIVE',
      rarity: 'RARE',
      icon: 'target',
    },
    {
      title: 'Zen Master',
      description: 'Reached an advanced mindfulness milestone',
      category: 'MASTER',
      rarity: 'EPIC',
      icon: 'lotus',
    },
  ];

  for (const badge of badges) {
    await upsertByField(prisma.badge, 'title', badge.title, badge);
  }
}

async function seedQuotes() {
  const quotes = [
    {
      text: 'Small daily habits build lasting calm.',
      author: 'Relax Project',
      category: 'MINDFULNESS',
      source: 'Internal',
    },
    {
      text: 'Rest is not a reward. It is part of the work.',
      author: 'Relax Project',
      category: 'WISDOM',
      source: 'Internal',
    },
    {
      text: 'A break taken on time saves energy later.',
      author: 'Relax Project',
      category: 'MOTIVATION',
      source: 'Internal',
    },
  ];

  for (const quote of quotes) {
    await upsertByField(prisma.quote, 'text', quote.text, quote);
  }
}

async function main() {
  await seedSubscriptionTiers();
  await seedAchievements();
  await seedBadges();
  await seedQuotes();
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
