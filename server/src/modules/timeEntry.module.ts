import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TimeEntry } from '../entities/TimeEntries/TimeEntries';
import { TimeEntryService } from '../services/TimeEntry';
import { TimeEntryController } from '../controllers/timeEntry.controller';
import { User } from '../entities/User/User';
import { Projects } from '../entities/Project/Project';

@Module({
  imports: [TypeOrmModule.forFeature([TimeEntry, User, Projects])],
  providers: [TimeEntryService],
  controllers: [TimeEntryController],
})
export class TimeEntryModule {}
