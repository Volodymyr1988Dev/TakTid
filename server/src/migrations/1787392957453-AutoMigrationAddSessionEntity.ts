import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigrationAddSessionEntity1787392957453 implements MigrationInterface {
    name = 'AutoMigrationAddSessionEntity1787392957453'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "sessions" ADD "access_token_expires_at" TIMESTAMP`);
        await queryRunner.query(`ALTER TABLE "sessions" ADD "refresh_token_expires_at" TIMESTAMP`);
        await queryRunner.query(`CREATE INDEX "IDX_e59af021a32c359c2d9dcf14cc" ON "sessions" ("refresh_token_expires_at") `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP INDEX "public"."IDX_e59af021a32c359c2d9dcf14cc"`);
        await queryRunner.query(`ALTER TABLE "sessions" DROP COLUMN "refresh_token_expires_at"`);
        await queryRunner.query(`ALTER TABLE "sessions" DROP COLUMN "access_token_expires_at"`);
    }

}
