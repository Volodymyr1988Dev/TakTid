import {
  Body,
  Controller,
  Post,
  Res,
  Get,
  Req,
  UnauthorizedException,
} from '@nestjs/common';
import { ApiBody, ApiOperation, ApiResponse } from '@nestjs/swagger';
import type { Request, Response } from 'express';
import 'dotenv/config';
import { AuthService } from '../services/AuthService';
import { LoginDto, RegisterDto, AuthResponseDto } from '../types';
import { Public } from '../utils/public.decorator';
import { setAuthCookies, clearAuthCookies } from '../utils/setAuthCookies';
import type { AuthRequest } from '../types/index';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}
  @Public()
  @Post('refresh')
  async refresh(
    @Req() req: Request & { cookies: { refresh_token?: string } },
    @Res({ passthrough: true }) res: Response,
  ) {
    const cookies = req.cookies as {
      refresh_token?: string;
    };
    const refreshToken = cookies?.refresh_token;
    if (!refreshToken) {
      throw new UnauthorizedException('No refresh token');
    }

    const refreshed =
      await this.authService.refreshByRefreshToken(refreshToken);

    if (!refreshed) {
      throw new UnauthorizedException('Invalid refresh token');
    }
    clearAuthCookies(res);
    setAuthCookies(res, {
      accessToken: refreshed.token,
      refreshToken: refreshed.refreshToken,
    });

    return {
      accessToken: refreshed.token,
      user: refreshed.user,
    };
  }
  @Get('me')
  me(@Req() req: AuthRequest) {
    return req.user;
  }

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
    clearAuthCookies(res);
    setAuthCookies(res, {
      accessToken: result.token,
      refreshToken: result.refreshToken,
    });
    return {
      message: 'Login successful',
      expiresAt: result.expiresAt,
      user: result.user,
    };
  }
  @Public()
  @Post('logout')
  @ApiOperation({ summary: 'Logout user and clear cookies' })
  @ApiResponse({ status: 200, description: 'Logout successful' })
  async logout(
    @Req() req: Request & { cookies: { refresh_token?: string } },
    @Res({ passthrough: true }) res: Response,
  ) {
    const coockie = req.cookies as {
      refresh_token?: string;
    };
    const refreshToken = coockie?.refresh_token;

    await this.authService.logout(refreshToken);
    clearAuthCookies(res);

    return { message: 'Logout successful' };
  }
}
