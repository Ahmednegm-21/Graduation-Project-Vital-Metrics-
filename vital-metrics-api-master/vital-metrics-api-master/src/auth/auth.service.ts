import {
  Injectable,
  Inject,
  ConflictException,
  UnauthorizedException,
  InternalServerErrorException,
  BadRequestException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { eq } from 'drizzle-orm';
import { randomBytes } from 'crypto';
import * as bcrypt from 'bcrypt';
import { OAuth2Client } from 'google-auth-library';
import { DRIZZLE } from '../drizzle/drizzle.module';
import { DrizzleDB } from '../drizzle/types/drizzle';
import { RegisterDto, LoginDto, GoogleTokenLoginDto } from './dto';
import {
  JwtPayload,
  AuthResponse,
  TokenResponse,
} from './interfaces/jwt-payload.interface';
import { AUTH_CONFIG, AUTH_ERRORS } from './constants/auth.constants';
import { UsersService } from '../users/users.service';
import { OtpService } from '../otp/otp.service';
import { MailService } from '../mail/mail.service';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDB,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly usersService: UsersService,
    private readonly otpService: OtpService,
    private readonly mailService: MailService,
  ) {}

  async register(registerDto: RegisterDto): Promise<{
    message: string;
    email: string;
    expiresAt: Date;
  }> {
    const { email, password, name, gender, date_of_birth, height, weight } =
      registerDto;

    const emailExists = await this.usersService.checkEmailExists(email);
    if (emailExists) {
      throw new ConflictException(AUTH_ERRORS.EMAIL_EXISTS);
    }

    const usernameExists = await this.usersService.checkUsernameExists(name);
    if (usernameExists) {
      throw new ConflictException(AUTH_ERRORS.USERNAME_EXISTS);
    }

    try {
      const hashedPassword = await this.hashPassword(password);

      const newUser = await this.usersService.createUser(
        { email, name, gender, date_of_birth, height, weight, password },
        hashedPassword,
      );

      const { code, expiresAt } = await this.otpService.createOtp(
        newUser.user_id,
        'verify_email',
      );

      await this.mailService.sendVerificationEmail(newUser.email, code);

      return {
        message: 'Verification code sent to your email',
        email: newUser.email,
        expiresAt,
      };
    } catch (error) {
      this.logger.error('Registration failed', error);
      throw new InternalServerErrorException(AUTH_ERRORS.REGISTRATION_FAILED);
    }
  }

  async login(loginDto: LoginDto): Promise<AuthResponse> {
    const { email, password } = loginDto;

    const user = await this.db.query.users.findFirst({
      where: (users) => eq(users.email, email),
    });

    if (!user) {
      throw new UnauthorizedException(AUTH_ERRORS.INVALID_CREDENTIALS);
    }

    const isPasswordValid = await this.verifyPassword(password, user.password);

    if (!isPasswordValid) {
      throw new UnauthorizedException(AUTH_ERRORS.INVALID_CREDENTIALS);
    }

    if (!user.is_verified) {
      const { code } = await this.otpService.createOtp(
        user.user_id,
        'verify_email',
      );

      await this.mailService.sendVerificationEmail(user.email, code);
      throw new ForbiddenException(
        'Email not verified. Verification code sent',
      );
    }

    const tokens = await this.generateTokens({
      sub: user.user_id,
      email: user.email,
      is_admin: user.is_admin,
    });

    const hashedRefreshToken = await this.hashRefreshToken(
      tokens.refresh_token,
    );
    await this.usersService.updateRefreshToken(
      user.user_id,
      hashedRefreshToken,
    );

    return {
      ...tokens,
      user: {
        user_id: user.user_id,
        name: user.name,
        email: user.email,
        is_admin: user.is_admin,
        is_verified: user.is_verified,
      },
    };
  }

  async loginWithGoogleToken(
    googleTokenLoginDto: GoogleTokenLoginDto,
  ): Promise<AuthResponse> {
    const googleClientId = this.configService.get<string>('GOOGLE_CLIENT_ID');
    if (!googleClientId) {
      throw new InternalServerErrorException(
        'GOOGLE_CLIENT_ID is not configured',
      );
    }

    const oauthClient = new OAuth2Client(googleClientId);

    let payload:
      | {
          sub?: string;
          email?: string;
          email_verified?: boolean;
        }
      | undefined;

    try {
      const ticket = await oauthClient.verifyIdToken({
        idToken: googleTokenLoginDto.id_token,
        audience: googleClientId,
      });
      payload = ticket.getPayload() as any;
    } catch {
      throw new UnauthorizedException('Invalid Google token');
    }

    const googleSub = payload?.sub;
    const email = payload?.email;

    if (!googleSub || !email) {
      throw new UnauthorizedException('Invalid Google token payload');
    }

    if (payload?.email_verified !== true) {
      throw new ForbiddenException('Google account email is not verified');
    }

    let user = await this.db.query.users.findFirst({
      where: (users) => eq(users.google_sub, googleSub),
    });

    if (!user) {
      user = await this.db.query.users.findFirst({
        where: (users) => eq(users.email, email),
      });

      if (user && !user.google_sub) {
        try {
          await this.usersService.updateGoogleSub(user.user_id, googleSub);
        } catch {
          throw new ConflictException('Google account is already linked');
        }
      }
    }

    if (user) {
      if (!user.is_verified) {
        await this.usersService.markVerified(user.user_id, true);
      }

      const tokens = await this.generateTokens({
        sub: user.user_id,
        email: user.email,
        is_admin: user.is_admin,
      });

      const hashedRefreshToken = await this.hashRefreshToken(
        tokens.refresh_token,
      );
      await this.usersService.updateRefreshToken(
        user.user_id,
        hashedRefreshToken,
      );

      return {
        ...tokens,
        user: {
          user_id: user.user_id,
          name: user.name,
          email: user.email,
          is_admin: user.is_admin,
          is_verified: true,
        },
      };
    }

    const { name, gender, date_of_birth, height, weight } = googleTokenLoginDto;
    if (
      !name ||
      !gender ||
      !date_of_birth ||
      height === undefined ||
      weight === undefined
    ) {
      throw new BadRequestException(
        'Missing required fields for first-time Google sign-in: name, gender, date_of_birth, height, weight',
      );
    }

    const usernameExists = await this.usersService.checkUsernameExists(name);
    if (usernameExists) {
      throw new ConflictException(AUTH_ERRORS.USERNAME_EXISTS);
    }

    const randomPassword = randomBytes(32).toString('hex');
    const hashedPassword = await this.hashPassword(randomPassword);

    const newUser = await this.usersService.createUser(
      {
        email,
        password: randomPassword,
        name,
        gender,
        date_of_birth,
        height,
        weight,
      },
      hashedPassword,
      { isVerified: true, googleSub },
    );

    const tokens = await this.generateTokens({
      sub: newUser.user_id,
      email: newUser.email,
      is_admin: newUser.is_admin,
    });

    const hashedRefreshToken = await this.hashRefreshToken(
      tokens.refresh_token,
    );
    await this.usersService.updateRefreshToken(
      newUser.user_id,
      hashedRefreshToken,
    );

    return {
      ...tokens,
      user: {
        user_id: newUser.user_id,
        name: newUser.name,
        email: newUser.email,
        is_admin: newUser.is_admin,
        is_verified: true,
      },
    };
  }

  async refreshTokens(
    userId: number,
    refreshToken: string,
  ): Promise<TokenResponse> {
    const user = await this.usersService.findById(userId);

    if (!user || !user.refresh_token) {
      throw new UnauthorizedException(AUTH_ERRORS.ACCESS_DENIED);
    }

    const isRefreshTokenValid = await this.verifyRefreshToken(
      refreshToken,
      user.refresh_token,
    );

    if (!isRefreshTokenValid) {
      throw new UnauthorizedException(AUTH_ERRORS.INVALID_REFRESH_TOKEN);
    }

    const tokens = await this.generateTokens({
      sub: user.user_id,
      email: user.email,
      is_admin: user.is_admin,
    });

    const hashedRefreshToken = await this.hashRefreshToken(
      tokens.refresh_token,
    );
    await this.usersService.updateRefreshToken(
      user.user_id,
      hashedRefreshToken,
    );

    return tokens;
  }

  async logout(userId: number): Promise<void> {
    const user = await this.db.query.users.findFirst({
      where: (users) => eq(users.user_id, userId),
    });

    if (!user || !user.refresh_token) {
      throw new UnauthorizedException(AUTH_ERRORS.ALREADY_LOGGED_OUT);
    }

    await this.usersService.updateRefreshToken(userId, null);
  }

  async requestPasswordReset(email: string): Promise<{
    message: string;
  }> {
    try {
      const user = await this.usersService.findByEmail(email);

      const { code, expiresAt } = await this.otpService.createOtp(
        user.user_id,
        'reset_password',
      );

      await this.mailService.sendPasswordResetOtp(email, code, expiresAt);
    } catch {
      // Silently ignore - don't reveal if email exists
    }

    return {
      message: 'If that email is registered, a reset code has been sent.',
    };
  }

  async verifyPasswordResetOtp(
    email: string,
    code: string,
  ): Promise<{ message: string }> {
    try {
      const user = await this.usersService.findByEmail(email);
      await this.otpService.checkOtp(user.user_id, 'reset_password', code);
    } catch {
      throw new BadRequestException('Invalid or expired code');
    }

    return {
      message: 'OTP verified successfully. You can now reset your password.',
    };
  }

  async verifyOtp(
    email: string,
    code: string,
    purpose: 'verify_email' | 'reset_password',
  ): Promise<AuthResponse | { message: string }> {
    if (purpose === 'reset_password') {
      return this.verifyPasswordResetOtp(email, code);
    }

    return this.verifyEmailOtp(email, code);
  }

  async verifyEmailOtp(email: string, code: string): Promise<AuthResponse> {
    let user;
    try {
      user = await this.usersService.findByEmail(email);
    } catch {
      throw new BadRequestException('Invalid or expired code');
    }

    if (user.is_verified) {
      throw new BadRequestException('Email already verified');
    }

    await this.otpService.verifyOtp(user.user_id, 'verify_email', code);

    await this.usersService.markVerified(user.user_id, true);

    const tokens = await this.generateTokens({
      sub: user.user_id,
      email: user.email,
      is_admin: user.is_admin,
    });

    const hashedRefreshToken = await this.hashRefreshToken(
      tokens.refresh_token,
    );
    await this.usersService.updateRefreshToken(
      user.user_id,
      hashedRefreshToken,
    );

    return {
      ...tokens,
      user: {
        user_id: user.user_id,
        name: user.name,
        email: user.email,
        is_admin: user.is_admin,
        is_verified: true,
      },
    };
  }

  async resetPassword(
    email: string,
    code: string,
    newPassword: string,
    confirmPassword: string,
  ): Promise<{ message: string }> {
    if (newPassword !== confirmPassword) {
      throw new BadRequestException('Passwords do not match');
    }

    let user;
    try {
      user = await this.usersService.findByEmail(email);
    } catch {
      throw new BadRequestException('Invalid or expired code');
    }

    await this.otpService.verifyOtp(user.user_id, 'reset_password', code);

    const hashedPassword = await this.hashPassword(newPassword);

    await this.usersService.updatePassword(user.user_id, hashedPassword);

    await this.usersService.updateRefreshToken(user.user_id, null);

    return {
      message:
        'Password reset successfully. Please login with your new password.',
    };
  }

  private async generateTokens(payload: JwtPayload): Promise<TokenResponse> {
    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>('JWT_SECRET'),
        expiresIn: AUTH_CONFIG.ACCESS_TOKEN_EXPIRY,
      }),
      this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
        expiresIn: AUTH_CONFIG.REFRESH_TOKEN_EXPIRY,
      }),
    ]);

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
    };
  }

  private async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, AUTH_CONFIG.SALT_ROUNDS);
  }

  private async verifyPassword(
    plainPassword: string,
    hashedPassword: string,
  ): Promise<boolean> {
    return bcrypt.compare(plainPassword, hashedPassword);
  }

  private async hashRefreshToken(refreshToken: string): Promise<string> {
    return bcrypt.hash(refreshToken, AUTH_CONFIG.SALT_ROUNDS);
  }

  private async verifyRefreshToken(
    token: string,
    hashedToken: string,
  ): Promise<boolean> {
    return bcrypt.compare(token, hashedToken);
  }
}