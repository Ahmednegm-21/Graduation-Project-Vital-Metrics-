import { ApiProperty } from '@nestjs/swagger';
import { IsDateString, IsIn, IsInt, Min } from 'class-validator';

export class CreateSleepDto {
  @ApiProperty({
    description: 'Sleep duration in minutes',
    example: 480,
    minimum: 1,
  })
  @IsInt()
  @Min(1)
  duration: number;

  @ApiProperty({
    description:
      'Sleep quality rating. Allowed values: "poor", "fair", "good", "excellent"',
    example: 'good',
    enum: ['poor', 'fair', 'good', 'excellent'],
  })
  @IsIn(['poor', 'fair', 'good', 'excellent'])
  quality: string;

  @ApiProperty({
    description: 'Date of the sleep log (YYYY-MM-DD)',
    example: '2026-03-16',
  })
  @IsDateString()
  date: string;
}
