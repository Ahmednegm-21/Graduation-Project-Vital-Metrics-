import {
  Controller,
  Post,
  Get,
  Delete,
  Patch,
  Body,
  Param,
  ParseIntPipe,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
} from '@nestjs/swagger';
import { DeviceTokensService } from './device-tokens.service';
import { RegisterDeviceDto, DeviceTokenResponseDto } from './dto';
import { JwtAuthGuard } from '../auth/guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Device Tokens')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('device-tokens')
export class DeviceTokensController {
  constructor(private readonly deviceTokensService: DeviceTokensService) {}

  @Post()
  @ApiOperation({ summary: 'Register a device token for push notifications' })
  @ApiResponse({
    status: 201,
    description: 'Device token registered successfully',
    type: DeviceTokenResponseDto,
  })
  async registerToken(
    @CurrentUser('user_id') userId: number,
    @Body() dto: RegisterDeviceDto,
  ) {
    return this.deviceTokensService.registerToken(userId, dto);
  }

  @Get()
  @ApiOperation({ summary: "List user's registered devices" })
  @ApiResponse({
    status: 200,
    description: 'List of registered device tokens',
    type: [DeviceTokenResponseDto],
  })
  async getUserTokens(@CurrentUser('user_id') userId: number) {
    return this.deviceTokensService.getUserTokens(userId);
  }

  @Patch(':tokenId/deactivate')
  @ApiOperation({ summary: 'Deactivate a device token' })
  @ApiResponse({
    status: 200,
    description: 'Device token deactivated successfully',
    type: DeviceTokenResponseDto,
  })
  async deactivateToken(
    @CurrentUser('user_id') userId: number,
    @Param('tokenId', ParseIntPipe) tokenId: number,
  ) {
    return this.deviceTokensService.deactivateToken(tokenId, userId);
  }

  @Delete(':tokenId')
  @ApiOperation({ summary: 'Remove a specific device token' })
  @ApiResponse({
    status: 200,
    description: 'Device token deleted successfully',
  })
  async deleteToken(
    @CurrentUser('user_id') userId: number,
    @Param('tokenId', ParseIntPipe) tokenId: number,
  ) {
    const deleted = await this.deviceTokensService.deleteToken(tokenId, userId);
    return { success: deleted };
  }
}
