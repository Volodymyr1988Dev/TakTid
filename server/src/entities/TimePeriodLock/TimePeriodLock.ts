
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

export enum PeriodType {
  WEEK = 'WEEK',
}

@Entity('time_period_lock')
@Index(
  'IDX_time_period_lock_period',
  ['periodType', 'periodStart'],
  { unique: true },
)
export class TimePeriodLock {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({
    type: 'enum',
    enum: PeriodType,
    default: PeriodType.WEEK,
  })
  periodType!: PeriodType;

  // Monday
  @Column({ type: 'date' })
  periodStart!: string;

  // Sunday
  @Column({ type: 'date' })
  periodEnd!: string;

  // Manual administrator closure
  @Column({ default: false })
  manuallyLocked!: boolean;

  // Temporary administrator unlock
  @Column({ type: 'timestamp', nullable: true })
  unlockedUntil!: Date | null;

  // Administrator who unlocked the period
  @Column({ type: 'uuid', nullable: true })
  unlockedByUserId!: string | null;

  // Administrator who closed the period
  @Column({ type: 'uuid', nullable: true })
  lockedByUserId!: string | null;

  @Column({ type: 'timestamp', nullable: true })
  lockedAt!: Date | null;

  @Column({ type: 'text', nullable: true })
  reason!: string | null;

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt!: Date;
}
