import { ApiProperty } from '@nestjs/swagger';

export class PreferencesResponseDto {
  @ApiProperty({ example: 1 })
  preference_id: number;

  @ApiProperty({ example: true })
  push_enabled: boolean;

  @ApiProperty({ example: true })
  daily_reminder: boolean;

  @ApiProperty({ example: true })
  goal_alerts: boolean;

  @ApiProperty({ example: true })
  water_reminders: boolean;

  @ApiProperty({ example: true })
  meal_reminders: boolean;

  @ApiProperty({ example: true })
  activity_reminders: boolean;

  @ApiProperty({ example: true })
  sleep_reminders: boolean;

  @ApiProperty({ example: '22:00', nullable: true })
  quiet_hours_start: string | null;

  @ApiProperty({ example: '07:00', nullable: true })
  quiet_hours_end: string | null;

  @ApiProperty({ example: 1 })
  user_id: number;
}
