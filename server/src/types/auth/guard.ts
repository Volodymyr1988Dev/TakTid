import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import 'dotenv/config';
import { JwtService } from '@nestjs/jwt';
//import type { Response } from 'express';
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

    const accessToken =
      request.cookies?.access_token;

    if (!accessToken) {
      throw new UnauthorizedException(
        'No access token provided',
      );
    }
    
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
      const now = new Date();

      //if (session.expires_at <= now) { throw new UnauthorizedException('Session expired')}
      if (
        !session.access_token_expires_at ||
        session.access_token_expires_at <= now
      ) {
        throw new UnauthorizedException('Access token expired');
      }
      //const now = new Date();
      if (
        !session.lastActivityAt ||
        now.getTime() - new Date(session.lastActivityAt).getTime() >
          5 * 60 * 1000
      ) {
        session.lastActivityAt = now;
        await this.sessionService.save(session);
      }

      //session.lastActivityAt = new Date();
      //await this.sessionService.save(session);
      request.user = this.sessionService.toAuthUser(session.user);

      return true;
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }

      throw new UnauthorizedException(
        'Invalid or expired token',
      );
    }
  }
}
