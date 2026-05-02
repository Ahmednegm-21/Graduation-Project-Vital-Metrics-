import { Controller, Get, Patch, Body, Request, UseGuards } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { UsersService } from './users.service';
import { UserResponseDto, UpdateProfileDto } from './dtos';
import { ErrorResponseDto } from '../auth/dto';
import { JwtAuthGuard } from 'src/auth/guard';
import { plainToInstance } from 'class-transformer';
import { GoalsService } from '../goals/goals.service';

@ApiTags('Users')
@ApiBearerAuth('JWT-auth')
@Controller('users')
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
    private readonly goalsService: GoalsService,
  ) {}

  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Get user profile',
    description: 'Retrieves the profile information of the authenticated user.',
  })
  @ApiResponse({
    status: 200,
    description: 'User profile retrieved successfully',
    type: UserResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid or missing JWT token',
    type: ErrorResponseDto,
  })
  @Get('profile')
  async getProfile(@Request() request) {
    const user = await this.usersService.findById(request.user.user_id);
    return plainToInstance(UserResponseDto, user);
  }

  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Update user profile',
    description:
      'Updates the profile information of the authenticated user. All fields are optional.',
  })
  @ApiResponse({
    status: 200,
    description: 'User profile updated successfully',
    type: UserResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid or missing JWT token',
    type: ErrorResponseDto,
  })
  @Patch('profile')
  async updateProfile(@Request() request, @Body() dto: UpdateProfileDto) {
    const userId = request.user.user_id;
    const user = await this.usersService.updateProfile(userId, dto);

    // Auto-recalculate goal when weight changes
    if (dto.weight !== undefined) {
      try {
        await this.goalsService.update(userId, {});
      } catch {
        // No goal exists - nothing to recalculate
      }
    }

    return plainToInstance(UserResponseDto, user);
  }
}
