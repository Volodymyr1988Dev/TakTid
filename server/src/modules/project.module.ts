import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Projects } from '../entities/Project/Project';
import { ProjectsService } from '../services/Project';
import { ProjectsController } from '../controllers/project.controller';
import { ProjectImagesModule } from './projectImage.module';
import { TimeEntry } from '../entities/TimeEntries/TimeEntries'
import { ProjectAssignment } from '../entities';
import { ProjectReceiptsController } from '../controllers/ProjectReceipts.controller';
import { ProjectReceiptsService } from '../services/ProjectReceipts';
import { ProjectReceipt } from '../entities/Project/ProjectReceipt';

@Module({
  imports: [TypeOrmModule.forFeature([Projects, TimeEntry,
      ProjectAssignment, ProjectReceipt]), ProjectImagesModule],
  providers: [ProjectsService, ProjectReceiptsService],
  controllers: [ProjectsController, ProjectReceiptsController],
  exports: [ProjectsService],
})
export class ProjectsModule {}
