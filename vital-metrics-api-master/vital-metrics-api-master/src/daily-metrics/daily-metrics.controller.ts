import {
  Controller,
  Get,
  Patch,
  Body,
  Param,
  ParseIntPipe,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
} from '@nestjs/swagger';
import { DailyMetricsService } from './daily-metrics.service';
import { UpdateStepsDto } from './dto/update-steps.dto';
import { DailyMetricResponseDto } from './dto/daily-metric-response.dto';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import { JwtAuthGuard } from '../auth/guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Daily Metrics')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('daily-metrics')
export class DailyMetricsController {
  constructor(private readonly dailyMetricsService: DailyMetricsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all daily metrics for the current user' })
  @ApiResponse({ status: 200, description: 'List of daily metrics', type: [DailyMetricResponseDto] })
  findAll(
    @CurrentUser('user_id') userId: number,
    @Query() query: PaginationQueryDto,
  ) {
    return this.dailyMetricsService.findAll(userId, query.page, query.limit);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get one daily metric by id' })
  @ApiResponse({ status: 200, description: 'Daily metric details', type: DailyMetricResponseDto })
  findOne(
    @CurrentUser('user_id') userId: number,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.dailyMetricsService.findOne(userId, id);
  }

  @Patch(':id/steps')
  @ApiOperation({
    summary: 'Update total steps for a daily metric',
    description:
      'Set total_steps from an external source (phone, watch, step-counter API).',
  })
  @ApiResponse({ status: 200, description: 'Steps updated', type: DailyMetricResponseDto })
  updateSteps(
    @CurrentUser('user_id') userId: number,
    @Param('id', ParseIntPipe) id: number,
    @Body() updateStepsDto: UpdateStepsDto,
  ) {
    return this.dailyMetricsService.updateSteps(
      userId,
      id,
      updateStepsDto.total_steps,
    );
  }
}
