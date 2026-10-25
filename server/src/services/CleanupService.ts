import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { SessionService } from './SessionService';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { Projects } from '../entities/Project/Project';
import { ProjectImage } from '../entities/Project/ProjectImages';
import { ProjectImagesService } from './ProjectImages.service';
import pLimit from 'p-limit';
import { ProjectReceiptsService } from './ProjectReceipts';

@Injectable()
export class CleanupService {
  private readonly logger = new Logger(CleanupService.name);
  private isRunning = false;
  private readonly veryOldProjectCondition = `
    p."createdAt" IS NOT NULL
    AND GREATEST(
      COALESCE(t.last_time_entry, p."createdAt"),
      COALESCE(a.last_assignment, p."createdAt"),
      p."createdAt"
    ) < NOW() - INTERVAL '5 years'
    AND NOT EXISTS (
      SELECT 1
      FROM time_entries te
      WHERE te."projectId" = p.id
        AND te.date >= CURRENT_DATE - INTERVAL '2 years'
    )
    AND NOT EXISTS (
      SELECT 1
      FROM project_assignments pa
      WHERE pa."projectId" = p.id
        AND pa.date >= CURRENT_DATE - INTERVAL '2 years'
    )
  `;
  constructor(
    private readonly dataSource: DataSource,
    private readonly sessionService: SessionService,

    @InjectRepository(Projects)
    private readonly projectRepo: Repository<Projects>,

    @InjectRepository(ProjectImage)
    private readonly imageRepo: Repository<ProjectImage>,
    private readonly receiptsService: ProjectReceiptsService,
    private readonly imagesService: ProjectImagesService,
  ) {}

  //@Cron('0 5 1 * *')
  @Cron('0 3 * * *')
  async handleCleanup(): Promise<void> {
    if (this.isRunning) {
      this.logger.warn('Cleanup is already running; skipping.');
      return;
    }

    this.isRunning = true;

    const queryRunner = this.dataSource.createQueryRunner();
    let lockAcquired = false;
    let failures = 0;

    try {
      await queryRunner.connect();

      const lockRows: { acquired: boolean | string }[] =
        await queryRunner.query(
          'SELECT pg_try_advisory_lock(741852, 1) AS acquired',
        );

      const lockValue = lockRows[0]?.acquired;
      lockAcquired =
        lockValue === true ||
        lockValue === 't' ||
        lockValue === 'true';

      if (!lockAcquired) {
        this.logger.warn(
          'Another instance is running cleanup; skipping this run.',
        );
        return;
      }

      this.logger.log('START CLEANUP');

      const steps: Array<[string, () => Promise<void>]> = [
        [
          'Expired sessions',
          () => this.cleanupExpiredSessions(),
        ],
        [
          'Inactive project images',
          () => this.cleanupInactiveImages(),
        ],
        [
          'Very old projects',
          () => this.cleanupVeryOldProjects(),
        ],
      ];

      for (const [name, run] of steps) {
        try {
          await run();
        } catch (error) {
          failures++;

          this.logger.error(
            `${name} cleanup failed: ${this.errorMessage(error)}`,
            error instanceof Error ? error.stack : undefined,
          );
        }
      }

      if (failures === 0) {
        this.logger.log('CLEANUP FINISHED');
      } else {
        this.logger.warn(
          `CLEANUP FINISHED WITH ${failures} FAILED STEP(S). Check logs.`,
        );
      }
    } catch (error) {
      this.logger.error(
        `CLEANUP FAILED: ${this.errorMessage(error)}`,
        error instanceof Error ? error.stack : undefined,
      );
    } finally {
      try {
        if (lockAcquired && queryRunner.isReleased === false) {
          await queryRunner.query(
            'SELECT pg_advisory_unlock(741852, 1)',
          );
        }
      } catch (error) {
        this.logger.error(
          `Failed to release cleanup advisory lock: ${this.errorMessage(error)}`,
        );
      } finally {
        try {
          if (!queryRunner.isReleased) {
            await queryRunner.release();
          }
        } catch (error) {
          this.logger.error(
            `Failed to release cleanup connection: ${this.errorMessage(error)}`,
          );
        } finally {
          this.isRunning = false;
        }
      }
    }
  }

  private async cleanupExpiredSessions() {
    try {
      await this.sessionService
        .cleanupExpiredSessions();
    } catch (error) {
      this.logger.error(
        '❌ Failed to cleanup sessions',
        error,
      );

      throw error;
    }
  }
//SELECT sub2.id
  private async cleanupInactiveImages(): Promise<void> {
    const images: { id: string }[] = await this.imageRepo.query(`
      SELECT ranked.id
      FROM (
        SELECT
          pi.id,
          ROW_NUMBER() OVER (
            PARTITION BY pi."projectId"
            ORDER BY pi."createdAt" DESC, pi.id DESC
          ) AS rn
        FROM project_images pi
        JOIN projects p ON p.id = pi."projectId"

        LEFT JOIN (
          SELECT
            "projectId",
            MAX(date)::timestamp AS last_time_entry
          FROM time_entries
          GROUP BY "projectId"
        ) t ON t."projectId" = p.id

        LEFT JOIN (
          SELECT
            "projectId",
            MAX(date)::timestamp AS last_assignment
          FROM project_assignments
          GROUP BY "projectId"
        ) a ON a."projectId" = p.id

        WHERE p."createdAt" IS NOT NULL
          AND GREATEST(
            COALESCE(t.last_time_entry, p."createdAt"),
            COALESCE(a.last_assignment, p."createdAt"),
            p."createdAt"
          ) < NOW() - INTERVAL '1 year'
      ) ranked
      WHERE ranked.rn > 3
    `);

    if (images.length === 0) {
      this.logger.log('No inactive project images to clean.');
      return;
    }

    const limit = pLimit(3);
    let deleted = 0;
    let failed = 0;

    await Promise.all(
      images.map((image) =>
        limit(async () => {
          try {
            await this.imagesService.remove(image.id);
            deleted++;
          } catch (error) {
            failed++;

            this.logger.error(
              `Failed to delete project image ${image.id}: ${this.errorMessage(error)}`,
              error instanceof Error ? error.stack : undefined,
            );
          }
        }),
      ),
    );

    this.logger.log(
      `Inactive images: deleted ${deleted}; failed ${failed}; total ${images.length}.`,
    );

    if (failed > 0) {
      throw new Error(
        `Failed to delete ${failed} inactive project image(s).`,
      );
    }
  }

  private async cleanupVeryOldProjects(): Promise<void> {
    const oldProjects: { id: string }[] = await this.projectRepo.query(`
      SELECT p.id
      FROM projects p

      LEFT JOIN (
        SELECT
          "projectId",
          MAX(date)::timestamp AS last_time_entry
        FROM time_entries
        GROUP BY "projectId"
      ) t ON t."projectId" = p.id

      LEFT JOIN (
        SELECT
          "projectId",
          MAX(date)::timestamp AS last_assignment
        FROM project_assignments
        GROUP BY "projectId"
      ) a ON a."projectId" = p.id

      WHERE ${this.veryOldProjectCondition}
      ORDER BY p."createdAt" ASC
    `);

    if (oldProjects.length === 0) {
      this.logger.log('No very old projects to delete.');
      return;
    }

    this.logger.warn(
      `Found ${oldProjects.length} candidate project(s) for deletion.`,
    );

    let deleted = 0;
    let skipped = 0;
    let failed = 0;

    for (const project of oldProjects) {
      try {
        const wasDeleted = await this.deleteVeryOldProject(project.id);

        if (wasDeleted) {
          deleted++;
        } else {
          skipped++;

          this.logger.warn(
            `Project ${project.id} is no longer eligible; skipped.`,
          );
        }
      } catch (error) {
        failed++;

        this.logger.error(
          `Failed to delete project ${project.id}: ${this.errorMessage(error)}`,
          error instanceof Error ? error.stack : undefined,
        );
      }
    }

    this.logger.log(
      `Old projects: deleted ${deleted}; skipped ${skipped}; failed ${failed}.`,
    );

    if (failed > 0) {
      throw new Error(
        `Failed to delete ${failed} old project(s).`,
      );
    }
  }
  
 private async deleteVeryOldProject(
    projectId: string,
  ): Promise<boolean> {
    return this.dataSource.transaction(async (manager) => {
      const locked: { id: string }[] = await manager.query(
        'SELECT id FROM projects WHERE id = $1 FOR UPDATE',
        [projectId],
      );

      if (locked.length === 0) {
        return false;
      }

      const eligible: { id: string }[] = await manager.query(
        `
          SELECT p.id
          FROM projects p

          LEFT JOIN (
            SELECT
              "projectId",
              MAX(date)::timestamp AS last_time_entry
            FROM time_entries
            GROUP BY "projectId"
          ) t ON t."projectId" = p.id

          LEFT JOIN (
            SELECT
              "projectId",
              MAX(date)::timestamp AS last_assignment
            FROM project_assignments
            GROUP BY "projectId"
          ) a ON a."projectId" = p.id

          WHERE p.id = $1
            AND ${this.veryOldProjectCondition}
        `,
        [projectId],
      );

      if (eligible.length === 0) {
        return false;
      }

      await this.imagesService.removeByProject(projectId);
      await this.receiptsService.removeByProject(projectId);

      await manager.query(
        'DELETE FROM time_entries WHERE "projectId" = $1',
        [projectId],
      );

      await manager.query(
        'DELETE FROM project_assignments WHERE "projectId" = $1',
        [projectId],
      );

      const result: { id: string }[] = await manager.query(
        'DELETE FROM projects WHERE id = $1 RETURNING id',
        [projectId],
      );

      if (result.length === 0) {
        throw new Error(
          `Project ${projectId} was not deleted from the database.`,
        );
      }

      this.logger.log(`Deleted old project ${projectId}.`);
      return true;
    });
  }
  private errorMessage(error: unknown): string {
    return error instanceof Error ? error.message : String(error);
  }
}
