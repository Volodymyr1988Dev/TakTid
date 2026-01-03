import {
  Column,
  //CreateDateColumn,
  Entity,
  //Index,
  ManyToOne,
  //OneToOne,
  PrimaryGeneratedColumn,
  //UpdateDateColumn,
} from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { User } from '../User/User';
import { Projects } from '../Project/Project';
import { timeKind } from '../../types/enums/enum';

@Entity('time_entries')
export class TimeEntry {
  @ApiProperty({
    description: 'Unique identifier for the time entry',
    example: 'a1b2c3d4-e5f6-7g8h-9i0j-k1l2m3n4o5p6',
  })
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { nullable: false })
  user: User;

  @ManyToOne(() => Projects, { nullable: true })
  project: Projects | null;

  @ApiProperty({
    description: 'Date of the time entry',
    example: '2025-01-15',
  })
  @Column({ type: 'date' })
  date: string;
  @ApiProperty({
    description: 'Number of hours logged',
    example: 8.5,
  })
  @Column({ type: 'decimal', precision: 5, scale: 2 })
  hours: number;

  @ApiProperty({
    description: 'Type of the time entry',
    example: 'WORK',
  })
  @Column({
    type: 'enum',
    enum: timeKind,
  })
  type: timeKind;

  @Column({ type: 'text', nullable: true })
  comment: string;
}
