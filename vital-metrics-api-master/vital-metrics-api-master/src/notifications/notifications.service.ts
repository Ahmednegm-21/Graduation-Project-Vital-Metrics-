import { Inject, Injectable, Logger } from '@nestjs/common';
import { eq, and, desc, gte, count } from 'drizzle-orm';
import * as admin from 'firebase-admin';
import { DRIZZLE } from '../drizzle/drizzle.module';
import { DrizzleDB } from '../drizzle/types/drizzle';
import {
  notifications,
  Notification,
  NotificationType,
} from '../drizzle/schema';
import { FirebaseService } from '../firebase/firebase.service';
import { DeviceTokensService } from '../device-tokens/device-tokens.service';
import { NotificationPreferencesService } from '../notification-preferences/notification-preferences.service';
import { NotificationQueryDto } from './dto';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDB,
    private readonly firebaseService: FirebaseService,
    private readonly deviceTokensService: DeviceTokensService,
    private readonly preferencesService: NotificationPreferencesService,
  ) {}

  /**
   * Send a notification to a user - creates DB record and sends push.
   * Includes deduplication: if a notification of the same type was recently
   * sent to this user (within the cooldown window), the request is silently
   * discarded to prevent spam.
   */
  async sendNotification(
    userId: number,
    title: string,
    message: string,
    type: NotificationType,
    data?: Record<string, string>,
  ): Promise<Notification | null> {
    // -- Deduplication: check cooldown window for this notification type --
    const cooldownMinutes = this.getCooldownMinutes(type);
    const cooldownThreshold = new Date(
      Date.now() - cooldownMinutes * 60 * 1000,
    );

    const recentDuplicate = await this.db.query.notifications.findFirst({
      where: and(
        eq(notifications.user_id, userId),
        eq(notifications.type, type),
        gte(notifications.time, cooldownThreshold),
      ),
    });

    if (recentDuplicate) {
      this.logger.debug(
        `Skipping ${type} notification for user ${userId} — duplicate within ${cooldownMinutes}min cooldown`,
      );
      return null;
    }

    // 1. Check user preferences
    const prefs = await this.preferencesService.getPreferences(userId);

    const shouldSendPush =
      prefs?.push_enabled &&
      this.preferencesService.isTypeEnabled(prefs, type) &&
      !this.preferencesService.isQuietHours(prefs);

    // 2. Store notification in DB
    const [notification] = await this.db
      .insert(notifications)
      .values({
        title,
        message,
        type,
        data: data ? JSON.stringify(data) : null,
        user_id: userId,
      })
      .returning();

    // 3. Send push notification if enabled
    if (shouldSendPush) {
      try {
        await this.sendPushToUser(
          userId,
          notification.notification_id,
          title,
          message,
          data,
        );
      } catch (error) {
        this.logger.error(
          `Failed to send push notification to user ${userId}`,
          error,
        );
      }
    } else {
      this.logger.debug(
        `Skipped push notification for user ${userId} - preferences or quiet hours`,
      );
    }

    return notification;
  }

  /**
   * Get cooldown period (in minutes) for each notification type.
   * Prevents sending duplicate notifications within this window.
   */
  private getCooldownMinutes(type: NotificationType): number {
    const cooldowns: Partial<Record<NotificationType, number>> = {
      water_reminder: 60,
      meal_reminder: 240, // 4 hours
      activity_reminder: 720, // 12 hours
      sleep_reminder: 720,
      daily_reminder: 720,
    };
    return cooldowns[type] ?? 30; // Default 30-minute cooldown
  }

  /**
   * Send push notification to user's devices via FCM
   */
  private async sendPushToUser(
    userId: number,
    notificationId: number,
    title: string,
    message: string,
    data?: Record<string, string>,
  ): Promise<void> {
    // Get active device tokens
    const deviceTokens = await this.deviceTokensService.getActiveTokens(userId);

    if (deviceTokens.length === 0) {
      this.logger.debug(`No active device tokens for user ${userId}`);
      return;
    }

    const tokens = deviceTokens.map((dt) => dt.token);

    // Convert data values to strings (FCM requirement)
    const fcmData = data
      ? Object.entries(data).reduce(
          (acc, [key, value]) => ({
            ...acc,
            [key]: String(value),
          }),
          {},
        )
      : undefined;

    // Send push via FCM
    const response = await this.firebaseService.sendPushNotification(
      tokens,
      title,
      message,
      fcmData,
    );

    // Handle FCM response (deactivate stale tokens)
    await this.handleFcmResponse(response, deviceTokens);

    // Mark push as sent
    await this.db
      .update(notifications)
      .set({ push_sent: true, push_sent_at: new Date() })
      .where(eq(notifications.notification_id, notificationId));

    this.logger.log(
      `Push notification sent to ${tokens.length} devices for user ${userId}`,
    );
  }

  /**
   * Handle FCM response and deactivate invalid tokens
   */
  private async handleFcmResponse(
    response: admin.messaging.BatchResponse,
    deviceTokens: any[],
  ) {
    const staleTokenIds: number[] = [];

    response.responses.forEach((res, idx) => {
      if (res.error) {
        const errorCode = res.error.code;
        if (
          errorCode === 'messaging/registration-token-not-registered' ||
          errorCode === 'messaging/invalid-registration-token'
        ) {
          staleTokenIds.push(deviceTokens[idx].token_id);
          this.logger.warn(
            `Stale token detected: ${deviceTokens[idx].token} - ${errorCode}`,
          );
        }
      }
    });

    if (staleTokenIds.length > 0) {
      await this.deviceTokensService.deactivateTokens(staleTokenIds);
      this.logger.log(`Deactivated ${staleTokenIds.length} stale tokens`);
    }
  }

  /**
   * Get user's notifications with pagination and filtering
   */
  async getUserNotifications(
    userId: number,
    query: NotificationQueryDto,
  ): Promise<{
    data: Notification[];
    total: number;
    page: number;
    limit: number;
  }> {
    const { page = 1, limit = 20, type, unread_only = false } = query;
    const offset = (page - 1) * limit;

    // Build where conditions
    const conditions = [eq(notifications.user_id, userId)];
    if (type) {
      conditions.push(eq(notifications.type, type));
    }
    if (unread_only) {
      conditions.push(eq(notifications.is_read, false));
    }

    // Get notifications
    const data = await this.db.query.notifications.findMany({
      where: and(...conditions),
      orderBy: [desc(notifications.time)],
      limit,
      offset,
    });

    // Get total count
    const [{ value: total }] = await this.db
      .select({ value: count() })
      .from(notifications)
      .where(and(...conditions));

    return { data, total, page, limit };
  }

  /**
   * Get unread notification count
   */
  async getUnreadCount(userId: number): Promise<number> {
    const [{ value }] = await this.db
      .select({ value: count() })
      .from(notifications)
      .where(
        and(
          eq(notifications.user_id, userId),
          eq(notifications.is_read, false),
        ),
      );
    return value;
  }

  /**
   * Mark a notification as read
   */
  async markAsRead(
    notificationId: number,
    userId: number,
  ): Promise<Notification | null> {
    const [updated] = await this.db
      .update(notifications)
      .set({ is_read: true })
      .where(
        and(
          eq(notifications.notification_id, notificationId),
          eq(notifications.user_id, userId),
        ),
      )
      .returning();

    return updated || null;
  }

  /**
   * Mark all notifications as read
   */
  async markAllAsRead(userId: number): Promise<number> {
    const result = await this.db
      .update(notifications)
      .set({ is_read: true })
      .where(
        and(
          eq(notifications.user_id, userId),
          eq(notifications.is_read, false),
        ),
      )
      .returning();

    this.logger.log(
      `Marked ${result.length} notifications as read for user ${userId}`,
    );
    return result.length;
  }

  /**
   * Delete a notification
   */
  async deleteNotification(
    notificationId: number,
    userId: number,
  ): Promise<boolean> {
    const result = await this.db
      .delete(notifications)
      .where(
        and(
          eq(notifications.notification_id, notificationId),
          eq(notifications.user_id, userId),
        ),
      )
      .returning();

    return result.length > 0;
  }

  /**
   * Clear all notifications for a user
   */
  async clearAllNotifications(userId: number): Promise<number> {
    const result = await this.db
      .delete(notifications)
      .where(eq(notifications.user_id, userId))
      .returning();

    this.logger.log(
      `Cleared ${result.length} notifications for user ${userId}`,
    );
    return result.length;
  }
}
