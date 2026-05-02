import { ApiProperty } from '@nestjs/swagger';

export class GoalResponseDto {
  @ApiProperty({ description: 'Goal ID', example: 1 })
  goal_id: number;

  @ApiProperty({
    description:
      'Goal type: lose or gain weight. Allowed values: "lose", "gain"',
    example: 'lose',
    enum: ['lose', 'gain'],
  })
  type: 'lose' | 'gain';

  @ApiProperty({ description: 'Target weight in kg', example: 70.5 })
  target_weight: number;

  @ApiProperty({
    description: 'Weekly rate of weight change in kg',
    example: 0.5,
  })
  weekly_rate: number;

  @ApiProperty({
    description: 'Calculated daily calorie intake to reach goal',
    example: 1800,
  })
  daily_calories: number;

  @ApiProperty({
    description: 'Estimated date to reach target weight',
    example: '2026-06-15',
  })
  target_date: string;

  @ApiProperty({ description: 'Goal creation date', example: '2026-03-12' })
  created_at: Date;

  @ApiProperty({ description: 'User ID', example: 1 })
  user_id: number;
}

export class GoalCalculationResultDto {
  @ApiProperty({
    description: 'Goal type. Allowed values: "lose", "gain"',
    example: 'lose',
    enum: ['lose', 'gain'],
  })
  type: 'lose' | 'gain';

  @ApiProperty({ description: 'Current weight in kg', example: 80 })
  current_weight: number;

  @ApiProperty({ description: 'Target weight in kg', example: 70 })
  target_weight: number;

  @ApiProperty({ description: 'Weight to change in kg', example: 10 })
  weight_to_change: number;

  @ApiProperty({ description: 'Weekly rate in kg', example: 0.5 })
  weekly_rate: number;

  @ApiProperty({
    description: 'Estimated weeks to reach goal',
    example: 20,
  })
  estimated_weeks: number;

  @ApiProperty({
    description: 'Estimated date to reach goal',
    example: '2026-08-01',
  })
  target_date: string;

  @ApiProperty({
    description: 'Base Metabolic Rate (BMR)',
    example: 1800,
  })
  bmr: number;

  @ApiProperty({
    description: 'Total Daily Energy Expenditure (TDEE)',
    example: 2160,
  })
  tdee: number;

  @ApiProperty({
    description: 'Daily calorie adjustment for goal',
    example: -550,
  })
  daily_calorie_adjustment: number;

  @ApiProperty({
    description: 'Recommended daily calorie intake',
    example: 1610,
  })
  daily_calories: number;
}
