import { IsString, IsUUID, IsInt, IsDateString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateProjectAssignmentDto {
  //@ApiProperty({ format: 'uuid' })
  //@IsUUID()
  //userId: string;

  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  projectId: string;

  @ApiProperty({ required: false })
  @IsString()
  comment?: string;

  @ApiProperty({ example: '09:00' })
  @IsString()
  startTime: string;

  @ApiProperty({ example: '17:30' })
  @IsString()
  endTime: string;

  @ApiProperty({ example: 30 })
  @IsInt()
  breakMinutes: number;

  @ApiProperty({ example: '2025-01-15' })
  @IsDateString()
  date: string;
}
