import {
  Controller,
  Get,
  Delete,
  Post,
  Put,
  Param,
  Body,
  Query,
  ParseIntPipe,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
  ApiParam,
} from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { AdminOverviewResponseDto } from './dto/admin-overview-response.dto';
import { SearchPaginationQueryDto } from '../common/dto/search-pagination-query.dto';
import { CreateMealDto } from '../meals/dto/create-meal.dto';
import { UpdateMealDto } from '../meals/dto/update-meal.dto';
import { MealResponseDto } from '../meals/dto/meal-response.dto';
import { UserResponseDto } from '../users/dtos/user-response.dto';
import { JwtAuthGuard, AdminGuard } from '../auth/guard';

@ApiTags('Admin')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  // ─── Users ──────────────────────────────────────────────────────────────

  @Get('users')
  @ApiOperation({
    summary: 'List all users (paginated)',
    description:
      'Returns a paginated list of all registered users. Admin only.',
  })
  @ApiResponse({ status: 200, description: 'Paginated user list', type: [UserResponseDto] })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – admin access required' })
  getUsers(@Query() query: SearchPaginationQueryDto) {
    return this.adminService.getUsers(query.page ?? 1, query.limit ?? 20, query.search);
  }

  @Delete('users/:id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Delete a user',
    description:
      'Permanently deletes a user account. Cannot delete admin accounts or yourself.',
  })
  @ApiParam({ name: 'id', description: 'User ID to delete', type: Number })
  @ApiResponse({
    status: 200,
    description: 'User deleted successfully',
    schema: { example: { message: 'User deleted successfully' } },
  })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'User not found' })
  deleteUser(@Param('id', ParseIntPipe) id: number, @Request() req) {
    return this.adminService.deleteUser(id, req.user.user_id);
  }

  // ─── Platform Metrics Overview ─────────────────────────────────────────

  @Get('metrics/overview')
  @ApiOperation({
    summary: 'Platform-wide metrics overview',
    description:
      'Returns aggregated counts of users, goals, meals, and daily metrics records.',
  })
  @ApiResponse({ status: 200, description: 'Overview stats returned', type: AdminOverviewResponseDto })
  getMetricsOverview() {
    return this.adminService.getMetricsOverview();
  }

  // ─── Meal Catalog Management ───────────────────────────────────────────

  @Post('meals')
  @ApiOperation({
    summary: 'Add a meal to the catalog',
    description: 'Creates a new shared meal entry in the global catalog.',
  })
  @ApiResponse({ status: 201, description: 'Meal created', type: MealResponseDto })
  createMeal(@Body() dto: CreateMealDto) {
    return this.adminService.createMeal(dto);
  }

  @Put('meals/:id')
  @ApiOperation({
    summary: 'Update a catalog meal',
    description: 'Updates an existing meal in the global catalog.',
  })
  @ApiParam({ name: 'id', description: 'Meal ID', type: Number })
  @ApiResponse({ status: 200, description: 'Meal updated', type: MealResponseDto })
  @ApiResponse({ status: 404, description: 'Meal not found' })
  updateMeal(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateMealDto,
  ) {
    return this.adminService.updateMeal(id, dto);
  }

  @Delete('meals/:id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Delete a catalog meal',
    description: 'Removes a meal from the global catalog.',
  })
  @ApiParam({ name: 'id', description: 'Meal ID', type: Number })
  @ApiResponse({
    status: 200,
    description: 'Meal deleted',
    schema: { example: { message: 'Meal deleted successfully' } },
  })
  @ApiResponse({ status: 404, description: 'Meal not found' })
  deleteMeal(@Param('id', ParseIntPipe) id: number) {
    return this.adminService.deleteMeal(id);
  }
}
