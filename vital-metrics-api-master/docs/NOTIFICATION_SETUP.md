# Notification System Setup Guide

## Overview

The notification system is now fully implemented! This guide will help you complete the setup and start sending push notifications to your mobile clients.

## What's Been Implemented

✅ **Database Schema**: New tables for `device_tokens`, `notification_preferences`, and extended `notifications` table  
✅ **Firebase Integration**: Complete FCM setup for sending push notifications  
✅ **Device Token Management**: API endpoints for registering/managing device tokens  
✅ **Notification Preferences**: User-level settings for notification types and quiet hours  
✅ **Notification Service**: Core service for creating and sending notifications  
✅ **Scheduled Notifications**: Cron jobs for recurring reminders (water, meals, sleep, etc.)  
✅ **Swagger Documentation**: All endpoints documented in `/api/docs`

## Setup Instructions

### 1. Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Navigate to **Project Settings** > **Service Accounts**
4. Click **Generate New Private Key** to download the service account JSON file
5. Extract the following values from the JSON:
   - `project_id` → `FIREBASE_PROJECT_ID`
   - `client_email` → `FIREBASE_CLIENT_EMAIL`
   - `private_key` → `FIREBASE_PRIVATE_KEY`

### 2. Environment Variables

Add the following to your `.env` file:

```env
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your-project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour-Private-Key-Here\n-----END PRIVATE KEY-----\n"
```

⚠️ **Important**: The private key must include the `\n` characters as shown. Keep the quotes around it.

### 3. Run Database Migration

Apply the new schema changes to your database:

```bash
npx drizzle-kit push
```

Or if you prefer to review the SQL first:

```bash
# Generate migration (already done)
npx drizzle-kit generate

# Apply migration
npx drizzle-kit migrate
```

### 4. Start the Application

```bash
# Development
npm run start:dev

# Production
npm run build
npm run start:prod
```

### 5. Verify Setup

1. Check the logs for: `Firebase Admin SDK initialized successfully`
2. Visit Swagger docs at `http://localhost:3000/api/docs`
3. Look for the new sections:
   - **Notifications**
   - **Device Tokens**
   - **Notification Preferences**

## API Endpoints

### Device Token Management

- `POST /device-tokens` - Register FCM device token
- `GET /device-tokens` - List user's registered devices
- `PATCH /device-tokens/:id/deactivate` - Deactivate a token
- `DELETE /device-tokens/:id` - Remove a token

### Notifications

- `GET /notifications` - List notifications (paginated, filterable)
- `GET /notifications/unread-count` - Get unread count
- `PATCH /notifications/:id/read` - Mark as read
- `PATCH /notifications/read-all` - Mark all as read
- `DELETE /notifications/:id` - Delete notification
- `DELETE /notifications` - Clear all notifications

### Notification Preferences

- `GET /notification-preferences` - Get user's preferences
- `PATCH /notification-preferences` - Update preferences

## Notification Types

The system supports the following notification types:

- `goal_reached` - When user achieves a goal
- `daily_reminder` - Daily summary notifications
- `water_reminder` - Hydration reminders (every 2 hours, 8 AM - 10 PM)
- `meal_reminder` - Meal logging reminders (breakfast, lunch, dinner)
- `activity_reminder` - Movement reminders (2 PM)
- `sleep_reminder` - Bedtime reminders (10 PM)
- `streak_milestone` - Achievement milestones
- `weight_update` - Weight goal notifications
- `system` - System announcements
- `custom` - Custom notifications

## Scheduled Notifications (Cron Jobs)

The following automatic notifications are configured:

| Notification       | Schedule      | Time         |
| ------------------ | ------------- | ------------ |
| Water Reminder     | Every 2 hours | 8 AM - 10 PM |
| Breakfast Reminder | Daily         | 8 AM         |
| Lunch Reminder     | Daily         | 12 PM        |
| Dinner Reminder    | Daily         | 6 PM         |
| Activity Reminder  | Daily         | 2 PM         |
| Sleep Reminder     | Daily         | 10 PM        |
| Daily Summary      | Daily         | 9 PM         |
| Token Cleanup      | Daily         | 3 AM         |

## Sending Notifications Programmatically

To send a notification from your code:

```typescript
import { NotificationsService } from './notifications/notifications.service';

// Inject the service
constructor(private notificationsService: NotificationsService) {}

// Send notification
await this.notificationsService.sendNotification(
  userId,
  'Goal Reached! 🎉',
  "You've reached your daily calorie goal of 2000 kcal!",
  'goal_reached',
  { screen: 'goals', goal_id: '5' }
);
```

## Mobile Client Integration

Your mobile app (iOS/Android) needs to:

1. **Set up Firebase SDK** and request push notification permissions
2. **Obtain FCM token** on app startup
3. **Register token** with backend: `POST /device-tokens`
4. **Handle token refresh** events and re-register
5. **Sync read state** when user views notifications
6. **Handle deep links** from notification data payload

Example registration payload:

```json
{
  "token": "fcm-device-token-string",
  "platform": "ios",
  "device_name": "iPhone 15 Pro"
}
```

## Testing

### Test Push Notification Flow

1. Register a test device token via Swagger UI
2. Update notification preferences if needed
3. Trigger a notification manually (e.g., by achieving a goal)
4. Check if push was sent via FCM

### Manual Notification Test

You can test the notification system by creating a custom notification:

```typescript
// In any service with NotificationsService injected
await this.notificationsService.sendNotification(
  userId,
  'Test Notification',
  'This is a test push notification!',
  'custom',
  { screen: 'home' },
);
```

## Troubleshooting

### Firebase SDK initialization fails

- Check that all three Firebase env vars are set correctly
- Verify the private key includes `\n` characters
- Ensure the service account email matches your Firebase project

### Push notifications not received

- Verify device token is registered: `GET /device-tokens`
- Check if token is active (`is_active: true`)
- Verify user preferences allow the notification type
- Check if user is in quiet hours
- Review Firebase logs in the console

### Scheduled notifications not running

- Check that `ScheduleModule.forRoot()` is imported in `AppModule`
- Verify `NotificationScheduler` is provided in `NotificationsModule`
- Check application logs for cron job execution

## Security Notes

- Device tokens are automatically transferred if registered by a new user
- Stale tokens (invalid/unregistered) are automatically deactivated
- Inactive tokens are cleaned up after 30 days
- Notifications respect user preferences and quiet hours
- All endpoints require JWT authentication

## Next Steps

1. **Set up Firebase** with the instructions above
2. **Run migrations** to update database schema
3. **Test the endpoints** in Swagger UI
4. **Integrate with mobile app** using FCM SDK
5. **Configure notification triggers** in your business logic

## Production Checklist

- [ ] Firebase service account configured
- [ ] Environment variables set in production
- [ ] Database migrations applied
- [ ] Mobile apps integrated with FCM
- [ ] Notification copy reviewed and approved
- [ ] Cron schedules aligned with user timezones (future enhancement)
- [ ] Analytics/monitoring set up for notification delivery rates

## Support

For issues or questions:

- Check the implementation plan: `docs/notification-system-plan.md`
- Review the Swagger documentation at `/api/docs`
- Check Firebase Console for delivery logs

---

**Status**: ✅ Implementation Complete - Ready for Firebase Configuration
