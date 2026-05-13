import { isNumber, IsNumber } from 'class-validator';

export class CreateSalaryDto {
  @IsNumber()
  salary!: number;
  @IsNumber()
  salaryNetto?: number;
  @IsNumber()
  currentSalary?: number;
}