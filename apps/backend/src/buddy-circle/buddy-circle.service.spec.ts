import { BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { BuddyCircleService } from './buddy-circle.service';

describe('BuddyCircleService — reactToFeed', () => {
  const update = jest.fn();
  const prisma = {
    feedEntry: {
      findUnique: jest.fn().mockResolvedValue({ id: 'e1', metadata: {} }),
      update,
    },
  } as unknown as PrismaService;
  const service = new BuddyCircleService(prisma);

  beforeEach(() => update.mockReset().mockResolvedValue({}));

  it.each(['❤️', '💪', '🤗', '👍🏽', '👨‍👩‍👧'])('accepts emoji %s', async (emoji) => {
    await service.reactToFeed('u1', 'e1', emoji);
    const metadata = update.mock.calls[0][0].data.metadata;
    expect(metadata.reactions[emoji]).toEqual(['u1']);
  });

  it.each([
    '__proto__',
    'constructor',
    'like',
    '',
    ':)',
    'x'.repeat(20),
    42,
    {},
  ])('rejects %p', async (emoji) => {
    await expect(service.reactToFeed('u1', 'e1', emoji)).rejects.toThrow(
      BadRequestException,
    );
    expect(update).not.toHaveBeenCalled();
  });
});
