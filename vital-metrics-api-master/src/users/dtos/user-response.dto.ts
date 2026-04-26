import { ApiProperty } from '@nestjs/swagger';
import { Exclude } from 'class-transformer';

export class UserResponseDto {
  @ApiProperty({
    description: 'Unique user identifier',
    example: 1,
  })
  user_id: number;

  @ApiProperty({
    description: 'User full name',
    example: 'John Doe',
  })
  name: string;

  @ApiProperty({
    description: 'User email address',
    example: 'john.doe@example.com',
  })
  email: string;

  @ApiProperty({
    description: 'User biological gender. Allowed values: "male", "female"',
    example: 'male',
    enum: ['male', 'female'],
  })
  gender: string;

  @ApiProperty({
    description: 'User date of birth',
    example: '1990-05-15',
  })
  date_of_birth: string;

  @ApiProperty({
    description: 'User height in centimeters',
    example: 175,
  })
  height: number;

  @ApiProperty({
    description: 'User weight in kilograms',
    example: 70.5,
  })
  weight: number;

  @ApiProperty({
    description: 'Indicates if the user has administrative privileges',
    example: false,
  })
  is_admin: boolean;

  @Exclude()
  password: string;

  @Exclude()
  refresh_token: string;
}
