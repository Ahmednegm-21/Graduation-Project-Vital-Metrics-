import { ApiProperty } from '@nestjs/swagger';
import { IsInt, Min } from 'class-validator';

export class UpdateStepsDto {
  @ApiProperty({
    description: 'Total steps logged for the day (from phone/watch)',
    example: 8500,
    minimum: 0,
  })
  @IsInt()
  @Min(0)
  total_steps: number;
}
