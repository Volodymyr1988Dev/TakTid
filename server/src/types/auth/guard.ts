import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import 'dotenv/config';
import type { Response } from 'express';
import { SessionService } from '../../services';
import type { AuthRequest } from '../index';
import { IS_PUBLIC_KEY } from '../../utils/public.decorator';
import { setAuthCookies } from '../../utils/setAuthCookies';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private readonly sessionService: SessionService,
    private readonly reflector: Reflector,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) return true;
    const request = context.switchToHttp().getRequest<AuthRequest>();
    const response = context.switchToHttp().getResponse<Response>();
    const cookies = request.cookies as {
      access_token?: string;
      //refresh_token?: string;
    };
    const token =
      cookies?.access_token ||
      request.headers.authorization?.replace('Bearer ', '');
    //const { access_token, refresh_token } = request.cookies ?? {};
    //const cookies = request.cookies as | { access_token?: string; refresh_token?: string }  | undefined;

    //const token = cookies?.access_token;
    //const refreshToken = cookies?.refresh_token;

    //if (!cookies?.access_token) {
    //  throw new UnauthorizedException('No access token');
    //}
    if (!token) {
      throw new UnauthorizedException('No token provided');
    }
    const result = await this.sessionService.validateToken(token);
    //const result = await this.sessionService.validateToken(
    //  cookies.access_token,
    //);
    if (!result) {
      //if (!refreshToken)
      //if (!cookies.refresh_token)
      throw new UnauthorizedException('Invalid or expired access token');
      //const refreshed =
      //await this.sessionService.refreshByRefreshToken(refreshToken);
      //await this.sessionService.refreshByRefreshToken(cookies.refresh_token);
      //if (!refreshed)
      //  throw new UnauthorizedException('Invalid or expired refresh token');
      //setAuthCookies(response, { accessToken: refreshed.token });
      //request.user = refreshed.user;
      //return true;
    }

    if (result.newToken) {
      setAuthCookies(response, { accessToken: result.newToken });
    }
    request.user = result.user;
    return true;
  }
}
