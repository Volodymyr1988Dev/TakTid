import {
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  Matches,
  IsUUID,
} from 'class-validator';
import { timeKind } from '../../types/enums/enum';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class UpdateTimeEntryDto {
  //@IsOptional()
  //@IsNumber()
  //hours?: number;

  @ApiProperty({ format: 'uuid', required: false })
  @IsOptional()
  @IsUUID()
  projectId?: string;

  @IsOptional()
  @IsEnum(timeKind)
  type?: timeKind;

  @IsOptional()
  @IsString()
  comment?: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  breakMinutes?: number;

  @IsOptional()
  @Matches(/^([01]\d|2[0-3]):([0-5]\d)$/)
  startTime?: string;

  @IsOptional()
  @Matches(/^([01]\d|2[0-3]):([0-5]\d)$/)
  endTime?: string;
}
