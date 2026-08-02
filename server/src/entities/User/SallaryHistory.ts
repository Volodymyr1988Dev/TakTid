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

  @Column('float', { nullable: true })
  salary!: number | null;

  @Column('float', { nullable: true })
  salaryNetto!: number | null;

  @CreateDateColumn()
  fromDate!: Date;
}
