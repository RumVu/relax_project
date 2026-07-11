import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import { Request } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RequirePremium } from '../common/decorators/require-premium.decorator';
import { AiInsightsService } from './ai-insights.service';
import { FeedbackInsightDto } from './dto/feedback-insight.dto';

interface AuthedRequest extends Request {
  user: { id: string };
}

@ApiTags('ai-insights')
@ApiBearerAuth()
@RequirePremium()
@Controller('ai/insights')
@UseGuards(JwtAuthGuard)
export class AiInsightsController {
  constructor(private readonly service: AiInsightsService) {}

  @Get('me')
  @ApiOperation({
    summary:
      'Get my recent AI insights and recommendations (auto-regenerates if stale).',
  })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  getMine(
    @Req() req: AuthedRequest,
    @Query('limit', new ParseIntPipe({ optional: true })) limit?: number,
  ) {
    return this.service.getMine(req.user.id, Math.min(limit ?? 5, 50));
  }

  @Post('me/refresh')
  @ApiOperation({
    summary: 'Force regeneration of insights using the configured AI provider.',
  })
  refresh(
    @Req() req: AuthedRequest,
    @Query('limit', new ParseIntPipe({ optional: true })) limit?: number,
  ) {
    return this.service.refreshMine(req.user.id, limit ?? 5);
  }

  @Patch('me/:id/feedback')
  @ApiOperation({ summary: 'Mark an insight as useful / not useful.' })
  setFeedback(
    @Req() req: AuthedRequest,
    @Param('id') insightId: string,
    @Body() dto: FeedbackInsightDto,
  ) {
    return this.service.setFeedback(req.user.id, insightId, dto.useful);
  }
}
