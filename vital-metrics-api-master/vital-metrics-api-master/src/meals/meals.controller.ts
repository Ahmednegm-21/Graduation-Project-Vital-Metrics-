import {
  Controller,
  Get,
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
import { MealsService } from './meals.service';
import { MealResponseDto } from './dto/meal-response.dto';
import { JwtAuthGuard } from '../auth/guard';
import { SearchPaginationQueryDto } from '../common/dto/search-pagination-query.dto';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Meals')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('meals')
export class MealsController {
  constructor(private readonly mealsService: MealsService) {}

  @Get()
  @ApiOperation({
    summary: 'Get all catalog meals',
    description: 'Returns the full shared meal catalog available to all users.',
  })
  @ApiResponse({ status: 200, description: 'List of catalog meals', type: [MealResponseDto] })
  findAll(@Query() query: SearchPaginationQueryDto) {
    return this.mealsService.findAll(query.page, query.limit, query.search);
  }

  @Get(':id/swap')
  @ApiOperation({
    summary: 'Get meal swap suggestions based on user goal',
    description:
      'Returns up to 5 alternative meals for the given meal. ' +
      'For "lose" goals: lower-calorie meals sorted by highest protein. ' +
      'For "gain" goals: higher-calorie meals sorted by highest calories & protein. ' +
      'If no goal is set: meals within ±10% of the original calories.',
  })
  @ApiResponse({
    status: 200,
    description: 'Swap suggestions returned successfully',
    type: [MealResponseDto],
  })
  @ApiResponse({ status: 404, description: 'Meal not found' })
  swapMeal(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser('user_id') userId: number,
  ) {
    return this.mealsService.swapMeal(id, userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a single meal by id' })
  @ApiResponse({ status: 200, description: 'Meal details', type: MealResponseDto })
  @ApiResponse({ status: 404, description: 'Meal not found' })
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.mealsService.findOne(id);
  }
}
