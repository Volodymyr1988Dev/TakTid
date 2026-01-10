import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Projects } from '../entities/Project/Project';
import { ProjectImage } from '../entities/Project/ProjectImages';
import { ProjectImagesController } from '../controllers/ProjectImages.controller';
import { ProjectImagesService } from '../services/ProjectImages.service';

@Module({
  imports: [TypeOrmModule.forFeature([ProjectImage, Projects])],
  providers: [ProjectImagesService],
  controllers: [ProjectImagesController],
})
export class ProjectImagesModule {}
