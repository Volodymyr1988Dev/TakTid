import {
  Controller,
  Delete,
  Param,
  Post,
  UseInterceptors,
  UploadedFile,
  UseGuards,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
//import { AuthGuard } from '../types/auth/guard';
import { AdminGuard } from '../types/auth/admin.guard';
import { FileInterceptor } from '@nestjs/platform-express';
import { ProjectImagesService } from '../services/ProjectImages.service';

@ApiTags('Project Images')
@Controller('project-images')
export class ProjectImagesController {
  constructor(private readonly imagesService: ProjectImagesService) {}

  /**
   * UPLOAD
   */
  @UseGuards(AdminGuard)
  @Post(':projectId')
  @UseInterceptors(FileInterceptor('file'))
  upload(
    @Param('projectId') projectId: string,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return this.imagesService.upload(projectId, file);
  }

  /**
   * DELETE
   */
  @UseGuards(AdminGuard)
  @Delete(':imageId')
  remove(@Param('imageId') imageId: string) {
    return this.imagesService.remove(imageId);
  }
}
