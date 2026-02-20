import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Patch,
  Query,
  Req,
  UnauthorizedException,
  ForbiddenException,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { TimeEntryService } from '../services/TimeEntry';
import { QueryTimeEntryDto } from '../types/timeEntry/timeEntry.query.dto';
import type { AuthRequest, AdminMonthStatsQueryDto } from '../types/index';
import { UpdateTimeEntryDto } from '../types/timeEntry/timeEntry.update.dto';
import { CreateTimeEntryDto } from '../types/timeEntry/timeEntry.create.dto';

@ApiTags('Time Entries')
@Controller('time-entries')
export class TimeEntryController {
  constructor(private readonly timeService: TimeEntryService) {}

  @Get('suggestions')
  findSuggestions(@Req() req: AuthRequest) {
    if (!req.user) {
      throw new UnauthorizedException();
    }
    return this.timeService.getSuggestions(req.user.id);
  }

  @Post()
  create(@Body() dto: CreateTimeEntryDto, @Req() req: AuthRequest) {
    if (!req.user) {
      throw new UnauthorizedException();
    }
    return this.timeService.create(dto, req.user.id);
  }

  @Get('user/:userId')
  findByUser(@Param('userId') userId: string) {
    return this.timeService.findByUser(userId);
  }
  @Get('period')
  findByPeriod(@Query() query: QueryTimeEntryDto, @Req() req: AuthRequest) {
    console.log('QUERY DTO:', query);
    if (!req.user) {
      throw new UnauthorizedException();
    }
    return this.timeService.findByPeriod(req.user.id, query.from, query.to);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateTimeEntryDto) {
    console.log('DTO:', dto);
    return this.timeService.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.timeService.remove(id);
  }
  @Get('stats/month/admin')
  getAdminStats(
    @Query() query: AdminMonthStatsQueryDto,
    @Req() req: AuthRequest,
  ) {
    if (!req.user?.isAdmin) {
      throw new ForbiddenException();
    }

    return this.timeService.getAdminMonthStats(query.year, query.month);
  }
}
