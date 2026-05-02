import {
  Injectable,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private transporter: nodemailer.Transporter | null = null;

  constructor(private readonly configService: ConfigService) {}

  private getTransporter(): nodemailer.Transporter {
    if (this.transporter) {
      return this.transporter;
    }

    const mailUser = this.configService.get<string>('EMAIL_USER');
    const mailPass = this.configService.get<string>('EMAIL_PASS');

    if (!mailUser || !mailPass) {
      throw new InternalServerErrorException('Email service not configured');
    }

    this.transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: mailUser,
        pass: mailPass,
      },
    });

    return this.transporter;
  }

  private getMailFrom(): string {
    const mailFrom = this.configService.get<string>('EMAIL_FROM');

    if (!mailFrom) {
      throw new InternalServerErrorException('Email service not configured');
    }

    return mailFrom;
  }

  async sendPasswordResetOtp(
    email: string,
    code: string,
    expiresAt: Date,
  ): Promise<void> {
    const transporter = this.getTransporter();
    const mailFrom = this.getMailFrom();
    const appName = 'Vital Metrics';

    try {
      await transporter.sendMail({
        from: mailFrom,
        to: email,
        subject: `${appName} Password Reset OTP`,
        text: `Your password reset OTP is ${code}. It expires at ${expiresAt.toISOString()}.`,
        html: `<p>Your password reset OTP is <strong>${code}</strong>.</p><p>It expires at ${expiresAt.toISOString()}.</p>`,
      });
    } catch (error) {
      this.logger.error('Failed to send password reset OTP email', error);
      throw new InternalServerErrorException('Failed to send OTP email');
    }
  }

  async sendVerificationEmail(email: string, code: string): Promise<void> {
    const transporter = this.getTransporter();
    const mailFrom = this.getMailFrom();
    const appName = 'Vital Metrics';

    try {
      await transporter.sendMail({
        from: mailFrom,
        to: email,
        subject: `${appName} Email Verification`,
        text: `Your email verification code is ${code}.`,
        html: `<p>Your email verification code is <strong>${code}</strong>.</p>`,
      });
    } catch (error) {
      this.logger.error('Failed to send verification email', error);
      throw new InternalServerErrorException(
        'Failed to send verification email',
      );
    }
  }
}
