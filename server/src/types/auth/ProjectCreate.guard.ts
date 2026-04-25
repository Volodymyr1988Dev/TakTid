import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { AuthRequest } from '../index';

@Injectable()
export class ProjectCreateGuard implements CanActivate {
  canActivate(ctx: ExecutionContext): boolean {
    const req = ctx.switchToHttp().getRequest<AuthRequest>();
    const user = req.user;

    if (!user) return false;

    return user.isAdmin === true || user.CanCreateProjects === true;
  }
}