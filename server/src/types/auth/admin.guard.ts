import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { AuthRequest } from '../index';

@Injectable()
export class AdminGuard implements CanActivate {
  canActivate(ctx: ExecutionContext): boolean {
    const req = ctx.switchToHttp().getRequest<AuthRequest>();
    const user = req.user;
    return !!user && user.isAdmin === true;
  }
}
