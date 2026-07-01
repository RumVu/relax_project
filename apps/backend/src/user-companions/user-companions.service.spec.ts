import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { CompanionAction, CompanionMood } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { RealtimeService } from '../realtime/realtime.service';
import { UsersService } from '../users/users.service';
import { UserCompanionsService } from './user-companions.service';

const mockCompanion = {
  id: 'comp-1',
  userId: 'user-1',
  name: 'Mon Leo',
  type: 'CAT',
  mood: CompanionMood.CHILL,
  action: CompanionAction.IDLE,
  affection: 30,
  energy: 80,
  level: 2,
  assetId: null,
  asset: null,
  personalizationMode: 'DEFAULT',
  lastSeenAt: new Date(),
  lastFedAt: null,
  lastMoodAt: null,
  createdAt: new Date(),
  updatedAt: new Date(),
};

describe('UserCompanionsService — chatWithCompanion', () => {
  let service: UserCompanionsService;
  let prisma: { [k: string]: any };
  let configGet: jest.Mock;

  beforeEach(async () => {
    configGet = jest.fn((key: string) => {
      if (key === 'GEMINI_API_KEY') return undefined;
      if (key === 'GEMINI_MODEL') return 'gemini-2.0-flash';
      return undefined;
    });

    prisma = {
      userCompanion: {
        findUnique: jest.fn().mockResolvedValue(mockCompanion),
        create: jest.fn().mockResolvedValue(mockCompanion),
        update: jest.fn().mockResolvedValue(mockCompanion),
      },
      companionInteraction: {
        findMany: jest.fn().mockResolvedValue([]),
        create: jest.fn().mockImplementation(({ data }) => ({
          id: `int-${Date.now()}`,
          ...data,
          createdAt: new Date(),
        })),
      },
      moodCheckin: {
        findMany: jest.fn().mockResolvedValue([]),
      },
      companionAsset: {
        findFirst: jest.fn().mockResolvedValue(null),
      },
      $transaction: jest.fn().mockImplementation((ops: Promise<unknown>[]) =>
        Promise.all(ops),
      ),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UserCompanionsService,
        { provide: PrismaService, useValue: prisma },
        {
          provide: UsersService,
          useValue: { findOne: jest.fn().mockResolvedValue({ id: 'user-1' }) },
        },
        {
          provide: RealtimeService,
          useValue: { emitToUser: jest.fn() },
        },
        {
          provide: ConfigService,
          useValue: { get: configGet },
        },
      ],
    }).compile();

    service = module.get(UserCompanionsService);
  });

  it('should return a local fallback reply when GEMINI_API_KEY is not set', async () => {
    const result = await service.chatWithCompanion('user-1', 'chào bạn');

    expect(result).toHaveProperty('reply');
    expect(typeof result.reply).toBe('string');
    expect(result.reply.length).toBeGreaterThan(0);
    expect(result).toHaveProperty('companion');
  });

  it('should return greeting-related reply for greeting messages', async () => {
    const result = await service.chatWithCompanion('user-1', 'hello');

    expect(result.reply).toMatch(/meow|chào|vui/i);
  });

  it('should return comfort reply for sad messages', async () => {
    const result = await service.chatWithCompanion('user-1', 'buồn quá');

    expect(result.reply).toMatch(/buồn|meow|lắng nghe/i);
  });

  it('should return sleep reply for sleep messages', async () => {
    const result = await service.chatWithCompanion('user-1', 'đi ngủ thôi');

    expect(result.reply).toMatch(/ngủ|meow/i);
  });

  it('should return love reply for affectionate messages', async () => {
    const result = await service.chatWithCompanion('user-1', 'yêu mèo quá');

    expect(result.reply).toMatch(/yêu|meow|tim/i);
  });

  it('should return generic fallback for unrecognized messages', async () => {
    const result = await service.chatWithCompanion(
      'user-1',
      'dksjfhsdkjfhsdf',
    );

    expect(result.reply).toBeTruthy();
    expect(result.companion).toBeDefined();
  });

  it('should persist user and companion messages via transaction', async () => {
    await service.chatWithCompanion('user-1', 'test message');

    expect(prisma.$transaction).toHaveBeenCalledTimes(1);
    const txArgs = prisma.$transaction.mock.calls[0][0];
    expect(txArgs).toHaveLength(3);
  });

  it('should increment affection by 2 on each chat', async () => {
    await service.chatWithCompanion('user-1', 'xin chào');

    const updateCall = prisma.userCompanion.update.mock.calls[0][0];
    expect(updateCall.data.affection).toBe(
      Math.min(100, mockCompanion.affection + 2),
    );
  });
});
