import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsIn, IsNotEmpty, IsString, Length } from 'class-validator';

export class VerifyOtpDto {
  @ApiProperty({
    description: 'Email address of the user',
    example: 'user@example.com',
    format: 'email',
  })
  @IsNotEmpty()
  @IsEmail()
  @IsString()
  email: string;

  @ApiProperty({
    description: 'The 6-digit OTP code sent to email',
    example: '123456',
    minLength: 6,
    maxLength: 6,
  })
  @IsNotEmpty()
  @IsString()
  @Length(6, 6)
  code: string;

  @ApiProperty({
    type: String,
    description:
      'OTP purpose. Allowed values: "verify_email", "reset_password"',
    enum: ['verify_email', 'reset_password'],
    example: 'verify_email',
  })
  @IsNotEmpty()
  @IsString()
  @IsIn(['verify_email', 'reset_password'])
  purpose: 'verify_email' | 'reset_password';
}
