import 'dotenv/config';
import { Response } from 'express';
import { safeMs } from './safeMs';

export function setAuthCookies(
  res: Response,
  tokens: { accessToken: string; refreshToken?: string },
  //tokens: { accessToken: string; refreshToken?: string; userId?: string },
): void {
  res.cookie('access_token', tokens.accessToken, {
    httpOnly: true,
    secure: true,
    //secure: process.env.NODE_ENV === 'production',
    sameSite: 'none',
    //sameSite: 'lax',
    path: '/',
    maxAge: safeMs(process.env.EXPIRES_AT ?? '30d'),
  });

  if (tokens.refreshToken) {
    res.cookie('refresh_token', tokens.refreshToken, {
      httpOnly: true,
      secure: true,
      //secure: process.env.NODE_ENV === 'production',
      //path: '/auth/refresh',
      path: '/',
      sameSite: 'none',
      //sameSite: 'lax',
      maxAge: safeMs(process.env.REFRESH_TOKEN_BEFORE_EXPIRES ?? '10d'),
    });
  }
  /*
  if (tokens.userId) {
    res.cookie('user_id', tokens.userId.toString(), {
      httpOnly: true,
      secure: true,
      sameSite: 'none',
      maxAge: safeMs(process.env.EXPIRES_AT ?? '4h'),
    });
  }
  */
}
