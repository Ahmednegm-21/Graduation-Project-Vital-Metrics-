import { ApiProperty } from '@nestjs/swagger';

export class DeviceTokenResponseDto {
  @ApiProperty({ example: 1 })
  token_id: number;

  @ApiProperty({ example: 'fcm-device-token-string-here' })
  token: string;

  @ApiProperty({ example: 'ios', enum: ['ios', 'android'] })
  platform: 'ios' | 'android';

  @ApiProperty({ example: 'iPhone 15 Pro', nullable: true })
  device_name: string | null;

  @ApiProperty({ example: true })
  is_active: boolean;

  @ApiProperty({ example: '2026-02-13T10:30:00.000Z' })
  created_at: Date;

  @ApiProperty({ example: '2026-02-13T10:30:00.000Z' })
  updated_at: Date;

  @ApiProperty({ example: 1 })
  user_id: number;
}
