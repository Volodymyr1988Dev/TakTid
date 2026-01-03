import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Patch,
  Query,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { TimeEntryService } from '../services/TimeEntry';
import {
  CreateTimeEntryDto,
  QueryTimeEntryDto,
  UpdateTimeEntryDto,
} from '../types/index';

@ApiTags('Time Entries')
@Controller('time-entries')
export class TimeEntryController {
  constructor(private readonly timeService: TimeEntryService) {}

  @Post()
  create(@Body() dto: CreateTimeEntryDto) {
    return this.timeService.create(dto);
  }

  @Get('user/:userId')
  findByUser(@Param('userId') userId: string) {
    return this.timeService.findByUser(userId);
  }

  @Get('period')
  findByPeriod(@Query() query: QueryTimeEntryDto) {
    return this.timeService.findByPeriod(query.userId, query.from, query.to);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateTimeEntryDto) {
    return this.timeService.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.timeService.remove(id);
  }
}
