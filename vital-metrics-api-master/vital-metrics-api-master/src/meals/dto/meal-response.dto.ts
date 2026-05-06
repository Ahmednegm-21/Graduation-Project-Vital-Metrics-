import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class MealResponseDto {
  @ApiProperty({ description: 'Meal ID', example: 1 })
  meal_id: number;

  @ApiProperty({ description: 'Meal name', example: 'Grilled Chicken Salad' })
  name: string;

  @ApiPropertyOptional({
    description: 'Meal description',
    example: 'Chicken breast with greens and olive oil dressing',
    nullable: true,
  })
  description: string | null;

  @ApiProperty({ description: 'Total calories', example: 450 })
  calories: number;

  @ApiProperty({ description: 'Protein in grams', example: '35.50' })
  protein: string;

  @ApiProperty({ description: 'Carbs in grams', example: '20.00' })
  carbs: string;

  @ApiProperty({ description: 'Fat in grams', example: '15.00' })
  fat: string;

  @ApiProperty({ description: 'Creation timestamp', example: '2026-03-16T10:00:00.000Z' })
  created_at: Date;

  @ApiProperty({ description: 'Last update timestamp', example: '2026-03-16T10:00:00.000Z' })
  updated_at: Date;
}
