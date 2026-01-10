import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Projects } from '../entities/Project/Project';
import { ProjectsService } from '../services/Project';
import { ProjectsController } from '../controllers/project.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Projects])],
  providers: [ProjectsService],
  controllers: [ProjectsController],
  exports: [ProjectsService],
})
export class ProjectsModule {}
