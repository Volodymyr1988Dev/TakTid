import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigrationProjectMaterialList1785688600378 implements MigrationInterface {
    name = 'AutoMigrationProjectMaterialList1785688600378'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "project_material_items" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "materialId" uuid NOT NULL, "label" character varying NOT NULL, "quantity" numeric(10,2), "unit" character varying(20) NOT NULL DEFAULT 'pcs', "price" numeric(10,2), "sortOrder" integer NOT NULL DEFAULT '0', CONSTRAINT "PK_d2ae9b8b31b3145ddb542c52864" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_42d4f2abf614c536382f8d419e" ON "project_material_items" ("materialId") `);
        await queryRunner.query(`CREATE TABLE "project_materials" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "projectId" uuid NOT NULL, "title" text, "other" text, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "REL_5400e7b44258b1b9781a0873c2" UNIQUE ("projectId"), CONSTRAINT "PK_4be35cdf6905d3effc565a82a64" PRIMARY KEY ("id"))`);
        await queryRunner.query(`ALTER TABLE "project_material_items" ADD CONSTRAINT "FK_42d4f2abf614c536382f8d419ec" FOREIGN KEY ("materialId") REFERENCES "project_materials"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "project_materials" ADD CONSTRAINT "FK_5400e7b44258b1b9781a0873c2e" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "project_materials" DROP CONSTRAINT "FK_5400e7b44258b1b9781a0873c2e"`);
        await queryRunner.query(`ALTER TABLE "project_material_items" DROP CONSTRAINT "FK_42d4f2abf614c536382f8d419ec"`);
        await queryRunner.query(`DROP TABLE "project_materials"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_42d4f2abf614c536382f8d419e"`);
        await queryRunner.query(`DROP TABLE "project_material_items"`);
    }

}
