import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

import { User } from '../User/User';

export enum RegistrationApprovalStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
}

@Entity('registration_approvals')
export class RegistrationApproval {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Index()
  @Column({ type: 'uuid' })
  userId!: string;

  @ManyToOne(() => User, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'userId' })
  user!: User;

  @Column({ type: 'varchar', length: 64 })
  tokenHash!: string;

  @Column({
    type: 'enum',
    enum: RegistrationApprovalStatus,
    default: RegistrationApprovalStatus.PENDING,
  })
  status!: RegistrationApprovalStatus;

  @Column({ type: 'timestamp with time zone' })
  expiresAt!: Date;

  @Column({
    type: 'timestamp with time zone',
    nullable: true,
  })
  usedAt!: Date | null;

  @CreateDateColumn({
    type: 'timestamp with time zone',
  })
  createdAt!: Date;

  @UpdateDateColumn({
    type: 'timestamp with time zone',
  })
  updatedAt!: Date;
}