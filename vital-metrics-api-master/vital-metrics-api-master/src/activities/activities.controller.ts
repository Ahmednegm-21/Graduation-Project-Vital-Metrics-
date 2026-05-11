import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
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
import { ActivitiesService } from './activities.service';
import { CreateActivityDto } from './dto/create-activity.dto';
import { UpdateActivityDto } from './dto/update-activity.dto';
import { ActivityResponseDto } from './dto/activity-response.dto';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import { JwtAuthGuard } from '../auth/guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Activities')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('activities')
export class ActivitiesController {
  constructor(private readonly activitiesService: ActivitiesService) {}

  @Post()
  @ApiOperation({ summary: 'Create an activity for a daily metric' })
  @ApiResponse({ status: 201, description: 'Activity created', type: ActivityResponseDto })
  create(
    @CurrentUser('user_id') userId: number,
    @Body() createActivityDto: CreateActivityDto,
  ) {
    return this.activitiesService.create(userId, createActivityDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all activities for the current user' })
  @ApiResponse({ status: 200, description: 'List of activities', type: [ActivityResponseDto] })
  findAll(
    @CurrentUser('user_id') userId: number,
    @Query() query: PaginationQueryDto,
  ) {
    return this.activitiesService.findAll(userId, query.page, query.limit);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get one activity by id' })
  @ApiResponse({ status: 200, description: 'Activity details', type: ActivityResponseDto })
  findOne(
    @CurrentUser('user_id') userId: number,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.activitiesService.findOne(userId, id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update an activity' })
  @ApiResponse({ status: 200, description: 'Activity updated', type: ActivityResponseDto })
  update(
    @CurrentUser('user_id') userId: number,
    @Param('id', ParseIntPipe) id: number,
    @Body() updateActivityDto: UpdateActivityDto,
  ) {
    return this.activitiesService.update(userId, id, updateActivityDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete an activity' })
  @ApiResponse({ status: 200, description: 'Activity deleted', type: ActivityResponseDto })
  remove(
    @CurrentUser('user_id') userId: number,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.activitiesService.remove(userId, id);
  }
}
