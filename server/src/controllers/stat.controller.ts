import { Controller, Get, Query, Param } from '@nestjs/common';
import { StatsService } from '../services/StatService';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('Admin Stats')
@Controller('stats')
export class StatsController {
  constructor(private readonly statsService: StatsService) {}

  @Get('month')
  getMonth(@Query('year') year: number, @Query('month') month: number) {
    return this.statsService.getMonthStats(+year, +month);
  }

  @Get('month/:userId')
  getUserDetails(
    @Query('year') year: number,
    @Query('month') month: number,
    @Param('userId') userId: string,
  ) {
    return this.statsService.getUserMonthDetails(userId, +year, +month);
  }
}
