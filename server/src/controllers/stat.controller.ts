import { Controller, Get, Query } from '@nestjs/common';
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
}
