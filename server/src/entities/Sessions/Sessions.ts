import { Entity, Column, PrimaryGeneratedColumn, ManyToOne } from 'typeorm';
import { User } from '../index';
import { ApiProperty } from '@nestjs/swagger';

@Entity('sessions')
export class Session {
  @ApiProperty({
    description: 'Unique identifier for the time entry',
    example: 'a1b2c3d4-e5f6-7g8h-9i0j-k1l2m3n4o5p6',
  })
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column()
  @ApiProperty({ example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' })
  token!: string;

  @Column({ nullable: true })
  @ApiProperty({ example: 'refresh-token-value', nullable: true })
  refresh_token?: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @ApiProperty({
    description: 'Користувач, якому належить сесія',
    type: () => User,
  })
  user!: User;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  @ApiProperty({ example: '2025-02-01T12:00:00.000Z' })
  created_at!: Date;

  @Column({ type: 'timestamp', nullable: true })
  @ApiProperty({ example: '2025-02-01T12:10:00.000Z', nullable: true })
  lastActivityAt!: Date;

  @Column({
    type: 'timestamp',
    default: () => 'CURRENT_TIMESTAMP',
    onUpdate: 'CURRENT_TIMESTAMP',
  })
  @ApiProperty({ example: '2025-02-01T13:00:00.000Z' })
  expires_at!: Date;
}
