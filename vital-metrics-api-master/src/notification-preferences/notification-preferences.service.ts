import { Inject, Injectable, Logger } from '@nestjs/common';
import { eq } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.module';
import { DrizzleDB } from '../drizzle/types/drizzle';
import {
  notificationPreferences,
  NotificationPreference,
  NotificationType,
} from '../drizzle/schema';
import { UpdatePreferencesDto } from './dto';

@Injectable()
export class NotificationPreferencesService {
  private readonly logger = new Logger(NotificationPreferencesService.name);

  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDB) {}

  /**
   * Get user's notification preferences (creates default if not exists)
   */
  async getPreferences(userId: number): Promise<NotificationPreference> {
    let preferences = await this.db.query.notificationPreferences.findFirst({
      where: eq(notificationPreferences.user_id, userId),
    });

    // Create default preferences if they don't exist
    if (!preferences) {
      preferences = await this.createDefaultPreferences(userId);
    }

    return preferences;
  }

  /**
   * Update user's notification preferences
   */
  async updatePreferences(
    userId: number,
    dto: UpdatePreferencesDto,
  ): Promise<NotificationPreference> {
    // Ensure preferences exist
    await this.getPreferences(userId);

    const [updated] = await this.db
      .update(notificationPreferences)
      .set(dto)
      .where(eq(notificationPreferences.user_id, userId))
      .returning();

    this.logger.log(`Updated notification preferences for user ${userId}`);
    return updated;
  }

  /**
   * Create default preferences for a new user
   */
  async createDefaultPreferences(
    userId: number,
  ): Promise<NotificationPreference> {
    const [preferences] = await this.db
      .insert(notificationPreferences)
      .values({ user_id: userId })
      .returning();

    this.logger.log(
      `Created default notification preferences for user ${userId}`,
    );
    return preferences;
  }

  /**
   * Check if a specific notification type is enabled for a user
   */
  isTypeEnabled(
    preferences: NotificationPreference,
    type: NotificationType,
  ): boolean {
    const typeMapping: Record<NotificationType, keyof NotificationPreference> =
      {
        goal_reached: 'goal_alerts',
        daily_reminder: 'daily_reminder',
        water_reminder: 'water_reminders',
        meal_reminder: 'meal_reminders',
        activity_reminder: 'activity_reminders',
        sleep_reminder: 'sleep_reminders',
        streak_milestone: 'goal_alerts',
        weight_update: 'goal_alerts',
        system: 'push_enabled',
        custom: 'push_enabled',
      };

    const prefKey = typeMapping[type];
    return prefKey ? (preferences[prefKey] as boolean) : true;
  }

  /**
   * Check if current time is within user's quiet hours
   */
  isQuietHours(preferences: NotificationPreference): boolean {
    if (!preferences.quiet_hours_start || !preferences.quiet_hours_end) {
      return false;
    }

    const now = new Date();
    const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;

    const start = preferences.quiet_hours_start;
    const end = preferences.quiet_hours_end;

    // Handle quiet hours that span midnight (e.g., 22:00 to 07:00)
    if (start > end) {
      return currentTime > start || currentTime <= end;
    }

    // Normal quiet hours (e.g., 01:00 to 06:00)
    return currentTime > start && currentTime <= end;
  }

  /**
   * Get all users with a specific preference enabled (for scheduled notifications).
   * Filters at the database level for efficiency.
   */
  async getUsersWithPreference(
    preferenceKey: keyof NotificationPreference,
    value: boolean,
  ): Promise<NotificationPreference[]> {
    // Explicit mapping from preference keys to their Drizzle column references.
    // This avoids accessing non-column members on the table object.
    const columnMap: Partial<
      Record<keyof NotificationPreference, ReturnType<typeof eq> extends infer _ ? any : never>
    > = {
      push_enabled: notificationPreferences.push_enabled,
      daily_reminder: notificationPreferences.daily_reminder,
      goal_alerts: notificationPreferences.goal_alerts,
      water_reminders: notificationPreferences.water_reminders,
      meal_reminders: notificationPreferences.meal_reminders,
      activity_reminders: notificationPreferences.activity_reminders,
      sleep_reminders: notificationPreferences.sleep_reminders,
    };

    const column = columnMap[preferenceKey];
    if (!column) {
      this.logger.warn(
        `Invalid preference key for DB filter: ${String(preferenceKey)}, returning empty result`,
      );
      return [];
    }

    return this.db.query.notificationPreferences.findMany({
      where: eq(column, value),
    });
  }
}
