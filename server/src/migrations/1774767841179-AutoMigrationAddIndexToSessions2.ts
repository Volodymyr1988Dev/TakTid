import { MigrationInterface, QueryRunner } from 'typeorm';

export class AutoMigrationAddIndexToSessions21774767841179 implements MigrationInterface {
  name = 'AutoMigrationAddIndexToSessions21774767841179';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE INDEX "IDX_4b6d28f4cdc75f1de55b2fa619" ON "sessions" ("lastActivityAt") `,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP INDEX "public"."IDX_4b6d28f4cdc75f1de55b2fa619"`,
    );
  }
}
