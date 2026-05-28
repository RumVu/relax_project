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
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiForbiddenResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import type { AuthUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { CreateJournalDto } from './dto/create-journal.dto';
import { JournalQueryDto } from './dto/journal-query.dto';
import { JournalPageDto, JournalResponseDto } from './dto/journal-response.dto';
import { UpdateJournalDto } from './dto/update-journal.dto';
import { JournalsService } from './journals.service';

@ApiTags('Journals')
@ApiBearerAuth('access-token')
@Controller('journals')
export class JournalsController {
  constructor(private readonly journalsService: JournalsService) {}

  @ApiOperation({ summary: 'List current user journals' })
  @ApiOkResponse({ type: JournalPageDto, description: 'Current user journal list.' })
  @UseGuards(JwtAuthGuard)
  @Get('me')
  findMine(@CurrentUser() user: AuthUser, @Query() query: JournalQueryDto) {
    return this.journalsService.findMine(user.id, query);
  }

  @ApiOperation({ summary: 'Get current user journal stats' })
  @ApiOkResponse({ description: 'Current user journal stats.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/stats')
  getMineStats(@CurrentUser() user: AuthUser, @Query() query: JournalQueryDto) {
    return this.journalsService.getStats(user.id, query);
  }

  @ApiOperation({ summary: 'Create current user journal' })
  @ApiCreatedResponse({ type: JournalResponseDto, description: 'Created journal.' })
  @UseGuards(JwtAuthGuard)
  @Post('me')
  createMine(@CurrentUser() user: AuthUser, @Body() dto: CreateJournalDto) {
    return this.journalsService.create(user.id, dto);
  }

  @ApiOperation({ summary: 'List journals by user id (admin)' })
  @ApiOkResponse({ type: JournalPageDto, description: 'User journal list.' })
  @ApiForbiddenResponse({ description: 'Requires ADMIN role.' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Get('user/:userId')
  findByUserId(
    @Param('userId') userId: string,
    @Query() query: JournalQueryDto,
  ) {
    return this.journalsService.findByUserId(userId, query);
  }

  @ApiOperation({ summary: 'Get one journal by id' })
  @ApiOkResponse({ type: JournalResponseDto, description: 'Journal payload.' })
  @UseGuards(JwtAuthGuard)
  @Get(':id')
  findOne(@Param('id') id: string, @CurrentUser() user: AuthUser) {
    return this.journalsService.findOne(id, user);
  }

  @ApiOperation({ summary: 'Update one journal by id' })
  @ApiOkResponse({ type: JournalResponseDto, description: 'Updated journal.' })
  @UseGuards(JwtAuthGuard)
  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() dto: UpdateJournalDto,
    @CurrentUser() user: AuthUser,
  ) {
    return this.journalsService.update(id, dto, user);
  }

  @ApiOperation({ summary: 'Delete one journal by id' })
  @ApiOkResponse({ type: JournalResponseDto, description: 'Deleted journal.' })
  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  remove(@Param('id') id: string, @CurrentUser() user: AuthUser) {
    return this.journalsService.remove(id, user);
  }
}
