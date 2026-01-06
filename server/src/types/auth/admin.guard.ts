import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { AuthRequest } from '../index';

@Injectable()
export class AdminGuard implements CanActivate {
  canActivate(ctx: ExecutionContext): boolean {
    const req = ctx.switchToHttp().getRequest<AuthRequest>();
    return req.user?.isAdmin === true;
  }
}
