import {
  BadRequestException,
  Inject,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { randomInt } from 'crypto';
import * as bcrypt from 'bcrypt';
import { and, desc, eq, gt } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.module';
import { DrizzleDB } from '../drizzle/types/drizzle';
import { otps } from '../drizzle/schema';
import { AUTH_CONFIG } from '../auth/constants/auth.constants';

@Injectable()
export class OtpService {
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDB,
    private readonly configService: ConfigService,
  ) {}

  async createOtp(
    userId: number,
    purpose: 'verify_email' | 'reset_password',
  ): Promise<{ code: string; expiresAt: Date; otpId: number }> {
    const code = randomInt(0, 1000000).toString().padStart(6, '0');
    const expiryMinutes = this.getExpiryMinutes();
    const expiresAt = new Date(Date.now() + expiryMinutes * 60 * 1000);

    try {
      const hashedCode = await bcrypt.hash(code, AUTH_CONFIG.SALT_ROUNDS);

      const result = await this.db.transaction(async (tx) => {
        await tx
          .update(otps)
          .set({ used: true })
          .where(
            and(
              eq(otps.user_id, userId),
              eq(otps.purpose, purpose),
              eq(otps.used, false),
            ),
          );

        const [created] = await tx
          .insert(otps)
          .values({
            user_id: userId,
            purpose,
            code: hashedCode,
            expires_at: expiresAt,
            used: false,
          })
          .returning({ otp_id: otps.otp_id });

        if (!created) {
          throw new InternalServerErrorException('Failed to create OTP');
        }

        return created;
      });

      return { code, expiresAt, otpId: result.otp_id };
    } catch (error) {
      if (error instanceof InternalServerErrorException) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to create OTP');
    }
  }

  async checkOtp(
    userId: number,
    purpose: 'verify_email' | 'reset_password',
    code: string,
  ): Promise<void> {
    await this.validateOtp(userId, purpose, code);
  }

  async verifyOtp(
    userId: number,
    purpose: 'verify_email' | 'reset_password',
    code: string,
  ): Promise<void> {
    const otp = await this.validateOtp(userId, purpose, code);

    await this.db
      .update(otps)
      .set({ used: true })
      .where(eq(otps.otp_id, otp.otp_id));
  }

  private async validateOtp(
    userId: number,
    purpose: 'verify_email' | 'reset_password',
    code: string,
  ): Promise<{
    otp_id: number;
    code: string;
    expires_at: Date;
    used: boolean;
  }> {
    const now = new Date();

    const [otp] = await this.db
      .select({
        otp_id: otps.otp_id,
        code: otps.code,
        expires_at: otps.expires_at,
        used: otps.used,
      })
      .from(otps)
      .where(
        and(
          eq(otps.user_id, userId),
          eq(otps.purpose, purpose),
          eq(otps.used, false),
          gt(otps.expires_at, now),
        ),
      )
      .orderBy(desc(otps.otp_id))
      .limit(1);

    if (!otp) {
      throw new BadRequestException('OTP is invalid or expired');
    }

    const isValid = await bcrypt.compare(code, otp.code);
    if (!isValid) {
      throw new BadRequestException('OTP is invalid or expired');
    }

    return otp;
  }

  private getExpiryMinutes(): number {
    const configured = this.configService.get<string>('OTP_EXPIRY_MINUTES');
    const parsed = configured ? Number.parseInt(configured, 10) : NaN;
    if (Number.isFinite(parsed) && parsed > 0) {
      return parsed;
    }
    return 10;
  }
}
