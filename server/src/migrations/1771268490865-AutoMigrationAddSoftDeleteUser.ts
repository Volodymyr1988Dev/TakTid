import { MigrationInterface, QueryRunner } from 'typeorm';

export class AutoMigrationAddSoftDeleteUser1771268490865 implements MigrationInterface {
  name = 'AutoMigrationAddSoftDeleteUser1771268490865';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "users" ADD "updatedAt" TIMESTAMP NOT NULL DEFAULT now()`,
    );
    await queryRunner.query(`ALTER TABLE "users" ADD "deletedAt" TIMESTAMP`);
    await queryRunner.query(`ALTER TABLE "users" ADD "deletedByUserId" uuid`);
    await queryRunner.query(
      `CREATE INDEX "IDX_2a32f641edba1d0f973c19cc94" ON "users" ("deletedAt") `,
    );
    await queryRunner.query(
      `ALTER TABLE "users" ADD CONSTRAINT "FK_4ffb8c41fed6d32b356ae4709cb" FOREIGN KEY ("deletedByUserId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "users" DROP CONSTRAINT "FK_4ffb8c41fed6d32b356ae4709cb"`,
    );
    await queryRunner.query(
      `DROP INDEX "public"."IDX_2a32f641edba1d0f973c19cc94"`,
    );
    await queryRunner.query(
      `ALTER TABLE "users" DROP COLUMN "deletedByUserId"`,
    );
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "deletedAt"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "updatedAt"`);
  }
}
