import { IsDateString } from 'class-validator';

export class QueryProjectAssignmentDto {
  @IsDateString()
  from: string;

  @IsDateString()
  to: string;
}
