import {
    BadRequestException,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Req,
  Body,
  UseInterceptors,
  UploadedFiles,
  UnauthorizedException,
  UseGuards,
  Delete,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import type { AuthRequest } from '../types/index';
import { ProjectTaskService } from '../services/project-task.service';
import { CreateProjectTaskDto } from '../types/project/create-project-task.dto';
import { UpdateProjectTaskDto } from '../types/project/update-project-task.dto';
import { AdminGuard } from '../types/auth/admin.guard';
//import { AuthRequest } from '../types/auth/auth.request.dto';
import { memoryStorage } from 'multer';

@Controller('projects')
export class ProjectTaskController {

  constructor(
    private readonly taskService: ProjectTaskService
  ) {}

  @Get(':id/tasks')
  getTasks(@Param('id') id: string) {
    return this.taskService.getProjectTasks(id)
  }

  @UseGuards(AdminGuard)
  @Post(':id/tasks')
    createTask(
    @Param('id') projectId: string,
    @Body() dto: CreateProjectTaskDto,
    ) {
    return this.taskService.createTask(
        projectId,
        dto,
    )
    }

    @UseGuards(AdminGuard)
    @Post(':id/import-tasks')
   @UseInterceptors(
    FilesInterceptor(
        'files',
        10,
        {
        storage: memoryStorage(),

        limits: {
            fileSize: 10 * 1024 * 1024,
        },
        },
    ),
    )
    upload(
    @Param('id')
    projectId: string,

    @UploadedFiles()
    files: Express.Multer.File[],
    ) {

    if (!files?.length) {
        throw new BadRequestException(
        'No files uploaded',
        )
    }

  return this.taskService.importTasks(
    projectId,
    files,
  )
}

  @UseGuards(AdminGuard)
    @Delete('/tasks/:taskId')
    deleteTask(
    @Param('taskId') taskId: string,
    ) {
    return this.taskService.deleteTask(taskId)
    }

  @UseGuards(AdminGuard)
  @Patch('/tasks/:taskId')
    updateTaskData(
    @Param('taskId') taskId: string,
    @Body() dto: UpdateProjectTaskDto,
    ) {
    return this.taskService.updateTaskData(
        taskId,
        dto,
    )
    }

  @UseGuards(AdminGuard)
  @Patch('/tasks/:taskId/toggle')
  toggle(
    @Param('taskId') taskId: string,
    @Req() req: AuthRequest
  ) {
    if (!req.user) {
        throw new UnauthorizedException()
    }
    return this.taskService.updateTask(
      taskId,
      req.user.id,
      //authUser: AuthUser,
    )
  }
}