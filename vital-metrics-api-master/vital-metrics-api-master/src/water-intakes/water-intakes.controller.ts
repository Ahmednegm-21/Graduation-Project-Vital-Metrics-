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
import { WaterIntakesService } from './water-intakes.service';
import { CreateWaterIntakeDto } from './dto/create-water-intake.dto';
import { UpdateWaterIntakeDto } from './dto/update-water-intake.dto';
import { WaterIntakeResponseDto } from './dto/water-intake-response.dto';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import { JwtAuthGuard } from '../auth/guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Water Intakes')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('water-intakes')
export class WaterIntakesController {
  constructor(private readonly waterIntakesService: WaterIntakesService) {}

  @Post()
  @ApiOperation({ summary: 'Log a water intake' })
  @ApiResponse({ status: 201, description: 'Water intake logged', type: WaterIntakeResponseDto })
  create(
    @CurrentUser('user_id') userId: number,
    @Body() dto: CreateWaterIntakeDto,
  ) {
    return this.waterIntakesService.create(userId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all water intakes for the current user' })
  @ApiResponse({ status: 200, description: 'List of water intakes', type: [WaterIntakeResponseDto] })
  findAll(
    @CurrentUser('user_id') userId: number,
    @Query() query: PaginationQueryDto,
  ) {
    return this.waterIntakesService.findAll(userId, query.page, query.limit);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get one water intake by id' })
  @ApiResponse({ status: 200, description: 'Water intake details', type: WaterIntakeResponseDto })
  findOne(
    @CurrentUser('user_id') userId: number,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.waterIntakesService.findOne(userId, id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a water intake' })
  @ApiResponse({ status: 200, description: 'Water intake updated', type: WaterIntakeResponseDto })
  update(
    @CurrentUser('user_id') userId: number,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateWaterIntakeDto,
  ) {
    return this.waterIntakesService.update(userId, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a water intake' })
  @ApiResponse({ status: 200, description: 'Water intake deleted', type: WaterIntakeResponseDto })
  remove(
    @CurrentUser('user_id') userId: number,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.waterIntakesService.remove(userId, id);
  }
}
