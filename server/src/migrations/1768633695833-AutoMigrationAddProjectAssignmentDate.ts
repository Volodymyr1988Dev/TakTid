import { MigrationInterface, QueryRunner } from 'typeorm';

export class AutoMigrationAddProjectAssignmentDate1768633695833 implements MigrationInterface {
  name = 'AutoMigrationAddProjectAssignmentDate1768633695833';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "project_assignments" ADD "date" date NOT NULL`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "project_assignments" DROP COLUMN "date"`,
    );
  }
}
