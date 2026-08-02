import { MigrationInterface, QueryRunner } from 'typeorm';

export class AutoMigrationChangeProjectAssignment1768598250854 implements MigrationInterface {
  name = 'AutoMigrationChangeProjectAssignment1768598250854';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "project_assignments" ADD "hours" numeric(5,2) NOT NULL`,
    );
    await queryRunner.query(
      `ALTER TABLE "project_assignments" ADD "breakMinutes" integer NOT NULL DEFAULT '0'`,
    );
    await queryRunner.query(
      `ALTER TABLE "project_assignments" ADD "startTime" TIME`,
    );
    await queryRunner.query(
      `ALTER TABLE "project_assignments" ADD "endTime" TIME`,
    );
    await queryRunner.query(
      `ALTER TYPE "public"."time_entries_type_enum" RENAME TO "time_entries_type_enum_old"`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."time_entries_type_enum" AS ENUM('WORK', 'SICK', 'VAB', 'VACATION', 'MEETING')`,
    );
    await queryRunner.query(
      `ALTER TABLE "time_entries" ALTER COLUMN "type" TYPE "public"."time_entries_type_enum" USING "type"::"text"::"public"."time_entries_type_enum"`,
    );
    await queryRunner.query(`DROP TYPE "public"."time_entries_type_enum_old"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TYPE "public"."time_entries_type_enum_old" AS ENUM('WORK', 'SICK', 'VAB', 'VACATION', 'EXTRA', 'MEETING')`,
    );
    await queryRunner.query(
      `ALTER TABLE "time_entries" ALTER COLUMN "type" TYPE "public"."time_entries_type_enum_old" USING "type"::"text"::"public"."time_entries_type_enum_old"`,
    );
    await queryRunner.query(`DROP TYPE "public"."time_entries_type_enum"`);
    await queryRunner.query(
      `ALTER TYPE "public"."time_entries_type_enum_old" RENAME TO "time_entries_type_enum"`,
    );
    await queryRunner.query(
      `ALTER TABLE "project_assignments" DROP COLUMN "endTime"`,
    );
    await queryRunner.query(
      `ALTER TABLE "project_assignments" DROP COLUMN "startTime"`,
    );
    await queryRunner.query(
      `ALTER TABLE "project_assignments" DROP COLUMN "breakMinutes"`,
    );
    await queryRunner.query(
      `ALTER TABLE "project_assignments" DROP COLUMN "hours"`,
    );
  }
}
