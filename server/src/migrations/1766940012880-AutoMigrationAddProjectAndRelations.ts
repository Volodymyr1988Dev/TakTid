import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigrationAddProjectAndRelations1766940012880 implements MigrationInterface {
    name = 'AutoMigrationAddProjectAndRelations1766940012880'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "projects" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "city" text, "address" text, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_6271df0a7aed1d6c0691ce6ac50" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "project_assignments" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "contributionPercentage" integer NOT NULL DEFAULT '0', "extraWork" text, "projectId" uuid, "userId" uuid, CONSTRAINT "PK_045df8f32ae1d54810b39b9c7bd" PRIMARY KEY ("id"))`);
        await queryRunner.query(`ALTER TABLE "project_assignments" ADD CONSTRAINT "FK_9c5f0cbd89c4d1e858a4b4a4e4f" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "project_assignments" ADD CONSTRAINT "FK_2de237ae3bf6566e76fa428199b" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "project_assignments" DROP CONSTRAINT "FK_2de237ae3bf6566e76fa428199b"`);
        await queryRunner.query(`ALTER TABLE "project_assignments" DROP CONSTRAINT "FK_9c5f0cbd89c4d1e858a4b4a4e4f"`);
        await queryRunner.query(`DROP TABLE "project_assignments"`);
        await queryRunner.query(`DROP TABLE "projects"`);
    }

}
