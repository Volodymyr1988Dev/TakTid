import 'dotenv/config';
import { Response } from 'express';
import { safeMs } from './safeMs';

export function setAuthCookies(
  res: Response,
  tokens: { accessToken: string; refreshToken?: string },
): void {
  const isProd = process.env.NODE_ENV === 'production';
  res.cookie('access_token', tokens.accessToken, {
    httpOnly: true,
    //secure: true,
    secure: isProd,
    //secure: process.env.NODE_ENV === 'production',
    //sameSite: 'none',
    sameSite: 'lax',
    path: '/',
    maxAge: safeMs(process.env.EXPIRES_AT ?? '30d'),
  });

  if (tokens.refreshToken) {
    res.cookie('refresh_token', tokens.refreshToken, {
      httpOnly: true,
      //secure: true,
      secure: isProd,
      //secure: process.env.NODE_ENV === 'production',
      //path: '/auth/refresh',
      path: '/',
      //sameSite: 'none',
      sameSite: 'lax',
      maxAge: safeMs(process.env.REFRESH_TOKEN_BEFORE_EXPIRES ?? '10d'),
    });
  }
}
export function clearAuthCookies(res: Response) {
  res.clearCookie('access_token', {
    httpOnly: true,
    path: '/',
    //secure: true,
    secure: process.env.NODE_ENV === 'production',
    //sameSite: 'none',
    sameSite: 'lax',
  });

  res.clearCookie('refresh_token', {
    httpOnly: true,
    path: '/',
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
  });
}
