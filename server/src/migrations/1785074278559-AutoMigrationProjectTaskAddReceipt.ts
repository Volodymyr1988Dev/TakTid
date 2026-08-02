import { MigrationInterface, QueryRunner } from 'typeorm';

export class AutoMigrationProjectTaskAddReceipt1785074278559 implements MigrationInterface {
  name = 'AutoMigrationProjectTaskAddReceipt1785074278559';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "project_receipts" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "url" character varying NOT NULL, "publicId" character varying NOT NULL, "projectId" uuid NOT NULL, "description" character varying, "amount" numeric(10,2), "createdAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_64cf70a8f0857f21724d9803dca" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `ALTER TABLE "project_receipts" ADD CONSTRAINT "FK_92d0bda0a82dcc0abf0b733fadc" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "project_receipts" DROP CONSTRAINT "FK_92d0bda0a82dcc0abf0b733fadc"`,
    );
    await queryRunner.query(`DROP TABLE "project_receipts"`);
  }
}
