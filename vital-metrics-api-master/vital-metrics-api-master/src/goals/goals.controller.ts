import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Delete,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
} from '@nestjs/swagger';
import { GoalsService } from './goals.service';
import {
  CreateGoalDto,
  UpdateGoalDto,
  GoalResponseDto,
  GoalCalculationResultDto,
} from './dto';
import { JwtAuthGuard } from '../auth/guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Goals')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('goals')
export class GoalsController {
  constructor(private readonly goalsService: GoalsService) {}

  @Post()
  @ApiOperation({
    summary: 'Create a new weight goal',
    description:
      'Creates a goal with calculated daily calories and target date based on user data and weekly rate',
  })
  @ApiResponse({
    status: 201,
    description: 'Goal created successfully with calculation details',
    type: GoalCalculationResultDto,
  })
  @ApiResponse({
    status: 400,
    description:
      'Invalid goal parameters (e.g., wrong target weight for goal type)',
  })
  @ApiResponse({
    status: 409,
    description: 'User already has a goal',
  })
  create(
    @CurrentUser('user_id') userId: number,
    @Body() createGoalDto: CreateGoalDto,
  ) {
    return this.goalsService.create(userId, createGoalDto);
  }

  @Get()
  @ApiOperation({ summary: "Get current user's goal" })
  @ApiResponse({
    status: 200,
    description: "User's goal",
    type: GoalResponseDto,
  })
  @ApiResponse({
    status: 404,
    description: 'Goal not found for user',
  })
  findMine(@CurrentUser('user_id') userId: number) {
    return this.goalsService.findByUserId(userId);
  }


  @Patch()
  @ApiOperation({
    summary: "Update current user's goal",
    description:
      'Update goal parameters - daily calories and target date will be recalculated',
  })
  @ApiResponse({
    status: 200,
    description: 'Goal updated successfully with new calculation details',
    type: GoalCalculationResultDto,
  })
  @ApiResponse({
    status: 404,
    description: 'Goal not found for user',
  })
  update(
    @CurrentUser('user_id') userId: number,
    @Body() updateGoalDto: UpdateGoalDto,
  ) {
    return this.goalsService.update(userId, updateGoalDto);
  }

  @Delete()
  @ApiOperation({ summary: "Delete current user's goal" })
  @ApiResponse({
    status: 200,
    description: 'Goal deleted successfully',
    schema: { example: { message: 'Goal deleted successfully' } },
  })
  @ApiResponse({
    status: 404,
    description: 'Goal not found for user',
  })
  remove(@CurrentUser('user_id') userId: number) {
    return this.goalsService.remove(userId);
  }
}
