import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProjectAssignment } from '../entities/Project/ProjectAssignment';
import { ProjectAssignmentService } from '../services/ProjectAssignment';
import { ProjectAssignmentController } from '../controllers/project.assignment.controller';
import { User } from '../entities/User/User';
import { Projects } from '../entities/Project/Project';
import { TimePeriodLockModule } from './timePeriodLock.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([ProjectAssignment, User, Projects]),
    TimePeriodLockModule
  ],
  providers: [ProjectAssignmentService],
  controllers: [ProjectAssignmentController],
  exports: [ProjectAssignmentService],
})
export class ProjectAssignmentModule {}
