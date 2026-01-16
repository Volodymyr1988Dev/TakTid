import { Request } from 'express';
import { User } from '../../entities';
//import { AuthUser } from './auth.types';

export interface AuthRequest extends Request {
  user?: User;
  //user: AuthUser;
}
