import {
  IsString,
  MinLength,
  MaxLength,
  IsEnum,
  IsDateString,
  IsNumber,
  Min,
  Max,
  IsOptional,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateProfileDto {
  @ApiPropertyOptional({
    description: 'Full name of the user',
    example: 'John Doe',
    minLength: 2,
    maxLength: 50,
  })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  name?: string;

  @ApiPropertyOptional({
    description: 'User height in centimeters',
    example: 175,
    minimum: 50,
    maximum: 300,
  })
  @IsOptional()
  @IsNumber()
  @Min(50)
  @Max(300)
  height?: number;

  @ApiPropertyOptional({
    description: 'User weight in kilograms',
    example: 70.5,
    minimum: 20,
    maximum: 500,
  })
  @IsOptional()
  @IsNumber()
  @Min(20)
  @Max(500)
  weight?: number;

  @ApiPropertyOptional({
    description: 'User biological gender. Allowed values: "male", "female"',
    example: 'male',
    enum: ['male', 'female'],
  })
  @IsOptional()
  @IsEnum(['male', 'female'])
  gender?: 'male' | 'female';

  @ApiPropertyOptional({
    description: 'User date of birth in ISO 8601 format',
    example: '1990-05-15',
    format: 'date',
  })
  @IsOptional()
  @IsDateString()
  date_of_birth?: string;
}
