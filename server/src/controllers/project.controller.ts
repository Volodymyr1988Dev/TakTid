import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
  Req,
  UnauthorizedException,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ProjectsService } from '../services/Project';
import { CreateProjectDto, UpdateProjectDto } from '../types/index';
import type { AuthRequest } from '../types/index';
import { AdminGuard } from '../types/auth/admin.guard';
@ApiTags('Projects')
@Controller('projects')
export class ProjectsController {
  constructor(private readonly projectsService: ProjectsService) {}
  @UseGuards(AdminGuard)
  @Post()
  create(@Body() dto: CreateProjectDto) {
    return this.projectsService.create(dto);
  }

  @Get()
  findAll(@Req() req: AuthRequest) {
    if (!req.user) {
      throw new UnauthorizedException();
    }
    return this.projectsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.projectsService.findOne(id);
  }

  @UseGuards(AdminGuard)
  @Get(':projectId/details')
  getProjectDetails(@Param('projectId') projectId: string) {
    return this.projectsService.getProjectDetails(projectId)
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateProjectDto) {
    return this.projectsService.update(id, dto);
  }
  @UseGuards(AdminGuard)
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.projectsService.remove(id);
  }
}
