import {
  Column,
  Entity,
  ManyToOne,
  PrimaryGeneratedColumn,
  JoinColumn,
  Index,
} from 'typeorm';
import { ProjectMaterial } from './ProjectMaterial';
import { decimalTransformer } from '../../utils/decimal.transformer';

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

  @Index()
  @Column({
    type: 'varchar',
    length: 100,
  })
  materialKey!: string;

  @Column({
    type: 'text',
    nullable: true,
  })
  note!: string | null;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    nullable: true,
    transformer: decimalTransformer,
  })
  quantity!: number | null;

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
