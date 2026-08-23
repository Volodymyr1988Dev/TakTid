import {
  IsNumber,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from 'class-validator';

export class MaterialItemDto {
  @IsString()
  @MaxLength(100)
  materialKey!: string

  @IsOptional()
  @IsNumber({
    allowNaN: false,
    allowInfinity: false,
  })
  @Min(0)
  quantity!: number | null;

  @IsOptional()
  @IsNumber({
    allowNaN: false,
    allowInfinity: false,
  })
  @Min(0)
  price!: number | null;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  note!: string | null
}