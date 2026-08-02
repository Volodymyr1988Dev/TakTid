import {
  Column,
  Entity,
  ManyToOne,
  PrimaryGeneratedColumn,
  JoinColumn,
  Index,
} from 'typeorm';
import { ProjectMaterial } from './ProjectMaterial';

@Entity('project_material_items')
export class ProjectMaterialItem {
  @PrimaryGeneratedColumn('uuid')
  id!: string;
  @Index()
  @Column('uuid')
  materialId!: string;
  @ManyToOne(() => ProjectMaterial, (material) => material.items, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({
    name: 'materialId',
  })
  material!: ProjectMaterial;

  @Column()
  label!: string;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    nullable: true,
  })
  quantity!: number | null;

  // pcs / pack / m / l

  @Column({
    default: 'pcs',
    length: 20,
  })
  unit!: string;

  // тільки для адміна

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    nullable: true,
  })
  price!: number | null;

  @Column({
    type: 'int',
    default: 0,
  })
  sortOrder!: number;
}
