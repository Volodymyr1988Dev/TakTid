import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseInterceptors,
  UploadedFile,
  UseGuards,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ProjectsService } from '../services/Project';
import { CreateProjectDto, UpdateProjectDto } from '../types/index';
//import { AuthGuard } from '../types/auth/guard';
import { AdminGuard } from '../types/auth/admin.guard';
import { FileInterceptor } from '@nestjs/platform-express';
import cloudinary from '../config/cloudinary.config';
@ApiTags('Projects')
@Controller('projects')
export class ProjectsController {
  constructor(private readonly projectsService: ProjectsService) {}
  @UseGuards(AdminGuard)
  @Post(':id/images')
  @UseInterceptors(FileInterceptor('file'))
  async upload(
    @Param('id') projectId: string,
    @UploadedFile() file: Express.Multer.File,
  ) {
    const uploaded = await cloudinary.uploader.upload(file.path, {
      folder: 'projects',
    });

    return this.projectsService.addImage(projectId, {
      url: uploaded.secure_url,
      publicId: uploaded.public_id,
    });
  }

  @UseGuards(AdminGuard)
  @Post()
  create(@Body() dto: CreateProjectDto) {
    return this.projectsService.create(dto);
  }

  @Get()
  findAll() {
    return this.projectsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.projectsService.findOne(id);
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
