import { ApiProperty } from '@nestjs/swagger';

export class DailyMetricResponseDto {
  @ApiProperty({ description: 'Daily metric ID', example: 1 })
  metrics_id: number;

  @ApiProperty({ description: 'Date (YYYY-MM-DD)', example: '2026-03-16' })
  date: string;

  @ApiProperty({ description: 'Total steps logged', example: 8500 })
  total_steps: number;

  @ApiProperty({ description: 'Calories consumed', example: 1800 })
  calories_consumed: number;

  @ApiProperty({ description: 'Total calories burned from activities', example: 300 })
  burned_total: number;

  @ApiProperty({ description: 'Total water intake in milliliters', example: 2000 })
  total_water_ml: number;

  @ApiProperty({ description: 'Total sleep in minutes', example: 480 })
  total_sleep_minutes: number;

  @ApiProperty({ description: 'User ID', example: 1 })
  user_id: number;
}
