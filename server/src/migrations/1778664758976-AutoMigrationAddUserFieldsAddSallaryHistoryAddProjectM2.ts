import { MigrationInterface, QueryRunner } from 'typeorm';

export class AutoMigrationAddUserFieldsAddSallaryHistoryAddProjectM21778664758976 implements MigrationInterface {
  name = 'AutoMigrationAddUserFieldsAddSallaryHistoryAddProjectM21778664758976';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "user_salary_history" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "salary" numeric, "salaryNetto" numeric, "fromDate" TIMESTAMP NOT NULL, "userId" uuid, CONSTRAINT "PK_dfb4b9c0a9b2ad332a77b9f1ceb" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(`ALTER TABLE "projects" ADD "pricePerM2" numeric`);
    await queryRunner.query(`ALTER TABLE "projects" ADD "areaM2" numeric`);
    await queryRunner.query(
      `ALTER TABLE "user_salary_history" ADD CONSTRAINT "FK_915b58ee89ccdde417b541709d5" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "user_salary_history" DROP CONSTRAINT "FK_915b58ee89ccdde417b541709d5"`,
    );
    await queryRunner.query(`ALTER TABLE "projects" DROP COLUMN "areaM2"`);
    await queryRunner.query(`ALTER TABLE "projects" DROP COLUMN "pricePerM2"`);
    await queryRunner.query(`DROP TABLE "user_salary_history"`);
  }
}
