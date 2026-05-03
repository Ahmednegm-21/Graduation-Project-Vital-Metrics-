import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsNumber, Min, Max } from 'class-validator';

export class CreateGoalDto {
  @ApiProperty({
    description:
      'Goal type: lose or gain weight. Allowed values: "lose", "gain"',
    example: 'lose',
    enum: ['lose', 'gain'],
  })
  @IsIn(['lose', 'gain'])
  type: 'lose' | 'gain';

  @ApiProperty({
    description: 'Target weight in kg',
    example: 70.5,
    minimum: 30,
    maximum: 150,
  })
  @IsNumber()
  @Min(30)
  @Max(150)
  target_weight: number;

  @ApiProperty({
    description:
      'Weekly weight change rate in kg (e.g., 0.5 means 0.5kg per week)',
    example: 0.5,
    minimum: 0.1,
    maximum: 1.5,
  })
  @IsNumber()
  @Min(0.1)
  @Max(1.5)
  weekly_rate: number;
}
