import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiCreatedResponse, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import type { AuthUser } from '../auth/auth.types';
import { FeedbacksService } from './feedbacks.service';
import { CreateFeedbackDto } from './dto/create-feedback.dto';

@ApiTags('Feedbacks')
@ApiBearerAuth('access-token')
@Controller('feedbacks')
export class FeedbacksController {
  constructor(private readonly feedbacksService: FeedbacksService) {}

  @ApiOperation({ summary: 'Submit feedback or bug report (user)' })
  @ApiCreatedResponse({ description: 'Feedback submitted.' })
  @UseGuards(JwtAuthGuard)
  @Post()
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateFeedbackDto) {
    return this.feedbacksService.create(user.id, dto);
  }

  @ApiOperation({ summary: 'List all feedbacks (admin only)' })
  @ApiOkResponse({ description: 'List of all feedbacks.' })
  @AdminOnly()
  @Get()
  findAll() {
    return this.feedbacksService.findAll();
  }

  @ApiOperation({ summary: 'Update feedback status (admin only)' })
  @ApiOkResponse({ description: 'Status updated.' })
  @AdminOnly()
  @Patch(':id/status')
  updateStatus(@Param('id') id: string, @Body('status') status: string) {
    return this.feedbacksService.updateStatus(id, status);
  }
}
