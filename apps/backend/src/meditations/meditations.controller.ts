import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import type { AuthUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateMeditationSessionDto } from './dto/create-meditation-session.dto';
import { CreateMeditationGuideDto } from './dto/create-meditation-guide.dto';
import { UpdateMeditationGuideDto } from './dto/update-meditation-guide.dto';
import { MeditationsService } from './meditations.service';

@ApiTags('Meditations')
@ApiBearerAuth('access-token')
@Controller('meditations')
export class MeditationsController {
  constructor(private readonly meditationsService: MeditationsService) {}

  @ApiOperation({ summary: 'Get active guided meditations' })
  @Get('guides')
  findGuides(
    @Query('difficulty') difficulty?: string,
    @Query('focusArea') focusArea?: string,
    @Query('admin') admin?: string,
  ) {
    return this.meditationsService.findGuides(
      difficulty,
      focusArea,
      admin === 'true',
    );
  }

  @ApiOperation({ summary: 'Create a new meditation guide' })
  @AdminOnly()
  @Post('guides')
  createGuide(@Body() dto: CreateMeditationGuideDto) {
    return this.meditationsService.createGuide(dto);
  }

  @ApiOperation({ summary: 'Update a meditation guide' })
  @AdminOnly()
  @Patch('guides/:id')
  updateGuide(@Param('id') id: string, @Body() dto: UpdateMeditationGuideDto) {
    return this.meditationsService.updateGuide(id, dto);
  }

  @ApiOperation({ summary: 'Delete a meditation guide' })
  @AdminOnly()
  @Delete('guides/:id')
  deleteGuide(@Param('id') id: string) {
    return this.meditationsService.deleteGuide(id);
  }

  @ApiOperation({ summary: 'Log a meditation session' })
  @UseGuards(JwtAuthGuard)
  @Post('sessions')
  createSession(
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateMeditationSessionDto,
  ) {
    return this.meditationsService.createSession(user.id, dto);
  }

  @ApiOperation({ summary: 'Get current user meditation sessions history' })
  @UseGuards(JwtAuthGuard)
  @Get('sessions/me')
  findSessions(@CurrentUser() user: AuthUser) {
    return this.meditationsService.findSessions(user.id);
  }
}
