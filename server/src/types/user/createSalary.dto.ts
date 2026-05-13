import { IsNumber } from 'class-validator';

export class CreateSalaryDto {
  @IsNumber()
  salary!: number;
}