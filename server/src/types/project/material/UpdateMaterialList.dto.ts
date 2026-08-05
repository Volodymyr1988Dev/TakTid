import {
  IsArray,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { MaterialItemDto } from './MaterialItem.dto';

export class UpdateMaterialListDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  other?: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => MaterialItemDto)
  items!: MaterialItemDto[];
}