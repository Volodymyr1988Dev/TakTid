import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TimeEntry } from '../entities/TimeEntries/TimeEntries';
import { ProjectAssignment } from '../entities/Project/ProjectAssignment';
import { StatsController } from '../controllers/stat.controller';
import { StatsService } from '../services/StatService';

@Module({
  imports: [TypeOrmModule.forFeature([TimeEntry, ProjectAssignment])],
  providers: [StatsService],
  controllers: [StatsController],
})
export class StatsModule {}
