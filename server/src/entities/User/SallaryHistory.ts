import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  ManyToOne,
  CreateDateColumn,
} from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { User } from './User';

@Entity('user_salary_history')
export class UserSalaryHistory {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @ManyToOne(() => User, (user) => user.salaryHistory, {
    onDelete: 'CASCADE',
  })
  user!: User;

  @Column('decimal', { nullable: true })
  salary!: number | null;

  @Column('decimal', { nullable: true })
  salaryNetto!: number | null;

  @Column({ type: 'timestamp' })
  fromDate!: Date;
}