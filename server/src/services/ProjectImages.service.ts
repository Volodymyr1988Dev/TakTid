import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { ProjectImage } from '../entities/Project/ProjectImages';
import { Projects } from '../entities';
import cloudinary from '../config/cloudinary.config';
import { Readable } from 'stream';
import { UploadApiResponse } from 'cloudinary';
import { Express } from 'express';
import pLimit from 'p-limit';

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
    if (!files || files.length === 0) {
      throw new BadRequestException('No files uploaded');
    }
    const limitUpload = pLimit(3);
    const uploadedPublicIds: string[] = [];
    const savedPublicIds: string[] = [];
    /*
    const uploads = files.map((file) =>
      limitUpload(async () => {
        const uploaded = await this.uploadToCloudinary(file.buffer, projectId);

        const image = this.imageRepo.create({
          url: uploaded.secure_url,
          publicId: uploaded.public_id,
          project,
        } as Partial<ProjectImage>);

        return this.imageRepo.save(image);
      }),
    );

    return Promise.all(uploads);*/
    const results = await Promise.allSettled(
      files.map((file) =>
        limitUpload(async () => {
          const uploaded = await this.uploadToCloudinary(
            file.buffer,
            projectId,
          );

          // Запам'ятовуємо тільки файли цього запиту.
          uploadedPublicIds.push(uploaded.public_id);

          const image = this.imageRepo.create({
            url: uploaded.secure_url,
            publicId: uploaded.public_id,
            project,
          } as Partial<ProjectImage>);

          //return this.imageRepo.save(image);
          const saved = await this.imageRepo.save(image);

          savedPublicIds.push(uploaded.public_id);

          return saved;
        }),
      ),
    );

    const failed = results.find(
      (result): result is PromiseRejectedResult =>
        result.status === 'rejected',
    );

    if (failed) {
      let databaseCleanupSucceeded = true;
      if (uploadedPublicIds.length > 0) {
        try {
          await this.imageRepo.delete({
            publicId: In(uploadedPublicIds),
          });
        } catch (error) {
          databaseCleanupSucceeded = false;
          console.error(
            '[ProjectImages] Failed to clean up database records:',
            error,
          );
        }

        const idsToDelete = databaseCleanupSucceeded
        ? uploadedPublicIds
        : uploadedPublicIds.filter(
            (id) => !savedPublicIds.includes(id),
          );
        const cleanupResults = await Promise.allSettled(
          idsToDelete.map(async (publicId) => {
            const result = await cloudinary.uploader.destroy(publicId);

            if (
              result.result !== 'ok' &&
              result.result !== 'not found'
            ) {
              throw new Error(
                `Cloudinary destroy returned: ${result.result}`,
              );
            }
          }),
        );

        cleanupResults.forEach((result, index) => {
          if (result.status === 'rejected') {
            console.error(
              '[ProjectImages] Failed to delete Cloudinary file:',
              idsToDelete[index],
              result.reason,
            );
          }
        });
      }

      throw failed.reason instanceof Error
        ? failed.reason
        : new Error('Project images upload failed');
    }

    return results.map((result) => {
      if (result.status !== 'fulfilled') {
        throw new Error('Unexpected image upload failure');
      }

      return result.value;
    });
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
      images.map(async (image) => {
        try {
          await cloudinary.uploader.destroy(image.publicId);
        } catch (e) {
          console.warn('Cloudinary delete failed:', image.publicId, e);
        }
      }),
    );

    await this.imageRepo.remove(images);
  }
  async remove(imageId: string) {
    const image = await this.imageRepo.findOne({
      where: { id: imageId },
    });

    //if (!image) { throw new NotFoundException('Image not found')}
    if (!image) return;

    //await cloudinary.uploader.destroy(image.publicId);
    try {
      await cloudinary.uploader.destroy(image.publicId);
    } catch (e) {
      console.warn('Cloudinary delete failed:', image.publicId, e);
    }

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
