import {
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  Matches,
} from 'class-validator';
import { timeKind } from '../../types/enums/enum';

export class UpdateTimeEntryDto {
  //@IsOptional()
  //@IsNumber()
  //hours?: number;

  @IsOptional()
  @IsEnum(timeKind)
  type?: timeKind;

  @IsOptional()
  @IsString()
  comment?: string;

  @IsOptional()
  @IsNumber()
  breakMinutes?: number;

  @IsOptional()
  @Matches(/^([01]\d|2[0-3]):([0-5]\d)$/)
  startTime?: string;

  @IsOptional()
  @Matches(/^([01]\d|2[0-3]):([0-5]\d)$/)
  endTime?: string;
}
