import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProjectImage } from '../entities/Project/ProjectImages';
import { Projects } from '../entities';
import cloudinary from '../config/cloudinary.config';

@Injectable()
export class ProjectImagesService {
  constructor(
    @InjectRepository(ProjectImage)
    private readonly imageRepo: Repository<ProjectImage>,

    @InjectRepository(Projects)
    private readonly projectRepo: Repository<Projects>,
  ) {}

  /**
   * ADD IMAGE
   */
  async uploadMultiple(projectId: string, files: Express.Multer.File[]) {
    console.log('SERVICE FILES:', files);
    const project = await this.projectRepo.findOneBy({ id: projectId });
    if (!project) throw new NotFoundException();
    if (!files || !files.length) {
      throw new BadRequestException('No files uploaded');
    }
    const results: ProjectImage[] = [];

    for (const file of files) {
      const uploaded = await cloudinary.uploader.upload(file.path, {
        folder: `projects/${projectId}`,
      });

      const image = this.imageRepo.create({
        url: uploaded.secure_url,
        publicId: uploaded.public_id,
        project,
      } as Partial<ProjectImage>);

      const saved = await this.imageRepo.save(image);
      results.push(saved);
    }

    return results;
  }

  async getByProject(projectId: string) {
    return this.imageRepo.find({
      where: { project: { id: projectId } },
      order: { createdAt: 'DESC' },
    });
  }

  async remove(imageId: string) {
    const image = await this.imageRepo.findOne({
      where: { id: imageId },
    });

    if (!image) {
      throw new NotFoundException('Image not found');
    }

    // ❗ delete from Cloudinary
    await cloudinary.uploader.destroy(image.publicId);

    // ❗ delete from DB
    await this.imageRepo.remove(image);
  }
}
