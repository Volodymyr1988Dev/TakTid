import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  OneToMany,
  OneToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import { Projects } from './Project';
import { ProjectMaterialItem } from './ProjectMaterialItem';

@Entity('project_materials')
export class ProjectMaterial {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Index({ unique: true })
  @Column('uuid')
  projectId!: string;

  @OneToOne(() => Projects, (project) => project.material, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({
    name: 'projectId',
  })
  project!: Projects;

  // Назва списку
  @Column({
    type: 'text',
    nullable: true,
  })
  title!: string | null;

  // Other
  @Column({
    type: 'text',
    nullable: true,
  })
  other!: string | null;

  @OneToMany(() => ProjectMaterialItem, (item) => item.material, {
    cascade: true,
    eager: true,
    orphanedRowAction: 'delete',
  })
  items!: ProjectMaterialItem[];

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt!: Date;
}
