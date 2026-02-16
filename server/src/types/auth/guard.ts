import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import 'dotenv/config';
import { JwtService } from '@nestjs/jwt';
import type { Response } from 'express';
import { SessionService } from '../../services';
import type { AuthRequest } from '../index';
import { IS_PUBLIC_KEY } from '../../utils/public.decorator';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private readonly sessionService: SessionService,
    private readonly reflector: Reflector,
    private readonly jwtService: JwtService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) return true;
    const request = context.switchToHttp().getRequest<AuthRequest>();

    const coockie = request.cookies as {
      access_token?: string;
    };
    const token = coockie?.access_token;
    if (!token) {
      throw new UnauthorizedException('No token provided');
    }
    try {
      this.jwtService.verify<{
        userId: string;
        email: string;
      }>(token, {
        secret: process.env.SECRET,
      });

      const session = await this.sessionService.findByToken(token);

      if (!session) {
        throw new UnauthorizedException('Session not found');
      }

      if (session.user.deletedAt) {
        throw new UnauthorizedException('User account deleted');
      }

      if (session.expires_at < new Date()) {
        throw new UnauthorizedException('Session expired');
      }

      request.user = this.sessionService.toAuthUser(session.user);

      return true;
    } catch {
      throw new UnauthorizedException('Invalid or expired token');
    }
  }
}
