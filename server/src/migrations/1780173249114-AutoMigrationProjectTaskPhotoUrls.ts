import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigrationProjectTaskPhotoUrls1780173249114 implements MigrationInterface {
    name = 'AutoMigrationProjectTaskPhotoUrls1780173249114'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "project_task" RENAME COLUMN "photoUrl" TO "photoUrls"`);
        await queryRunner.query(`ALTER TABLE "project_task" DROP COLUMN "photoUrls"`);
        await queryRunner.query(`ALTER TABLE "project_task" ADD "photoUrls" text array`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "project_task" DROP COLUMN "photoUrls"`);
        await queryRunner.query(`ALTER TABLE "project_task" ADD "photoUrls" text`);
        await queryRunner.query(`ALTER TABLE "project_task" RENAME COLUMN "photoUrls" TO "photoUrl"`);
    }

}
