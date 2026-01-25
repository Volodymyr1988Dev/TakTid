import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigrationAddProjectImagesProjectId1769321195198 implements MigrationInterface {
    name = 'AutoMigrationAddProjectImagesProjectId1769321195198'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "project_images" DROP CONSTRAINT "FK_a6efe5710e20ed5469e7719f074"`);
        await queryRunner.query(`ALTER TABLE "project_images" ALTER COLUMN "projectId" SET NOT NULL`);
        await queryRunner.query(`ALTER TABLE "project_images" ADD CONSTRAINT "FK_a6efe5710e20ed5469e7719f074" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "project_images" DROP CONSTRAINT "FK_a6efe5710e20ed5469e7719f074"`);
        await queryRunner.query(`ALTER TABLE "project_images" ALTER COLUMN "projectId" DROP NOT NULL`);
        await queryRunner.query(`ALTER TABLE "project_images" ADD CONSTRAINT "FK_a6efe5710e20ed5469e7719f074" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

}
