import { ApiProperty } from '@nestjs/swagger';
import { Type, Transform } from 'class-transformer';
import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  Max,
  Min,
} from 'class-validator';
import { NotificationType } from '../../drizzle/schema';

export class NotificationQueryDto {
  @ApiProperty({
    description: 'Page number',
    example: 1,
    required: false,
    default: 1,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiProperty({
    description: 'Items per page',
    example: 20,
    required: false,
    default: 20,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number = 20;

  @ApiProperty({
    description:
      'Filter by notification type. Allowed values: "goal_reached", "daily_reminder", "water_reminder", "meal_reminder", "activity_reminder", "sleep_reminder", "streak_milestone", "weight_update", "system", "custom"',
    enum: [
      'goal_reached',
      'daily_reminder',
      'water_reminder',
      'meal_reminder',
      'activity_reminder',
      'sleep_reminder',
      'streak_milestone',
      'weight_update',
      'system',
      'custom',
    ],
    required: false,
  })
  @IsOptional()
  @IsEnum([
    'goal_reached',
    'daily_reminder',
    'water_reminder',
    'meal_reminder',
    'activity_reminder',
    'sleep_reminder',
    'streak_milestone',
    'weight_update',
    'system',
    'custom',
  ])
  type?: NotificationType;

  @ApiProperty({
    description: 'Show only unread notifications',
    example: false,
    required: false,
    default: false,
  })
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  unread_only?: boolean = false;
}
