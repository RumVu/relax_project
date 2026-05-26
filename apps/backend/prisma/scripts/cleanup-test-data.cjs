const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();
const dryRun = process.argv.includes('--dry-run');

const testUserWhere = {
  OR: [
    { email: { endsWith: '@ex.com' } },
    { email: { startsWith: 'load', endsWith: '@relax.local' } },
  ],
};

async function main() {
  const users = await prisma.user.findMany({
    where: testUserWhere,
    select: {
      id: true,
      email: true,
      name: true,
      role: true,
      createdAt: true,
    },
    orderBy: { createdAt: 'asc' },
  });

  if (users.length === 0) {
    console.log('No test users found. Database is already clean.');
    return;
  }

  console.table(
    users.map((user) => ({
      email: user.email,
      name: user.name ?? '-',
      role: user.role,
      createdAt: user.createdAt.toISOString(),
    })),
  );

  if (dryRun) {
    console.log(`Dry-run only: ${users.length} test users would be deleted.`);
    return;
  }

  const userIds = users.map((user) => user.id);

  await prisma.$transaction([
    prisma.appEvent.deleteMany({ where: { userId: { in: userIds } } }),
    prisma.platformEvent.updateMany({
      where: { userId: { in: userIds } },
      data: { userId: null },
    }),
    prisma.feedback.updateMany({
      where: { userId: { in: userIds } },
      data: { userId: null },
    }),
    prisma.storageFile.updateMany({
      where: { userId: { in: userIds } },
      data: { userId: null },
    }),
    prisma.user.deleteMany({ where: { id: { in: userIds } } }),
  ]);

  console.log(`Deleted ${users.length} test users and detached nullable support records.`);
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
