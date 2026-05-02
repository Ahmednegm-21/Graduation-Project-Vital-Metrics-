import {
  Controller,
  Get,
  Patch,
  Delete,
  Param,
  Query,
  ParseIntPipe,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
} from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { NotificationQueryDto, NotificationResponseDto } from './dto';
import { JwtAuthGuard } from '../auth/guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Notifications')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: "List user's notifications (paginated)" })
  @ApiResponse({
    status: 200,
    description: 'List of notifications',
    type: [NotificationResponseDto],
  })
  async getNotifications(
    @CurrentUser('user_id') userId: number,
    @Query() query: NotificationQueryDto,
  ) {
    return this.notificationsService.getUserNotifications(userId, query);
  }

  @Get('unread-count')
  @ApiOperation({ summary: 'Get unread notification count' })
  @ApiResponse({
    status: 200,
    description: 'Unread notification count',
    schema: { example: { count: 5 } },
  })
  async getUnreadCount(@CurrentUser('user_id') userId: number) {
    const count = await this.notificationsService.getUnreadCount(userId);
    return { count };
  }

  @Patch(':id/read')
  @ApiOperation({ summary: 'Mark a notification as read' })
  @ApiResponse({
    status: 200,
    description: 'Notification marked as read',
    type: NotificationResponseDto,
  })
  async markAsRead(
    @CurrentUser('user_id') userId: number,
    @Param('id', ParseIntPipe) notificationId: number,
  ) {
    return this.notificationsService.markAsRead(notificationId, userId);
  }

  @Patch('read-all')
  @ApiOperation({ summary: 'Mark all notifications as read' })
  @ApiResponse({
    status: 200,
    description: 'All notifications marked as read',
    schema: { example: { updated: 10 } },
  })
  async markAllAsRead(@CurrentUser('user_id') userId: number) {
    const updated = await this.notificationsService.markAllAsRead(userId);
    return { updated };
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a notification' })
  @ApiResponse({
    status: 200,
    description: 'Notification deleted',
    schema: { example: { success: true } },
  })
  async deleteNotification(
    @CurrentUser('user_id') userId: number,
    @Param('id', ParseIntPipe) notificationId: number,
  ) {
    const success = await this.notificationsService.deleteNotification(
      notificationId,
      userId,
    );
    return { success };
  }

  @Delete()
  @ApiOperation({ summary: 'Clear all notifications' })
  @ApiResponse({
    status: 200,
    description: 'All notifications cleared',
    schema: { example: { deleted: 20 } },
  })
  async clearAll(@CurrentUser('user_id') userId: number) {
    const deleted =
      await this.notificationsService.clearAllNotifications(userId);
    return { deleted };
  }
}
