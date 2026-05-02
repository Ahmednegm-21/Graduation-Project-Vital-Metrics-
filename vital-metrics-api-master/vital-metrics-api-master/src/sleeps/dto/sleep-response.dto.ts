import { ApiProperty } from '@nestjs/swagger';

export class SleepResponseDto {
  @ApiProperty({ description: 'Sleep log ID', example: 1 })
  sleep_id: number;

  @ApiProperty({ description: 'Sleep duration in minutes', example: 480 })
  duration: number;

  @ApiProperty({
    description:
      'Sleep quality rating. Allowed values: "poor", "fair", "good", "excellent"',
    example: 'good',
    enum: ['poor', 'fair', 'good', 'excellent'],
  })
  quality: string;

  @ApiProperty({ description: 'Associated daily metrics ID', example: 1 })
  metrics_id: number;
}
