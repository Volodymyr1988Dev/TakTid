import { ApiProperty } from '@nestjs/swagger';
import { User } from '../../entities/User/User';

export class AuthResponseDto {
  @ApiProperty({ example: 'User registered successfully' })
  message: string;

  @ApiProperty({ example: '2025-02-02T10:00:00Z' })
  expiresAt: string;

  @ApiProperty({ type: () => User })
  user: User;
}
