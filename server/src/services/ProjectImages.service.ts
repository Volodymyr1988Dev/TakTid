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
import { Readable } from 'stream';
import { UploadApiResponse } from 'cloudinary';
import { Express } from 'express';

@Injectable()
export class ProjectImagesService {
  constructor(
    @InjectRepository(ProjectImage)
    private readonly imageRepo: Repository<ProjectImage>,

    @InjectRepository(Projects)
    private readonly projectRepo: Repository<Projects>,
  ) {}

  async uploadMultiple(
    projectId: string,
    files: Express.Multer.File[],
  ): Promise<ProjectImage[]> {
    const project = await this.projectRepo.findOneBy({ id: projectId });
    if (!project) throw new NotFoundException();
    if (!files || !files.length) {
      throw new BadRequestException('No files uploaded');
    }
    const results: ProjectImage[] = [];

    for (const file of files) {
      const uploaded: UploadApiResponse = await this.uploadToCloudinary(
        file.buffer,
        projectId,
      );
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

  async getByProject(projectId: string, page: number, limit: number) {
    const [data, total] = await this.imageRepo.findAndCount({
      where: { project: { id: projectId } },
      order: { createdAt: 'DESC' },
      take: limit,
      skip: (page - 1) * limit,
    });

    return {
      data,
      total,
      page,
      lastPage: Math.ceil(total / limit),
    };
  }
  async removeByProject(projectId: string): Promise<void> {
    const images = await this.imageRepo.find({
      where: { project: { id: projectId } },
    });

    await Promise.all(
      images.map((image) => cloudinary.uploader.destroy(image.publicId)),
    );

    await this.imageRepo.remove(images);
  }
  async remove(imageId: string) {
    const image = await this.imageRepo.findOne({
      where: { id: imageId },
    });

    if (!image) {
      throw new NotFoundException('Image not found');
    }

    await cloudinary.uploader.destroy(image.publicId);

    await this.imageRepo.remove(image);
  }
  private uploadToCloudinary(
    buffer: Buffer,
    projectId: string,
  ): Promise<UploadApiResponse> {
    return new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        {
          folder: `projects/${projectId}`,
          transformation: [
            {
              width: 1600,
              height: 1600,
              crop: 'limit',
            },
            {
              quality: 'auto',
              fetch_format: 'auto',
            },
          ],
        },
        (error, result) => {
          if (error) return reject(new Error(error.message));
          if (!result) {
            return reject(new Error('Cloudinary upload failed'));
          }
          resolve(result);
        },
      );

      Readable.from(buffer).pipe(uploadStream);
    });
  }
}
