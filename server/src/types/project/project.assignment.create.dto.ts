import { IsString, IsUUID, IsInt } from 'class-validator';
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

  @IsString()
  startTime: string;

  @IsString()
  endTime: string;

  @IsInt()
  breakMinutes: number;
}
