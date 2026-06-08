import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
} from 'typeorm'

import { Projects } from './Project'
import { User } from '../User/User'

@Entity()
export class ProjectTask {

  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column()
  title!: string

  @Column({ default: false })
  done!: boolean

  @Column({ type: 'text', nullable: true })
  completedByName!: string | null

  @CreateDateColumn()
  createdAt!: Date

  @Column({ type: 'timestamp', nullable: true })
  completedAt!: Date | null

  @Column({ type: 'text', nullable: true })
    comment!: string | null

  @Column('text', {
  array: true,
  nullable: true,
  })
  photoUrls!: string[] | null

  @Column({
    nullable: true,
    type: 'text',
  })
  note!: string | null

  @Column({
    nullable: true,
    type: 'text',
  })
  attentionNote!: string | null

  @ManyToOne(() => Projects, project => project.tasks, {
    onDelete: 'CASCADE'
  })
  project!: Projects

  @ManyToOne(() => User, {
    nullable: true
  })
  completedBy!: User | null
}