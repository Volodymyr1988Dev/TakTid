import { IsNumber, IsOptional } from 'class-validator';

export class CreateSalaryDto {
  @IsNumber()
  salary!: number;
  /*
  @IsOptional()
  @IsNumber()
  salaryNetto?: number;
  @IsOptional()
  @IsNumber()
  currentSalary?: number;*/
}