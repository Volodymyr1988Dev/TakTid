import { IsDateString, IsNumber, IsUUID } from 'class-validator';

export class QueryTimeEntryDto {
  @IsUUID()
  userId: string;

  @IsDateString()
  from: string;

  @IsDateString()
  to: string;

  @IsNumber()
  breakMinutes: number;
}
