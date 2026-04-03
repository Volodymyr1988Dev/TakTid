import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { SessionService } from './SessionService';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Projects } from '../entities/Project/Project';
import { ProjectImage } from '../entities/Project/ProjectImages';
import { ProjectImagesService } from './ProjectImages.service';
import { ProjectAssignment } from '../entities/Project/ProjectAssignment';
import { TimeEntry } from '../entities/TimeEntries/TimeEntries';
import pLimit from 'p-limit';

@Injectable()
export class CleanupService {
  private readonly logger = new Logger(CleanupService.name);

  constructor(
    private readonly sessionService: SessionService,

    @InjectRepository(Projects)
    private readonly projectRepo: Repository<Projects>,

    @InjectRepository(ProjectImage)
    private readonly imageRepo: Repository<ProjectImage>,

    @InjectRepository(ProjectAssignment)
    private readonly assignmentRepo: Repository<ProjectAssignment>,

    @InjectRepository(TimeEntry)
    private readonly timeEntryRepo: Repository<TimeEntry>,

    private readonly imagesService: ProjectImagesService,
  ) {}

  private isRunning = false;

  @Cron('0 2 * * *')
  async handleCleanup() {
    if (this.isRunning) {
      this.logger.warn('⚠️ Cleanup already running, skipping...');
      return;
    }

    this.isRunning = true;

    try {
      this.logger.log('🧹 START CLEANUP');

      await this.sessionService.cleanupExpiredSessions();
      await this.cleanupInactiveImages();
      await this.cleanupVeryOldProjects();

      this.logger.log('✅ CLEANUP DONE');
    } finally {
      this.isRunning = false;
    }
  }
  //SELECT sub.id, sub."publicId"
  private async cleanupInactiveImages() {
    const images: { id: string; publicId: string }[] = await this.imageRepo
      .query(`
      SELECT sub2.id, sub2."publicId"
      FROM (
        SELECT 
          pi.id,
          pi."publicId",
          ROW_NUMBER() OVER (
            PARTITION BY pi."projectId"
            ORDER BY pi."createdAt" DESC
          ) as rn
        FROM project_images pi
        JOIN projects p ON p.id = pi."projectId"
        LEFT JOIN (
          SELECT "projectId", MAX(date) as last_time_entry
          FROM time_entries
          GROUP BY "projectId"
        ) t ON t."projectId" = p.id
        LEFT JOIN (
          SELECT "projectId", MAX(date) as last_assignment
          FROM project_assignments
          GROUP BY "projectId"
        ) a ON a."projectId" = p.id
        WHERE p."createdAt" IS NOT NULL
          AND pi."projectId" IS NOT NULL
          AND COALESCE(t.last_time_entry, a.last_assignment, p."createdAt")
              < NOW() - INTERVAL '1 year'
      ) AS sub2  
      WHERE sub2.rn > 3
    `);

    if (!images.length) {
      this.logger.log('🖼 No images to clean');
      return;
    }
    const limit = pLimit(5);
    await Promise.all(
      images.map((img) => limit(() => this.imagesService.remove(img.id))),
    );
    this.logger.log(`🖼 Deleted ${images.length} old images`);
  }

  private async cleanupVeryOldProjects() {
    const oldProjects: { id: string }[] = await this.projectRepo.query(`
    SELECT p.id
    FROM projects p
    LEFT JOIN (
      SELECT "projectId", MAX(date) as last_time_entry
      FROM time_entries
      GROUP BY "projectId"
    ) t ON t."projectId" = p.id
    LEFT JOIN (
      SELECT "projectId", MAX(date) as last_assignment
      FROM project_assignments
      GROUP BY "projectId"
    ) a ON a."projectId" = p.id
    WHERE p."createdAt" IS NOT NULL -- ✅ FIX
      AND COALESCE(t.last_time_entry, a.last_assignment, p."createdAt")
            < NOW() - INTERVAL '5 years'
  `);

    for (const p of oldProjects) {
      this.logger.warn(`🔥 DELETE PROJECT ${p.id}`);

      // ✅ Cloudinary + DB images
      try {
        await this.imagesService.removeByProject(p.id);
      } catch (e) {
        this.logger.error(`❌ Failed to delete images for project ${p.id}`, e);
        continue;
      }

      // ✅ SQL cleanup
      await this.timeEntryRepo.query(
        `DELETE FROM time_entries WHERE "projectId" = $1`,
        [p.id],
      );

      await this.assignmentRepo.query(
        `DELETE FROM project_assignments WHERE "projectId" = $1`,
        [p.id],
      );

      await this.projectRepo.query(`DELETE FROM projects WHERE id = $1`, [
        p.id,
      ]);
    }
  }
}
