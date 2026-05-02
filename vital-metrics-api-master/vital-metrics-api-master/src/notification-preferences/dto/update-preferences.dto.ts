import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsOptional, IsString, Matches } from 'class-validator';

export class UpdatePreferencesDto {
  @ApiProperty({
    description: 'Enable/disable all push notifications',
    example: true,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  push_enabled?: boolean;

  @ApiProperty({
    description: 'Enable/disable daily reminder notifications',
    example: true,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  daily_reminder?: boolean;

  @ApiProperty({
    description: 'Enable/disable goal alert notifications',
    example: true,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  goal_alerts?: boolean;

  @ApiProperty({
    description: 'Enable/disable water reminder notifications',
    example: true,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  water_reminders?: boolean;

  @ApiProperty({
    description: 'Enable/disable meal reminder notifications',
    example: true,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  meal_reminders?: boolean;

  @ApiProperty({
    description: 'Enable/disable activity reminder notifications',
    example: true,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  activity_reminders?: boolean;

  @ApiProperty({
    description: 'Enable/disable sleep reminder notifications',
    example: true,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  sleep_reminders?: boolean;

  @ApiProperty({
    description: 'Quiet hours start time in HH:MM format',
    example: '22:00',
    required: false,
  })
  @IsOptional()
  @IsString()
  @Matches(/^\d{2}:\d{2}$/, {
    message: 'quiet_hours_start must be in HH:MM format',
  })
  quiet_hours_start?: string;

  @ApiProperty({
    description: 'Quiet hours end time in HH:MM format',
    example: '07:00',
    required: false,
  })
  @IsOptional()
  @IsString()
  @Matches(/^\d{2}:\d{2}$/, {
    message: 'quiet_hours_end must be in HH:MM format',
  })
  quiet_hours_end?: string;
}
