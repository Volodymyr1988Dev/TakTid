import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProjectMaterialService } from '../services/ProjectMaterial.service';
import { ProjectMaterialController } from '../controllers/ProjectMaterial.controller';
import { ProjectMaterial } from '../entities/Project/ProjectMaterial';
import { ProjectMaterialItem } from '../entities/Project/ProjectMaterialItem';
import { Projects } from '../entities/Project/Project';

@Module({
  imports: [
    TypeOrmModule.forFeature([ProjectMaterial, ProjectMaterialItem, Projects]),
  ],
  providers: [ProjectMaterialService],
  controllers: [ProjectMaterialController],
})
export class ProjectMaterialModule {}
