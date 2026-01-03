import { ApiProperty } from '@nestjs/swagger';
import { User } from '../../entities/User/User';

export class CreateSessionDto {
  @ApiProperty({ type: () => User })
  user: User;
}
