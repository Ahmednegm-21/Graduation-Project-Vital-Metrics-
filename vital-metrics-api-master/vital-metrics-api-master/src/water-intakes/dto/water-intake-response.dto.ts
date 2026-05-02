import { ApiProperty } from '@nestjs/swagger';

export class WaterIntakeResponseDto {
  @ApiProperty({ description: 'Water intake ID', example: 1 })
  water_id: number;

  @ApiProperty({ description: 'Amount in milliliters', example: 250 })
  amount_ml: number;

  @ApiProperty({ description: 'Intake timestamp', example: '2026-03-16T14:00:00.000Z' })
  time: Date;

  @ApiProperty({ description: 'Associated daily metrics ID', example: 1 })
  metrics_id: number;
}
