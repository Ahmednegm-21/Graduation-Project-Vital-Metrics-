import {
  pgTable,
  serial,
  text,
  integer,
  date,
  numeric,
  boolean,
  timestamp,
} from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  user_id: serial('user_id').primaryKey(),
  name: text('name').notNull().unique(),
  email: text('email').notNull().unique(),
  password: text('password').notNull(),
  google_sub: text('google_sub').unique(),
  is_admin: boolean('is_admin').default(false).notNull(),
  is_verified: boolean('is_verified').default(false).notNull(),
  gender: text('gender').$type<'male' | 'female'>().notNull(),
  date_of_birth: date('date_of_birth').notNull(),
  height: numeric('height', { precision: 5, scale: 2 }).notNull(),
  weight: numeric('weight', { precision: 5, scale: 2 }).notNull(),
  refresh_token: text('refresh_token'),
});

export const goals = pgTable('goals', {
  goal_id: serial('goal_id').primaryKey(),
  type: text('type').$type<'lose' | 'gain'>().notNull(),
  target_weight: numeric('target_weight', { precision: 5, scale: 2 }).notNull(),
  daily_calories: integer('daily_calories').notNull(),
  user_id: integer('user_id')
    .references(() => users.user_id)
    .unique()
    .notNull(),
});

export const dailyMetrics = pgTable('daily_metrics', {
  metrics_id: serial('metrics_id').primaryKey(),
  date: date('date').notNull(),
  total_steps: integer('total_steps').default(0),
  total_calories: integer('total_calories').default(0),
  user_id: integer('user_id')
    .references(() => users.user_id)
    .notNull(),
});

export const notifications = pgTable('notifications', {
  notification_id: serial('notification_id').primaryKey(),
  title: text('title').notNull(),
  message: text('message').notNull(),
  type: text('type')
    .$type<
      | 'goal_reached'
      | 'daily_reminder'
      | 'water_reminder'
      | 'meal_reminder'
      | 'activity_reminder'
      | 'sleep_reminder'
      | 'streak_milestone'
      | 'weight_update'
      | 'system'
      | 'custom'
    >()
    .notNull(),
  data: text('data'),
  time: timestamp('time').defaultNow().notNull(),
  is_read: boolean('is_read').default(false).notNull(),
  push_sent: boolean('push_sent').default(false).notNull(),
  push_sent_at: timestamp('push_sent_at'),
  user_id: integer('user_id')
    .references(() => users.user_id, { onDelete: 'cascade' })
    .notNull(),
});

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

export const notificationPreferences = pgTable('notification_preferences', {
  preference_id: serial('preference_id').primaryKey(),
  push_enabled: boolean('push_enabled').default(true).notNull(),
  daily_reminder: boolean('daily_reminder').default(true).notNull(),
  goal_alerts: boolean('goal_alerts').default(true).notNull(),
  water_reminders: boolean('water_reminders').default(true).notNull(),
  meal_reminders: boolean('meal_reminders').default(true).notNull(),
  activity_reminders: boolean('activity_reminders').default(true).notNull(),
  sleep_reminders: boolean('sleep_reminders').default(true).notNull(),
  quiet_hours_start: text('quiet_hours_start'),
  quiet_hours_end: text('quiet_hours_end'),
  user_id: integer('user_id')
    .references(() => users.user_id, { onDelete: 'cascade' })
    .unique()
    .notNull(),
});

export const voiceLogs = pgTable('voice_logs', {
  log_id: serial('log_id').primaryKey(),
  transcript: text('transcript').notNull(),
  time: timestamp('time').defaultNow().notNull(),
  user_id: integer('user_id')
    .references(() => users.user_id)
    .notNull(),
});

export const userMeals = pgTable('user_meals', {
  user_meal_id: serial('user_meal_id').primaryKey(),
  user_id: integer('user_id')
    .references(() => users.user_id)
    .notNull(),
});

export const meals = pgTable('meals', {
  meal_id: serial('meal_id').primaryKey(),
  name: text('name').notNull().unique(),
  calories: integer('calories').notNull(),
  protein: numeric('protein', { precision: 5, scale: 2 }).notNull(),
  carbs: numeric('carbs', { precision: 5, scale: 2 }).notNull(),
  fat: numeric('fat', { precision: 5, scale: 2 }).notNull(),
  user_meal_id: integer('user_meal_id').references(
    () => userMeals.user_meal_id,
  ),
});

export const activities = pgTable('activities', {
  activity_id: serial('activity_id').primaryKey(),
  type: text('type').$type<'walk' | 'run'>().notNull(),
  duration: integer('duration').notNull(),
  calories_burned: integer('calories_burned').notNull(),
  metrics_id: integer('metrics_id')
    .references(() => dailyMetrics.metrics_id)
    .notNull(),
});

export const waterIntakes = pgTable('water_intakes', {
  water_id: serial('water_id').primaryKey(),
  amount_ml: integer('amount_ml').notNull(),
  time: timestamp('time').defaultNow().notNull(),
  metrics_id: integer('metrics_id')
    .references(() => dailyMetrics.metrics_id)
    .notNull(),
});

export const sleeps = pgTable('sleeps', {
  sleep_id: serial('sleep_id').primaryKey(),
  duration: integer('duration').notNull(),
  quality: text('quality').notNull(),
  metrics_id: integer('metrics_id')
    .references(() => dailyMetrics.metrics_id)
    .notNull(),
});

export const otps = pgTable('otps', {
  otp_id: serial('otp_id').primaryKey(),
  code: text('code').notNull(),
  purpose: text('purpose').$type<'verify_email' | 'reset_password'>().notNull(),
  expires_at: timestamp('expires_at').notNull(),
  used: boolean('used').default(false).notNull(),
  user_id: integer('user_id')
    .references(() => users.user_id)
    .notNull(),
});

// Type exports
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

export type Notification = typeof notifications.$inferSelect;
export type NewNotification = typeof notifications.$inferInsert;

export type DeviceToken = typeof deviceTokens.$inferSelect;
export type NewDeviceToken = typeof deviceTokens.$inferInsert;

export type NotificationPreference =
  typeof notificationPreferences.$inferSelect;
export type NewNotificationPreference =
  typeof notificationPreferences.$inferInsert;
