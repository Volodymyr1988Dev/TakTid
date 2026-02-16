import {
  Matches,
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
  @ApiProperty({ format: 'uuid', required: false })
  @IsOptional()
  @IsUUID()
  projectId?: string;

  @ApiProperty({ example: '2025-01-15' })
  @IsDateString()
  date!: string;

  @ApiProperty({ enum: timeKind })
  @IsEnum(timeKind)
  type!: timeKind;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  comment!: string;

  @ApiProperty({ example: 30, required: false })
  @IsNumber()
  breakMinutes!: number;

  @ApiProperty({ example: '09:00' })
  @Matches(/^([01]\d|2[0-3]):([0-5]\d)$/, {
    message: 'startTime must be in HH:mm format',
  })
  startTime!: string;

  @ApiProperty({ example: '17:30' })
  @Matches(/^([01]\d|2[0-3]):([0-5]\d)$/, {
    message: 'endTime must be in HH:mm format',
  })
  endTime!: string;
}
