import {
  IsNumber,
  IsOptional,
  IsString,
} from 'class-validator';

export class MaterialItemDto {
  @IsString()
  label!: string;

  @IsOptional()
  @IsNumber()
  quantity!: number | null;

  @IsOptional()
  @IsNumber()
  price!: number | null;

  @IsOptional()
  @IsString()
  unit?: string;
}