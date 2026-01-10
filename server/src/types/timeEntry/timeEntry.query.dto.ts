import { IsDateString } from 'class-validator';

export class QueryTimeEntryDto {
  @IsDateString()
  from: string;

  @IsDateString()
  to: string;
}
