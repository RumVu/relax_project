import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { ApiProperty } from '@nestjs/swagger';
import { IsString, Length, Matches } from 'class-validator';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { AdminUserPlanService } from './admin-user-plan.service';

export class SetUserPlanDto {
  @ApiProperty({
    description:
      'Tier code (UPPER_SNAKE) matching one of the rows from /admin/billing/tiers. E.g. "FREE", "CHILL_PLUS".',
    example: 'CHILL_PLUS',
  })
  @IsString()
  @Length(2, 48)
  @Matches(/^[A-Z][A-Z0-9_]+$/)
  planName!: string;
}

@ApiTags('Admin · Users')
@AdminOnly()
@Controller('admin/users')
export class AdminUserPlanController {
  constructor(private readonly service: AdminUserPlanService) {}

  @Get(':userId/subscription')
  @ApiOperation({ summary: "Read a user's current active subscription." })
  getCurrent(@Param('userId') userId: string) {
    return this.service.getCurrent(userId);
  }

  @Post(':userId/plan')
  @ApiOperation({
    summary:
      "Admin-set the user's plan immediately, without going through payment. Cancels any active subscription and provisions a fresh ACTIVE one for the chosen tier.",
  })
  setPlan(@Param('userId') userId: string, @Body() dto: SetUserPlanDto) {
    return this.service.setUserPlan(userId, dto.planName);
  }
}
