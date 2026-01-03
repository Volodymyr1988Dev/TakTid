import { ApiProperty } from '@nestjs/swagger';
import { CreateUserDto } from '../user/CreateUser.dto';

export class RegisterDto extends CreateUserDto {
  @ApiProperty({
    example: 'John Doe',
    required: false,
    description: 'Optional user name',
  })
  declare name?: string;
}
