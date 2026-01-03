import { IsEnum, IsNumber, IsOptional, IsString } from 'class-validator';
import { timeKind } from '../../types/enums/enum';

export class UpdateTimeEntryDto {
  @IsOptional()
  @IsNumber()
  hours?: number;

  @IsOptional()
  @IsEnum(timeKind)
  type?: timeKind;

  @IsOptional()
  @IsString()
  comment?: string;
}
