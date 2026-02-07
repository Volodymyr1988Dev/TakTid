import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { User } from '../User/User';
import { Projects } from '../Project/Project';
import { ApiProperty } from '@nestjs/swagger';

@Entity('project_assignments')
export class ProjectAssignment {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @ManyToOne(() => Projects, (project) => project.assignments, {
    onDelete: 'CASCADE',
  })
  project!: Projects;

  @ManyToOne(() => User, (user) => user.assignments, { onDelete: 'CASCADE' })
  user!: User;

  @ApiProperty({
    description: 'Extra work description for this assignment',
    example: 'Installed additional sensors',
  })
  @Column({ type: 'text', nullable: true })
  comment!: string;

  @ApiProperty({
    description: 'Number of hours logged',
    example: 8.5,
  })
  @Column({ type: 'decimal', precision: 5, scale: 2 })
  hours!: number;

  @ApiProperty({
    description: 'Number of break minutes taken',
    example: 30,
  })
  @Column({ type: 'int', default: 0 })
  breakMinutes!: number;

  @ApiProperty({
    description: 'Start time of the assignment',
    example: '08:00',
  })
  @Column({ type: 'time', nullable: true })
  startTime!: string;

  @ApiProperty({
    description: 'End time of the assignment',
    example: '16:30',
  })
  @Column({ type: 'time', nullable: true })
  endTime!: string;

  @ApiProperty({
    description: 'Date of the time entry',
    example: '2025-01-15',
  })
  @Column({ type: 'date' })
  date!: string;
}
