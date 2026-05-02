import { ApiProperty } from '@nestjs/swagger';

export class ActivityResponseDto {
  @ApiProperty({ description: 'Activity ID', example: 1 })
  activity_id: number;

  @ApiProperty({
    type: String,
    description: 'Activity type. Allowed values: "walk", "run"',
    example: 'walk',
    enum: ['walk', 'run'],
  })
  type: 'walk' | 'run';

  @ApiProperty({ description: 'Duration in minutes', example: 45 })
  duration: number;

  @ApiProperty({ description: 'Calories burned', example: 300 })
  calories_burned: number;

  @ApiProperty({ description: 'Associated daily metrics ID', example: 1 })
  metrics_id: number;
}
