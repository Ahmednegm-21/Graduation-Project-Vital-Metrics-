import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { NotificationsService } from './notifications.service';
import { NotificationPreferencesService } from '../notification-preferences/notification-preferences.service';
import { DeviceTokensService } from '../device-tokens/device-tokens.service';

@Injectable()
export class NotificationScheduler {
  private readonly logger = new Logger(NotificationScheduler.name);

  constructor(
    private readonly notificationsService: NotificationsService,
    private readonly preferencesService: NotificationPreferencesService,
    private readonly deviceTokensService: DeviceTokensService,
  ) {}

  /**
   * Water reminder - every 2 hours during daytime (8 AM to 10 PM)
   */
  @Cron('0 */2 8-22 * * *')
  async waterReminder() {
    this.logger.log('Running water reminder job');

    try {
      const users = await this.preferencesService.getUsersWithPreference(
        'water_reminders',
        true,
      );

      for (const user of users) {
        // Skip if in quiet hours
        if (this.preferencesService.isQuietHours(user)) {
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

      this.logger.log(`Sent water reminders to ${users.length} users`);
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
   * Helper method to send meal reminders
   */
  private async sendMealReminder(mealType: string, title: string) {
    try {
      const users = await this.preferencesService.getUsersWithPreference(
        'meal_reminders',
        true,
      );

      for (const user of users) {
        // Skip if in quiet hours
        if (this.preferencesService.isQuietHours(user)) {
          continue;
        }

        await this.notificationsService.sendNotification(
          user.user_id,
          title,
          `Don't forget to log your ${mealType}! Keep track of your nutrition.`,
          'meal_reminder',
          { screen: 'meals', meal_type: mealType },
        );
      }

      this.logger.log(`Sent ${mealType} reminders to ${users.length} users`);
    } catch (error) {
      this.logger.error(`Failed to send ${mealType} reminders`, error);
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

        // TODO: Check if user has logged activity today before sending
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
   * Sleep reminder - at 10 PM
   */
  @Cron('0 0 22 * * *')
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
