
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { TimePeriodLock } from
  '../entities/TimePeriodLock/TimePeriodLock';

import { TimePeriodLockService } from
  '../services/TimePeriodLock.service';

import { TimesheetPeriodController } from
  '../controllers/TimePeriodLock.controller';

@Module({
  imports: [ TypeOrmModule.forFeature([TimePeriodLock])],
  controllers: [ TimesheetPeriodController ],
  providers: [ TimePeriodLockService ],
  exports: [ TimePeriodLockService ],
})
export class TimePeriodLockModule {}
