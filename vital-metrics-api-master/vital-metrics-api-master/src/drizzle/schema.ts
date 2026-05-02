import {
  pgTable,
  serial,
  text,
  integer,
  date,
  numeric,
  boolean,
  timestamp,
  uniqueIndex,
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
  weekly_rate: numeric('weekly_rate', { precision: 3, scale: 2 }).notNull(), // kg per week (e.g., 0.5)
  daily_calories: integer('daily_calories').notNull(),
  target_date: date('target_date').notNull(),
  created_at: timestamp('created_at').defaultNow().notNull(),
  user_id: integer('user_id')
    .references(() => users.user_id, { onDelete: 'cascade' })
    .unique()
    .notNull(),
});

export const dailyMetrics = pgTable(
  'daily_metrics',
  {
    metrics_id: serial('metrics_id').primaryKey(),
    date: date('date').notNull(),
    total_steps: integer('total_steps').default(0),
    calories_consumed: integer('calories_consumed').default(0).notNull(),
    burned_total: integer('burned_total').default(0).notNull(),
    total_water_ml: integer('total_water_ml').default(0).notNull(),
    total_sleep_minutes: integer('total_sleep_minutes').default(0).notNull(),
    user_id: integer('user_id')
      .references(() => users.user_id, { onDelete: 'cascade' })
      .notNull(),
  },
  (table) => ({
    userDateUnique: uniqueIndex('daily_metrics_user_date_unique').on(
      table.user_id,
      table.date,
    ),
  }),
);

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

export const meals = pgTable('meals', {
  meal_id: serial('meal_id').primaryKey(),
  name: text('name').notNull(),
  description: text('description'),
  calories: integer('calories').notNull(),
  protein: numeric('protein', { precision: 5, scale: 2 }).notNull(),
  carbs: numeric('carbs', { precision: 5, scale: 2 }).notNull(),
  fat: numeric('fat', { precision: 5, scale: 2 }).notNull(),
  created_at: timestamp('created_at').defaultNow().notNull(),
  updated_at: timestamp('updated_at').defaultNow().notNull(),
});

export const consumedMeals = pgTable('consumed_meals', {
  consumed_id: serial('consumed_id').primaryKey(),
  quantity: integer('quantity').default(1).notNull(),
  consumed_at: timestamp('consumed_at').defaultNow().notNull(),
  meal_id: integer('meal_id')
    .references(() => meals.meal_id, { onDelete: 'cascade' })
    .notNull(),
  metrics_id: integer('metrics_id')
    .references(() => dailyMetrics.metrics_id, { onDelete: 'cascade' })
    .notNull(),
});

export const activities = pgTable('activities', {
  activity_id: serial('activity_id').primaryKey(),
  type: text('type').$type<'walk' | 'run'>().notNull(),
  duration: integer('duration').notNull(),
  calories_burned: integer('calories_burned').notNull(),
  metrics_id: integer('metrics_id')
    .references(() => dailyMetrics.metrics_id, { onDelete: 'cascade' })
    .notNull(),
});

export const waterIntakes = pgTable('water_intakes', {
  water_id: serial('water_id').primaryKey(),
  amount_ml: integer('amount_ml').notNull(),
  time: timestamp('time').defaultNow().notNull(),
  metrics_id: integer('metrics_id')
    .references(() => dailyMetrics.metrics_id, { onDelete: 'cascade' })
    .notNull(),
});

export const sleeps = pgTable('sleeps', {
  sleep_id: serial('sleep_id').primaryKey(),
  duration: integer('duration').notNull(),
  quality: text('quality').notNull(),
  metrics_id: integer('metrics_id')
    .references(() => dailyMetrics.metrics_id, { onDelete: 'cascade' })
    .notNull(),
});

export const otps = pgTable('otps', {
  otp_id: serial('otp_id').primaryKey(),
  code: text('code').notNull(),
  purpose: text('purpose').$type<'verify_email' | 'reset_password'>().notNull(),
  expires_at: timestamp('expires_at').notNull(),
  used: boolean('used').default(false).notNull(),
  user_id: integer('user_id')
    .references(() => users.user_id, { onDelete: 'cascade' })
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

export type Goal = typeof goals.$inferSelect;
export type NewGoal = typeof goals.$inferInsert;

export type DailyMetric = typeof dailyMetrics.$inferSelect;
export type NewDailyMetric = typeof dailyMetrics.$inferInsert;

export type Activity = typeof activities.$inferSelect;
export type NewActivity = typeof activities.$inferInsert;

export type Meal = typeof meals.$inferSelect;
export type NewMeal = typeof meals.$inferInsert;

export type ConsumedMeal = typeof consumedMeals.$inferSelect;
export type NewConsumedMeal = typeof consumedMeals.$inferInsert;

export type WaterIntake = typeof waterIntakes.$inferSelect;
export type NewWaterIntake = typeof waterIntakes.$inferInsert;

export type Sleep = typeof sleeps.$inferSelect;
export type NewSleep = typeof sleeps.$inferInsert;

export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;
