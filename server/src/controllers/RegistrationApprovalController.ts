import {
  Controller,
  Get,
  Param,
  Post,
  Res,
} from '@nestjs/common';

import type { Response } from 'express';

import { Public } from '../utils/public.decorator';
import { RegistrationApprovalService } from '../services/RegistrationApproval.service';

@Controller('auth/registration-approval')
export class RegistrationApprovalController {
  constructor(
    private readonly approvalService: RegistrationApprovalService,
  ) {}

  @Public()
  @Get(':token')
  async review(
    @Param('token') token: string,
    @Res() res: Response,
  ) {
    try {
      const approval =
        await this.approvalService.getByToken(
          token,
        );

      const html =
        this.renderReviewPage(
          token,
          approval.user.name,
          approval.user.email,
        );

      return res
        .status(200)
        .type('html')
        .send(html);
    } catch (error) {
      return res
        .status(400)
        .type('html')
        .send(
          this.renderErrorPage(
            this.getErrorMessage(error),
          ),
        );
    }
  }

  @Public()
  @Post(':token/approve')
  async approve(
    @Param('token') token: string,
    @Res() res: Response,
  ) {
    try {
      const result =
        await this.approvalService.approve(
          token,
        );

      return res
        .status(200)
        .type('html')
        .send(
          this.renderResultPage(
            'Registration approved',
            `The registration for ${this.escapeHtml(
              result.user.email,
            )} has been approved.`,
          ),
        );
    } catch (error) {
      return res
        .status(400)
        .type('html')
        .send(
          this.renderErrorPage(
            this.getErrorMessage(error),
          ),
        );
    }
  }

  @Public()
  @Post(':token/reject')
  async reject(
    @Param('token') token: string,
    @Res() res: Response,
  ) {
    try {
      const result =
        await this.approvalService.reject(
          token,
        );

      return res
        .status(200)
        .type('html')
        .send(
          this.renderResultPage(
            'Registration rejected',
            `The registration for ${this.escapeHtml(
              result.user.email,
            )} has been rejected.`,
          ),
        );
    } catch (error) {
      return res
        .status(400)
        .type('html')
        .send(
          this.renderErrorPage(
            this.getErrorMessage(error),
          ),
        );
    }
  }

  private renderReviewPage(
    token: string,
    name: string,
    email: string,
  ): string {
    const safeToken =
      this.escapeHtml(token);

    return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  >
  <title>TakTid registration approval</title>
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
      max-width:560px;
      margin:50px auto;
      background:white;
      padding:32px;
      border-radius:12px;
    "
  >
    <h2>TakTid registration request</h2>

    <p>
      A user wants to register for TakTid.
    </p>

    <p>
      <strong>Name:</strong>
      ${this.escapeHtml(name)}
    </p>

    <p>
      <strong>Email:</strong>
      ${this.escapeHtml(email)}
    </p>

    <p>
      Do you approve this registration?
    </p>

    <div
      style="
        display:flex;
        gap:12px;
        flex-wrap:wrap;
        margin-top:24px;
      "
    >
      <form
        method="POST"
        action="/api/auth/registration-approval/${safeToken}/approve"
      >
        <button
          type="submit"
          style="
            padding:12px 22px;
            border:0;
            border-radius:8px;
            background:#16a34a;
            color:white;
            font-size:16px;
            cursor:pointer;
          "
        >
          Approve registration
        </button>
      </form>

      <form
        method="POST"
        action="/api/auth/registration-approval/${safeToken}/reject"
      >
        <button
          type="submit"
          style="
            padding:12px 22px;
            border:0;
            border-radius:8px;
            background:#dc2626;
            color:white;
            font-size:16px;
            cursor:pointer;
          "
        >
          Reject registration
        </button>
      </form>
    </div>
  </div>
</body>
</html>
`.trim();
  }

  private renderResultPage(
    title: string,
    message: string,
  ): string {
    return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  >
  <title>TakTid</title>
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
      max-width:560px;
      margin:50px auto;
      background:white;
      padding:32px;
      border-radius:12px;
    "
  >
    <h2>${this.escapeHtml(title)}</h2>
    <p>${message}</p>
  </div>
</body>
</html>
`.trim();
  }

  private renderErrorPage(
    message: string,
  ): string {
    return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  >
  <title>TakTid</title>
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
      max-width:560px;
      margin:50px auto;
      background:white;
      padding:32px;
      border-radius:12px;
    "
  >
    <h2>Registration request unavailable</h2>
    <p>${this.escapeHtml(message)}</p>
  </div>
</body>
</html>
`.trim();
  }

  private getErrorMessage(
    error: unknown,
  ): string {
    if (
      error &&
      typeof error === 'object' &&
      'message' in error
    ) {
      const message =
        (error as { message?: unknown })
          .message;

      if (typeof message === 'string') {
        return message;
      }
    }

    return 'The registration request could not be processed.';
  }

  private escapeHtml(
    value: string,
  ): string {
    return value
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }
}