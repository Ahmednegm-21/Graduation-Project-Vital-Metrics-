import { ApiProperty } from '@nestjs/swagger';
import { IsDateString, IsInt, Min } from 'class-validator';

export class CreateWaterIntakeDto {
  @ApiProperty({
    description: 'Amount of water in milliliters',
    example: 250,
    minimum: 1,
  })
  @IsInt()
  @Min(1)
  amount_ml: number;

  @ApiProperty({
    description: 'Date the water was consumed (YYYY-MM-DD)',
    example: '2026-03-16',
  })
  @IsDateString()
  date: string;
}
