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

  @Cron('0 3 * * *')
  async handleCleanup() {
    this.logger.log('🧹 START CLEANUP');

    await this.cleanupSessions();
    await this.cleanupInactiveProjects();
    await this.cleanupVeryOldProjects();

    this.logger.log('✅ CLEANUP DONE');
  }

  private async cleanupSessions() {
    await this.sessionService.cleanupExpiredSessions();
    await this.sessionService.cleanupInactiveSessions();
  }

  private async cleanupInactiveProjects() {
    const oneYearAgo = new Date();
    oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1);

    const projects = await this.projectRepo.find({
      relations: ['images', 'timeEntries', 'assignments'],
    });

    for (const project of projects) {
      let lastActivity = this.getLastActivity(project);

      //if (!lastActivity || lastActivity > oneYearAgo) continue;
      //if (!lastActivity) continue;
      if (!lastActivity /*&& project.createdAt  */) {
        lastActivity = project.createdAt;
      }

      //if (!lastActivity) continue;

      //if (lastActivity > oneYearAgo) continue;
      const isInactive = lastActivity <= oneYearAgo;
      if (!isInactive) continue;
      const images = await this.imageRepo.find({
        where: { project: { id: project.id } },
        order: { createdAt: 'DESC' },
      });

      if (images.length <= 3) continue;

      const imagesToDelete = images.slice(3);

      this.logger.log(
        `🖼 Cleaning images for project ${project.id}, deleting ${imagesToDelete.length}`,
      );

      //for (const img of imagesToDelete) { await this.imagesService.remove(img.id)}
      await Promise.all(
        imagesToDelete.map((img) => this.imagesService.remove(img.id)),
      );
    }
  }

  private async cleanupVeryOldProjects() {
    const fiveYearsAgo = new Date();
    fiveYearsAgo.setFullYear(fiveYearsAgo.getFullYear() - 5);

    const projects = await this.projectRepo.find({
      relations: ['images', 'timeEntries', 'assignments'],
    });

    for (const project of projects) {
      let lastActivity = this.getLastActivity(project);

      //if (!lastActivity || lastActivity > fiveYearsAgo) continue;
      //if (!lastActivity) continue;
      if (!lastActivity /*&& project.createdAt*/) {
        lastActivity = project.createdAt;
      }

      //if (!lastActivity) continue;

      //if (lastActivity > fiveYearsAgo) continue;
      const isVeryOld = lastActivity <= fiveYearsAgo;
      if (!isVeryOld) continue;
      this.logger.warn(`🔥 DELETING PROJECT ${project.id}`);

      await this.imagesService.removeByProject(project.id);

      await this.timeEntryRepo.delete({
        project: { id: project.id },
      });

      await this.assignmentRepo.delete({
        project: { id: project.id },
      });

      await this.projectRepo.delete(project.id);
    }
  }

  private getLastActivity(project: Projects): Date | null {
    const dates: Date[] = [];

    if (project.createdAt) {
      dates.push(new Date(project.createdAt));
    }

    if (project.timeEntries?.length) {
      for (const t of project.timeEntries) {
        if (t.date) dates.push(new Date(t.date));
      }
    }
    if (project.assignments?.length) {
      for (const a of project.assignments) {
        if (a.date) dates.push(new Date(a.date));
      }
    }
    return dates.length
      ? new Date(Math.max(...dates.map((d) => d.getTime())))
      : null;
  }
}
