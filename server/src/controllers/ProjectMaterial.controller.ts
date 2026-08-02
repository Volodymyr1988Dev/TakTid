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
import { ProjectMaterialService } from '../services/ProjectMaterial.service';
import { CreateMaterialListDto } from '../types/project/material/CreateMaterialList.dto';
import { UpdateMaterialListDto } from '../types/project/material/UpdateMaterialList.dto';

@ApiTags('Project Materials')
@Controller('project-materials')
export class ProjectMaterialController {
  constructor(private readonly service: ProjectMaterialService) {}

  @Get('project/:projectId')
  getByProject(
    @Param('projectId')
    projectId: string,
  ) {
    return this.service.findByProject(projectId);
  }

  @Post()
  create(
    @Body()
    dto: CreateMaterialListDto,
  ) {
    return this.service.create(dto);
  }
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }

  @Patch(':id')
  update(
    @Param('id')
    id: string,
    @Body()
    dto: UpdateMaterialListDto,
  ) {
    return this.service.update(id, dto);
  }
}
