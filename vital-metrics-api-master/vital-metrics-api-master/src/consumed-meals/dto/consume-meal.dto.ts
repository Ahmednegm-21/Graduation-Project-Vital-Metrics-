import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsDateString, IsInt, IsOptional, Min } from 'class-validator';

export class ConsumeMealDto {
  @ApiProperty({ description: 'Catalog meal id', example: 1 })
  @IsInt()
  @Min(1)
  meal_id: number;

  @ApiProperty({
    description: 'Date the meal was consumed (YYYY-MM-DD)',
    example: '2026-03-16',
  })
  @IsDateString()
  date: string;

  @ApiPropertyOptional({
    description: 'Number of servings consumed',
    example: 2,
    minimum: 1,
  })
  @IsOptional()
  @IsInt()
  @Min(1)
  quantity?: number;
}
