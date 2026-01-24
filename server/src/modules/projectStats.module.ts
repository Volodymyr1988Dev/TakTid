import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Projects } from '../entities/Project/Project';
import { TimeEntry } from '../entities/TimeEntries/TimeEntries';
import { ProjectAssignment } from '../entities/Project/ProjectAssignment';
import { ProjectStatsService } from '../services/projectStats.service';
import { ProjectStatsController } from '../controllers/projectStats.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Projects, TimeEntry, ProjectAssignment])],
  providers: [ProjectStatsService],
  controllers: [ProjectStatsController],
})
export class ProjectStatsModule {}
