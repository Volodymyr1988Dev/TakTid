import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { User } from '../User/User';
import { Projects } from '../Project/Project';
import { ApiProperty } from '@nestjs/swagger';

@Entity('project_assignments')
export class ProjectAssignment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Projects, (project) => project.assignments, {
    onDelete: 'CASCADE',
  })
  project: Projects;

  @ManyToOne(() => User, (user) => user.assignments, { onDelete: 'CASCADE' })
  user: User;

  @ApiProperty({
    description: 'Extra work description for this assignment',
    example: 'Installed additional sensors',
  })
  @Column({ type: 'text', nullable: true })
  comment: string;
}
