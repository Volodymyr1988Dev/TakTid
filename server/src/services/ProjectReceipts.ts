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
import pLimit from 'p-limit';
import { ProjectReceipt } from '../entities/Project/ProjectReceipt';

@Injectable()
export class ProjectReceiptsService {
  constructor(
    @InjectRepository(ProjectReceipt)
    private readonly receiptRepo: Repository<ProjectReceipt>,

    @InjectRepository(Projects)
    private readonly projectRepo: Repository<Projects>,
  ) {}

  async uploadMultiple(
    projectId: string,
    files: Express.Multer.File[],
  ): Promise<ProjectReceipt[]> {
    const project = await this.projectRepo.findOneBy({ id: projectId });
    if (!project) throw new NotFoundException();
    if (!files || files.length === 0) {
      throw new BadRequestException('No files uploaded');
    }
    const limitUpload = pLimit(3);
    const uploads = files.map((file) =>
      limitUpload(async () => {
        const uploaded = await this.uploadToCloudinary(file.buffer, projectId);

        const receipt = this.receiptRepo.create({
          url: uploaded.secure_url,
          publicId: uploaded.public_id,
          project,
        } as Partial<ProjectReceipt>);

        return this.receiptRepo.save(receipt);
      }),
    );

    return Promise.all(uploads);
  }

  async getByProject(projectId: string, page: number, limit: number) {
    const [data, total] = await this.receiptRepo.findAndCount({
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

  async getCount(projectId: string) {
    const count = await this.receiptRepo.count({
      where: { project: { id: projectId } },
    });
    return { count };
  }

  async removeByProject(projectId: string): Promise<void> {
    const receipts = await this.receiptRepo.find({
      where: { project: { id: projectId } },
    });

    await Promise.all(
      receipts.map(async (receipt) => {
        try {
          await cloudinary.uploader.destroy(receipt.publicId);
        } catch (e) {
          console.warn('Cloudinary delete failed:', receipt.publicId, e);
        }
      }),
    );

    await this.receiptRepo.remove(receipts);
  }
  async remove(receiptId: string) {
    const receipt = await this.receiptRepo.findOne({
      where: { id: receiptId },
    });

    if (!receipt) {
      throw new NotFoundException('Receipt not found');
    }
    //if (!receipt) return;

    //await cloudinary.uploader.destroy(receipt.publicId);
    try {
      await cloudinary.uploader.destroy(receipt.publicId);
    } catch (e) {
      console.warn('Cloudinary delete failed:', receipt.publicId, e);
    }

    await this.receiptRepo.remove(receipt);
  }
  private uploadToCloudinary(
    buffer: Buffer,
    projectId: string,
  ): Promise<UploadApiResponse> {
    return new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        {
          folder: `projects/${projectId}/receipts`,
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
