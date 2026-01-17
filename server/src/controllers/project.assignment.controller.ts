import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Req,
  Query,
  UnauthorizedException,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ProjectAssignmentService } from '../services/ProjectAssignment';
import { CreateProjectAssignmentDto } from '../types/project/project.assignment.create.dto';
import { UpdateProjectAssignmentDto } from '../types/project/project.assignment.update.dto';
import { QueryProjectAssignmentDto } from '../types/project/project.assignments.query.dto';
import { UseGuards } from '@nestjs/common';
import type { AuthRequest } from '../types/index';
//import { AuthGuard } from '../types/auth/guard';
import { AdminGuard } from '../types/auth/admin.guard';

@ApiTags('Project Assignments')
//@UseGuards(AuthGuard)
@Controller('project-assignments')
export class ProjectAssignmentController {
  constructor(private readonly assignmentService: ProjectAssignmentService) {}
  @UseGuards(AdminGuard)
  @Post()
  create(@Body() dto: CreateProjectAssignmentDto, @Req() req: AuthRequest) {
    if (!req.user) {
      throw new Error('Unauthorized');
    }
    return this.assignmentService.create(dto, req.user);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateProjectAssignmentDto) {
    return this.assignmentService.update(id, dto);
  }
  @Get()
  findByPeriod(
    @Query() query: QueryProjectAssignmentDto,
    @Req() req: AuthRequest,
  ) {
    if (!req.user) {
      throw new UnauthorizedException();
    }

    return this.assignmentService.findByPeriod(
      req.user.id,
      query.from,
      query.to,
    );
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
