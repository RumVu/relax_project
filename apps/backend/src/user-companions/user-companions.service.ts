import { HttpStatus, Injectable } from '@nestjs/common';
import {
  CompanionAction,
  CompanionMood,
  CompanionPersonalizationMode,
  Prisma,
} from '@prisma/client';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { RealtimeService } from '../realtime/realtime.service';
import { UsersService } from '../users/users.service';
import { CreateCompanionInteractionDto } from './dto/create-companion-interaction.dto';
import { SwitchCompanionPersonalizationDto } from './dto/switch-companion-personalization.dto';
import { UpsertUserCompanionDto } from './dto/upsert-user-companion.dto';
import { ConfigService } from '@nestjs/config';
import { GoogleGenerativeAI, SchemaType } from '@google/generative-ai';

@Injectable()
export class UserCompanionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
    private readonly realtime: RealtimeService,
    private readonly configService: ConfigService,
  ) {}

  private emitCompanionUpdate(
    userId: string,
    companion: { id: string; mood?: unknown; action?: unknown },
  ) {
    this.realtime.emitToUser(userId, 'companion.updated', {
      id: companion.id,
      mood: companion.mood,
      action: companion.action,
    });
  }

  async getMine(userId: string) {
    await this.usersService.findOne(userId);
    return this.ensureCompanion(userId);
  }

  async upsertMine(userId: string, dto: UpsertUserCompanionDto) {
    await this.usersService.findOne(userId);
    const existing = await this.prisma.userCompanion.findUnique({
      where: { userId },
    });
    const personalizationMode =
      dto.personalizationMode ??
      existing?.personalizationMode ??
      CompanionPersonalizationMode.DEFAULT;
    const asset = await this.resolveAsset(userId, personalizationMode, dto);
    const data = {
      assetId: asset?.id ?? dto.assetId,
      name: dto.name,
      type: dto.type ?? asset?.type,
      personalizationMode,
      mood: dto.mood,
      action: dto.action,
      level: dto.level,
      affection: dto.affection,
      energy: dto.energy,
      lastSeenAt: new Date(),
      lastMoodAt: dto.mood ? new Date() : undefined,
    };

    const companion = existing
      ? await this.prisma.userCompanion.update({
          where: { userId },
          data,
          include: { asset: true },
        })
      : await this.prisma.userCompanion.create({
          data: {
            userId,
            assetId: asset?.id ?? dto.assetId,
            name: dto.name ?? 'Mon Leo',
            type: dto.type ?? asset?.type,
            personalizationMode,
            mood: dto.mood ?? CompanionMood.CHILL,
            action: dto.action ?? CompanionAction.IDLE,
            level: dto.level ?? 1,
            affection: dto.affection ?? 0,
            energy: dto.energy ?? 100,
            lastSeenAt: new Date(),
          },
          include: { asset: true },
        });

    this.emitCompanionUpdate(userId, companion);
    return companion;
  }

  async interact(userId: string, dto: CreateCompanionInteractionDto) {
    const companion = await this.ensureCompanion(userId);
    const affectionGain = this.getAffectionGain(dto.type);
    const energyDelta = this.getEnergyDelta(dto.type);

    const [interaction, updated] = await this.prisma.$transaction([
      this.prisma.companionInteraction.create({
        data: {
          userId,
          companionId: companion.id,
          type: dto.type,
          metadata: dto.metadata as Prisma.InputJsonValue,
        },
      }),
      this.prisma.userCompanion.update({
        where: { id: companion.id },
        data: {
          affection: Math.min(100, companion.affection + affectionGain),
          energy: Math.max(0, Math.min(100, companion.energy + energyDelta)),
          lastSeenAt: new Date(),
          lastFedAt: dto.type === 'FEED' ? new Date() : companion.lastFedAt,
        },
        include: { asset: true },
      }),
    ]);

    this.emitCompanionUpdate(userId, updated);
    return { interaction, companion: updated };
  }

  async getStats(userId: string) {
    const companion = await this.ensureCompanion(userId);
    const [totalInteractions, recentInteractions] = await Promise.all([
      this.prisma.companionInteraction.count({
        where: { companionId: companion.id },
      }),
      this.prisma.companionInteraction.findMany({
        where: { companionId: companion.id },
        orderBy: { createdAt: 'desc' },
        take: 10,
      }),
    ]);

    return {
      companion,
      totalInteractions,
      recentInteractions,
    };
  }

  async getPersonalizationOptions(userId: string) {
    await this.usersService.findOne(userId);
    const profile = await this.prisma.userProfile.findUnique({
      where: { userId },
      select: {
        birthday: true,
        zodiacSign: true,
        chineseZodiac: true,
      },
    });
    const [defaultAssets, zodiacAssets, chineseZodiacAssets] =
      await Promise.all([
        this.prisma.companionAsset.findMany({
          where: { isDefault: true, isActive: true },
          orderBy: { createdAt: 'desc' },
        }),
        this.prisma.companionAsset.findMany({
          where: {
            isActive: true,
            zodiacSign: profile?.zodiacSign ?? undefined,
          },
          orderBy: { createdAt: 'desc' },
        }),
        this.prisma.companionAsset.findMany({
          where: {
            isActive: true,
            chineseZodiac: profile?.chineseZodiac ?? undefined,
          },
          orderBy: { createdAt: 'desc' },
        }),
      ]);

    return {
      profile,
      modes: [
        {
          mode: CompanionPersonalizationMode.DEFAULT,
          label: 'Mặc định',
          available: defaultAssets.length > 0,
          assets: defaultAssets,
        },
        {
          mode: CompanionPersonalizationMode.ZODIAC,
          label: 'Theo cung hoàng đạo',
          key: profile?.zodiacSign ?? null,
          available: Boolean(profile?.zodiacSign) && zodiacAssets.length > 0,
          assets: zodiacAssets,
        },
        {
          mode: CompanionPersonalizationMode.CHINESE_ZODIAC,
          label: 'Theo 12 con giáp',
          key: profile?.chineseZodiac ?? null,
          available:
            Boolean(profile?.chineseZodiac) && chineseZodiacAssets.length > 0,
          assets: chineseZodiacAssets,
        },
        {
          mode: CompanionPersonalizationMode.CUSTOM,
          label: 'Tự chọn linh thú',
          available: true,
          assets: [],
        },
      ],
    };
  }

  async switchPersonalization(
    userId: string,
    dto: SwitchCompanionPersonalizationDto,
  ) {
    const companion = await this.ensureCompanion(userId);

    if (
      dto.personalizationMode === CompanionPersonalizationMode.CUSTOM &&
      !dto.assetId
    ) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'assetId is required when personalizationMode is CUSTOM',
        HttpStatus.BAD_REQUEST,
      );
    }

    const asset = await this.resolveAsset(userId, dto.personalizationMode, {
      assetId: dto.assetId,
      personalizationMode: dto.personalizationMode,
    });
    const preserveProgress = dto.preserveProgress !== false;
    const resetVisualState = dto.resetVisualState ?? true;
    const updated = await this.prisma.userCompanion.update({
      where: { id: companion.id },
      data: {
        assetId: asset?.id ?? companion.assetId,
        type: asset?.type ?? companion.type,
        personalizationMode: dto.personalizationMode,
        level: preserveProgress ? companion.level : 1,
        affection: preserveProgress ? companion.affection : 0,
        energy: preserveProgress ? companion.energy : 100,
        mood: resetVisualState ? CompanionMood.CHILL : companion.mood,
        action: resetVisualState ? CompanionAction.IDLE : companion.action,
        lastSeenAt: new Date(),
      },
      include: { asset: true },
    });

    this.emitCompanionUpdate(userId, updated);
    return {
      companion: updated,
      transition: {
        fromMode: companion.personalizationMode,
        toMode: dto.personalizationMode,
        fromAssetId: companion.assetId,
        toAssetId: updated.assetId,
        preserveProgress,
        resetVisualState,
        rule: preserveProgress
          ? 'Giữ level/affection/energy khi đổi linh thú.'
          : 'Reset level/affection/energy theo lựa chọn của client.',
      },
    };
  }

  private async ensureCompanion(userId: string) {
    const companion = await this.prisma.userCompanion.findUnique({
      where: { userId },
      include: { asset: true },
    });

    if (companion) {
      return companion;
    }

    return this.upsertMine(userId, {});
  }

  private async resolveAsset(
    userId: string,
    mode: CompanionPersonalizationMode,
    dto: UpsertUserCompanionDto,
  ) {
    if (mode === CompanionPersonalizationMode.CUSTOM && dto.assetId) {
      return this.prisma.companionAsset.findFirst({
        where: { id: dto.assetId, isActive: true },
      });
    }

    if (mode === CompanionPersonalizationMode.ZODIAC) {
      const profile = await this.prisma.userProfile.findUnique({
        where: { userId },
        select: { zodiacSign: true },
      });

      if (profile?.zodiacSign) {
        const asset = await this.prisma.companionAsset.findFirst({
          where: { zodiacSign: profile.zodiacSign, isActive: true },
          orderBy: { createdAt: 'desc' },
        });

        if (asset) return asset;
      }
    }

    if (mode === CompanionPersonalizationMode.CHINESE_ZODIAC) {
      const profile = await this.prisma.userProfile.findUnique({
        where: { userId },
        select: { chineseZodiac: true },
      });

      if (profile?.chineseZodiac) {
        const asset = await this.prisma.companionAsset.findFirst({
          where: { chineseZodiac: profile.chineseZodiac, isActive: true },
          orderBy: { createdAt: 'desc' },
        });

        if (asset) return asset;
      }
    }

    return this.prisma.companionAsset.findFirst({
      where: { isDefault: true, isActive: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  private getAffectionGain(type: string) {
    const normalized = type.toUpperCase();
    if (normalized === 'PET') return 4;
    if (normalized === 'FEED') return 6;
    if (normalized === 'PLAY') return 5;
    if (normalized === 'MOOD_CHECKIN') return 3;
    return 1;
  }

  private getEnergyDelta(type: string) {
    const normalized = type.toUpperCase();
    if (normalized === 'FEED') return 10;
    if (normalized === 'PLAY') return -8;
    if (normalized === 'SLEEP') return 20;
    return 0;
  }

  async chatWithCompanion(userId: string, message: string) {
    const companion = await this.ensureCompanion(userId);
    const apiKey = this.configService.get<string>('GEMINI_API_KEY');

    let reply = 'Cảm ơn bạn đã trò chuyện với mình nhé! Hôm nay bạn thế nào?';
    let newMood = companion.mood;
    let newAction = companion.action;

    if (apiKey) {
      try {
        const historyRows = await this.prisma.companionInteraction.findMany({
          where: { userId, companionId: companion.id, type: 'CHAT' },
          orderBy: { createdAt: 'desc' },
          take: 10,
        });
        const historyList = [...historyRows].reverse();
        const historyText = historyList
          .map((row) => {
            const meta = row.metadata as {
              sender?: string;
              text?: string;
            } | null;
            if (meta?.sender && meta?.text) {
              return `${meta.sender === 'user' ? 'User' : companion.name}: ${meta.text}`;
            }
            return '';
          })
          .filter(Boolean)
          .join('\n');

        const prompt = [
          `Bạn là ${companion.name}, linh thú trợ lý ảo thuộc hệ ${companion.type} của người dùng.`,
          `Trạng thái hiện tại của bạn:`,
          `- Cảm xúc hiện tại: ${companion.mood}`,
          `- Động tác hiện tại: ${companion.action}`,
          `- Độ thân thiết (0-100): ${companion.affection}`,
          `- Năng lượng (0-100): ${companion.energy}`,
          ``,
          `Quy tắc trả lời:`,
          `- Trả lời cực kỳ thân thiện, ấm áp bằng tiếng Việt.`,
          `- Ngắn gọn (1-2 câu), giống như tin nhắn chat nhanh.`,
          `- Phù hợp với tính cách hệ linh thú ${companion.type} và mức độ thân thiện hiện tại.`,
          `- Dựa vào lịch sử hội thoại gần đây để tiếp nối câu chuyện tự nhiên.`,
          ``,
          `Lịch sử hội thoại gần đây:`,
          historyText || '(Chưa có hội thoại trước đó)',
          ``,
          `Tin nhắn mới nhất từ người dùng: "${message}"`,
        ].join('\n');

        const genAI = new GoogleGenerativeAI(apiKey);
        const model = genAI.getGenerativeModel({
          model: 'gemini-1.5-flash',
          generationConfig: {
            responseMimeType: 'application/json',
            responseSchema: {
              type: SchemaType.OBJECT,
              properties: {
                reply: {
                  type: SchemaType.STRING,
                  description:
                    'Lời phản hồi bằng tiếng Việt ngắn gọn (1-2 câu).',
                },
                mood: {
                  type: SchemaType.STRING,
                  format: 'enum',
                  enum: ['CHILL', 'HAPPY', 'EXCITED', 'TIRED'],
                },
                action: {
                  type: SchemaType.STRING,
                  format: 'enum',
                  enum: ['IDLE', 'WAVE', 'EAT', 'SLEEP'],
                },
              },
              required: ['reply', 'mood', 'action'],
            },
          },
        });

        const result = await model.generateContent(prompt);
        const text = result.response.text();
        const parsed = JSON.parse(text) as {
          reply: string;
          mood: string;
          action: string;
        };

        if (parsed.reply) {
          reply = parsed.reply;
          newMood = parsed.mood as CompanionMood;
          newAction = parsed.action as CompanionAction;
        }
      } catch {
        const localRes = this.getLocalFallbackReply(
          message,
          companion.name || 'Linh thú',
          companion.mood,
          companion.action,
        );
        reply = localRes.reply;
        newMood = localRes.mood;
        newAction = localRes.action;
      }
    } else {
      const localRes = this.getLocalFallbackReply(
        message,
        companion.name || 'Linh thú',
        companion.mood,
        companion.action,
      );
      reply = localRes.reply;
      newMood = localRes.mood;
      newAction = localRes.action;
    }

    const [userMsgRow, companionMsgRow, updated] =
      await this.prisma.$transaction([
        this.prisma.companionInteraction.create({
          data: {
            userId,
            companionId: companion.id,
            type: 'CHAT',
            metadata: {
              sender: 'user',
              text: message,
            },
          },
        }),
        this.prisma.companionInteraction.create({
          data: {
            userId,
            companionId: companion.id,
            type: 'CHAT',
            metadata: {
              sender: 'companion',
              text: reply,
            },
          },
        }),
        this.prisma.userCompanion.update({
          where: { id: companion.id },
          data: {
            affection: Math.min(100, companion.affection + 2),
            mood: newMood,
            action: newAction,
            lastSeenAt: new Date(),
          },
          include: { asset: true },
        }),
      ]);

    this.emitCompanionUpdate(userId, updated);

    return {
      reply,
      companion: updated,
      userMessage: userMsgRow,
      companionMessage: companionMsgRow,
    };
  }

  private getLocalFallbackReply(
    message: string,
    name: string,
    currentMood: CompanionMood,
    currentAction: CompanionAction,
  ): { reply: string; mood: CompanionMood; action: CompanionAction } {
    const msg = message.toLowerCase().trim();
    let reply = 'Cảm ơn bạn đã trò chuyện với mình nhé! Hôm nay bạn thế nào?';
    let mood = currentMood;
    let action = currentAction;

    if (
      msg.includes('hello') ||
      msg.includes('hi') ||
      msg.includes('chào') ||
      msg.includes('alo') ||
      msg.includes('chao')
    ) {
      const replies = [
        `Chào anh/chị meow! Hôm nay anh/chị thế nào rồi? Cần ${name} em lắng nghe gì không?`,
        `Meow chào anh/chị! Chúc anh/chị có một ngày thật bình yên nhé!`,
        `Xin chào meow! Rất vui được trò chuyện với anh/chị. Hôm nay anh/chị có gì vui kể em nghe đi!`,
      ];
      reply = replies[Math.floor(Math.random() * replies.length)];
      mood = CompanionMood.HAPPY;
      action = CompanionAction.LOOKING;
    } else if (
      msg.includes('buồn') ||
      msg.includes('buon') ||
      msg.includes('chán') ||
      msg.includes('chan') ||
      msg.includes('tệ') ||
      msg.includes('te') ||
      msg.includes('khóc') ||
      msg.includes('khoc') ||
      msg.includes('sad') ||
      msg.includes('depress')
    ) {
      const replies = [
        `Đừng buồn nha meow... Có em ở đây luôn lắng nghe anh/chị nè! Để em ôm một cái meow meow~`,
        `Thương anh/chị nhiều meow... Hãy hít thở thật sâu nhé, mọi chuyện rồi sẽ ổn thôi mà!`,
        `Meow~ Anh/chị có chuyện gì kể em nghe đi, đừng giữ một mình trong lòng nha.`,
      ];
      reply = replies[Math.floor(Math.random() * replies.length)];
      mood = CompanionMood.SAD;
      action = CompanionAction.SITTING;
    } else if (
      msg.includes('mệt') ||
      msg.includes('met') ||
      msg.includes('tired') ||
      msg.includes('oải') ||
      msg.includes('oai') ||
      msg.includes('stress')
    ) {
      const replies = [
        `Anh/chị đã vất vả nhiều rồi meow... Hãy dành chút thời gian uống nước và nghỉ ngơi đi ạ.`,
        `Nghe anh/chị nói mệt em xót quá meow... Mình tạm gác công việc qua một bên và nghỉ xíu nha.`,
        `Cần em mát-xa chân bằng đệm thịt meow meow không? Nghỉ ngơi chút đi anh/chị ơi.`,
      ];
      reply = replies[Math.floor(Math.random() * replies.length)];
      mood = CompanionMood.SLEEPY;
      action = CompanionAction.SITTING;
    } else if (
      msg.includes('vui') ||
      msg.includes('khỏe') ||
      msg.includes('khoe') ||
      msg.includes('tốt') ||
      msg.includes('tot') ||
      msg.includes('good') ||
      msg.includes('happy') ||
      msg.includes('tuyệt') ||
      msg.includes('tuyet')
    ) {
      const replies = [
        `Nghe vậy em cũng thấy vui lây meow! Anh/chị thật tuyệt vời, cùng meow tận hưởng ngày hôm nay nhé!`,
        `Hihi tuyệt vời quá meow! Mong niềm vui này sẽ ở bên anh/chị suốt cả ngày.`,
        `Meow meow! Anh/chị cười lên trông đáng yêu lắm đó, hãy luôn vui vẻ thế này nha!`,
      ];
      reply = replies[Math.floor(Math.random() * replies.length)];
      mood = CompanionMood.PLAYFUL;
      action = CompanionAction.PLAYING;
    } else if (
      msg.includes('ăn') ||
      msg.includes('an') ||
      msg.includes('đói') ||
      msg.includes('doi') ||
      msg.includes('hungry') ||
      msg.includes('food') ||
      msg.includes('cơm') ||
      msg.includes('com') ||
      msg.includes('thèm') ||
      msg.includes('them')
    ) {
      const replies = [
        `Nhoàm nhoàm... anh/chị có gì ngon cho em ăn không meow? Nhắc tới ăn em cũng thấy đói bụng rồi nè!`,
        `Meow~ Ăn uống đầy đủ mới có sức khỏe nha anh/chị! Nhớ ăn món gì thật ngon đấy.`,
        `Hôm nay ăn món gì ngon kể em nghe với meow! Em thèm pate quá đi mất thôi.`,
      ];
      reply = replies[Math.floor(Math.random() * replies.length)];
      mood = CompanionMood.HUNGRY;
      action = CompanionAction.SITTING;
    } else if (
      msg.includes('ngủ') ||
      msg.includes('ngu') ||
      msg.includes('sleep') ||
      msg.includes('night') ||
      msg.includes('bed') ||
      msg.includes('mơ') ||
      msg.includes('mo')
    ) {
      const replies = [
        `Khò khò... chúc anh/chị ngủ ngon và có những giấc mơ thật đẹp meow~ Em đi ngủ đây...`,
        `Chúc anh/chị ngủ thật ngon meow~ Mai thức dậy sẽ lại tràn đầy năng lượng!`,
        `Ngoan nào, đi ngủ thôi meow~ Để em nằm cạnh sưởi ấm cho anh/chị nha.`,
      ];
      reply = replies[Math.floor(Math.random() * replies.length)];
      mood = CompanionMood.SLEEPY;
      action = CompanionAction.SLEEPING;
    } else if (
      msg.includes('yêu') ||
      msg.includes('yeu') ||
      msg.includes('thương') ||
      msg.includes('thuong') ||
      msg.includes('love') ||
      msg.includes('cute') ||
      msg.includes('thích') ||
      msg.includes('thich') ||
      msg.includes('like')
    ) {
      const replies = [
        `Hihi meow meow~ Em cũng yêu anh/chị nhiều lắm! Cảm ơn anh/chị đã luôn chăm sóc em.`,
        `Được anh/chị yêu thương là hạnh phúc lớn nhất của em meow! Moa~`,
        `Meow meow! Trái tim em đang đập thình thịch vì ngượng nè hihi.`,
      ];
      reply = replies[Math.floor(Math.random() * replies.length)];
      mood = CompanionMood.HAPPY;
      action = CompanionAction.LOOKING;
    } else {
      const fallbacks = [
        `Meow~ Anh/chị nói tiếp đi, em vẫn đang chăm chú lắng nghe nè!`,
        `Em hiểu rồi meow! Đôi khi chỉ cần chia sẻ ra là lòng sẽ nhẹ nhõm hơn nhiều đó.`,
        `Meow meow! Anh/chị hôm nay có mệt lắm không? Đừng quên nghỉ ngơi và uống nước nhé.`,
        `Meow~ Em luôn ở đây đồng hành cùng anh/chị trên mọi nẻo đường!`,
        `Thật vậy hả anh/chị meow? Kể thêm cho em nghe đi.`,
      ];
      reply = fallbacks[Math.floor(Math.random() * fallbacks.length)];
      action = Math.random() > 0.5 ? CompanionAction.LOOKING : CompanionAction.IDLE;
    }

    return { reply, mood, action };
  }

  async getMemoryInsights(userId: string) {
    const companion = await this.ensureCompanion(userId);
    const since = new Date();
    since.setDate(since.getDate() - 30);

    const [checkins, interactions, relaxSessions] = await Promise.all([
      this.prisma.moodCheckin.findMany({
        where: { userId, createdAt: { gte: since } },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.companionInteraction.findMany({
        where: { companionId: companion.id, createdAt: { gte: since } },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.relaxSession.findMany({
        where: { userId, createdAt: { gte: since } },
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    const moodCounts: Record<string, number> = {};
    const triggerCounts: Record<string, number> = {};
    let totalScore = 0;

    for (const c of checkins) {
      moodCounts[c.mood] = (moodCounts[c.mood] || 0) + 1;
      totalScore += c.finalScore ?? c.rawScore ?? 50;
      if (c.trigger) {
        triggerCounts[String(c.trigger)] =
          (triggerCounts[String(c.trigger)] || 0) + 1;
      }
    }

    const dominantMood =
      Object.entries(moodCounts).sort((a, b) => b[1] - a[1])[0]?.[0] ||
      'NEUTRAL';
    const topTriggers = Object.entries(triggerCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([trigger, count]) => ({ trigger, count }));
    const avgScore =
      checkins.length > 0 ? Math.round(totalScore / checkins.length) : 50;

    const chatCount = interactions.filter((i) => i.type === 'CHAT').length;
    const totalInteractionCount = interactions.length;
    const activityCount = relaxSessions.length;

    const memories: Array<{ type: string; text: string; emoji: string }> = [];

    if (checkins.length >= 7) {
      memories.push({
        type: 'streak',
        text: `Bạn đã check-in ${checkins.length} lần trong 30 ngày qua`,
        emoji: '🔥',
      });
    }
    if (dominantMood === 'HAPPY' || dominantMood === 'CALM') {
      memories.push({
        type: 'positive',
        text: `Mood chủ đạo của bạn là ${dominantMood.toLowerCase()} — rất tuyệt!`,
        emoji: '✨',
      });
    }
    if (topTriggers.length > 0) {
      memories.push({
        type: 'trigger',
        text: `Trigger hay gặp nhất: ${topTriggers[0].trigger} (${topTriggers[0].count} lần)`,
        emoji: '🎯',
      });
    }
    if (chatCount >= 5) {
      memories.push({
        type: 'bond',
        text: `${companion.name} đã trò chuyện với bạn ${chatCount} lần — thật thân thiết!`,
        emoji: '💬',
      });
    }
    if (activityCount >= 5) {
      memories.push({
        type: 'activity',
        text: `Bạn đã hoàn thành ${activityCount} hoạt động thư giãn`,
        emoji: '🧘',
      });
    }
    if (avgScore < 40) {
      memories.push({
        type: 'care',
        text: `${companion.name} nhận thấy bạn hay stress gần đây — hãy nghỉ ngơi nhiều hơn nhé`,
        emoji: '🤗',
      });
    }

    return {
      companion: {
        name: companion.name,
        level: companion.level,
        affection: companion.affection,
      },
      period: {
        from: since.toISOString(),
        to: new Date().toISOString(),
        days: 30,
      },
      stats: {
        totalCheckins: checkins.length,
        avgScore,
        dominantMood,
        topTriggers,
        chatCount,
        totalInteractions: totalInteractionCount,
        activityCount,
      },
      memories,
    };
  }

  async getWeeklyMemoryCard(userId: string) {
    const companion = await this.ensureCompanion(userId);
    const since = new Date();
    since.setDate(since.getDate() - 7);

    const [checkins, relaxSessions] = await Promise.all([
      this.prisma.moodCheckin.findMany({
        where: { userId, createdAt: { gte: since } },
        orderBy: { createdAt: 'asc' },
      }),
      this.prisma.relaxSession.findMany({
        where: { userId, createdAt: { gte: since } },
      }),
    ]);

    const moodJourney = checkins.map((c) => ({
      mood: c.mood,
      score: c.finalScore ?? c.rawScore ?? 50,
      date: c.createdAt,
    }));

    const bestDay = moodJourney.reduce(
      (best, cur) => (cur.score < best.score ? cur : best),
      moodJourney[0] || { mood: 'NEUTRAL', score: 50, date: new Date() },
    );
    const worstDay = moodJourney.reduce(
      (worst, cur) => (cur.score > worst.score ? cur : worst),
      moodJourney[0] || { mood: 'NEUTRAL', score: 50, date: new Date() },
    );

    const avgScore =
      moodJourney.length > 0
        ? Math.round(
            moodJourney.reduce((s, m) => s + m.score, 0) / moodJourney.length,
          )
        : 50;

    const messages: string[] = [];
    if (checkins.length === 0) {
      messages.push(
        `${companion.name} nhớ bạn lắm! Tuần này chưa thấy bạn check-in.`,
      );
    } else if (avgScore <= 35) {
      messages.push(`Tuần này bạn khá ổn! ${companion.name} vui vì điều đó.`);
    } else if (avgScore >= 65) {
      messages.push(
        `${companion.name} thấy bạn hơi stress tuần này. Tuần tới mình thử thư giãn nhiều hơn nha!`,
      );
    } else {
      messages.push(
        `Một tuần bình thường — ${companion.name} luôn ở đây bên bạn.`,
      );
    }

    if (relaxSessions.length > 0) {
      messages.push(
        `Bạn đã thực hành ${relaxSessions.length} hoạt động thư giãn — giỏi lắm!`,
      );
    }

    return {
      companionName: companion.name,
      companionLevel: companion.level,
      weekOf: since.toISOString(),
      summary: {
        checkinCount: checkins.length,
        avgScore,
        activityCount: relaxSessions.length,
        bestDay: bestDay ? { mood: bestDay.mood, date: bestDay.date } : null,
        worstDay: worstDay
          ? { mood: worstDay.mood, date: worstDay.date }
          : null,
      },
      moodJourney: moodJourney.slice(0, 14),
      messages,
    };
  }

  async getChatHistory(userId: string) {
    const companion = await this.ensureCompanion(userId);
    const rows = await this.prisma.companionInteraction.findMany({
      where: { userId, companionId: companion.id, type: 'CHAT' },
      orderBy: { createdAt: 'desc' },
      take: 30,
    });
    return [...rows].reverse().map((r) => {
      const meta = r.metadata as { sender?: string; text?: string } | null;
      return {
        id: r.id,
        sender: meta?.sender || 'user',
        text: meta?.text || '',
        createdAt: r.createdAt,
      };
    });
  }
}
