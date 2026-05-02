import { ApiProperty } from '@nestjs/swagger';
import { IsDateString, IsIn, IsInt, Min } from 'class-validator';

export class CreateActivityDto {
  @ApiProperty({
    description: 'Date of the activity (YYYY-MM-DD)',
    example: '2026-03-16',
  })
  @IsDateString()
  date: string;

  @ApiProperty({
    type: String,
    description: 'Activity type. Allowed values: "walk", "run"',
    example: 'walk',
    enum: ['walk', 'run'],
  })
  @IsIn(['walk', 'run'])
  type: 'walk' | 'run';

  @ApiProperty({
    description: 'Duration in minutes',
    example: 45,
    minimum: 1,
  })
  @IsInt()
  @Min(1)
  duration: number;

  @ApiProperty({
    description:
      'Calories burned in this activity. Contributes to burned totals (not consumed calories).',
    example: 300,
    minimum: 0,
  })
  @IsInt()
  @Min(0)
  calories_burned: number;
}
