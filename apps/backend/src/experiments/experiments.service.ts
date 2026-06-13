import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateExperimentDto } from './dto/create-experiment.dto';
import { UpdateExperimentDto } from './dto/update-experiment.dto';
import { LogExperimentEventDto } from './dto/log-experiment-event.dto';

@Injectable()
export class ExperimentsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    const items = await this.prisma.experiment.findMany({
      orderBy: { createdAt: 'desc' },
    });
    return { items, total: items.length };
  }

  async findByKey(key: string) {
    return this.prisma.experiment.findUnique({ where: { key } });
  }

  async create(dto: CreateExperimentDto) {
    return this.prisma.experiment.create({
      data: {
        key: dto.key,
        name: dto.name,
        description: dto.description,
        variants: dto.variants,
        isActive: dto.isActive ?? true,
      },
    });
  }

  async update(key: string, dto: UpdateExperimentDto) {
    const experiment = await this.prisma.experiment.findUnique({
      where: { key },
    });
    if (!experiment) {
      throw new NotFoundException(`Experiment with key "${key}" not found`);
    }

    return this.prisma.experiment.update({
      where: { key },
      data: {
        ...(dto.key !== undefined && { key: dto.key }),
        ...(dto.name !== undefined && { name: dto.name }),
        ...(dto.description !== undefined && { description: dto.description }),
        ...(dto.variants !== undefined && { variants: dto.variants }),
        ...(dto.isActive !== undefined && { isActive: dto.isActive }),
      },
    });
  }

  async delete(key: string) {
    const experiment = await this.prisma.experiment.findUnique({
      where: { key },
    });
    if (!experiment) {
      throw new NotFoundException(`Experiment with key "${key}" not found`);
    }

    return this.prisma.experiment.delete({ where: { key } });
  }

  async getAssignment(userId: string, experimentKey: string) {
    const experiment = await this.prisma.experiment.findUnique({
      where: { key: experimentKey },
    });
    if (!experiment) {
      throw new NotFoundException(
        `Experiment with key "${experimentKey}" not found`,
      );
    }

    const existing = await this.prisma.experimentAssignment.findUnique({
      where: {
        userId_experimentId: { userId, experimentId: experiment.id },
      },
    });

    if (existing) {
      return { experiment, variant: existing.variant };
    }

    const variants = experiment.variants as string[];
    const variant = variants[Math.floor(Math.random() * variants.length)];

    await this.prisma.experimentAssignment.create({
      data: {
        userId,
        experimentId: experiment.id,
        variant,
      },
    });

    return { experiment, variant };
  }

  async getMyAssignments(userId: string) {
    const assignments = await this.prisma.experimentAssignment.findMany({
      where: { userId },
      include: { experiment: true },
      orderBy: { createdAt: 'desc' },
    });

    return {
      items: assignments.map((a) => ({
        experiment: a.experiment,
        variant: a.variant,
        assignedAt: a.createdAt,
      })),
      total: assignments.length,
    };
  }

  async logEvent(userId: string, dto: LogExperimentEventDto) {
    return this.prisma.appEvent.create({
      data: {
        userId,
        type: `experiment_${dto.eventType}`,
        data: {
          experimentKey: dto.experimentKey,
          variant: dto.variant,
        },
      },
    });
  }
}
