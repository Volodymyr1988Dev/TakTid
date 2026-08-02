import { MigrationInterface, QueryRunner } from 'typeorm';

export class AutoMigrationAddUserFieldsAddDayOffAddRedDay1777136116400 implements MigrationInterface {
  name = 'AutoMigrationAddUserFieldsAddDayOffAddRedDay1777136116400';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
            ALTER TYPE "time_entries_type_enum"
            ADD VALUE IF NOT EXISTS 'RED_DAY'
        `);

    await queryRunner.query(`
            ALTER TYPE "time_entries_type_enum"
            ADD VALUE IF NOT EXISTS 'DAY_OFF'
        `);
    await queryRunner.query(
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "CanCreateProjects" boolean NOT NULL DEFAULT false`,
    );
    await queryRunner.query(
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "SpecialCan" boolean NOT NULL DEFAULT false`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "users" DROP COLUMN IF EXISTS "SpecialCan"`,
    );
    await queryRunner.query(
      `ALTER TABLE "users" DROP COLUMN IF EXISTS "CanCreateProjects"`,
    );
  }
}
