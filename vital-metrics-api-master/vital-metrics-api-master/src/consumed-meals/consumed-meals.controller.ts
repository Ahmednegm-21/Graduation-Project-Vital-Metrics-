import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guard';
import { ConsumedMealsService } from './consumed-meals.service';
import { ConsumeMealDto } from './dto/consume-meal.dto';
import { ConsumedMealResponseDto } from './dto/consumed-meal-response.dto';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';

@ApiTags('Consumed Meals')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('consumed-meals')
export class ConsumedMealsController {
  constructor(private readonly consumedMealsService: ConsumedMealsService) {}

  @Post()
  @ApiOperation({ summary: 'Consume a catalog meal' })
  @ApiResponse({ status: 201, description: 'Consumed meal created', type: ConsumedMealResponseDto })
  create(
    @CurrentUser('user_id') userId: number,
    @Body() consumeMealDto: ConsumeMealDto,
  ) {
    return this.consumedMealsService.create(userId, consumeMealDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all consumed meals for the current user' })
  @ApiResponse({ status: 200, description: 'List of consumed meals', type: [ConsumedMealResponseDto] })
  findAll(
    @CurrentUser('user_id') userId: number,
    @Query() query: PaginationQueryDto,
  ) {
    return this.consumedMealsService.findAll(userId, query.page, query.limit);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a consumed meal by id' })
  @ApiResponse({ status: 200, description: 'Consumed meal details', type: ConsumedMealResponseDto })
  findOne(
    @CurrentUser('user_id') userId: number,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.consumedMealsService.findOne(userId, id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a consumed meal' })
  @ApiResponse({ status: 200, description: 'Consumed meal deleted', type: ConsumedMealResponseDto })
  remove(
    @CurrentUser('user_id') userId: number,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.consumedMealsService.remove(userId, id);
  }
}
