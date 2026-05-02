import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from 'class-validator';

export class CreateMealDto {
  @ApiProperty({ description: 'Meal name', example: 'Grilled Chicken Salad' })
  @IsString()
  name: string;

  @ApiPropertyOptional({
    description: 'Optional meal description',
    example: 'Chicken breast with greens and olive oil dressing',
  })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @ApiProperty({
    description: 'Total calories in this meal',
    example: 450,
    minimum: 0,
  })
  @IsInt()
  @Min(0)
  calories: number;

  @ApiProperty({
    description: 'Protein in grams',
    example: 35.5,
    minimum: 0,
  })
  @IsNumber()
  @Min(0)
  protein: number;

  @ApiProperty({
    description: 'Carbs in grams',
    example: 20.0,
    minimum: 0,
  })
  @IsNumber()
  @Min(0)
  carbs: number;

  @ApiProperty({
    description: 'Fat in grams',
    example: 15.0,
    minimum: 0,
  })
  @IsNumber()
  @Min(0)
  fat: number;
}
