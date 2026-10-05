import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigrationAddRegistrationApproval1791142186801 implements MigrationInterface {
    name = 'AutoMigrationAddRegistrationApproval1791142186801'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TYPE "public"."registration_approvals_status_enum" AS ENUM('pending', 'approved', 'rejected')`);
        await queryRunner.query(`CREATE TABLE "registration_approvals" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" uuid NOT NULL, "tokenHash" character varying(64) NOT NULL, "status" "public"."registration_approvals_status_enum" NOT NULL DEFAULT 'pending', "expiresAt" TIMESTAMP WITH TIME ZONE NOT NULL, "usedAt" TIMESTAMP WITH TIME ZONE, "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), CONSTRAINT "PK_684da43f336bb8a858a0df6a620" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_d0b91fcf539def7b9ad50741f0" ON "registration_approvals" ("userId") `);
        await queryRunner.query(`ALTER TABLE "registration_approvals" ADD CONSTRAINT "FK_d0b91fcf539def7b9ad50741f0b" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "registration_approvals" DROP CONSTRAINT "FK_d0b91fcf539def7b9ad50741f0b"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_d0b91fcf539def7b9ad50741f0"`);
        await queryRunner.query(`DROP TABLE "registration_approvals"`);
        await queryRunner.query(`DROP TYPE "public"."registration_approvals_status_enum"`);
    }

}
