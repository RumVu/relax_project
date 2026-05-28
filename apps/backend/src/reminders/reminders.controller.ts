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
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import type { AuthUser } from '../auth/auth.types';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateReminderDto } from './dto/create-reminder.dto';
import { ReminderQueryDto } from './dto/reminder-query.dto';
import {
  ReminderPageDto,
  ReminderResponseDto,
} from './dto/reminder-response.dto';
import { UpdateReminderDto } from './dto/update-reminder.dto';
import { RemindersService } from './reminders.service';

@ApiTags('Reminders')
@ApiBearerAuth('access-token')
@Controller('reminders')
export class RemindersController {
  constructor(private readonly remindersService: RemindersService) {}

  @ApiOperation({ summary: 'List current user reminders' })
  @ApiOkResponse({
    type: ReminderPageDto,
    description: 'Paginated reminder list for current user.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me')
  listMine(@CurrentUser() user: AuthUser, @Query() query: ReminderQueryDto) {
    return this.remindersService.listMine(user.id, query);
  }

  @ApiOperation({ summary: 'Get current user reminder stats' })
  @ApiOkResponse({ description: 'Reminder counters for dashboard settings.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/stats')
  getMineStats(@CurrentUser() user: AuthUser) {
    return this.remindersService.getStats(user.id);
  }

  @ApiOperation({ summary: 'Create current user reminder' })
  @ApiCreatedResponse({
    type: ReminderResponseDto,
    description: 'Created reminder.',
  })
  @UseGuards(JwtAuthGuard)
  @Post('me')
  createMine(@CurrentUser() user: AuthUser, @Body() dto: CreateReminderDto) {
    return this.remindersService.create(user.id, dto);
  }

  @ApiOperation({ summary: 'List all reminders (admin)' })
  @ApiOkResponse({
    type: ReminderPageDto,
    description: 'Paginated reminder list across users.',
  })
  @AdminOnly()
  @Get()
  listAll(@Query() query: ReminderQueryDto) {
    return this.remindersService.listAll(query);
  }

  @ApiOperation({ summary: 'List reminders by user id (admin)' })
  @ApiOkResponse({
    type: ReminderPageDto,
    description: 'Paginated reminder list for a user.',
  })
  @AdminOnly()
  @Get('user/:userId')
  listByUserId(
    @Param('userId') userId: string,
    @Query() query: ReminderQueryDto,
  ) {
    return this.remindersService.listByUserId(userId, query);
  }

  @ApiOperation({ summary: 'Get one reminder by id' })
  @ApiOkResponse({
    type: ReminderResponseDto,
    description: 'Reminder payload.',
  })
  @UseGuards(JwtAuthGuard)
  @Get(':id')
  findOne(@Param('id') id: string, @CurrentUser() user: AuthUser) {
    return this.remindersService.findOne(id, user);
  }

  @ApiOperation({ summary: 'Update one reminder by id' })
  @ApiOkResponse({
    type: ReminderResponseDto,
    description: 'Updated reminder.',
  })
  @UseGuards(JwtAuthGuard)
  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() dto: UpdateReminderDto,
    @CurrentUser() user: AuthUser,
  ) {
    return this.remindersService.update(id, dto, user);
  }

  @ApiOperation({ summary: 'Delete one reminder by id' })
  @ApiOkResponse({ description: 'Reminder removal result.' })
  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  remove(@Param('id') id: string, @CurrentUser() user: AuthUser) {
    return this.remindersService.remove(id, user);
  }
}
