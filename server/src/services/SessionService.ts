import { Injectable /*, UnauthorizedException*/ } from '@nestjs/common';
import { JwtService, JwtSignOptions } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import 'dotenv/config';
import { LessThan, Repository } from 'typeorm';
//import { ValidateTokenResult } from '../types/index';
import { User, Session } from '../entities';
import { safeMs } from '../utils/safeMs';
import { AuthUser } from '../types/index';

@Injectable()
export class SessionService {
  constructor(
    @InjectRepository(Session)
    private readonly sessionRepository: Repository<Session>,
    private readonly jwtService: JwtService,
  ) {}

  async createForUser(user: User): Promise<Session> {
    const payload = { userId: user.id, email: user.email };
    const options: JwtSignOptions = {
      secret: process.env.SECRET,
      expiresIn: process.env.EXPIRES_AT as JwtSignOptions['expiresIn'],
    };
    const token = this.jwtService.sign(payload, options);
    const decoded = this.jwtService.decode<{ exp?: number }>(token);
    const expiresAt = decoded?.exp ? new Date(decoded.exp * 1000) : new Date();

    const refreshToken = this.jwtService.sign(payload, {
      secret: process.env.SECRET,
      expiresIn: process.env
        .REFRESH_TOKEN_EXPIRES_IN as JwtSignOptions['expiresIn'],
    });

    const session = this.sessionRepository.create({
      user,
      token,
      refresh_token: refreshToken,
      expires_at: expiresAt,
      lastActivityAt: new Date(),
    });

    return this.sessionRepository.save(session);
  }
  /*
  async validateToken(token: string): Promise<ValidateTokenResult | null> {
    const now = new Date();
    try {
      this.jwtService.verify<{
        userId: string;
        email: string;
      }>(token, { secret: process.env.SECRET });

      const session = await this.sessionRepository.findOne({
        where: { token },
        relations: ['user'],
      });

      if (!session || session.expires_at < now) return null;

      const refreshTokenBeforeExpires = safeMs(
        process.env.REFRESH_TOKEN_BEFORE_EXPIRES ?? '1h',
      );
      const timeLeft = session.expires_at.getTime() - now.getTime();

      if (timeLeft < refreshTokenBeforeExpires) {
        const refreshed = await this.refreshSession(session);
        return { user: refreshed.user, newToken: refreshed.token };
      }

      return { user: session.user };
      //return { user: this.toAuthUser(session.user) };
    } /*catch (e: unknown) {
      if (e instanceof Error) {
        throw new Error(`Invalid or expired token: ${e.message}`);
      }
      return null;
    }
      */ /* catch {
      throw new UnauthorizedException('Invalid or expired token');
    }
  }
*/

  async findByToken(token: string): Promise<Session | null> {
    return this.sessionRepository.findOne({
      where: { token },
      relations: ['user'],
    });
  }

  async refreshSession(session: Session): Promise<Session> {
    const payload = { userId: session.user.id, email: session.user.email };
    const token = this.jwtService.sign(payload, {
      secret: process.env.SECRET,
      expiresIn: process.env.EXPIRES_AT as JwtSignOptions['expiresIn'],
    });

    const decoded = this.jwtService.decode<{ exp?: number }>(token);
    const expiresAt = decoded?.exp ? new Date(decoded.exp * 1000) : new Date();

    session.token = token;
    session.expires_at = expiresAt;
    session.lastActivityAt = new Date();

    return this.sessionRepository.save(session);
  }

  async cleanupExpiredSessions(): Promise<void> {
    const maxAge = safeMs(process.env.CLEAN_SESSION_TOKEN_AFTER ?? '30d');
    const sessionClean = new Date(Date.now() - maxAge);

    await this.sessionRepository.delete({
      expires_at: LessThan(sessionClean),
    });
  }

  async refreshByRefreshToken(refreshToken: string): Promise<Session | null> {
    try {
      const decoded = this.jwtService.verify<{ userId: string; email: string }>(
        refreshToken,
        {
          secret: process.env.SECRET,
        },
      );

      const session = await this.sessionRepository.findOne({
        where: { refresh_token: refreshToken },
        relations: ['user'],
      });

      if (!session || session.user.id !== decoded.userId) return null;

      return this.refreshSession(session);
    } catch {
      return null;
    }
  }

  async findAll(): Promise<Session[]> {
    return this.sessionRepository.find({ relations: ['user'] });
  }

  async remove(id: string): Promise<void> {
    const result = await this.sessionRepository.delete(id);
    if (result.affected === 0) {
      throw new Error('Session not found');
    }
  }

  async removeAllByUser(userId: string): Promise<void> {
    await this.sessionRepository.softDelete({
      user: { id: userId },
    });
  }
  public toAuthUser(user: User): AuthUser {
    return {
      id: user.id,
      email: user.email,
      name: user.name,
      isAdmin: user.isAdmin,
    };
  }
}
