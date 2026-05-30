import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'

import { ProjectTask } from '../entities/Project/ProjectTask'
import { User } from '../entities/User/User'

import { ProjectTaskController } from '../controllers/projectTask.controller'
import { ProjectTaskService } from '../services/project-task.service'

import { OcrService } from '../services/OCR.sevice'

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ProjectTask,
      User,
    ]),
  ],

  controllers: [
    ProjectTaskController,
  ],

  providers: [
    ProjectTaskService,
    OcrService,
  ],

  exports: [
    ProjectTaskService,
  ],
})
export class ProjectTaskModule {}