import { PartialType } from '@nestjs/swagger';
import { CreateProjectDto } from './project.create.dto';
import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, IsOptional } from 'class-validator';

export class UpdateProjectDto extends PartialType(CreateProjectDto) {
    @ApiProperty({ example: 120, required: false })
    @IsOptional()
    @IsNumber()
    areaM2?: number;

    @ApiProperty({ example: 2500, required: false })
    @IsOptional()
    @IsNumber()
    pricePerM2?: number;
}
