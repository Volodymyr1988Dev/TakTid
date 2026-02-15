import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigrationAddDayOFF1771168485131 implements MigrationInterface {
    name = 'AutoMigrationAddDayOFF1771168485131'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TYPE "public"."time_entries_type_enum" RENAME TO "time_entries_type_enum_old"`);
        await queryRunner.query(`CREATE TYPE "public"."time_entries_type_enum" AS ENUM('WORK', 'SICK', 'VAB', 'VACATION', 'MEETING', 'DAY_OFF')`);
        await queryRunner.query(`ALTER TABLE "time_entries" ALTER COLUMN "type" TYPE "public"."time_entries_type_enum" USING "type"::"text"::"public"."time_entries_type_enum"`);
        await queryRunner.query(`DROP TYPE "public"."time_entries_type_enum_old"`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TYPE "public"."time_entries_type_enum_old" AS ENUM('WORK', 'SICK', 'VAB', 'VACATION', 'MEETING')`);
        await queryRunner.query(`ALTER TABLE "time_entries" ALTER COLUMN "type" TYPE "public"."time_entries_type_enum_old" USING "type"::"text"::"public"."time_entries_type_enum_old"`);
        await queryRunner.query(`DROP TYPE "public"."time_entries_type_enum"`);
        await queryRunner.query(`ALTER TYPE "public"."time_entries_type_enum_old" RENAME TO "time_entries_type_enum"`);
    }

}
