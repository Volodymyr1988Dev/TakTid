import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CleanupService } from '../services/CleanupService';
import { Projects } from '../entities/Project/Project';
import { ProjectImage } from '../entities/Project/ProjectImages';
import { ProjectAssignment } from '../entities/Project/ProjectAssignment';
import { TimeEntry } from '../entities/TimeEntries/TimeEntries';
import { SessionModule } from './session.module';
import { ProjectImagesModule } from './projectImage.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Projects,
      ProjectImage,
      ProjectAssignment,
      TimeEntry,
    ]),
    SessionModule,
    ProjectImagesModule,
  ],
  providers: [CleanupService],
})
export class CleanupModule {}
