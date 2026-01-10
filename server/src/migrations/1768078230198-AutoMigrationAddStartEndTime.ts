import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigrationAddStartEndTime1768078230198 implements MigrationInterface {
    name = 'AutoMigrationAddStartEndTime1768078230198'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "time_entries" ADD "startTime" TIME`);
        await queryRunner.query(`ALTER TABLE "time_entries" ADD "endTime" TIME`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "time_entries" DROP COLUMN "endTime"`);
        await queryRunner.query(`ALTER TABLE "time_entries" DROP COLUMN "startTime"`);
    }

}
