import { IsString, IsOptional, IsInt } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateProjectAssignmentDto {
  @ApiProperty()
  @IsString()
  @IsOptional()
  comment?: string;

  @IsString()
  startTime: string;

  @IsString()
  endTime: string;

  @IsInt()
  breakMinutes: number;
}
