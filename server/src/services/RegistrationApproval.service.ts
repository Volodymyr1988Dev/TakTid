import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';

import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as crypto from 'crypto';
import * as nodemailer from 'nodemailer';

import {
  RegistrationApproval,
  RegistrationApprovalStatus,
} from '../entities/Auth/RegistrationApproval';

import { User } from '../entities/User/User';

@Injectable()
export class RegistrationApprovalService {
  private readonly transporter: nodemailer.Transporter;

  constructor(
    @InjectRepository(RegistrationApproval)
    private readonly approvalRepository: Repository<RegistrationApproval>,

    private readonly configService: ConfigService,
  ) {
    const host =
      this.configService.get<string>('SMTP_HOST');

    const port =
      Number(
        this.configService.get<string>('SMTP_PORT') ??
          '587',
      );

    const user =
      this.configService.get<string>('SMTP_USER');

    const pass =
      this.configService.get<string>('SMTP_PASSWORD');

    if (!host || !user || !pass) {
      throw new Error(
        'SMTP configuration is incomplete. ' +
          'Required: SMTP_HOST, SMTP_USER, SMTP_PASSWORD',
      );
    }

    this.transporter =
      nodemailer.createTransport({
        host,
        port,
        secure: port === 465,
        //family: 4,
        auth: {
          user,
          pass,
        },
      });
      this.transporter.verify()
      .then(() => {
        console.log('SMTP connection verified successfully');
      })
      .catch((error) => {
        console.error('SMTP connection failed:', error);
      });
  }

  /**
   * Creates a pending registration approval
   * and sends an email containing a one-time token.
   */
  async createAndSend(user: User): Promise<void> {
    await this.approvalRepository
      .update(
        {
          userId: user.id,
          status:
            RegistrationApprovalStatus.PENDING,
        },
        {
          status:
            RegistrationApprovalStatus.REJECTED,
          usedAt: new Date(),
        },
      );

    const rawToken =
      crypto.randomBytes(32).toString('hex');

    const tokenHash =
      this.hashToken(rawToken);

    const expiresHours =
      Number(
        this.configService.get<string>(
          'REGISTRATION_APPROVAL_EXPIRES_HOURS',
        ) ?? '24',
      );

    const expiresAt = new Date(
      Date.now() +
        expiresHours * 60 * 60 * 1000,
    );

    const approval =
      this.approvalRepository.create({
        userId: user.id,
        tokenHash,
        status:
          RegistrationApprovalStatus.PENDING,
        expiresAt,
        usedAt: null,
      });

    await this.approvalRepository.save(
      approval,
    );

    try {
      await this.sendApprovalEmail(
        user,
        rawToken,
        expiresHours,
      );
    } catch (error) {
      console.error(
        'Failed to send registration approval email:',
        error,
      );

      throw new InternalServerErrorException(
        'Registration request was created, but the approval email could not be sent.',
      );
    }
  }

  /**
   * Returns the approval request without changing it.
   */
  async getByToken(token: string) {
    const approval =
      await this.findByToken(token);

    if (!approval) {
      throw new NotFoundException(
        'Registration approval request not found.',
      );
    }

    this.ensureTokenIsUsable(approval);

    return approval;
  }

  /**
   * Approves the registration.
   */
  async approve(token: string) {
    const approval =
      await this.findByToken(token);

    if (!approval) {
      throw new NotFoundException(
        'Registration approval request not found.',
      );
    }

    this.ensureTokenIsUsable(approval);

    approval.status =
      RegistrationApprovalStatus.APPROVED;

    approval.usedAt = new Date();

    await this.approvalRepository.save(
      approval,
    );

    return {
      message:
        'Registration approved successfully.',
      user: {
        id: approval.user.id,
        email: approval.user.email,
        name: approval.user.name,
      },
    };
  }

  /**
   * Rejects the registration.
   */
  async reject(token: string) {
    const approval =
      await this.findByToken(token);

    if (!approval) {
      throw new NotFoundException(
        'Registration approval request not found.',
      );
    }

    this.ensureTokenIsUsable(approval);

    approval.status =
      RegistrationApprovalStatus.REJECTED;

    approval.usedAt = new Date();

    await this.approvalRepository.save(
      approval,
    );

    return {
      message:
        'Registration rejected successfully.',
      user: {
        id: approval.user.id,
        email: approval.user.email,
        name: approval.user.name,
      },
    };
  }

  /**
   * Checks whether a user is allowed to log in.
   *
   * IMPORTANT:
   * If there is no approval record, the user is an
   * existing/legacy user and is considered approved.
   */
  async canLogin(userId: string): Promise<boolean> {
    const approval =
      await this.approvalRepository.findOne({
        where: {
          userId,
        },
        order: {
          createdAt: 'DESC',
        },
      });

    if (!approval) {
      return true;
    }

    return (
      approval.status ===
      RegistrationApprovalStatus.APPROVED
    );
  }

  async getLatestForUser(userId: string) {
    return this.approvalRepository.findOne({
      where: {
        userId,
      },
      order: {
        createdAt: 'DESC',
      },
    });
  }

  private async findByToken(
    token: string,
  ): Promise<RegistrationApproval | null> {
    if (!token || token.length < 32) {
      return null;
    }

    const tokenHash =
      this.hashToken(token);

    return this.approvalRepository.findOne({
      where: {
        tokenHash,
      },
      relations: {
        user: true,
      },
    });
  }

  private ensureTokenIsUsable(
    approval: RegistrationApproval,
  ): void {
    if (
      approval.status !==
      RegistrationApprovalStatus.PENDING
    ) {
      throw new BadRequestException(
        'This registration request has already been processed.',
      );
    }

    if (
      approval.usedAt !== null
    ) {
      throw new BadRequestException(
        'This registration request has already been used.',
      );
    }

    if (
      approval.expiresAt.getTime() <=
      Date.now()
    ) {
      throw new BadRequestException(
        'This registration request has expired.',
      );
    }
  }

  private hashToken(token: string): string {
    return crypto
      .createHash('sha256')
      .update(token)
      .digest('hex');
  }

  private async sendApprovalEmail(
    user: User,
    token: string,
    expiresHours: number,
  ): Promise<void> {
    const approvalEmail =
      this.configService.get<string>(
        'REGISTRATION_APPROVAL_EMAIL',
      );

    const from =
      this.configService.get<string>(
        'SMTP_FROM',
      );

    const appUrl =
      this.configService.get<string>(
        'APP_URL',
      );

    if (
      !approvalEmail ||
      !from ||
      !appUrl
    ) {
      throw new Error(
        'Registration approval email configuration is incomplete.',
      );
    }

    const approvalUrl =
      `${appUrl.replace(/\/$/, '')}` +
      `/api/auth/registration-approval/${encodeURIComponent(token)}`;

    const safeName =
      this.escapeHtml(user.name);

    const safeEmail =
      this.escapeHtml(user.email);

    const text = `
New registration request for TakTid.

A new user has requested access to TakTid.

Name: ${user.name}
Email: ${user.email}

Please open the following link to review the request:

${approvalUrl}

The link will expire in ${expiresHours} hours.

If you did not expect this request, you can ignore this email.
`.trim();

    const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TakTid registration request</title>
</head>

<body
  style="
    margin:0;
    padding:0;
    background:#f5f5f5;
    font-family:Arial,Helvetica,sans-serif;
  "
>
  <div
    style="
      max-width:600px;
      margin:40px auto;
      background:#ffffff;
      padding:32px;
      border-radius:12px;
    "
  >
    <h2>New registration request for TakTid</h2>

    <p>
      A new user has requested access to TakTid.
    </p>

    <p>
      <strong>Name:</strong>
      ${safeName}
    </p>

    <p>
      <strong>Email:</strong>
      ${safeEmail}
    </p>

    <p>
      Do you approve this registration?
    </p>

    <p>
      <a
        href="${approvalUrl}"
        style="
          display:inline-block;
          padding:12px 20px;
          background:#2563eb;
          color:#ffffff;
          text-decoration:none;
          border-radius:8px;
          font-weight:bold;
        "
      >
        Review registration
      </a>
    </p>

    <p
      style="
        margin-top:24px;
        color:#666666;
        font-size:13px;
      "
    >
      The approval request expires in
      ${expiresHours} hours.
    </p>

    <p
      style="
        color:#888888;
        font-size:12px;
      "
    >
      If you did not expect this request,
      you can safely ignore this email.
    </p>
  </div>
</body>
</html>
`.trim();

    await this.transporter.sendMail({
      from,
      to: approvalEmail,
      subject:
        'TakTid — New registration request',
      text,
      html,
    });
  }

  private escapeHtml(value: string): string {
    return value
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }
}