import { Injectable, NotFoundException } from '@nestjs/common';
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
  async upload(projectId: string, file: Express.Multer.File) {
    const project = await this.projectRepo.findOne({
      where: { id: projectId },
    });

    if (!project) {
      throw new NotFoundException('Project not found');
    }

    // ⬆️ Cloudinary upload
    const uploaded = await cloudinary.uploader.upload(file.path, {
      folder: `projects/${projectId}`,
    });

    // ⬇️ Save metadata
    const image = this.imageRepo.create({
      url: uploaded.secure_url,
      publicId: uploaded.public_id,
      project,
    });

    return this.imageRepo.save(image);
  }

  /**
   * REMOVE IMAGE
   */
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
