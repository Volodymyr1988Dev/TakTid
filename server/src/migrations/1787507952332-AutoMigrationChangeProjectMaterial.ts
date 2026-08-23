import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigrationChangeProjectMaterial1787507952332 implements MigrationInterface {
    name = 'AutoMigrationChangeProjectMaterial1787507952332'
    
    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "project_material_items" DROP COLUMN "label"`);
        await queryRunner.query(`ALTER TABLE "project_material_items" DROP COLUMN "unit"`);
        await queryRunner.query(`ALTER TABLE "project_material_items" ADD "materialKey" character varying(100) NOT NULL`);
        await queryRunner.query(`ALTER TABLE "project_material_items" ADD "note" text`);
        await queryRunner.query(`CREATE INDEX "IDX_7000e05107037eb10111e87388" ON "project_material_items" ("materialKey") `);
        await queryRunner.query(`CREATE UNIQUE INDEX "IDX_5400e7b44258b1b9781a0873c2" ON "project_materials" ("projectId") `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP INDEX "public"."IDX_5400e7b44258b1b9781a0873c2"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_7000e05107037eb10111e87388"`);
        await queryRunner.query(`ALTER TABLE "project_material_items" DROP COLUMN "note"`);
        await queryRunner.query(`ALTER TABLE "project_material_items" DROP COLUMN "materialKey"`);
        await queryRunner.query(`ALTER TABLE "project_material_items" ADD "unit" character varying(20) NOT NULL DEFAULT 'pcs'`);
        await queryRunner.query(`ALTER TABLE "project_material_items" ADD "label" character varying NOT NULL`);
    }

}
