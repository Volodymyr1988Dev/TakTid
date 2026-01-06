import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ProjectAssignmentService } from '../services/ProjectAssignment';
import { CreateProjectAssignmentDto } from '../types/project/project.assignment.create.dto';
import { UpdateProjectAssignmentDto } from '../types/project/project.assignment.update.dto';
import { UseGuards } from '@nestjs/common';
//import { AuthGuard } from '../types/auth/guard';
import { AdminGuard } from '../types/auth/admin.guard';

@ApiTags('Project Assignments')
//@UseGuards(AuthGuard)
@Controller('project-assignments')
export class ProjectAssignmentController {
  constructor(private readonly assignmentService: ProjectAssignmentService) {}
  @UseGuards(AdminGuard)
  @Post()
  create(@Body() dto: CreateProjectAssignmentDto) {
    return this.assignmentService.create(dto);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateProjectAssignmentDto) {
    return this.assignmentService.update(id, dto);
  }

  @Get('project/:projectId')
  findByProject(@Param('projectId') projectId: string) {
    return this.assignmentService.findByProject(projectId);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.assignmentService.remove(id);
  }
}
