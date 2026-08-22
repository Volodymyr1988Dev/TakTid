import { Injectable } from '@nestjs/common';
import { JwtService, JwtSignOptions } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import 'dotenv/config';
import { LessThanOrEqual, Repository } from 'typeorm';
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
/*
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
*/

  async createForUser(user: User): Promise<Session> {
    const payload = {
      userId: user.id,
      email: user.email,
    };

    const accessOptions: JwtSignOptions = {
      secret: process.env.SECRET,
      expiresIn: process.env.EXPIRES_AT as JwtSignOptions['expiresIn'],
    };

    const accessToken = this.jwtService.sign(payload, /*{
      secret: process.env.SECRET,
      expiresIn: process.env.EXPIRES_AT as JwtSignOptions['expiresIn'],
    }*/ accessOptions);

    const decodedAccess =
      this.jwtService.decode<{ exp?: number }>(accessToken);

    const accessExpiresAt = decodedAccess?.exp
      ? new Date(decodedAccess.exp * 1000)
      //: new Date(Date.now() + safeMs('30m'));
      : new Date(
          Date.now() +
            safeMs(process.env.EXPIRES_AT ?? '30m'),
        );

    const refreshToken = this.jwtService.sign(payload, {
      secret: process.env.SECRET,
      expiresIn:
        process.env.REFRESH_TOKEN_EXPIRES_IN as JwtSignOptions['expiresIn'],
    });

    const decodedRefresh =
      this.jwtService.decode<{ exp?: number }>(refreshToken);

    const refreshExpiresAt = decodedRefresh?.exp
      ? new Date(decodedRefresh.exp * 1000)
      //: new Date(Date.now() + safeMs('30d'));
      : new Date(
          Date.now() +
            safeMs(
              process.env.REFRESH_TOKEN_EXPIRES_IN ?? '30d',
            ),
        );

    const session = this.sessionRepository.create({
      user,
      token: accessToken,
      refresh_token: refreshToken,
      access_token_expires_at: accessExpiresAt,
      refresh_token_expires_at: refreshExpiresAt,
      lastActivityAt: new Date(),
    });

    return this.sessionRepository.save(session);
  }

  async findByToken(token: string): Promise<Session | null> {
    return this.sessionRepository.findOne({
      where: { token },
      relations: ['user'],
    });
  }

  async save(session: Session): Promise<Session> {
    return this.sessionRepository.save(session);
  }

  async removeByRefreshToken(refreshToken: string) : Promise<void> {
    await this.sessionRepository.delete({
      refresh_token: refreshToken,
    });
  }
/*
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
*//*
  async cleanupExpiredSessions(): Promise<void> {
    const maxAge = safeMs(process.env.CLEAN_SESSION_TOKEN_AFTER ?? '30d');
    const expireDate = new Date(Date.now() - maxAge);

    const result = await this.sessionRepository.delete({
      expires_at: LessThan(expireDate),
    });

    console.log(`🧹 Expired sessions deleted: ${result.affected}`);
  }
*/

  async cleanupExpiredSessions(): Promise<void> {
    const now = new Date();
    const result = await this.sessionRepository.delete({
        refresh_token_expires_at:
          LessThanOrEqual(now),
      });
      //.createQueryBuilder()
      //.delete()
      //.from(Session)
      //.where( `"refresh_token_expires_at" < CURRENT_TIMESTAMP` )
      //.execute();

    console.log(
      `🧹 Expired sessions deleted: ${result.affected ?? 0}`,
    );
  }
/*
  async cleanupExpiredSessions(): Promise<void> {
    const now = new Date();

    const result = await this.sessionRepository.delete({
      refresh_token_expires_at: LessThan(now),
    });

    console.log(
      `🧹 Expired sessions deleted: ${result.affected ?? 0}`,
    );
  }
*/
  async refreshSession(session: Session): Promise<Session> {
    const now = new Date();
    if (
      !session.refresh_token_expires_at ||
      session.refresh_token_expires_at <= now
    ) {
      throw new Error(
        'Refresh token session has expired',
      );
    }
    const payload = {
      userId: session.user.id,
      email: session.user.email,
    };

    const accessToken = this.jwtService.sign(payload, {
      secret: process.env.SECRET,
      expiresIn: process.env.EXPIRES_AT as JwtSignOptions['expiresIn'],
    });

    const decodedAccess =
      this.jwtService.decode<{ exp?: number }>(accessToken);

    const accessExpiresAt = decodedAccess?.exp
      ? new Date(decodedAccess.exp * 1000)
      //: new Date(Date.now() + safeMs('30m'));
      : new Date(
          Date.now() +
            safeMs(process.env.EXPIRES_AT ?? '30m'),
        );
        /*
    const refreshToken = this.jwtService.sign(payload, {
      secret: process.env.SECRET,
      expiresIn:
        process.env.REFRESH_TOKEN_EXPIRES_IN as JwtSignOptions['expiresIn'],
    });

    const decodedRefresh =
      this.jwtService.decode<{ exp?: number }>(refreshToken);

    const refreshExpiresAt = decodedRefresh?.exp
      ? new Date(decodedRefresh.exp * 1000)
      //: new Date(Date.now() + safeMs('30d'));
      : new Date(
          Date.now() +
            safeMs(
              process.env.REFRESH_TOKEN_EXPIRES_IN ?? '30d',
            ),
        );
        */
    session.token = accessToken;
    //session.refresh_token = refreshToken;

    session.access_token_expires_at = accessExpiresAt;
    //session.refresh_token_expires_at = refreshExpiresAt;

    session.lastActivityAt = now; //new Date();

    return this.sessionRepository.save(session);
  }

  async cleanupInactiveSessions(): Promise<void> {
    const maxIdle = safeMs(process.env.CLEAN_SESSION_IDLE ?? '30d');

    const idleDate = new Date(Date.now() - maxIdle);

    const result =
      await this.sessionRepository
        .createQueryBuilder()
        .delete()
        .from(Session)
        .where(
          '"lastActivityAt" < :idleDate',
          { idleDate },
        )
        .execute();

    //const result = await this.sessionRepository.delete({ lastActivityAt: LessThan(idleDate)});

    console.log(`💤 Inactive sessions deleted: ${result.affected ?? 0}`);
  }

  async refreshByRefreshToken(refreshToken: string): Promise<Session | null> {
    try {
      const decoded = this.jwtService.verify<{ userId: string; email: string; exp?: number; }>(
        refreshToken,
        {
          secret: process.env.SECRET,
        },
      );

      const session = await this.sessionRepository.findOne({
        where: { refresh_token: refreshToken },
        relations: ['user'],
      });

      if (!session) {
        return null;
      }

      if (session.user.id !== decoded.userId) {
        return null;
      }
        //if (!session || session.user.id !== decoded.userId) return null;
      /*
      if (
        session.refresh_token_expires_at.getTime() <=
        Date.now()
      ) {
        await this.sessionRepository.delete(session.id);
        return null;
      }

      return this.refreshSession(session);*/
      if (
        !session.refresh_token_expires_at ||
        session.refresh_token_expires_at <=
          new Date()
      ) {
        await this.removeByRefreshToken(
          refreshToken,
        );

        return null;
      }

      return await this.refreshSession(
        session,
      );
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
    /*
    await this.sessionRepository
      .createQueryBuilder()
      .delete()
      .from(Session)
      .where('"userId" = :userId', {
        userId,
      })
      .execute();
    */
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
      CanCreateProjects: user.CanCreateProjects,
      SpecialCan: user.SpecialCan,
    };
  }
}
