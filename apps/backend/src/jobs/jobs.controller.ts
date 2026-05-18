import { Body, Controller, Get, Post } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { RunWeeklyMoodStatsJobDto } from './dto/run-weekly-mood-stats-job.dto';
import { JobsService } from './jobs.service';

@ApiTags('Jobs')
@ApiBearerAuth('access-token')
@Controller('jobs')
export class JobsController {
  constructor(private readonly jobsService: JobsService) {}

  @ApiOperation({ summary: 'Get backend job status (admin)' })
  @ApiOkResponse({ description: 'Configured jobs and last run metadata.' })
  @AdminOnly()
  @Get('status')
  getStatus() {
    return this.jobsService.getStatus();
  }

  @ApiOperation({
    summary: 'Run weekly mood stats materialization job (admin)',
  })
  @ApiCreatedResponse({ description: 'Weekly mood stats job result.' })
  @AdminOnly()
  @Post('weekly-mood-stats/run')
  runWeeklyMoodStats(@Body() dto: RunWeeklyMoodStatsJobDto) {
    return this.jobsService.runWeeklyMoodStats(dto);
  }
}
