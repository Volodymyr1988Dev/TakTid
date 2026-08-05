import { MigrationInterface, QueryRunner } from 'typeorm';

export class AutoMigrationAddSessionTimeEntries1767265559051 implements MigrationInterface {
  name = 'AutoMigrationAddSessionTimeEntries1767265559051';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TYPE "public"."time_entries_type_enum" AS ENUM('WORK', 'SICK', 'VAB', 'VACATION', 'EXTRA', 'MEETING')`,
    );
    await queryRunner.query(
      `CREATE TABLE "time_entries" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "date" date NOT NULL, "hours" numeric(5,2) NOT NULL, "type" "public"."time_entries_type_enum" NOT NULL, "comment" text, "userId" uuid NOT NULL, "projectId" uuid, CONSTRAINT "PK_b8bc5f10269ba2fe88708904aa0" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "sessions" ("id" SERIAL NOT NULL, "token" character varying NOT NULL, "refresh_token" character varying, "created_at" TIMESTAMP NOT NULL DEFAULT now(), "lastActivityAt" TIMESTAMP, "expires_at" TIMESTAMP NOT NULL DEFAULT now(), "userId" uuid, CONSTRAINT "PK_3238ef96f18b355b671619111bc" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_e9f62f5dcb8a54b84234c9e7a0" ON "sessions" ("token") `,
    );
    await queryRunner.query(
      `ALTER TABLE "project_assignments" DROP COLUMN "contributionPercentage"`,
    );
    await queryRunner.query(
      `ALTER TABLE "time_entries" ADD CONSTRAINT "FK_d1b452d7f0d45863303b7d30000" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "time_entries" ADD CONSTRAINT "FK_f051d95ecf3cd671445ef0c9be8" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "sessions" ADD CONSTRAINT "FK_57de40bc620f456c7311aa3a1e6" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "sessions" DROP CONSTRAINT "FK_57de40bc620f456c7311aa3a1e6"`,
    );
    await queryRunner.query(
      `ALTER TABLE "time_entries" DROP CONSTRAINT "FK_f051d95ecf3cd671445ef0c9be8"`,
    );
    await queryRunner.query(
      `ALTER TABLE "time_entries" DROP CONSTRAINT "FK_d1b452d7f0d45863303b7d30000"`,
    );
    await queryRunner.query(
      `ALTER TABLE "project_assignments" ADD "contributionPercentage" integer NOT NULL DEFAULT '0'`,
    );
    await queryRunner.query(
      `DROP INDEX "public"."IDX_e9f62f5dcb8a54b84234c9e7a0"`,
    );
    await queryRunner.query(`DROP TABLE "sessions"`);
    await queryRunner.query(`DROP TABLE "time_entries"`);
    await queryRunner.query(`DROP TYPE "public"."time_entries_type_enum"`);
  }
}
