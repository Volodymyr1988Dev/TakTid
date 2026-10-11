import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import * as crypto from 'crypto';
import * as bcrypt from 'bcrypt';
import { Resend } from 'resend';

import { PasswordResetToken } from '../entities/Auth/PasswordResetToken';
import { User } from '../entities/User/User';

@Injectable()
export class PasswordResetService {
  private readonly resend: Resend;

  constructor(
    @InjectRepository(PasswordResetToken)
    private readonly tokenRepository: Repository<PasswordResetToken>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly config: ConfigService,
    private readonly dataSource: DataSource,
  ) {
    const apiKey = this.config.get<string>('RESEND_API_KEY');

    if (!apiKey) {
      throw new Error('RESEND_API_KEY is not configured');
    }

    this.resend = new Resend(apiKey);
  }

  private hashToken(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }

  async requestReset(email: string, language = 'en'): Promise<void> {
    const normalizedEmail = email.trim().toLowerCase();

    const user = await this.userRepository.findOne({
      where: { email: normalizedEmail },
    });

    // Do not disclose whether an account exists.
    if (!user || user.deletedAt) return;

    // Invalidate any earlier, unused reset links.
    await this.tokenRepository
      .createQueryBuilder()
      .update(PasswordResetToken)
      .set({ usedAt: new Date() })
      .where('"userId" = :userId AND "usedAt" IS NULL', {
        userId: user.id,
      })
      .execute();

    const rawToken = crypto.randomBytes(32).toString('hex');
    const tokenHash = this.hashToken(rawToken);
    const expiresAt = new Date(Date.now() + 30 * 60 * 1000);

    await this.tokenRepository.save(
      this.tokenRepository.create({
        userId: user.id,
        tokenHash,
        expiresAt,
        usedAt: null,
      }),
    );

    const appUrl = this.config.get<string>('APP_URL');
    const from = this.config.get<string>('RESEND_FROM');

    if (!appUrl || !from) {
      throw new InternalServerErrorException(
        'Password reset email configuration is incomplete',
      );
    }

    const safeLanguage = ['uk', 'pl', 'ro', 'sv'].includes(language)
      ? language
      : 'en';

    const messages = {
      en: {
        subject: 'TakTid — reset your password',
        intro: 'We received a request to reset your TakTid password.',
        action: 'Reset password',
        expiry: 'This link expires in 30 minutes.',
        ignore: 'If you did not request this, you can ignore this email.',
      },
      uk: {
        subject: 'TakTid — відновлення пароля',
        intro: 'Ми отримали запит на відновлення пароля TakTid.',
        action: 'Змінити пароль',
        expiry: 'Посилання дійсне протягом 30 хвилин.',
        ignore: 'Якщо ви не надсилали цей запит, проігноруйте лист.',
      },
      pl: {
        subject: 'TakTid — reset hasła',
        intro: 'Otrzymaliśmy prośbę o zmianę hasła do TakTid.',
        action: 'Zmień hasło',
        expiry: 'Link wygaśnie za 30 minut.',
        ignore: 'Jeśli nie wysyłano tej prośby, zignoruj tę wiadomość.',
      },
      ro: {
        subject: 'TakTid — resetarea parolei',
        intro: 'Am primit o solicitare de resetare a parolei TakTid.',
        action: 'Schimbă parola',
        expiry: 'Linkul expiră în 30 de minute.',
        ignore: 'Dacă nu ai făcut această solicitare, poți ignora mesajul.',
      },
      sv: {
        subject: 'TakTid — återställ lösenord',
        intro: 'Vi har fått en begäran om att återställa ditt TakTid-lösenord.',
        action: 'Återställ lösenord',
        expiry: 'Länken upphör att gälla om 30 minuter.',
        ignore: 'Om du inte begärde detta kan du ignorera mejlet.',
      },
    };

    const m = messages[safeLanguage];
    const resetUrl =
      `${appUrl.replace(/\/+$/, '')}/reset-password?token=` +
      encodeURIComponent(rawToken);

    const { error } = await this.resend.emails.send({
      from,
      to: [normalizedEmail],
      subject: m.subject,
      text: `${m.intro}\n\n${resetUrl}\n\n${m.expiry}\n${m.ignore}`,
      html: `
        <div style="font-family:Arial,sans-serif;max-width:560px;margin:auto;padding:24px">
          <h2>TakTid</h2>
          <p>${m.intro}</p>
          <p>
            <a href="${resetUrl}"
               style="display:inline-block;padding:12px 20px;background:#2563eb;color:white;text-decoration:none;border-radius:8px">
              ${m.action}
            </a>
          </p>
          <p>${m.expiry}</p>
          <p>${m.ignore}</p>
        </div>
      `,
    });

    if (error) {
      await this.tokenRepository.delete({ tokenHash });
      console.error('Failed to send password reset email:', error.message);
      throw new InternalServerErrorException(
        'Unable to send password reset email',
      );
    }
  }

  async resetPassword(
    token: string,
    password: string,
    confirmPassword: string,
  ): Promise<void> {
    if (!token || token.length !== 64) {
      throw new BadRequestException('Invalid or expired reset link');
    }

    if (password.length < 6) {
      throw new BadRequestException('Password must be at least 6 characters');
    }

    if (password !== confirmPassword) {
      throw new BadRequestException('Passwords do not match');
    }

    const tokenHash = this.hashToken(token);

    await this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(PasswordResetToken);

      const reset = await repository.findOne({
        where: { tokenHash },
        lock: { mode: 'pessimistic_write' },
      });

      if (
        !reset ||
        reset.usedAt ||
        reset.expiresAt.getTime() <= Date.now()
      ) {
        throw new BadRequestException('Invalid or expired reset link');
      }

      const userRepository = manager.getRepository(User);
      const user = await userRepository.findOne({
        where: { id: reset.userId },
        lock: { mode: 'pessimistic_write' },
      });

      if (!user || user.deletedAt) {
        throw new BadRequestException('Invalid or expired reset link');
      }

      user.password = await bcrypt.hash(password, 10);
      await userRepository.save(user);

      // Consume all outstanding reset links for this account.
      await repository
        .createQueryBuilder()
        .update(PasswordResetToken)
        .set({ usedAt: new Date() })
        .where('"userId" = :userId AND "usedAt" IS NULL', {
          userId: user.id,
        })
        .execute();
    });
  }
}