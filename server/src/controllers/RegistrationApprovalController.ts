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
          //approval.user.name,
          approval.name,
          approval.email,
          //approval.user.email,
        );

      return res
        .status(200)
        .type('html')
        .send(html);
    } catch (error) {
      return this.sendErrorPage(res, error);
      /*return res
        .status(400)
        .type('html')
        .send(
          this.renderErrorPage(
            this.getErrorMessage(error),
          ),
        );*/
    }
  }
  @Public()
   @Get(':token/approve')
  async approvePage(
    @Param('token') token: string,
    @Res() res: Response,
  ) {
    try {
      const approval =
        await this.approvalService.getByToken(
          token,
        );

      return res
        .status(200)
        .type('html')
        .send(
          this.renderActionPage(
            token,
            'approve',
            approval.name,
            approval.email,
          ),
        );
    } catch (error) {
      return this.sendErrorPage(
        res,
        error,
      );
    }
  }

  /**
   * Reject confirmation page.
   *
   * Does not change database state.
   */
  @Public()
  @Get(':token/reject')
  async rejectPage(
    @Param('token') token: string,
    @Res() res: Response,
  ) {
    try {
      const approval =
        await this.approvalService.getByToken(
          token,
        );

      return res
        .status(200)
        .type('html')
        .send(
          this.renderActionPage(
            token,
            'reject',
            approval.name,
            approval.email,
          ),
        );
    } catch (error) {
      return this.sendErrorPage(
        res,
        error,
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
            `
              <p>
                The registration has been approved.
              </p>

              <p>
                <strong>${this.escapeHtml(result.user.name)}</strong>
                (${this.escapeHtml(result.user.email)})
                can now log in to TakTid.
              </p>
            `,
          ),
        );
    } catch (error) {
      return this.sendErrorPage(res, error);
      /*
      return res
        .status(400)
        .type('html')
        .send(
          //res,
          //error,
          this.renderErrorPage(
            this.getErrorMessage(error),
          ),
        );*/
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
            `
              <p>
                The registration request has been rejected.
              </p>

              <p>
                <strong>${this.escapeHtml(result.name)}</strong>
                (${this.escapeHtml(result.email)})
                will not be able to log in to TakTid.
              </p>
            `,
          ),//result.user.email,
        );
    } catch (error) {
      return this.sendErrorPage(res, error);
      /*
      return res
        .status(400)
        .type('html')
        .send(
          this.renderErrorPage(
            this.getErrorMessage(error),
          ),
        );*/
    }
  }

  private renderReviewPage(
    token: string,
    name: string,
    email: string,
  ): string {
    //const safeToken = this.escapeHtml(token);
     const safeToken =
      encodeURIComponent(token);

    const safeName =
      this.escapeHtml(name);

    const safeEmail =
      this.escapeHtml(email);

    return this.basePage(
      'TakTid registration request',
      `
        <h1>Registration request</h1>

        <p>
          A new user wants to access TakTid.
        </p>

        <p>
          <strong>Name:</strong>
          ${safeName}
        </p>

        <p>
          <strong>Email:</strong>
          ${safeEmail}
        </p>

        <div style="margin-top:24px;">
          <a
            href="/auth/registration-approval/${safeToken}/approve"
            style="
              display:inline-block;
              padding:12px 20px;
              background:#16a34a;
              color:white;
              text-decoration:none;
              border-radius:8px;
              font-weight:bold;
              margin-right:8px;
            "
          >
            Approve
          </a>

          <a
            href="/auth/registration-approval/${safeToken}/reject"
            style="
              display:inline-block;
              padding:12px 20px;
              background:#dc2626;
              color:white;
              text-decoration:none;
              border-radius:8px;
              font-weight:bold;
            "
          >
            Reject
          </a>
        </div>
      `,
    );
  }

  private renderActionPage(
    token: string,
    action: 'approve' | 'reject',
    name: string,
    email: string,
  ): string {
    const safeToken =
      encodeURIComponent(token);

    const safeName =
      this.escapeHtml(name);

    const safeEmail =
      this.escapeHtml(email);

    const isApprove =
      action === 'approve';

    const title = isApprove
      ? 'Approve registration?'
      : 'Reject registration?';

    const buttonText = isApprove
      ? 'Approve registration'
      : 'Reject registration';

    const buttonColor = isApprove
      ? '#16a34a'
      : '#dc2626';

    return this.basePage(
      title,
      `
        <h1>${title}</h1>

        <p>
          <strong>Name:</strong>
          ${safeName}
        </p>

        <p>
          <strong>Email:</strong>
          ${safeEmail}
        </p>

        <form
          method="POST"
          action="/api/auth/registration-approval/${safeToken}/${action}"
          style="margin-top:24px;"
        >
          <button
            type="submit"
            style="
              padding:12px 20px;
              background:${buttonColor};
              color:white;
              border:none;
              border-radius:8px;
              font-weight:bold;
              cursor:pointer;
            "
          >
            ${buttonText}
          </button>
        </form>
      `,
    );
  }

  private renderSuccessPage(
    title: string,
    content: string,
  ): string {
    return this.basePage(
      title,
      `
        <h1>${title}</h1>

        ${content}

        <p
          style="
            margin-top:24px;
            color:#666;
          "
        >
          You can close this window.
        </p>
      `,
    );
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

  private getErrorStatus(
    error: unknown,
  ): number {
    if (
      error &&
      typeof error === 'object' &&
      'getStatus' in error &&
      typeof (
        error as { getStatus?: unknown }
      ).getStatus === 'function'
    ) {
      return (
        error as {
          getStatus: () => number;
        }
      ).getStatus();
    }

    return 400;
  }

  private sendErrorPage(
    res: Response,
    error: unknown,
  ) {
    const message =
      this.getErrorMessage(error);

    const status =
      this.getErrorStatus(error);

    return res
      .status(status)
      .send(
        this.basePage(
          'TakTid',
          `
            <h1>Registration request unavailable</h1>

            <p>
              ${this.escapeHtml(message)}
            </p>

            <p
              style="
                margin-top:24px;
                color:#666;
              "
            >
              You can close this window.
            </p>
          `,
        ),
      );
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

  private basePage(
    title: string,
    content: string,
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
    <title>${this.escapeHtml(title)}</title>
  </head>

  <body
    style="
      margin:0;
      padding:40px 20px;
      background:#f5f5f5;
      font-family:Arial,Helvetica,sans-serif;
    "
  >
    <div
      style="
        max-width:560px;
        margin:0 auto;
        background:#ffffff;
        padding:32px;
        border-radius:12px;
        box-shadow:0 4px 20px rgba(0,0,0,0.08);
      "
    >
      <div
        style="
          font-size:24px;
          font-weight:bold;
          margin-bottom:24px;
        "
      >
        TakTid
      </div>

      ${content}
    </div>
  </body>
  </html>
  `.trim();
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