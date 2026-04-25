import { ApiProperty } from '@nestjs/swagger';
import { NotificationType } from '../../drizzle/schema';

export class NotificationResponseDto {
  @ApiProperty({ example: 1 })
  notification_id: number;

  @ApiProperty({ example: 'Goal Reached! 🎉' })
  title: string;

  @ApiProperty({
    example: "You've reached your daily calorie goal of 2000 kcal.",
  })
  message: string;

  @ApiProperty({
    example: 'goal_reached',
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
  })
  type: NotificationType;

  @ApiProperty({
    example: '{"screen":"goals","goal_id":5}',
    nullable: true,
  })
  data: string | null;

  @ApiProperty({ example: '2026-02-13T10:30:00.000Z' })
  time: Date;

  @ApiProperty({ example: false })
  is_read: boolean;

  @ApiProperty({ example: true })
  push_sent: boolean;

  @ApiProperty({ example: '2026-02-13T10:30:05.000Z', nullable: true })
  push_sent_at: Date | null;

  @ApiProperty({ example: 1 })
  user_id: number;
}
