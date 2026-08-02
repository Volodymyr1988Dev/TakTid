import { MigrationInterface, QueryRunner } from 'typeorm';

export class AutoMigrationProjectTaskAddAttentionNote1780798485037 implements MigrationInterface {
  name = 'AutoMigrationProjectTaskAddAttentionNote1780798485037';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "project_task" ADD "note" text`);
    await queryRunner.query(
      `ALTER TABLE "project_task" ADD "attentionNote" text`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "project_task" DROP COLUMN "attentionNote"`,
    );
    await queryRunner.query(`ALTER TABLE "project_task" DROP COLUMN "note"`);
  }
}
