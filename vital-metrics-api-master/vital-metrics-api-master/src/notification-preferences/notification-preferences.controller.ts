import { Controller, Get, Patch, Body, UseGuards } from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
} from '@nestjs/swagger';
import { NotificationPreferencesService } from './notification-preferences.service';
import { UpdatePreferencesDto, PreferencesResponseDto } from './dto';
import { JwtAuthGuard } from '../auth/guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Notification Preferences')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('notification-preferences')
export class NotificationPreferencesController {
  constructor(
    private readonly preferencesService: NotificationPreferencesService,
  ) {}

  @Get()
  @ApiOperation({ summary: "Get user's notification preferences" })
  @ApiResponse({
    status: 200,
    description: 'User notification preferences',
    type: PreferencesResponseDto,
  })
  async getPreferences(@CurrentUser('user_id') userId: number) {
    return this.preferencesService.getPreferences(userId);
  }

  @Patch()
  @ApiOperation({ summary: 'Update notification preferences' })
  @ApiResponse({
    status: 200,
    description: 'Preferences updated successfully',
    type: PreferencesResponseDto,
  })
  async updatePreferences(
    @CurrentUser('user_id') userId: number,
    @Body() dto: UpdatePreferencesDto,
  ) {
    return this.preferencesService.updatePreferences(userId, dto);
  }
}
