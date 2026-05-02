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
import { SleepsService } from './sleeps.service';
import { CreateSleepDto } from './dto/create-sleep.dto';
import { UpdateSleepDto } from './dto/update-sleep.dto';
import { SleepResponseDto } from './dto/sleep-response.dto';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import { JwtAuthGuard } from '../auth/guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Sleeps')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('sleeps')
export class SleepsController {
  constructor(private readonly sleepsService: SleepsService) {}

  @Post()
  @ApiOperation({ summary: 'Log a sleep session' })
  @ApiResponse({ status: 201, description: 'Sleep log created', type: SleepResponseDto })
  create(
    @CurrentUser('user_id') userId: number,
    @Body() dto: CreateSleepDto,
  ) {
    return this.sleepsService.create(userId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all sleep logs for the current user' })
  @ApiResponse({ status: 200, description: 'List of sleep logs', type: [SleepResponseDto] })
  findAll(
    @CurrentUser('user_id') userId: number,
    @Query() query: PaginationQueryDto,
  ) {
    return this.sleepsService.findAll(userId, query.page, query.limit);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get one sleep log by id' })
  @ApiResponse({ status: 200, description: 'Sleep log details', type: SleepResponseDto })
  findOne(
    @CurrentUser('user_id') userId: number,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.sleepsService.findOne(userId, id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a sleep log' })
  @ApiResponse({ status: 200, description: 'Sleep log updated', type: SleepResponseDto })
  update(
    @CurrentUser('user_id') userId: number,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateSleepDto,
  ) {
    return this.sleepsService.update(userId, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a sleep log' })
  @ApiResponse({ status: 200, description: 'Sleep log deleted', type: SleepResponseDto })
  remove(
    @CurrentUser('user_id') userId: number,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.sleepsService.remove(userId, id);
  }
}
