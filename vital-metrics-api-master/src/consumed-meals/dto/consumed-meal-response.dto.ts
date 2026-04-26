import { ApiProperty } from '@nestjs/swagger';

export class ConsumedMealResponseDto {
  @ApiProperty({ description: 'Consumed meal ID', example: 1 })
  consumed_id: number;

  @ApiProperty({ description: 'Number of servings', example: 2 })
  quantity: number;

  @ApiProperty({ description: 'Consumption timestamp', example: '2026-03-16T12:30:00.000Z' })
  consumed_at: Date;

  @ApiProperty({ description: 'Catalog meal ID', example: 1 })
  meal_id: number;

  @ApiProperty({ description: 'Associated daily metrics ID', example: 1 })
  metrics_id: number;
}
