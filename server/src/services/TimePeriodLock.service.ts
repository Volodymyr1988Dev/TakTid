
import {
  Injectable,
  //NotFoundException,
  BadRequestException,
  ForbiddenException
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import {
  TimePeriodLock,
  PeriodType,
} from '../entities/TimePeriodLock/TimePeriodLock';

@Injectable()
export class TimePeriodLockService {
  private readonly UNLOCK_HOURS = 24;

  constructor(
    @InjectRepository(TimePeriodLock)
    private readonly lockRepo: Repository<TimePeriodLock>,
  ) {}

  // Get today's date in Swedish local time.
  private getToday(): string {
    const parts = new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Europe/Stockholm',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).formatToParts(new Date());

    const values = Object.fromEntries(
      parts.map(p => [p.type, p.value]),
    );

    return `${values.year}-${values.month}-${values.day}`;
  }

  // Always calculate Monday-Sunday.
  getWeekRange(date: string) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      throw new BadRequestException('Invalid date');
    }

    const parsed = new Date(`${date}T00:00:00.000Z`);

    if (
      Number.isNaN(parsed.getTime()) ||
      parsed.toISOString().slice(0, 10) !== date
    ) {
      throw new BadRequestException('Invalid date');
    }

    const day = parsed.getUTCDay();

    const diff = day === 0 ? -6 : 1 - day;

    parsed.setUTCDate(parsed.getUTCDate() + diff);

    const start = parsed.toISOString().slice(0, 10);

    parsed.setUTCDate(parsed.getUTCDate() + 6);

    const end = parsed.toISOString().slice(0, 10);

    return {
      periodStart: start,
      periodEnd: end,
    };
  }

  private async getOrCreatePeriod(date: string) {
    const { periodStart, periodEnd } =
      this.getWeekRange(date);

    let period = await this.lockRepo.findOne({
      where: {
        periodType: PeriodType.WEEK,
        periodStart,
      },
    });

    if (!period) {
      period = this.lockRepo.create({
        periodType: PeriodType.WEEK,
        periodStart,
        periodEnd,
        manuallyLocked: false,
        unlockedUntil: null,
        unlockedByUserId: null,
        lockedByUserId: null,
        lockedAt: null,
        reason: null,
      });

      try {
        period = await this.lockRepo.save(period);
      } catch (error: any) {
        // Handle concurrent creation.
        if (error.code !== '23505') {
          throw error;
        }

        period = await this.lockRepo.findOneOrFail({
          where: {
            periodType: PeriodType.WEEK,
            periodStart,
          },
        });
      }
    }

    return period;
  }

  private isPeriodLocked(period: TimePeriodLock): boolean {
    const today = this.getToday();

    const temporarilyUnlocked =
      period.unlockedUntil !== null &&
      period.unlockedUntil.getTime() > Date.now();

    if (temporarilyUnlocked) {
      return false;
    }

    // Automatically close completed weeks.
    const automaticallyClosed =
      period.periodEnd < today;

    return (
      period.manuallyLocked ||
      automaticallyClosed
    );
  }

  async assertPeriodOpen(
    //_userId: string,
    date: string,
  ): Promise<void> {
    const period = await this.getOrCreatePeriod(date);

    if (this.isPeriodLocked(period)) {
      throw new ForbiddenException(
        `This week is locked (${period.periodStart} - ${period.periodEnd})`,
      );
    }
  }

  async getPeriodStatus(date: string) {
    const period = await this.getOrCreatePeriod(date);

    const locked = this.isPeriodLocked(period);

    return {
      id: period.id,
      periodType: period.periodType,
      periodStart: period.periodStart,
      periodEnd: period.periodEnd,
      locked,
      manuallyLocked: period.manuallyLocked,
      automaticallyLocked:
        period.periodEnd < this.getToday(),
      temporarilyUnlocked:
        period.unlockedUntil !== null &&
        period.unlockedUntil.getTime() > Date.now(),
      unlockedUntil: period.unlockedUntil,
      lockedAt: period.lockedAt,
      lockedByUserId: period.lockedByUserId,
      unlockedByUserId: period.unlockedByUserId,
      reason: period.reason,
    };
  }

  async closeWeek(
    date: string,
    adminId: string,
    reason?: string,
  ) {
    const period = await this.getOrCreatePeriod(date);

    period.manuallyLocked = true;
    period.unlockedUntil = null;
    period.unlockedByUserId = null;
    period.lockedByUserId = adminId;
    period.lockedAt = new Date();
    period.reason = reason ?? null;

    return this.lockRepo.save(period);
  }

  async unlockWeek(
    date: string,
    adminId: string,
    reason?: string,
  ) {
    const period = await this.getOrCreatePeriod(date);

    period.unlockedUntil = new Date(
      Date.now() + this.UNLOCK_HOURS * 60 * 60 * 1000,
    );

    period.unlockedByUserId = adminId;
    period.reason = reason ?? null;

    return this.lockRepo.save(period);
  }
}
