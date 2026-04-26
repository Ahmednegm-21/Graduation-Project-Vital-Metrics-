# Notification System Plan — Push Notifications for Mobile Clients

## 1. Overview

This document outlines the full plan for implementing a push notification system in the **Vital Metrics API**. The system will support sending push notifications to mobile clients (iOS & Android) using **Firebase Cloud Messaging (FCM)** as the push delivery provider.

### Goals

- Allow the backend to send real-time push notifications to individual users or broadcast to groups.
- Store notification history in the database (leveraging the existing `notifications` table).
- Let users register/unregister device tokens from multiple devices.
- Provide APIs for clients to manage notification preferences and read/unread state.
- Support both triggered (event-driven) and scheduled notifications.

---

## 2. Current State Analysis

### Existing Infrastructure

| Aspect               | Current State                                                                                        |
| -------------------- | ---------------------------------------------------------------------------------------------------- |
| **Framework**        | NestJS v10 with TypeScript                                                                           |
| **Database**         | PostgreSQL 16 via Drizzle ORM                                                                        |
| **Auth**             | JWT (access + refresh tokens), Google OAuth                                                          |
| **Existing Schema**  | `notifications` table already exists with `notification_id`, `message`, `time`, `is_read`, `user_id` |
| **Modules**          | `AuthModule`, `UsersModule`, `OtpModule`, `MailModule`, `DrizzleModule`                              |
| **Containerization** | Docker Compose (api + postgres)                                                                      |
| **API Docs**         | Swagger at `/api/docs`                                                                               |

### Existing `notifications` Table

```typescript
export const notifications = pgTable('notifications', {
  notification_id: serial('notification_id').primaryKey(),
  message: text('message').notNull(),
  time: timestamp('time').defaultNow().notNull(),
  is_read: boolean('is_read').default(false).notNull(),
  user_id: integer('user_id')
    .references(() => users.user_id)
    .notNull(),
});
```

This table stores in-app notification records. It needs to be extended to support push notification metadata.

---

## 3. Architecture

```
┌─────────────────┐         ┌──────────────────────┐
│  Mobile Client   │◄────────│   FCM / APNs          │
│  (iOS/Android)   │         └──────────┬───────────┘
└────────┬────────┘                     │
         │ Register Token               │ Push Delivery
         ▼                              │
┌─────────────────────────────────────────────────────┐
│                  Vital Metrics API                    │
│                                                       │
│  ┌──────────────┐  ┌──────────────────┐              │
│  │ Notification  │  │ Device Token     │              │
│  │ Controller    │  │ Controller       │              │
│  └──────┬───────┘  └──────┬───────────┘              │
│         │                  │                          │
│  ┌──────▼──────────────────▼───────────┐             │
│  │       Notification Service           │             │
│  │  - create & store notifications      │             │
│  │  - dispatch push via FCM             │             │
│  │  - handle preferences                │             │
│  └──────────────┬──────────────────────┘             │
│                 │                                     │
│  ┌──────────────▼──────────────────────┐             │
│  │       Firebase Admin SDK             │             │
│  │  (firebase-admin)                    │             │
│  └──────────────┬──────────────────────┘             │
│                 │                                     │
│  ┌──────────────▼──────────────────────┐             │
│  │       PostgreSQL (Drizzle ORM)       │             │
│  │  - notifications                     │             │
│  │  - device_tokens                     │             │
│  │  - notification_preferences          │             │
│  └─────────────────────────────────────┘             │
└─────────────────────────────────────────────────────┘
```

### Why Firebase Cloud Messaging?

- **Free tier** covers most use cases.
- **Cross-platform**: Single API for iOS (via APNs) and Android.
- **Reliable delivery** with built-in retry logic.
- **Topic-based messaging** for group/broadcast notifications.
- **Well-maintained** official Node.js Admin SDK (`firebase-admin`).

---

## 4. Database Schema Changes

### 4.1 New Table: `device_tokens`

Stores FCM device tokens for each user. A user can have multiple devices.

```typescript
export const deviceTokens = pgTable('device_tokens', {
  token_id: serial('token_id').primaryKey(),
  token: text('token').notNull().unique(),
  platform: text('platform').$type<'ios' | 'android'>().notNull(),
  device_name: text('device_name'),
  is_active: boolean('is_active').default(true).notNull(),
  created_at: timestamp('created_at').defaultNow().notNull(),
  updated_at: timestamp('updated_at').defaultNow().notNull(),
  user_id: integer('user_id')
    .references(() => users.user_id, { onDelete: 'cascade' })
    .notNull(),
});
```

### 4.2 New Table: `notification_preferences`

User-level preferences for notification types.

```typescript
export const notificationPreferences = pgTable('notification_preferences', {
  preference_id: serial('preference_id').primaryKey(),
  push_enabled: boolean('push_enabled').default(true).notNull(),
  daily_reminder: boolean('daily_reminder').default(true).notNull(),
  goal_alerts: boolean('goal_alerts').default(true).notNull(),
  water_reminders: boolean('water_reminders').default(true).notNull(),
  meal_reminders: boolean('meal_reminders').default(true).notNull(),
  activity_reminders: boolean('activity_reminders').default(true).notNull(),
  sleep_reminders: boolean('sleep_reminders').default(true).notNull(),
  quiet_hours_start: text('quiet_hours_start'), // e.g. "22:00"
  quiet_hours_end: text('quiet_hours_end'), // e.g. "07:00"
  user_id: integer('user_id')
    .references(() => users.user_id, { onDelete: 'cascade' })
    .unique()
    .notNull(),
});
```

### 4.3 Extend Existing `notifications` Table

Add columns for push notification metadata:

```typescript
export const notifications = pgTable('notifications', {
  notification_id: serial('notification_id').primaryKey(),
  title: text('title').notNull(), // NEW
  message: text('message').notNull(),
  type: text('type').$type<NotificationType>().notNull(), // NEW
  data: text('data'), // NEW — JSON payload for deep linking
  time: timestamp('time').defaultNow().notNull(),
  is_read: boolean('is_read').default(false).notNull(),
  push_sent: boolean('push_sent').default(false).notNull(), // NEW
  push_sent_at: timestamp('push_sent_at'), // NEW
  user_id: integer('user_id')
    .references(() => users.user_id, { onDelete: 'cascade' })
    .notNull(),
});
```

### 4.4 Notification Types Enum

```typescript
export type NotificationType =
  | 'goal_reached'
  | 'daily_reminder'
  | 'water_reminder'
  | 'meal_reminder'
  | 'activity_reminder'
  | 'sleep_reminder'
  | 'streak_milestone'
  | 'weight_update'
  | 'system'
  | 'custom';
```

### 4.5 Drizzle Migration

A new migration file will be generated via `drizzle-kit generate` to capture all schema changes above.

---

## 5. New Dependencies

```bash
npm install firebase-admin
npm install --save-dev @types/node  # already present
```

No other runtime dependencies are needed. `firebase-admin` bundles its own types.

---

## 6. Environment Variables

Add to `.env` and `docker-compose.yml`:

```env
# Firebase
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_CLIENT_EMAIL=your-service-account-email
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"

# Or alternatively, path to service account JSON
# FIREBASE_SERVICE_ACCOUNT_PATH=/path/to/service-account.json
```

Docker Compose additions:

```yaml
environment:
  FIREBASE_PROJECT_ID: ${FIREBASE_PROJECT_ID}
  FIREBASE_CLIENT_EMAIL: ${FIREBASE_CLIENT_EMAIL}
  FIREBASE_PRIVATE_KEY: ${FIREBASE_PRIVATE_KEY}
```

---

## 7. Module Structure

```
src/
  notifications/
    notifications.module.ts
    notifications.controller.ts
    notifications.service.ts
    notifications.gateway.ts           # optional: WebSocket for real-time (future)
    dto/
      index.ts
      create-notification.dto.ts
      notification-response.dto.ts
      update-notification.dto.ts
      notification-query.dto.ts
    constants/
      notification.constants.ts
    interfaces/
      notification.interfaces.ts
  device-tokens/
    device-tokens.module.ts
    device-tokens.controller.ts
    device-tokens.service.ts
    dto/
      index.ts
      register-device.dto.ts
      device-token-response.dto.ts
  notification-preferences/
    notification-preferences.module.ts
    notification-preferences.controller.ts
    notification-preferences.service.ts
    dto/
      index.ts
      update-preferences.dto.ts
      preferences-response.dto.ts
  firebase/
    firebase.module.ts
    firebase.service.ts
```

---

## 8. API Endpoints

### 8.1 Device Token Management

| Method   | Endpoint                             | Auth | Description                    |
| -------- | ------------------------------------ | ---- | ------------------------------ |
| `POST`   | `/device-tokens`                     | JWT  | Register a device token        |
| `DELETE` | `/device-tokens/:tokenId`            | JWT  | Remove a specific device token |
| `GET`    | `/device-tokens`                     | JWT  | List user's registered devices |
| `PATCH`  | `/device-tokens/:tokenId/deactivate` | JWT  | Deactivate a device token      |

#### `POST /device-tokens` — Request Body

```json
{
  "token": "fcm-device-token-string",
  "platform": "ios",
  "device_name": "iPhone 15 Pro"
}
```

### 8.2 Notifications

| Method   | Endpoint                      | Auth | Description                           |
| -------- | ----------------------------- | ---- | ------------------------------------- |
| `GET`    | `/notifications`              | JWT  | List user's notifications (paginated) |
| `GET`    | `/notifications/unread-count` | JWT  | Get unread notification count         |
| `PATCH`  | `/notifications/:id/read`     | JWT  | Mark a notification as read           |
| `PATCH`  | `/notifications/read-all`     | JWT  | Mark all notifications as read        |
| `DELETE` | `/notifications/:id`          | JWT  | Delete a notification                 |
| `DELETE` | `/notifications`              | JWT  | Clear all notifications               |

#### `GET /notifications` — Query Parameters

```
?page=1&limit=20&type=goal_reached&unread_only=true
```

#### Notification Response Shape

```json
{
  "notification_id": 1,
  "title": "Goal Reached! 🎉",
  "message": "You've reached your daily calorie goal of 2000 kcal.",
  "type": "goal_reached",
  "data": "{\"screen\": \"goals\", \"goal_id\": 5}",
  "time": "2026-02-12T10:30:00Z",
  "is_read": false
}
```

### 8.3 Notification Preferences

| Method  | Endpoint                    | Auth | Description                         |
| ------- | --------------------------- | ---- | ----------------------------------- |
| `GET`   | `/notification-preferences` | JWT  | Get user's notification preferences |
| `PATCH` | `/notification-preferences` | JWT  | Update notification preferences     |

#### `PATCH /notification-preferences` — Request Body

```json
{
  "push_enabled": true,
  "daily_reminder": true,
  "goal_alerts": true,
  "water_reminders": false,
  "quiet_hours_start": "22:00",
  "quiet_hours_end": "07:00"
}
```

### 8.4 Admin Endpoints (Future/Optional)

| Method | Endpoint                         | Auth        | Description                        |
| ------ | -------------------------------- | ----------- | ---------------------------------- |
| `POST` | `/admin/notifications/broadcast` | JWT + Admin | Send notification to all users     |
| `POST` | `/admin/notifications/send`      | JWT + Admin | Send notification to specific user |

---

## 9. Implementation Details

### 9.1 Firebase Service (`firebase.service.ts`)

```typescript
@Injectable()
export class FirebaseService implements OnModuleInit {
  private app: admin.app.App;

  constructor(private configService: ConfigService) {}

  onModuleInit() {
    this.app = admin.initializeApp({
      credential: admin.credential.cert({
        projectId: this.configService.get('FIREBASE_PROJECT_ID'),
        clientEmail: this.configService.get('FIREBASE_CLIENT_EMAIL'),
        privateKey: this.configService
          .get('FIREBASE_PRIVATE_KEY')
          ?.replace(/\\n/g, '\n'),
      }),
    });
  }

  async sendPushNotification(
    tokens: string[],
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<admin.messaging.BatchResponse> {
    const message: admin.messaging.MulticastMessage = {
      tokens,
      notification: { title, body },
      data,
      android: {
        priority: 'high',
        notification: { channelId: 'vital_metrics_default' },
      },
      apns: {
        payload: {
          aps: { sound: 'default', badge: 1 },
        },
      },
    };

    return admin.messaging().sendEachForMulticast(message);
  }

  async sendToTopic(
    topic: string,
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<string> {
    return admin.messaging().send({
      topic,
      notification: { title, body },
      data,
    });
  }
}
```

### 9.2 Notification Service (`notifications.service.ts`)

Core responsibilities:

1. **Create & persist** notification record in database.
2. **Retrieve device tokens** for the target user.
3. **Check user preferences** and quiet hours before sending.
4. **Dispatch push** via `FirebaseService`.
5. **Handle stale tokens** — if FCM returns `messaging/registration-token-not-registered`, deactivate the token.
6. **Update `push_sent`** flag after successful delivery.

```typescript
@Injectable()
export class NotificationsService {
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDB,
    private readonly firebaseService: FirebaseService,
    private readonly deviceTokensService: DeviceTokensService,
    private readonly preferencesService: NotificationPreferencesService,
  ) {}

  async sendNotification(
    userId: number,
    title: string,
    message: string,
    type: NotificationType,
    data?: Record<string, string>,
  ): Promise<void> {
    // 1. Check user preferences
    const prefs = await this.preferencesService.getPreferences(userId);
    if (!prefs?.push_enabled || !this.isTypeEnabled(prefs, type)) return;
    if (this.isQuietHours(prefs)) return;

    // 2. Store notification in DB
    const [notification] = await this.db
      .insert(notifications)
      .values({
        title,
        message,
        type,
        data: JSON.stringify(data),
        user_id: userId,
      })
      .returning();

    // 3. Get active device tokens
    const tokens = await this.deviceTokensService.getActiveTokens(userId);
    if (tokens.length === 0) return;

    // 4. Send push via FCM
    const response = await this.firebaseService.sendPushNotification(
      tokens.map((t) => t.token),
      title,
      message,
      data,
    );

    // 5. Handle failures (deactivate invalid tokens)
    await this.handleFcmResponse(response, tokens);

    // 6. Mark push as sent
    await this.db
      .update(notifications)
      .set({ push_sent: true, push_sent_at: new Date() })
      .where(eq(notifications.notification_id, notification.notification_id));
  }
}
```

### 9.3 Device Token Service (`device-tokens.service.ts`)

- **Register**: Upsert token (if token already exists for another user, transfer it).
- **Deactivate**: Mark `is_active = false` instead of deleting (for audit trail).
- **Cleanup**: Periodic job to remove tokens inactive for 30+ days.

### 9.4 Stale Token Handling

When FCM returns error codes indicating an invalid registration token:

```typescript
private async handleFcmResponse(
  response: admin.messaging.BatchResponse,
  tokens: DeviceToken[],
) {
  const staleTokenIds: number[] = [];

  response.responses.forEach((res, idx) => {
    if (res.error) {
      const errorCode = res.error.code;
      if (
        errorCode === 'messaging/registration-token-not-registered' ||
        errorCode === 'messaging/invalid-registration-token'
      ) {
        staleTokenIds.push(tokens[idx].token_id);
      }
    }
  });

  if (staleTokenIds.length > 0) {
    await this.deviceTokensService.deactivateTokens(staleTokenIds);
  }
}
```

---

## 10. Notification Triggers

These are the events across the app that should trigger push notifications:

| Trigger Event          | Notification Type   | Title Example              | When to Send                            |
| ---------------------- | ------------------- | -------------------------- | --------------------------------------- |
| Daily calorie goal met | `goal_reached`      | "Goal Reached! 🎉"         | When `total_calories >= daily_calories` |
| Daily step milestone   | `streak_milestone`  | "Step Milestone! 🏃"       | At 5k, 10k, 15k steps                   |
| Water intake reminder  | `water_reminder`    | "Stay Hydrated 💧"         | Every 2 hours (scheduled)               |
| Meal logging reminder  | `meal_reminder`     | "Time to Log Your Meal 🍽️" | At breakfast/lunch/dinner times         |
| Activity reminder      | `activity_reminder` | "Get Moving! 🚶"           | If no activity logged by afternoon      |
| Sleep reminder         | `sleep_reminder`    | "Time to Wind Down 🌙"     | At user's configured bedtime            |
| Daily summary          | `daily_reminder`    | "Your Daily Summary 📊"    | End of day summary                      |
| Weight target reached  | `weight_update`     | "Weight Goal Reached! ⭐"  | When weight matches target              |
| System announcements   | `system`            | "App Update Available"     | Admin-triggered                         |

### Integration Points

Notifications will be triggered from existing services by injecting `NotificationsService`:

```typescript
// Example: In a future DailyMetricsService
async updateDailyCalories(userId: number, calories: number) {
  // ... existing logic ...

  const goal = await this.getGoal(userId);
  if (goal && calories >= goal.daily_calories) {
    await this.notificationsService.sendNotification(
      userId,
      'Goal Reached! 🎉',
      `You've hit your daily calorie goal of ${goal.daily_calories} kcal!`,
      'goal_reached',
      { screen: 'goals', goal_id: String(goal.goal_id) },
    );
  }
}
```

---

## 11. Scheduled Notifications (Cron Jobs)

Use `@nestjs/schedule` for recurring notifications.

```bash
npm install @nestjs/schedule
```

```typescript
@Injectable()
export class NotificationScheduler {
  constructor(
    private readonly notificationsService: NotificationsService,
    private readonly preferencesService: NotificationPreferencesService,
  ) {}

  // Water reminder — every 2 hours during daytime
  @Cron('0 */2 8-22 * * *')
  async waterReminder() {
    const users = await this.preferencesService.getUsersWithPreference(
      'water_reminders',
      true,
    );
    for (const user of users) {
      await this.notificationsService.sendNotification(
        user.user_id,
        'Stay Hydrated 💧',
        "Don't forget to drink water! Log your intake.",
        'water_reminder',
        { screen: 'water_intake' },
      );
    }
  }

  // Daily summary — every day at 9 PM
  @Cron('0 0 21 * * *')
  async dailySummary() {
    // ... fetch users and send daily summary notifications
  }
}
```

---

## 12. DTOs

### `RegisterDeviceDto`

```typescript
export class RegisterDeviceDto {
  @IsString()
  @IsNotEmpty()
  token: string;

  @IsEnum(['ios', 'android'])
  platform: 'ios' | 'android';

  @IsOptional()
  @IsString()
  device_name?: string;
}
```

### `NotificationQueryDto`

```typescript
export class NotificationQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number = 20;

  @IsOptional()
  @IsString()
  type?: NotificationType;

  @IsOptional()
  @Transform(({ value }) => value === 'true')
  @IsBoolean()
  unread_only?: boolean = false;
}
```

### `UpdatePreferencesDto`

```typescript
export class UpdatePreferencesDto {
  @IsOptional() @IsBoolean() push_enabled?: boolean;
  @IsOptional() @IsBoolean() daily_reminder?: boolean;
  @IsOptional() @IsBoolean() goal_alerts?: boolean;
  @IsOptional() @IsBoolean() water_reminders?: boolean;
  @IsOptional() @IsBoolean() meal_reminders?: boolean;
  @IsOptional() @IsBoolean() activity_reminders?: boolean;
  @IsOptional() @IsBoolean() sleep_reminders?: boolean;
  @IsOptional()
  @IsString()
  @Matches(/^\d{2}:\d{2}$/)
  quiet_hours_start?: string;
  @IsOptional() @IsString() @Matches(/^\d{2}:\d{2}$/) quiet_hours_end?: string;
}
```

---

## 13. Module Registration

### `app.module.ts` Updates

```typescript
@Module({
  imports: [
    DrizzleModule,
    ConfigModule.forRoot({ isGlobal: true }),
    ScheduleModule.forRoot(), // NEW
    AuthModule,
    UsersModule,
    OtpModule,
    MailModule,
    FirebaseModule, // NEW
    NotificationsModule, // NEW
    DeviceTokensModule, // NEW
    NotificationPreferencesModule, // NEW
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
```

### Module Dependencies

```
FirebaseModule (global)
  └── exports: FirebaseService

DeviceTokensModule
  └── imports: DrizzleModule
  └── exports: DeviceTokensService

NotificationPreferencesModule
  └── imports: DrizzleModule
  └── exports: NotificationPreferencesService

NotificationsModule
  └── imports: DrizzleModule, FirebaseModule, DeviceTokensModule, NotificationPreferencesModule
  └── exports: NotificationsService
  └── providers: NotificationScheduler
```

---

## 14. Testing Strategy

### Unit Tests

| File                                       | What to Test                                                        |
| ------------------------------------------ | ------------------------------------------------------------------- |
| `firebase.service.spec.ts`                 | Mock `firebase-admin`, verify message construction                  |
| `notifications.service.spec.ts`            | Preference checks, quiet hours, stale token handling, DB operations |
| `device-tokens.service.spec.ts`            | Token registration, deactivation, cleanup                           |
| `notification-preferences.service.spec.ts` | CRUD operations, default creation                                   |
| `notifications.controller.spec.ts`         | Route guards, pagination, validation                                |

### Integration Tests

- Register device → send notification → verify DB record + FCM call.
- Preference toggling → verify notification is/isn't sent.
- Token deactivation flow after FCM error.

### E2E Tests

- Full flow: register device token → trigger event → notification appears in `GET /notifications`.

---

## 15. Swagger Documentation

Add Swagger tags and decorators to all new controllers:

```typescript
@ApiTags('Notifications')
@ApiBearerAuth('JWT-auth')
@Controller('notifications')
export class NotificationsController { ... }

@ApiTags('Device Tokens')
@ApiBearerAuth('JWT-auth')
@Controller('device-tokens')
export class DeviceTokensController { ... }

@ApiTags('Notification Preferences')
@ApiBearerAuth('JWT-auth')
@Controller('notification-preferences')
export class NotificationPreferencesController { ... }
```

Update `main.ts` builder:

```typescript
.addTag('Notifications', 'Push notification management')
.addTag('Device Tokens', 'Device registration for push notifications')
.addTag('Notification Preferences', 'User notification settings')
```

---

## 16. Security Considerations

1. **Device token ownership**: Ensure users can only manage their own tokens. Validate `user_id` from JWT on every token operation.
2. **Rate limiting**: Prevent notification spam — implement rate limits on admin broadcast endpoints.
3. **Token transfer**: When a device token is registered by a new user, remove it from the previous user (a device can only belong to one user).
4. **Data payload**: Never include sensitive user data in push notification payloads (they can be intercepted by OS-level tools).
5. **Firebase credentials**: Store service account credentials securely via environment variables, never commit to source control.
6. **Quiet hours**: Respect user-configured quiet hours to avoid sending at inconvenient times.

---

## 17. Implementation Order

### Phase 1 — Foundation (Week 1)

- [ ] Install `firebase-admin` and `@nestjs/schedule` dependencies
- [ ] Add Firebase environment variables to `.env` and `docker-compose.yml`
- [ ] Create `FirebaseModule` + `FirebaseService` with FCM initialization
- [ ] Update Drizzle schema: add `device_tokens`, `notification_preferences` tables
- [ ] Extend `notifications` table with new columns (`title`, `type`, `data`, `push_sent`, `push_sent_at`)
- [ ] Generate and run Drizzle migration

### Phase 2 — Core Services (Week 1-2)

- [ ] Implement `DeviceTokensModule` (service + controller + DTOs)
- [ ] Implement `NotificationPreferencesModule` (service + controller + DTOs)
- [ ] Implement `NotificationsModule` (service + controller + DTOs)
- [ ] Wire up stale token cleanup logic
- [ ] Add Swagger documentation to all new endpoints

### Phase 3 — Notification Triggers (Week 2-3)

- [ ] Integrate `NotificationsService` into existing services for event-driven notifications
- [ ] Implement `NotificationScheduler` for recurring cron-based notifications
- [ ] Define all notification templates/copy

### Phase 4 — Testing & Polish (Week 3)

- [ ] Write unit tests for all new services
- [ ] Write integration tests for key flows
- [ ] Write E2E tests for device registration → notification delivery
- [ ] Load test with multiple concurrent push sends
- [ ] Add notification count badge support in push payload

### Phase 5 — Admin Features (Future)

- [ ] Admin broadcast endpoint
- [ ] Admin send-to-user endpoint
- [ ] Notification analytics/delivery tracking dashboard

---

## 18. Mobile Client Integration Notes

The mobile client (iOS / Android) will need to:

1. **Set up Firebase SDK** in the app and request push notification permissions.
2. **Obtain FCM token** on app startup and after token refresh events.
3. **Call `POST /device-tokens`** to register the token with the backend after login.
4. **Call `DELETE /device-tokens/:id`** on logout to unregister.
5. **Listen for token refresh** events and re-register with the backend.
6. **Handle incoming notifications**:
   - Foreground: display in-app banner.
   - Background: OS handles display, app handles tap-to-open with deep link from `data` payload.
7. **Sync read state**: call `PATCH /notifications/:id/read` when user views a notification.
8. **Fetch preferences** on settings screen and submit updates via `PATCH /notification-preferences`.

### Deep Linking Data Payload Structure

```json
{
  "screen": "goals",
  "id": "5"
}
```

The mobile app should parse `data.screen` to navigate to the correct view on notification tap.

---

## 19. Files to Create/Modify Summary

### New Files

| File Path                                                             | Purpose                       |
| --------------------------------------------------------------------- | ----------------------------- |
| `src/firebase/firebase.module.ts`                                     | Firebase Admin SDK module     |
| `src/firebase/firebase.service.ts`                                    | FCM push sending service      |
| `src/device-tokens/device-tokens.module.ts`                           | Device token module           |
| `src/device-tokens/device-tokens.controller.ts`                       | Device token API endpoints    |
| `src/device-tokens/device-tokens.service.ts`                          | Device token business logic   |
| `src/device-tokens/dto/register-device.dto.ts`                        | Registration DTO              |
| `src/device-tokens/dto/device-token-response.dto.ts`                  | Response DTO                  |
| `src/device-tokens/dto/index.ts`                                      | DTO barrel export             |
| `src/notifications/notifications.module.ts`                           | Notifications module          |
| `src/notifications/notifications.controller.ts`                       | Notification API endpoints    |
| `src/notifications/notifications.service.ts`                          | Notification business logic   |
| `src/notifications/notifications.scheduler.ts`                        | Cron-based notification jobs  |
| `src/notifications/dto/create-notification.dto.ts`                    | Create notification DTO       |
| `src/notifications/dto/notification-response.dto.ts`                  | Response DTO                  |
| `src/notifications/dto/notification-query.dto.ts`                     | Query/filter DTO              |
| `src/notifications/dto/index.ts`                                      | DTO barrel export             |
| `src/notifications/constants/notification.constants.ts`               | Notification types & messages |
| `src/notifications/interfaces/notification.interfaces.ts`             | TypeScript interfaces         |
| `src/notification-preferences/notification-preferences.module.ts`     | Preferences module            |
| `src/notification-preferences/notification-preferences.controller.ts` | Preferences API endpoints     |
| `src/notification-preferences/notification-preferences.service.ts`    | Preferences business logic    |
| `src/notification-preferences/dto/update-preferences.dto.ts`          | Update DTO                    |
| `src/notification-preferences/dto/preferences-response.dto.ts`        | Response DTO                  |
| `src/notification-preferences/dto/index.ts`                           | DTO barrel export             |

### Modified Files

| File Path               | Change                                                                       |
| ----------------------- | ---------------------------------------------------------------------------- |
| `src/drizzle/schema.ts` | Add `deviceTokens`, `notificationPreferences` tables; extend `notifications` |
| `src/app.module.ts`     | Import new modules + `ScheduleModule`                                        |
| `src/main.ts`           | Add new Swagger tags                                                         |
| `docker-compose.yml`    | Add Firebase env vars                                                        |
| `package.json`          | New dependencies                                                             |

---

## 20. Estimated Effort

| Phase                           | Effort        |
| ------------------------------- | ------------- |
| Phase 1 — Foundation            | ~1 day        |
| Phase 2 — Core Services         | ~2-3 days     |
| Phase 3 — Notification Triggers | ~2 days       |
| Phase 4 — Testing & Polish      | ~2 days       |
| **Total**                       | **~7-8 days** |
