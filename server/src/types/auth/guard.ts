import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import 'dotenv/config';
import { Response } from 'express';
import { SessionService } from '../../services';
import { AuthRequest } from '../index';
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
    const cookies = request.cookies as
      | { access_token?: string; refresh_token?: string }
      | undefined;

    const token = cookies?.access_token;
    const refreshToken = cookies?.refresh_token;

    if (!token) {
      throw new UnauthorizedException('No token provided');
    }
    const result = await this.sessionService.validateToken(token);
    if (!result) {
      if (!refreshToken)
        throw new UnauthorizedException('No refresh token provided');

      const refreshed =
        await this.sessionService.refreshByRefreshToken(refreshToken);
      if (!refreshed)
        throw new UnauthorizedException('Invalid or expired refresh token');
      setAuthCookies(response, { accessToken: refreshed.token });
      request.user = refreshed.user;
      return true;
    }

    if (result.newToken) {
      setAuthCookies(response, { accessToken: result.newToken });
    }
    request.user = result.user;
    return true;
  }
}
