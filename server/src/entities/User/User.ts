import {
  Column,
  //CreateDateColumn,
  Entity,
  Index,
  OneToMany,
  //OneToOne,
  PrimaryGeneratedColumn,
  //UpdateDateColumn,
} from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { ProjectAssignment } from '../Project/ProjectAssignment';
import { Session } from '../Sessions/Sessions';
import { TimeEntry } from '../TimeEntries/TimeEntries';

@Entity('users')
export class User {
  @ApiProperty({
    description: 'Unique identifier for the user',
    example: 'a1b2c3d4-e5f6-7g8h-9i0j-k1l2m3n4o5p6',
  })
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ApiProperty({
    description: 'Email address of the user',
    example: 'test@example.com',
  })
  @Index({ unique: true })
  @Column({ type: 'varchar', length: 255, unique: true })
  email: string;

  @ApiProperty({
    description: 'Enter password',
    example: '12gdf56',
  })
  @Column({ type: 'varchar', length: 255 })
  password: string;

  @ApiProperty({
    description: 'Name of the user',
    example: 'John Doe',
  })
  @Column({ type: 'varchar', length: 255 })
  name: string;

  @ApiProperty({
    description: 'Creation date of the user record',
    example: '2023-01-01T00:00:00.000Z',
  })
  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @ApiProperty({
    description: 'If user have admin role',
    example: false,
  })
  @Column({ type: 'boolean', default: false })
  isAdmin: boolean;
  @OneToMany(() => ProjectAssignment, (assignment) => assignment.user)
  assignments: ProjectAssignment[];
  @OneToMany(() => Session, (session) => session.user)
  sessions: Session[];
  @OneToMany(() => TimeEntry, (timeEntry) => timeEntry.user)
  timeEntries: TimeEntry[];
}
