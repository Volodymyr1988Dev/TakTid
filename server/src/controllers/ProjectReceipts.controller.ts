import {
  Controller,
  Delete,
  Param,
  Query,
  Post,
  UseInterceptors,
  UseGuards,
  Get,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { AdminGuard } from '../types/auth/admin.guard';
import { FilesInterceptor } from '@nestjs/platform-express';
import { UploadedFiles } from '@nestjs/common/decorators/http/route-params.decorator';
import { ProjectReceiptsService } from '../services/ProjectReceipts';

@ApiTags('Project Receipts')
@Controller('project-receipts')
export class ProjectReceiptsController {

  constructor(private readonly receiptsService: ProjectReceiptsService) {}
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
  ) {
    return this.receiptsService.uploadMultiple(projectId, files);
  }

  @Get('project/:projectId')
  getByProject(
    @Param('projectId') projectId: string,
    @Query('page') page = '1',
    @Query('limit') limit = '5',
  ) {
    return this.receiptsService.getByProject(
      projectId,
      Number(page),
      Number(limit),
    );
  }

  @UseGuards(AdminGuard)
  @Delete(':receiptId')
  remove(@Param('receiptId') receiptId: string) {
    return this.receiptsService.remove(receiptId);
  }
}
