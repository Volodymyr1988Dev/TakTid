import {
  Controller,
  Delete,
  Param,
  Query,
  Post,
  UseInterceptors,
  //UploadedFile,
  UseGuards,
  Get,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
//import { AuthGuard } from '../types/auth/guard';
import { AdminGuard } from '../types/auth/admin.guard';
import { FilesInterceptor } from '@nestjs/platform-express';
import { ProjectImagesService } from '../services/ProjectImages.service';
import { UploadedFiles } from '@nestjs/common/decorators/http/route-params.decorator';

@ApiTags('Project Images')
@Controller('project-images')
export class ProjectImagesController {
  constructor(private readonly imagesService: ProjectImagesService) {}

  @Post(':projectId')
  @UseInterceptors(
    FilesInterceptor('files', 10, {
      limits: {
        fileSize: 10 * 1024 * 1024,
      },
    }),
  )
  uploadMultiple(
    @Param('projectId') projectId: string,
    @UploadedFiles() files: Express.Multer.File[],
    //@UploadedFiles() files: Array<Express.Multer.File>,
  ) {
    console.log('FILES:', files);
    return this.imagesService.uploadMultiple(projectId, files);
  }

  @Get('project/:projectId')
  getByProject(
    @Param('projectId') projectId: string,
    @Query('page') page = '1',
    @Query('limit') limit = '5',
  ) {
    return this.imagesService.getByProject(
      projectId,
      Number(page),
      Number(limit),
    );
  }

  @UseGuards(AdminGuard)
  @Delete(':imageId')
  remove(@Param('imageId') imageId: string) {
    return this.imagesService.remove(imageId);
  }
}
