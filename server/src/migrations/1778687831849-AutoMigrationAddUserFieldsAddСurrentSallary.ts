import { MigrationInterface, QueryRunner } from 'typeorm';

export class AutoMigrationAddUserFieldsAddСurrentSallary1778687831849 implements MigrationInterface {
  name = 'AutoMigrationAddUserFieldsAddСurrentSallary1778687831849';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "users" ADD "currentSalary" integer`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "currentSalary"`);
  }
}
