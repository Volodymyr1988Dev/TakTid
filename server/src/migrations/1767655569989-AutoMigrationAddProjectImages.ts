import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigrationAddProjectImages1767655569989 implements MigrationInterface {
    name = 'AutoMigrationAddProjectImages1767655569989'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "project_images" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "url" character varying NOT NULL, "publicId" character varying NOT NULL, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "projectId" uuid, CONSTRAINT "PK_7683abb57ed0c0fa8379f54692b" PRIMARY KEY ("id"))`);
        await queryRunner.query(`ALTER TABLE "time_entries" ADD "breakMinutes" integer NOT NULL DEFAULT '0'`);
        await queryRunner.query(`ALTER TABLE "project_images" ADD CONSTRAINT "FK_a6efe5710e20ed5469e7719f074" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "project_images" DROP CONSTRAINT "FK_a6efe5710e20ed5469e7719f074"`);
        await queryRunner.query(`ALTER TABLE "time_entries" DROP COLUMN "breakMinutes"`);
        await queryRunner.query(`DROP TABLE "project_images"`);
    }

}
