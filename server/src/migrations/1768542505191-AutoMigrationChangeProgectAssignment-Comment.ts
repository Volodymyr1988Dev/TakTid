import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigrationChangeProgectAssignmentComment1768542505191 implements MigrationInterface {
    name = 'AutoMigrationChangeProgectAssignmentComment1768542505191'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "project_assignments" RENAME COLUMN "extraWork" TO "comment"`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "project_assignments" RENAME COLUMN "comment" TO "extraWork"`);
    }

}
