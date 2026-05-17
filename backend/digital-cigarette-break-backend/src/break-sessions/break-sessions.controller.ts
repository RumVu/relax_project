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
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import type { AuthUser } from '../auth/auth.types';
import { CreateBreakSessionDto } from './dto/create-break-session.dto';
import { UpdateBreakSessionDto } from './dto/update-break-session.dto';
import { BreakSessionsService } from './break-sessions.service';

@ApiTags('break-sessions')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('break-sessions')
export class BreakSessionsController {
  constructor(private readonly breakSessionsService: BreakSessionsService) {}

  @Post()
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateBreakSessionDto) {
    return this.breakSessionsService.create(user.id, dto);
  }

  @Get()
  findAll(@CurrentUser() user: AuthUser) {
    return this.breakSessionsService.findAll(user.id);
  }

  @Get(':id')
  findOne(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.breakSessionsService.findOne(user.id, id);
  }

  @Patch(':id')
  update(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: UpdateBreakSessionDto,
  ) {
    return this.breakSessionsService.update(user.id, id, dto);
  }

  @Delete(':id')
  remove(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.breakSessionsService.remove(user.id, id);
  }
}
