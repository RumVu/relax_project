export const userSelect = {
  id: true,
  email: true,
  name: true,
  avatar: true,
  role: true,
  authProvider: true,
  emailVerified: true,
  isActive: true,
  lastLoginAt: true,
  deletedAt: true,
  createdAt: true,
  updatedAt: true,
  profile: true,
  preferences: true,
  subscriptions: {
    orderBy: { createdAt: 'desc' },
    take: 1,
    select: {
      id: true,
      planName: true,
      status: true,
      endDate: true,
      tier: {
        select: {
          name: true,
        },
      },
    },
  },
} as const;
