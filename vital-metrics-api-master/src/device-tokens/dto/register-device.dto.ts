import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class RegisterDeviceDto {
  @ApiProperty({
    description: 'FCM device token',
    example: 'fcm-device-token-string',
  })
  @IsString()
  @IsNotEmpty()
  token: string;

  @ApiProperty({
    description: 'Device platform. Allowed values: "ios", "android"',
    enum: ['ios', 'android'],
    example: 'ios',
  })
  @IsEnum(['ios', 'android'])
  platform: 'ios' | 'android';

  @ApiProperty({
    description: 'Device name (optional)',
    example: 'iPhone 15 Pro',
    required: false,
  })
  @IsOptional()
  @IsString()
  device_name?: string;
}
