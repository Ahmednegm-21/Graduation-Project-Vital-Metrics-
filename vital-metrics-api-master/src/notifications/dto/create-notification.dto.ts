import { ApiProperty } from '@nestjs/swagger';
import {
  IsEnum,
  IsNotEmpty,
  IsObject,
  IsOptional,
  IsString,
} from 'class-validator';
import { NotificationType } from '../../drizzle/schema';

export class CreateNotificationDto {
  @ApiProperty({
    description: 'Notification title',
    example: 'Goal Reached! 🎉',
  })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty({
    description: 'Notification message',
    example: "You've reached your daily calorie goal of 2000 kcal.",
  })
  @IsString()
  @IsNotEmpty()
  message: string;

  @ApiProperty({
    description: 'Notification type',
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
    example: 'goal_reached',
  })
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
  type: NotificationType;

  @ApiProperty({
    description: 'Additional data for deep linking (JSON object)',
    example: { screen: 'goals', goal_id: 5 },
    required: false,
  })
  @IsOptional()
  @IsObject()
  data?: Record<string, any>;
}
