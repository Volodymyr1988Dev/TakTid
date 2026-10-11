import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Post,
} from '@nestjs/common';
import { IsEmail, IsIn, IsOptional, IsString, MaxLength } from 'class-validator';
import { Public } from '../utils/public.decorator';
import { PasswordResetService } from '../services/PasswordReset.service';

class RequestPasswordResetDto {
  @IsEmail()
  @MaxLength(254)
  email!: string;

  @IsOptional()
  @IsIn(['en', 'uk', 'pl', 'ro', 'sv'])
  language?: string;
}

class ConfirmPasswordResetDto {
  @IsString()
  @MaxLength(64)
  token!: string;

  @IsString()
  @MaxLength(128)
  password!: string;

  @IsString()
  @MaxLength(128)
  confirmPassword!: string;
}

@Public()
@Controller('auth/password-reset')
export class PasswordResetController {
  constructor(private readonly service: PasswordResetService) {}

  @Post('request')
  @HttpCode(HttpStatus.OK)
  async request(@Body() dto: RequestPasswordResetDto) {
    await this.service.requestReset(dto.email, dto.language);

    return {
      message:
        'If an account exists for this email, a reset link will be sent.',
    };
  }

  @Post('confirm')
  @HttpCode(HttpStatus.OK)
  async confirm(@Body() dto: ConfirmPasswordResetDto) {
    await this.service.resetPassword(
      dto.token,
      dto.password,
      dto.confirmPassword,
    );

    return {
      message: 'Password has been reset successfully.',
    };
  }
}