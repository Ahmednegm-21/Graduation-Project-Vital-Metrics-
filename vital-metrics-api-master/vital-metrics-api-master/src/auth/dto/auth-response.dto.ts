import { ApiProperty } from '@nestjs/swagger';

export class AuthTokensResponseDto {
  @ApiProperty({
    description: 'JWT access token for authenticated requests',
    example:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJlbWFpbCI6ImpvaG4uZG9lQGV4YW1wbGUuY29tIiwiaWF0IjoxNjE2MjM5MDIyfQ.xyz',
  })
  access_token: string;

  @ApiProperty({
    description: 'JWT refresh token for obtaining new access tokens',
    example:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJpYXQiOjE2MTYyMzkwMjJ9.abc',
  })
  refresh_token: string;
}

export class AuthUserResponseDto {
  @ApiProperty({
    description: 'User ID',
    example: 1,
  })
  user_id: number;

  @ApiProperty({
    description: 'User name',
    example: 'John Doe',
  })
  name: string;

  @ApiProperty({
    description: 'User email address',
    example: 'john.doe@example.com',
    format: 'email',
  })
  email: string;

  @ApiProperty({
    description: 'Admin flag',
    example: false,
  })
  is_admin: boolean;

  @ApiProperty({
    description: 'Email verification status',
    example: true,
  })
  is_verified: boolean;
}

export class AuthResponseDto extends AuthTokensResponseDto {
  @ApiProperty({
    description: 'Authenticated user info',
    type: AuthUserResponseDto,
  })
  user: AuthUserResponseDto;
}

export class VerificationResponseDto {
  @ApiProperty({
    description: 'Response message',
    example: 'Verification code sent to your email',
  })
  message: string;

  @ApiProperty({
    description: 'User email address',
    example: 'john.doe@example.com',
    format: 'email',
  })
  email: string;

  @ApiProperty({
    description: 'OTP expiry timestamp (ISO 8601)',
    example: '2026-02-05T20:45:00.000Z',
  })
  expiresAt: string;
}

export class MessageResponseDto {
  @ApiProperty({
    description: 'Response message',
    example: 'Logged out successfully',
  })
  message: string;
}

export class ErrorResponseDto {
  @ApiProperty({
    description: 'HTTP status code',
    example: 400,
  })
  statusCode: number;

  @ApiProperty({
    description: 'Error message or array of validation errors',
    example: 'Invalid credentials',
    oneOf: [{ type: 'string' }, { type: 'array', items: { type: 'string' } }],
  })
  message: string | string[];

  @ApiProperty({
    description: 'Error type',
    example: 'Bad Request',
  })
  error: string;
}
