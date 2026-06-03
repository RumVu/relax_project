import {
  Controller,
  Get,
  Param,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { Locale, QuestsService } from './quests.service';

interface AuthedRequest extends Request {
  user: { id: string };
}

function pickLocale(raw: unknown): Locale {
  return raw === 'en' ? 'en' : 'vi';
}

@ApiTags('quests')
@ApiBearerAuth()
@Controller('quests')
@UseGuards(JwtAuthGuard)
export class QuestsController {
  constructor(private readonly service: QuestsService) {}

  @Get('me')
  @ApiOperation({
    summary: 'List my active daily quests (auto-seeded + auto-completed).',
  })
  getMine(@Req() req: AuthedRequest, @Query('locale') locale?: string) {
    return this.service.getMine(req.user.id, pickLocale(locale));
  }

  @Post('me/:id/reroll')
  @ApiOperation({
    summary:
      'Replace one of my active quests with a different random template I have not seen.',
  })
  reroll(
    @Req() req: AuthedRequest,
    @Param('id') id: string,
    @Query('locale') locale?: string,
  ) {
    return this.service.reroll(req.user.id, id, pickLocale(locale));
  }
}
