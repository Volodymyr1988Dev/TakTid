import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigrationAddRegistrationApprovalNameEmail1791231903181 implements MigrationInterface {
    name = 'AutoMigrationAddRegistrationApprovalNameEmail1791231903181'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "registration_approvals" DROP CONSTRAINT "FK_d0b91fcf539def7b9ad50741f0b"`);
        await queryRunner.query(`ALTER TABLE "registration_approvals" ADD "email" character varying(320) NOT NULL`);
        await queryRunner.query(`ALTER TABLE "registration_approvals" ADD "name" character varying(255) NOT NULL`);
        await queryRunner.query(`ALTER TABLE "registration_approvals" ADD "passwordHash" character varying(255) NOT NULL`);
        await queryRunner.query(`ALTER TABLE "registration_approvals" ALTER COLUMN "userId" DROP NOT NULL`);
        await queryRunner.query(`ALTER TABLE "registration_approvals" ADD CONSTRAINT "FK_d0b91fcf539def7b9ad50741f0b" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "registration_approvals" DROP CONSTRAINT "FK_d0b91fcf539def7b9ad50741f0b"`);
        await queryRunner.query(`ALTER TABLE "registration_approvals" ALTER COLUMN "userId" SET NOT NULL`);
        await queryRunner.query(`ALTER TABLE "registration_approvals" DROP COLUMN "passwordHash"`);
        await queryRunner.query(`ALTER TABLE "registration_approvals" DROP COLUMN "name"`);
        await queryRunner.query(`ALTER TABLE "registration_approvals" DROP COLUMN "email"`);
        await queryRunner.query(`ALTER TABLE "registration_approvals" ADD CONSTRAINT "FK_d0b91fcf539def7b9ad50741f0b" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

}
