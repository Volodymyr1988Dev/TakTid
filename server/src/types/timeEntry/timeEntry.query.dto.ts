import { IsDateString, IsUUID } from 'class-validator';

export class QueryTimeEntryDto {
  @IsUUID()
  userId: string;

  @IsDateString()
  from: string;

  @IsDateString()
  to: string;
}
