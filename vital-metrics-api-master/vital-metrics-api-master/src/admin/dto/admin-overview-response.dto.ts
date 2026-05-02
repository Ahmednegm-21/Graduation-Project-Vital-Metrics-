import { ApiProperty } from '@nestjs/swagger';

export class AdminOverviewResponseDto {
  @ApiProperty({ description: 'Total registered users', example: 150 })
  totalUsers: number;

  @ApiProperty({ description: 'Total goals created', example: 85 })
  totalGoals: number;

  @ApiProperty({ description: 'Total meals in catalog', example: 45 })
  totalMeals: number;

  @ApiProperty({ description: 'Total daily metric records', example: 1200 })
  totalDailyMetrics: number;
}
