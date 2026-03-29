import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigrationAddIndexToSessions1774765456495 implements MigrationInterface {
    name = 'AutoMigrationAddIndexToSessions1774765456495'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE INDEX "IDX_9cfe37d28c3b229a350e086d94" ON "sessions" ("expires_at") `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP INDEX "public"."IDX_9cfe37d28c3b229a350e086d94"`);
    }

}
