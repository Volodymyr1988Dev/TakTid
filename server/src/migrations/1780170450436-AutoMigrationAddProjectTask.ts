import { MigrationInterface, QueryRunner } from 'typeorm';

export class AutoMigrationAddProjectTask1780170450436 implements MigrationInterface {
  name = 'AutoMigrationAddProjectTask1780170450436';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "project_task" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "title" character varying NOT NULL, "done" boolean NOT NULL DEFAULT false, "completedByName" text, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "completedAt" TIMESTAMP, "comment" text, "photoUrl" text, "projectId" uuid, "completedById" uuid, CONSTRAINT "PK_f8275249858f42bc01e47cb979d" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `ALTER TABLE "project_task" ADD CONSTRAINT "FK_a81f1f3ca71d469236a55e2bcaa" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "project_task" ADD CONSTRAINT "FK_5fea8867d69a5edacf7f11b0fce" FOREIGN KEY ("completedById") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "project_task" DROP CONSTRAINT "FK_5fea8867d69a5edacf7f11b0fce"`,
    );
    await queryRunner.query(
      `ALTER TABLE "project_task" DROP CONSTRAINT "FK_a81f1f3ca71d469236a55e2bcaa"`,
    );
    await queryRunner.query(`DROP TABLE "project_task"`);
  }
}
