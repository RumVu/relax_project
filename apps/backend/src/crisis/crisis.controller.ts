import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CheckContentDto } from './dto/check-content.dto';
import { CrisisService } from './crisis.service';

@ApiTags('Crisis')
@ApiBearerAuth('access-token')
@Controller('crisis')
export class CrisisController {
  constructor(private readonly crisisService: CrisisService) {}

  @ApiOperation({ summary: 'Check text content for crisis indicators' })
  @ApiOkResponse({ description: 'Safety assessment result.' })
  @UseGuards(JwtAuthGuard)
  @Post('check')
  checkContent(@Body() dto: CheckContentDto) {
    return this.crisisService.checkContent(dto.text);
  }

  @ApiOperation({ summary: 'Get crisis hotlines' })
  @ApiOkResponse({ description: 'List of crisis hotlines.' })
  @ApiQuery({ name: 'country', required: false, example: 'VN' })
  @UseGuards(JwtAuthGuard)
  @Get('hotlines')
  getHotlines(@Query('country') country?: string) {
    return this.crisisService.getHotlines(country);
  }

  @ApiOperation({ summary: 'Get safety disclaimer' })
  @ApiOkResponse({ description: 'Safety disclaimer text.' })
  @UseGuards(JwtAuthGuard)
  @Get('disclaimer')
  getDisclaimer() {
    return this.crisisService.getSafetyDisclaimer();
  }
}
