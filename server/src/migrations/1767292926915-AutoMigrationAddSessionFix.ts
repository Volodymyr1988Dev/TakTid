import { MigrationInterface, QueryRunner } from 'typeorm';

export class AutoMigrationAddSessionFix1767292926915 implements MigrationInterface {
  name = 'AutoMigrationAddSessionFix1767292926915';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP INDEX "public"."IDX_e9f62f5dcb8a54b84234c9e7a0"`,
    );
    await queryRunner.query(
      `ALTER TABLE "sessions" DROP CONSTRAINT "PK_3238ef96f18b355b671619111bc"`,
    );
    await queryRunner.query(`ALTER TABLE "sessions" DROP COLUMN "id"`);
    await queryRunner.query(
      `ALTER TABLE "sessions" ADD "id" uuid NOT NULL DEFAULT uuid_generate_v4()`,
    );
    await queryRunner.query(
      `ALTER TABLE "sessions" ADD CONSTRAINT "PK_3238ef96f18b355b671619111bc" PRIMARY KEY ("id")`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "sessions" DROP CONSTRAINT "PK_3238ef96f18b355b671619111bc"`,
    );
    await queryRunner.query(`ALTER TABLE "sessions" DROP COLUMN "id"`);
    await queryRunner.query(`ALTER TABLE "sessions" ADD "id" SERIAL NOT NULL`);
    await queryRunner.query(
      `ALTER TABLE "sessions" ADD CONSTRAINT "PK_3238ef96f18b355b671619111bc" PRIMARY KEY ("id")`,
    );
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_e9f62f5dcb8a54b84234c9e7a0" ON "sessions" ("token") `,
    );
  }
}
