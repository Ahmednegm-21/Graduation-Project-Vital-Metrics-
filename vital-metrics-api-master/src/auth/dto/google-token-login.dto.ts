import {
  IsNotEmpty,
  IsString,
  IsOptional,
  IsEnum,
  IsDateString,
  IsNumber,
  Min,
  MinLength,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class GoogleTokenLoginDto {
  @ApiProperty({
    description:
      'Google ID token obtained on the client (Sign in with Google). The API verifies it and issues its own JWTs.',
    example: 'eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...snip',
  })
  @IsNotEmpty()
  @IsString()
  id_token: string;

  @ApiPropertyOptional({
    description:
      'Required only when this Google account is signing in for the first time: unique username for this API (maps to users.name).',
    example: 'john_doe_92',
    minLength: 3,
  })
  @IsOptional()
  @IsString()
  @MinLength(3)
  name?: string;

  @ApiPropertyOptional({
    description:
      'Required only when this Google account is signing in for the first time: user biological gender.',
    example: 'male',
    enum: ['male', 'female'],
  })
  @IsOptional()
  @IsEnum(['male', 'female'])
  gender?: 'male' | 'female';

  @ApiPropertyOptional({
    description:
      'Required only when this Google account is signing in for the first time: date of birth (ISO 8601).',
    example: '1990-05-15',
    format: 'date',
  })
  @IsOptional()
  @IsDateString()
  date_of_birth?: string;

  @ApiPropertyOptional({
    description:
      'Required only when this Google account is signing in for the first time: height in centimeters.',
    example: 175,
    minimum: 0,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  height?: number;

  @ApiPropertyOptional({
    description:
      'Required only when this Google account is signing in for the first time: weight in kilograms.',
    example: 70.5,
    minimum: 0,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  weight?: number;
}
