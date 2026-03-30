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

  @Cron('0 2 * * *')
  async handleCleanup() {
    this.logger.log('🧹 START CLEANUP');

    await this.sessionService.cleanupExpiredSessions();

    await this.cleanupInactiveImages();
    await this.cleanupVeryOldProjects();

    this.logger.log('✅ CLEANUP DONE');
  }

  private async cleanupInactiveImages() {
    await this.imageRepo.query(`
      DELETE FROM project_image pi
      WHERE pi.id IN (
        SELECT id FROM (
          SELECT pi.id,
                 ROW_NUMBER() OVER (
                   PARTITION BY pi."projectId"
                   ORDER BY pi."createdAt" DESC
                 ) as rn
          FROM project_image pi
          JOIN projects p ON p.id = pi."projectId"
          LEFT JOIN (
            SELECT "projectId", MAX(date) as last_time_entry
            FROM time_entry
            GROUP BY "projectId"
          ) t ON t."projectId" = p.id
          LEFT JOIN (
            SELECT "projectId", MAX(date) as last_assignment
            FROM project_assignment
            GROUP BY "projectId"
          ) a ON a."projectId" = p.id
          WHERE COALESCE(t.last_time_entry, a.last_assignment, p."createdAt")
                < NOW() - INTERVAL '1 year'
        ) sub
        WHERE sub.rn > 3
      );
    `);

    this.logger.log('🖼 Old images cleaned');
  }

  private async cleanupVeryOldProjects() {
    const oldProjects: { id: string }[] = await this.projectRepo.query(`
      SELECT p.id
      FROM projects p
      LEFT JOIN (
        SELECT "projectId", MAX(date) as last_time_entry
        FROM time_entry
        GROUP BY "projectId"
      ) t ON t."projectId" = p.id
      LEFT JOIN (
        SELECT "projectId", MAX(date) as last_assignment
        FROM project_assignment
        GROUP BY "projectId"
      ) a ON a."projectId" = p.id
      WHERE COALESCE(t.last_time_entry, a.last_assignment, p."createdAt")
            < NOW() - INTERVAL '5 years'
    `);

    for (const p of oldProjects) {
      this.logger.warn(`🔥 DELETE PROJECT ${p.id}`);

      await this.imagesService.removeByProject(p.id);

      await this.timeEntryRepo.query(
        `DELETE FROM time_entry WHERE "projectId" = $1`,
        [p.id],
      );

      await this.assignmentRepo.query(
        `DELETE FROM project_assignment WHERE "projectId" = $1`,
        [p.id],
      );

      await this.projectRepo.query(`DELETE FROM projects WHERE id = $1`, [
        p.id,
      ]);
    }
  }
}
