import { ApiProperty } from '@nestjs/swagger';

export class ValidateTokenDto {
  @ApiProperty({ example: 'jwt.token.value' })
  token!: string;
}
