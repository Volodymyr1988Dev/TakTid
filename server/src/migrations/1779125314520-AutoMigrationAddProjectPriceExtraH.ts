import { MigrationInterface, QueryRunner } from 'typeorm';

export class AutoMigrationAddProjectPriceExtraH1779125314520 implements MigrationInterface {
  name = 'AutoMigrationAddProjectPriceExtraH1779125314520';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "projects" ADD "pricePerExtraH" numeric`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "projects" DROP COLUMN "pricePerExtraH"`,
    );
  }
}
