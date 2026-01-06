import { Injectable } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Projects } from '../entities/Project/Project';
import { ProjectImage } from '../entities/Project/ProjectImages';
import cloudinary from '../config/cloudinary.config';
import dayjs from 'dayjs';

@Injectable()
export class ImageCleanupCron {
  constructor(
    @InjectRepository(Projects)
    private readonly projectRepo: Repository<Projects>,
    @InjectRepository(ProjectImage)
    private readonly imageRepo: Repository<ProjectImage>,
  ) {}

  @Cron('0 3 * * *')
  async cleanupImages() {
    const projects = await this.projectRepo.find({
      relations: ['images', 'timeEntries'],
    });

    for (const project of projects) {
      //const lastEntry = project.timeEntries?.at(-1);
      const lastEntry = project.timeEntries?.sort(
        (a, b) => dayjs(b.date).unix() - dayjs(a.date).unix(),
      )[0];

      if (!lastEntry) continue;

      if (dayjs().diff(dayjs(lastEntry.date), 'year') >= 1) {
        const toDelete = project.images
          .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
          .slice(3);

        for (const img of toDelete) {
          await cloudinary.uploader.destroy(img.publicId);
          await this.imageRepo.delete(img.id);
        }
      }
    }
  }
}
