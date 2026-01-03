import { Body, Controller, Post, Res } from '@nestjs/common';
import { ApiBody, ApiOperation, ApiResponse } from '@nestjs/swagger';
import 'dotenv/config';
import type { Response } from 'express';
import { AuthService } from '../services/AuthService';
import { LoginDto, RegisterDto, AuthResponseDto } from '../types';
import { Public } from '../utils/public.decorator';
import { setAuthCookies } from '../utils/setAuthCookies';

@Public()
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}
  @Public()
  @Post('register')
  @ApiOperation({ summary: 'Register a new user' })
  @ApiBody({ type: RegisterDto })
  @ApiResponse({
    status: 201,
    description: 'User registered successfully',
    type: AuthResponseDto,
  })
  async register(
    @Body() registerDto: RegisterDto,
    @Res({ passthrough: true }) res: Response,
  ) {
    const result = await this.authService.register(registerDto);
    setAuthCookies(res, {
      accessToken: result.token,
      refreshToken: result.refreshToken,
      userId: result.user.id,
    });
    return {
      result,
      message: 'User registered successfully',
      user: result.user,
      expiresAt: result.expiresAt,
    };
  }

  @Public()
  @Post('login')
  @ApiOperation({ summary: 'Login user and get access token' })
  @ApiBody({ type: LoginDto })
  @ApiResponse({
    status: 200,
    description: 'Login successful',
    type: AuthResponseDto,
  })
  async login(
    @Body() loginDto: LoginDto,
    @Res({ passthrough: true }) res: Response,
  ) {
    const result = await this.authService.login(loginDto);
    setAuthCookies(res, {
      accessToken: result.token,
      refreshToken: result.refreshToken,
      userId: result.user.id,
    });
    return {
      message: 'Login successful',
      expiresAt: result.expiresAt,
      user: result.user,
    };
  }

  @Post('logout')
  @ApiOperation({ summary: 'Logout user and clear cookies' })
  @ApiResponse({ status: 200, description: 'Logout successful' })
  logout(@Res({ passthrough: true }) res: Response) {
    res.clearCookie('access_token');
    res.clearCookie('refresh_token');
    return { message: 'Logout successful' };
  }
}
