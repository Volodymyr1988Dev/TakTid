import { ApiProperty } from '@nestjs/swagger';
import { User } from '../../entities/User/User';

export class ValidateTokenResult {
  @ApiProperty({ type: () => User })
  user: User;

  @ApiProperty({ example: 'new.jwt.token', required: false })
  newToken?: string;
}
