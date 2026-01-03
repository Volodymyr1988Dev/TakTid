import {
  IsDateString,
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { timeKind } from '../enums/enum';

export class CreateTimeEntryDto {
  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  userId: string;

  @ApiProperty({ format: 'uuid', required: false })
  @IsOptional()
  @IsUUID()
  projectId?: string;

  @ApiProperty({ example: '2025-01-15' })
  @IsDateString()
  date: string;

  @ApiProperty({ example: 8.5 })
  @IsNumber()
  hours: number;

  @ApiProperty({ enum: timeKind })
  @IsEnum(timeKind)
  type: timeKind;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  comment?: string;
}
