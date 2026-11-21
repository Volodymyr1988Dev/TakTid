
import {
  Controller,
  Get,
  Post,
  Query,
  Req,
  UseGuards,
  ForbiddenException,
  Body,
  //BadRequestException,
} from '@nestjs/common';

import { TimePeriodLockService } from
  '../services/TimePeriodLock.service';

import { AdminGuard } from
  '../types/auth/admin.guard';

import type { AuthRequest } from
  '../types/index';

@Controller('timesheet-periods')
export class TimesheetPeriodController {
  constructor(
    private readonly timePeriodLockService:
      TimePeriodLockService,
  ) {}

  @Get('status')
  getStatus(
    @Query('date') date: string,
    @Req() req: AuthRequest,
  ) {
    if (!req.user) {
      throw new ForbiddenException();
    }

    return this.timePeriodLockService.getPeriodStatus(
      date,
    );
  }

  @UseGuards(AdminGuard)
  @Post('close')
  close(
    @Query('date') date: string,
    @Body() body: { reason?: string },
    @Req() req: AuthRequest,
  ) {
    const adminId = req.user?.id;

    if (!adminId) {
      throw new ForbiddenException();
    }

    return this.timePeriodLockService.closeWeek(
      date,
      adminId,
      body.reason,
    );
  }

  @UseGuards(AdminGuard)
  @Post('unlock')
  unlock(
    @Query('date') date: string,
    @Body() body: { reason?: string },
    @Req() req: AuthRequest,
  ) {
    const adminId = req.user?.id;

    if (!adminId) {
      throw new ForbiddenException();
    }

    return this.timePeriodLockService.unlockWeek(
      date,
      adminId,
      body.reason,
    );
  }
}
