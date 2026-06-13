import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { AuthUser } from '../auth/auth.types';
import { ExperimentsService } from './experiments.service';
import { CreateExperimentDto } from './dto/create-experiment.dto';
import { UpdateExperimentDto } from './dto/update-experiment.dto';
import { LogExperimentEventDto } from './dto/log-experiment-event.dto';

@ApiTags('Experiments')
@ApiBearerAuth()
@Controller('experiments')
export class ExperimentsController {
  constructor(private readonly service: ExperimentsService) {}

  // ── Admin endpoints ─────────────────────────────────────

  @Get()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'List all experiments (admin)' })
  @ApiOkResponse({ description: 'List of all experiments' })
  findAll() {
    return this.service.findAll();
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create an experiment (admin)' })
  @ApiCreatedResponse({ description: 'Experiment created' })
  create(@Body() dto: CreateExperimentDto) {
    return this.service.create(dto);
  }

  @Patch(':key')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update an experiment (admin)' })
  @ApiOkResponse({ description: 'Experiment updated' })
  update(@Param('key') key: string, @Body() dto: UpdateExperimentDto) {
    return this.service.update(key, dto);
  }

  @Delete(':key')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete an experiment (admin)' })
  @ApiOkResponse({ description: 'Experiment deleted' })
  delete(@Param('key') key: string) {
    return this.service.delete(key);
  }

  // ── User endpoints ──────────────────────────────────────

  @Get('me/assignments')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Get all my experiment assignments' })
  @ApiOkResponse({ description: 'List of user experiment assignments' })
  getMyAssignments(@CurrentUser() user: AuthUser) {
    return this.service.getMyAssignments(user.id);
  }

  @Get('me/:key')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Get my assignment for a specific experiment' })
  @ApiOkResponse({ description: 'Experiment assignment (auto-assigns if needed)' })
  getAssignment(
    @CurrentUser() user: AuthUser,
    @Param('key') key: string,
  ) {
    return this.service.getAssignment(user.id, key);
  }

  @Post('me/events')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Log an experiment event' })
  @ApiCreatedResponse({ description: 'Experiment event logged' })
  logEvent(
    @CurrentUser() user: AuthUser,
    @Body() dto: LogExperimentEventDto,
  ) {
    return this.service.logEvent(user.id, dto);
  }
}
