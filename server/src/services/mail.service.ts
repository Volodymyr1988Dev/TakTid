
import {
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';

@Injectable()
export class MailService {
  private readonly transporter: nodemailer.Transporter;
  private readonly from: string;

  constructor(private readonly config: ConfigService) {
    const host = this.config.get<string>('SMTP_HOST');
    const port = Number(
      this.config.get<string>('SMTP_PORT') ?? '465',
    );
    const user = this.config.get<string>('SMTP_USER');
    const password = this.config.get<string>('SMTP_PASSWORD');
    const from = this.config.get<string>('SMTP_FROM');

    if (
      !host ||
      !Number.isInteger(port) ||
      port < 1 ||
      port > 65535 ||
      !user ||
      !password ||
      !from
    ) {
      throw new Error('SMTP configuration is incomplete or invalid');
    }

    this.from = from;

    this.transporter = nodemailer.createTransport({
      host,
      port,
      secure: port === 465,
      auth: {
        user,
        pass: password,
      },
      connectionTimeout: 10000,
      greetingTimeout: 10000,
      socketTimeout: 20000,
    });
  }

  async sendMail(options: {
    to: string | string[];
    subject: string;
    text: string;
    html?: string;
  }): Promise<string | undefined> {
    try {
      const info = await this.transporter.sendMail({
        from: this.from,
        ...options,
      });

      console.info('[Mail] SMTP accepted message', {
        messageId: info.messageId,
      });

      return info.messageId;
    } catch (error) {
      console.error('[Mail] SMTP send failed', {
        message:
          error instanceof Error
            ? error.message
            : 'Unknown SMTP error',
        code:
          typeof error === 'object' &&
          error !== null &&
          'code' in error
            ? String(error.code)
            : undefined,
      });

      throw new InternalServerErrorException(
        'Unable to send email',
      );
    }
  }
}
