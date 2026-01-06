import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { Projects } from './Project';

@Entity('project_images')
export class ProjectImage {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  url: string;

  @Column()
  publicId: string;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @ManyToOne(() => Projects, (project) => project.images, {
    onDelete: 'CASCADE',
  })
  project: Projects;
}
