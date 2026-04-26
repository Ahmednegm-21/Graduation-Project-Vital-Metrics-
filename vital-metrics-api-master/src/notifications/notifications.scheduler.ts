import { Injectable, Logger, Inject, OnModuleInit } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { and, eq, gte, lt, sql } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.module';
import { DrizzleDB } from '../drizzle/types/drizzle';
import { activities, consumedMeals, dailyMetrics } from '../drizzle/schema';
import { NotificationsService } from './notifications.service';
import { NotificationPreferencesService } from '../notification-preferences/notification-preferences.service';
import { DeviceTokensService } from '../device-tokens/device-tokens.service';

@Injectable()
export class NotificationScheduler implements OnModuleInit {
  private readonly logger = new Logger(NotificationScheduler.name);

  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDB,
    private readonly notificationsService: NotificationsService,
    private readonly preferencesService: NotificationPreferencesService,
    private readonly deviceTokensService: DeviceTokensService,
  ) {}

  /**
   * Run all time-appropriate reminders once on startup so users
   * don't have to wait until the next cron slot after a deploy/restart.
   */
  async onModuleInit() {
    this.logger.log('Running startup notification check…');
    const hour = new Date().getHours();

    // Water reminder window: 8 AM – 10 PM
    if (hour >= 8 && hour <= 22) {
      await this.waterReminder();
    }

    // Meal reminders based on current hour
    if (hour >= 7 && hour <= 9) {
      await this.breakfastReminder();
    } else if (hour >= 11 && hour <= 13) {
      await this.lunchReminder();
    } else if (hour >= 17 && hour <= 19) {
      await this.dinnerReminder();
    }

    // Activity reminder window: around 2 PM
    if (hour >= 13 && hour <= 15) {
      await this.activityReminder();
    }

    // Sleep reminder window: around 9:30 PM
    if (hour >= 21 && hour <= 22) {
      await this.sleepReminder();
    }

    // Daily summary window: around 9 PM
    if (hour >= 20 && hour <= 21) {
      await this.dailySummary();
    }

    this.logger.log('Startup notification check complete');
  }

  /**
   * Water reminder - every 2 hours during daytime (8 AM to 10 PM)
   */
  @Cron('0 0 8-22/2 * * *')
  async waterReminder() {
    this.logger.log('Running water reminder job');

    try {
      const users = await this.preferencesService.getUsersWithPreference(
        'water_reminders',
        true,
      );

      const today = new Date().toISOString().split('T')[0];

      for (const user of users) {
        // Skip if in quiet hours
        if (this.preferencesService.isQuietHours(user)) {
          continue;
        }

        // Phase 2: Skip if user already met their daily water goal (2000ml)
        const todayMetric = await this.db.query.dailyMetrics.findFirst({
          where: and(
            eq(dailyMetrics.user_id, user.user_id),
            eq(dailyMetrics.date, today),
          ),
        });

        if (todayMetric && todayMetric.total_water_ml >= 2000) {
          this.logger.debug(
            `Skipping water reminder for user ${user.user_id} — already met 2000ml goal (${todayMetric.total_water_ml}ml)`,
          );
          continue;
        }

        await this.notificationsService.sendNotification(
          user.user_id,
          'Stay Hydrated 💧',
          "Don't forget to drink water! Log your intake to stay on track.",
          'water_reminder',
          { screen: 'water_intake' },
        );
      }

      this.logger.log(`Processed water reminders for ${users.length} users`);
    } catch (error) {
      this.logger.error('Failed to send water reminders', error);
    }
  }

  /**
   * Daily summary - every day at 9 PM
   */
  @Cron('0 0 21 * * *')
  async dailySummary() {
    this.logger.log('Running daily summary job');

    try {
      const users = await this.preferencesService.getUsersWithPreference(
        'daily_reminder',
        true,
      );

      for (const user of users) {
        // Skip if in quiet hours
        if (this.preferencesService.isQuietHours(user)) {
          continue;
        }

        await this.notificationsService.sendNotification(
          user.user_id,
          'Your Daily Summary 📊',
          "Check out your progress today! See how you're doing with your goals.",
          'daily_reminder',
          { screen: 'dashboard' },
        );
      }

      this.logger.log(`Sent daily summaries to ${users.length} users`);
    } catch (error) {
      this.logger.error('Failed to send daily summaries', error);
    }
  }

  /**
   * Meal reminder - breakfast at 8 AM
   */
  @Cron('0 0 8 * * *')
  async breakfastReminder() {
    this.logger.log('Running breakfast reminder job');
    await this.sendMealReminder('breakfast', 'Time for Breakfast 🍳');
  }

  /**
   * Meal reminder - lunch at 12 PM
   */
  @Cron('0 0 12 * * *')
  async lunchReminder() {
    this.logger.log('Running lunch reminder job');
    await this.sendMealReminder('lunch', 'Time for Lunch 🍽️');
  }

  /**
   * Meal reminder - dinner at 6 PM
   */
  @Cron('0 0 18 * * *')
  async dinnerReminder() {
    this.logger.log('Running dinner reminder job');
    await this.sendMealReminder('dinner', 'Time for Dinner 🍴');
  }

  /**
   * Helper method to send meal reminders.
   * Phase 2: Checks if the user already logged a consumed meal for today
   * around the relevant meal window before sending the reminder.
   */
  private async sendMealReminder(mealType: string, title: string) {
    try {
      const users = await this.preferencesService.getUsersWithPreference(
        'meal_reminders',
        true,
      );

      const today = new Date().toISOString().split('T')[0];

      for (const user of users) {
        // Skip if in quiet hours
        if (this.preferencesService.isQuietHours(user)) {
          continue;
        }

        // Phase 2: Check if the user already logged any consumed meal today
        const todayMetric = await this.db.query.dailyMetrics.findFirst({
          where: and(
            eq(dailyMetrics.user_id, user.user_id),
            eq(dailyMetrics.date, today),
          ),
        });

        if (todayMetric) {
          // Determine the time window for this meal type
          const { windowStart, windowEnd } = this.getMealWindow(mealType);

          const mealLogged = await this.db.query.consumedMeals.findFirst({
            where: and(
              eq(consumedMeals.metrics_id, todayMetric.metrics_id),
              gte(consumedMeals.consumed_at, windowStart),
              lt(consumedMeals.consumed_at, windowEnd),
            ),
          });

          if (mealLogged) {
            this.logger.debug(
              `Skipping ${mealType} reminder for user ${user.user_id} — meal already logged`,
            );
            continue;
          }
        }

        await this.notificationsService.sendNotification(
          user.user_id,
          title,
          `Don't forget to log your ${mealType}! Keep track of your nutrition.`,
          'meal_reminder',
          { screen: 'meals', meal_type: mealType },
        );
      }

      this.logger.log(`Processed ${mealType} reminders for ${users.length} users`);
    } catch (error) {
      this.logger.error(`Failed to send ${mealType} reminders`, error);
    }
  }

  /**
   * Get the time window for a given meal type.
   * Used to check if the user already logged a meal in this period today.
   */
  private getMealWindow(mealType: string): {
    windowStart: Date;
    windowEnd: Date;
  } {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    switch (mealType) {
      case 'breakfast':
        return {
          windowStart: new Date(today.getTime() + 5 * 60 * 60 * 1000), // 5 AM
          windowEnd: new Date(today.getTime() + 11 * 60 * 60 * 1000), // 11 AM
        };
      case 'lunch':
        return {
          windowStart: new Date(today.getTime() + 11 * 60 * 60 * 1000), // 11 AM
          windowEnd: new Date(today.getTime() + 15 * 60 * 60 * 1000), // 3 PM
        };
      case 'dinner':
        return {
          windowStart: new Date(today.getTime() + 17 * 60 * 60 * 1000), // 5 PM
          windowEnd: new Date(today.getTime() + 22 * 60 * 60 * 1000), // 10 PM
        };
      default:
        // Full day fallback
        return {
          windowStart: today,
          windowEnd: new Date(today.getTime() + 24 * 60 * 60 * 1000),
        };
    }
  }

  /**
   * Activity reminder - at 2 PM if no activity logged
   */
  @Cron('0 0 14 * * *')
  async activityReminder() {
    this.logger.log('Running activity reminder job');

    try {
      const users = await this.preferencesService.getUsersWithPreference(
        'activity_reminders',
        true,
      );

      for (const user of users) {
        // Skip if in quiet hours
        if (this.preferencesService.isQuietHours(user)) {
          continue;
        }

        const today = new Date().toISOString().split('T')[0];
        const todayMetric = await this.db.query.dailyMetrics.findFirst({
          where: and(
            eq(dailyMetrics.user_id, user.user_id),
            eq(dailyMetrics.date, today),
          ),
        });

        if (todayMetric) {
          const existingActivity = await this.db.query.activities.findFirst({
            where: eq(activities.metrics_id, todayMetric.metrics_id),
          });

          if (existingActivity) {
            continue;
          }
        }

        await this.notificationsService.sendNotification(
          user.user_id,
          'Get Moving! 🚶',
          'Time to get active! Take a walk or do some exercise.',
          'activity_reminder',
          { screen: 'activities' },
        );
      }

      this.logger.log(`Sent activity reminders to ${users.length} users`);
    } catch (error) {
      this.logger.error('Failed to send activity reminders', error);
    }
  }

  /**
   * Sleep reminder - at 9:30 PM (moved from 10 PM to avoid quiet hours boundary)
   */
  @Cron('0 30 21 * * *')
  async sleepReminder() {
    this.logger.log('Running sleep reminder job');

    try {
      const users = await this.preferencesService.getUsersWithPreference(
        'sleep_reminders',
        true,
      );

      for (const user of users) {
        // Skip if in quiet hours (though this is typically the start of quiet hours)
        if (this.preferencesService.isQuietHours(user)) {
          continue;
        }

        await this.notificationsService.sendNotification(
          user.user_id,
          'Time to Wind Down 🌙',
          "It's almost bedtime! Get ready for a good night's sleep.",
          'sleep_reminder',
          { screen: 'sleep' },
        );
      }

      this.logger.log(`Sent sleep reminders to ${users.length} users`);
    } catch (error) {
      this.logger.error('Failed to send sleep reminders', error);
    }
  }

  /**
   * Cleanup inactive device tokens - runs daily at 3 AM
   */
  @Cron('0 0 3 * * *')
  async cleanupInactiveTokens() {
    this.logger.log('Running inactive token cleanup job');

    try {
      const deleted = await this.deviceTokensService.cleanupInactiveTokens();
      this.logger.log(`Cleaned up ${deleted} inactive device tokens`);
    } catch (error) {
      this.logger.error('Failed to cleanup inactive tokens', error);
    }
  }
}
