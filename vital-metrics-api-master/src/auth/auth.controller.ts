import {
  Controller,
  Post,
  Body,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiBody,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import {
  RegisterDto,
  LoginDto,
  RefreshTokenDto,
  GoogleTokenLoginDto,
  AuthTokensResponseDto,
  AuthResponseDto,
  MessageResponseDto,
  ErrorResponseDto,
  VerificationResponseDto,
  ForgotPasswordDto,
  VerifyOtpDto,
  ResetPasswordDto,
} from './dto';
import { JwtRefreshAuthGuard, JwtAuthGuard } from './guard';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Register a new user',
    description:
      'Creates a new user account with health profile information. Password is automatically hashed before storage.',
  })
  @ApiResponse({
    status: 201,
    description: 'Verification code sent to email',
    type: VerificationResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid input data or email already exists',
    type: ErrorResponseDto,
  })
  @ApiResponse({
    status: 409,
    description: 'User with this email already exists',
    type: ErrorResponseDto,
  })
  @ApiBody({ type: RegisterDto })
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'User login',
    description:
      'Authenticates a user with email and password. Returns access and refresh tokens on successful authentication.',
  })
  @ApiResponse({
    status: 200,
    description: 'Successfully authenticated',
    type: AuthResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid input format',
    type: ErrorResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Invalid credentials',
    type: ErrorResponseDto,
  })
  @ApiResponse({
    status: 403,
    description: 'Email not verified',
    type: ErrorResponseDto,
  })
  @ApiBody({ type: LoginDto })
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @Post('google/token')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Login with Google (ID token)',
    description:
      "Verifies a Google ID token and returns this API's access and refresh tokens. If this is the first sign-in, the request must also include required health profile fields and a unique username (name).",
  })
  @ApiResponse({
    status: 200,
    description: 'Successfully authenticated with Google',
    type: AuthResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid input format or missing required profile fields',
    type: ErrorResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Invalid Google token',
    type: ErrorResponseDto,
  })
  @ApiResponse({
    status: 409,
    description: 'Username already exists',
    type: ErrorResponseDto,
  })
  @ApiBody({ type: GoogleTokenLoginDto })
  async googleTokenLogin(@Body() googleTokenLoginDto: GoogleTokenLoginDto) {
    return this.authService.loginWithGoogleToken(googleTokenLoginDto);
  }

  @Post('refresh')
  @UseGuards(JwtRefreshAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Refresh access token',
    description:
      'Generates a new access token using a valid refresh token. The refresh token must be provided in the request body and a valid JWT token in the Authorization header.',
  })
  @ApiResponse({
    status: 200,
    description: 'New tokens successfully generated',
    type: AuthTokensResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Invalid or expired refresh token',
    type: ErrorResponseDto,
  })
  @ApiResponse({
    status: 403,
    description: 'Refresh token does not match stored token',
    type: ErrorResponseDto,
  })
  @ApiBody({ type: RefreshTokenDto })
  async refresh(@Body() refreshTokenDto: RefreshTokenDto, @Request() req: any) {
    return this.authService.refreshTokens(
      req.user.user_id,
      refreshTokenDto.refresh_token,
    );
  }

  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Request password reset',
    description:
      "Sends a password reset OTP to the user's registered email address. The OTP is valid for 10 minutes.",
  })
  @ApiResponse({
    status: 200,
    description: 'Password reset OTP sent successfully',
    schema: {
      example: { message: 'Password reset OTP sent successfully' },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'User with this email does not exist',
    type: ErrorResponseDto,
  })
  @ApiBody({ type: ForgotPasswordDto })
  async requestPasswordReset(@Body() forgotPasswordDto: ForgotPasswordDto) {
    return this.authService.requestPasswordReset(forgotPasswordDto.email);
  }

  @Post('verify-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Verify password reset OTP',
    description:
      'Verifies the OTP code sent to the user. For password reset, this step is required before setting a new password. For email verification, this completes verification and returns tokens.',
  })
  @ApiResponse({
    status: 200,
    description:
      'OTP verified successfully (reset_password purpose returns message, verify_email purpose returns auth tokens)',
    schema: {
      oneOf: [
        {
          type: 'object',
          properties: {
            message: { type: 'string', example: 'OTP verified successfully' },
          },
        },
        { $ref: '#/components/schemas/AuthResponseDto' },
      ],
    },
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid or expired OTP',
    type: ErrorResponseDto,
  })
  @ApiResponse({
    status: 404,
    description: 'User with this email does not exist',
    type: ErrorResponseDto,
  })
  @ApiBody({ type: VerifyOtpDto })
  async verifyOtp(@Body() verifyOtpDto: VerifyOtpDto) {
    return this.authService.verifyOtp(
      verifyOtpDto.email,
      verifyOtpDto.code,
      verifyOtpDto.purpose,
    );
  }

  @Post('reset-password/confirm')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Reset password with OTP',
    description:
      'Resets the user password using a valid OTP. The OTP must be verified first. All existing sessions will be invalidated.',
  })
  @ApiResponse({
    status: 200,
    description: 'Password reset successfully',
    schema: {
      example: { message: 'Password has been reset successfully' },
    },
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid OTP, expired OTP, or passwords do not match',
    type: ErrorResponseDto,
  })
  @ApiResponse({
    status: 404,
    description: 'User with this email does not exist',
    type: ErrorResponseDto,
  })
  @ApiBody({ type: ResetPasswordDto })
  async resetPassword(@Body() resetPasswordDto: ResetPasswordDto) {
    return this.authService.resetPassword(
      resetPasswordDto.email,
      resetPasswordDto.code,
      resetPasswordDto.newPassword,
      resetPasswordDto.confirmPassword,
    );
  }

  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'User logout',
    description:
      'Logs out the current user by invalidating their refresh token. Requires a valid access token in the Authorization header.',
  })
  @ApiResponse({
    status: 200,
    description: 'Successfully logged out',
    type: MessageResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Invalid or missing authentication token',
    type: ErrorResponseDto,
  })
  async logout(@Request() req: any) {
    await this.authService.logout(req.user.user_id);
    return { message: 'Logged out successfully' };
  }
}
