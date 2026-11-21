import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigrationAddTimePeriodLock1795294228027 implements MigrationInterface {
    name = 'AutoMigrationAddTimePeriodLock1795294228027'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TYPE "public"."time_period_lock_periodtype_enum" AS ENUM('WEEK')`);
        await queryRunner.query(`CREATE TABLE "time_period_lock" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "periodType" "public"."time_period_lock_periodtype_enum" NOT NULL DEFAULT 'WEEK', "periodStart" date NOT NULL, "periodEnd" date NOT NULL, "manuallyLocked" boolean NOT NULL DEFAULT false, "unlockedUntil" TIMESTAMP, "unlockedByUserId" uuid, "lockedByUserId" uuid, "lockedAt" TIMESTAMP, "reason" text, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_de7aecb3220624167814edb421e" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE UNIQUE INDEX "IDX_time_period_lock_period" ON "time_period_lock" ("periodType", "periodStart") `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP INDEX "public"."IDX_time_period_lock_period"`);
        await queryRunner.query(`DROP TABLE "time_period_lock"`);
        await queryRunner.query(`DROP TYPE "public"."time_period_lock_periodtype_enum"`);
    }

}
