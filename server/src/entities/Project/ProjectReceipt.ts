import { Column, Entity, JoinColumn, PrimaryGeneratedColumn, ManyToOne } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { Projects } from './Project';

@Entity('project_receipts')
export class ProjectReceipt {

    @PrimaryGeneratedColumn('uuid')
    @ApiProperty({
        description:'Unique identifier for the project receipt',
        example:'a1b2c3d4-e5f6-7g8h-9i0j-k1l2m3n4o5p6'
    })
    id!: string

    @ApiProperty({
        description:'URL of the receipt image',
        example:'https://example.com/receipt.jpg'
    })
    @Column()
    url!: string

    @ApiProperty({
        description:'Cloudinary public ID of the receipt image',
        example:'project_receipts/receipt.jpg'
    })
    @Column()
    publicId!: string

    @ApiProperty({
        description:'ID of the project to which the receipt belongs',
        example:'a1b2c3d4-e5f6-7g8h-9i0j-k1l2m3n4o5p6'
    })
    @Column()
    projectId!: string

    @ApiProperty({
        description:'Description of the receipt',
        example:'Office supplies purchase'
    })
    @Column({
        nullable:true
    })
    description?: string

    @ApiProperty({
        description:'Amount of the receipt',
        example:100.00
    })
    @Column({
        nullable:true,
        type:'decimal',
        precision:10,
        scale:2
    })
    amount?: number

    @Column({
        type:'timestamp',
        default:()=>'CURRENT_TIMESTAMP'
    })
    createdAt!:Date

    @ManyToOne(
        ()=>Projects,
        project=>project.receipts,
        {
            onDelete:'CASCADE'
        }
    )
    @JoinColumn({
        name:'projectId'
    })
    project!:Projects
}