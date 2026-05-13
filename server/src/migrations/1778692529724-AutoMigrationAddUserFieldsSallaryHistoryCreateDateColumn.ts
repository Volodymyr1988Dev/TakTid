import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigrationAddUserFieldsSallaryHistoryCreateDateColumn1778692529724 implements MigrationInterface {
    name = 'AutoMigrationAddUserFieldsSallaryHistoryCreateDateColumn1778692529724'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "user_salary_history" DROP COLUMN "salary"`);
        await queryRunner.query(`ALTER TABLE "user_salary_history" ADD "salary" double precision`);
        await queryRunner.query(`ALTER TABLE "user_salary_history" DROP COLUMN "salaryNetto"`);
        await queryRunner.query(`ALTER TABLE "user_salary_history" ADD "salaryNetto" double precision`);
        await queryRunner.query(`ALTER TABLE "user_salary_history" ALTER COLUMN "fromDate" SET DEFAULT now()`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "user_salary_history" ALTER COLUMN "fromDate" DROP DEFAULT`);
        await queryRunner.query(`ALTER TABLE "user_salary_history" DROP COLUMN "salaryNetto"`);
        await queryRunner.query(`ALTER TABLE "user_salary_history" ADD "salaryNetto" numeric`);
        await queryRunner.query(`ALTER TABLE "user_salary_history" DROP COLUMN "salary"`);
        await queryRunner.query(`ALTER TABLE "user_salary_history" ADD "salary" numeric`);
    }

}
