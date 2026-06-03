import { Logger } from '@nestjs/common';
import { EmailPayload, EmailProvider, EmailSendResult } from '../email.types';

/**
 * Dev-only provider: writes the email to the log instead of sending it.
 * Useful so password-reset / verify-email flows can be exercised end-to-end
 * without any third-party account, while still surfacing the token via the
 * `devToken` field on the API response.
 */
export class LogEmailProvider implements EmailProvider {
  readonly name = 'log';
  private readonly logger = new Logger('Email:log');

  async send(payload: EmailPayload): Promise<EmailSendResult> {
    this.logger.log(
      `[${payload.purpose}] to=${payload.to} subject="${payload.subject}"`,
    );
    this.logger.debug(payload.text);
    return { provider: this.name, delivered: true, messageId: 'log-only' };
  }
}
