import {
  Injectable,
  Inject,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { and, count, desc, eq, gte, lt, sum } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.module';
import { DrizzleDB } from '../drizzle/types/drizzle';
import {
  activities,
  consumedMeals,
  dailyMetrics,
  meals,
  notifications,
  waterIntakes,
  sleeps,
  Notification,
} from '../drizzle/schema';
import { GoalsService } from '../goals/goals.service';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class DailyMetricsService {
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDB,
    private readonly goalsService: GoalsService,
    private readonly notificationsService: NotificationsService,
  ) {}

  private normalizeDate(date: string): string {
    if (/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      return date;
    }

    return new Date(date).toISOString().split('T')[0];
  }

  async assertMetricOwnership(metricsId: number, userId: number) {
    const metric = await this.db.query.dailyMetrics.findFirst({
      where: and(
        eq(dailyMetrics.metrics_id, metricsId),
        eq(dailyMetrics.user_id, userId),
      ),
    });

    if (!metric) {
      throw new ForbiddenException('Metric does not belong to current user');
    }

    return metric;
  }

  async getOrCreateForDate(userId: number, date: string) {
    const normalizedDate = this.normalizeDate(date);

    const existing = await this.db.query.dailyMetrics.findFirst({
      where: and(
        eq(dailyMetrics.user_id, userId),
        eq(dailyMetrics.date, normalizedDate),
      ),
    });

    if (existing) return existing;

    const [created] = await this.db
      .insert(dailyMetrics)
      .values({
        date: normalizedDate,
        total_steps: 0,
        calories_consumed: 0,
        burned_total: 0,
        total_water_ml: 0,
        total_sleep_minutes: 0,
        user_id: userId,
      })
      .returning();

    return created;
  }

  async findAll(userId: number, page: number = 1, limit: number = 20) {
    const offset = (page - 1) * limit;

    const [data, [{ value: total }]] = await Promise.all([
      this.db.query.dailyMetrics.findMany({
        where: eq(dailyMetrics.user_id, userId),
        orderBy: [desc(dailyMetrics.date)],
        limit,
        offset,
      }),
      this.db
        .select({ value: count() })
        .from(dailyMetrics)
        .where(eq(dailyMetrics.user_id, userId)),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(userId: number, id: number) {
    const metric = await this.db.query.dailyMetrics.findFirst({
      where: and(
        eq(dailyMetrics.metrics_id, id),
        eq(dailyMetrics.user_id, userId),
      ),
    });

    if (!metric) {
      throw new NotFoundException(`Daily metric with ID ${id} not found`);
    }

    return metric;
  }

  /**
   * Update total_steps (manually set from phone / watch / external APIs).
   */
  async updateSteps(userId: number, id: number, totalSteps: number) {
    const metric = await this.findOne(userId, id);

    const [updated] = await this.db
      .update(dailyMetrics)
      .set({ total_steps: totalSteps })
      .where(eq(dailyMetrics.metrics_id, metric.metrics_id))
      .returning();

    return updated;
  }

  async syncCaloriesFromActivities(metricsId: number, userId: number) {
    const metric = await this.assertMetricOwnership(metricsId, userId);
    const activityRows = await this.db.query.activities.findMany({
      where: eq(activities.metrics_id, metricsId),
    });

    const burnedTotal = activityRows.reduce(
      (sum, item) => sum + item.calories_burned,
      0,
    );

    const [updated] = await this.db
      .update(dailyMetrics)
      .set({
        burned_total: burnedTotal,
      })
      .where(eq(dailyMetrics.metrics_id, metricsId))
      .returning();

    await this.evaluateGoalReached(userId, {
      ...metric,
      calories_consumed: updated.calories_consumed,
      burned_total: updated.burned_total,
    });

    return updated;
  }

  async syncCaloriesFromConsumedMeals(metricsId: number, userId: number) {
    await this.assertMetricOwnership(metricsId, userId);

    const rows = await this.db
      .select({
        quantity: consumedMeals.quantity,
        calories: meals.calories,
      })
      .from(consumedMeals)
      .innerJoin(meals, eq(consumedMeals.meal_id, meals.meal_id))
      .where(eq(consumedMeals.metrics_id, metricsId));

    const consumedTotal = rows.reduce(
      (sum, item) => sum + item.calories * item.quantity,
      0,
    );

    const [updated] = await this.db
      .update(dailyMetrics)
      .set({
        calories_consumed: consumedTotal,
      })
      .where(eq(dailyMetrics.metrics_id, metricsId))
      .returning();

    await this.evaluateGoalReached(userId, updated);

    return updated;
  }

  /**
   * Aggregate all water intake entries for a daily metric and update total_water_ml.
   */
  async syncWaterFromIntakes(metricsId: number, userId: number) {
    await this.assertMetricOwnership(metricsId, userId);

    const intakeRows = await this.db.query.waterIntakes.findMany({
      where: eq(waterIntakes.metrics_id, metricsId),
    });

    const totalWater = intakeRows.reduce(
      (sum, item) => sum + item.amount_ml,
      0,
    );

    const [updated] = await this.db
      .update(dailyMetrics)
      .set({ total_water_ml: totalWater })
      .where(eq(dailyMetrics.metrics_id, metricsId))
      .returning();

    return updated;
  }

  /**
   * Aggregate all sleep entries for a daily metric and update total_sleep_minutes.
   */
  async syncSleepFromLogs(metricsId: number, userId: number) {
    await this.assertMetricOwnership(metricsId, userId);

    const sleepRows = await this.db.query.sleeps.findMany({
      where: eq(sleeps.metrics_id, metricsId),
    });

    const totalSleep = sleepRows.reduce(
      (sum, item) => sum + item.duration,
      0,
    );

    const [updated] = await this.db
      .update(dailyMetrics)
      .set({ total_sleep_minutes: totalSleep })
      .where(eq(dailyMetrics.metrics_id, metricsId))
      .returning();

    return updated;
  }

  private async alreadySentGoalReachedToday(
    userId: number,
    metricDate: string,
  ) {
    const dayStart = new Date(metricDate + 'T00:00:00.000Z');
    const dayEnd = new Date(metricDate + 'T23:59:59.999Z');

    const existing = await this.db.query.notifications.findFirst({
      where: and(
        eq(notifications.user_id, userId),
        eq(notifications.type, 'goal_reached'),
        gte(notifications.time, dayStart),
        lt(notifications.time, dayEnd),
      ),
    });

    return !!existing;
  }

  /**
   * Evaluate whether to send a goal notification based on net calories.
   *
   * Net calories = calories_consumed - burned_total.
   * - Lose weight: warn if net_calories >= daily_calories (they've eaten too much).
   * - Gain weight: congratulate when net_calories >= daily_calories (goal met).
   */
  private async evaluateGoalReached(
    userId: number,
    metric: typeof dailyMetrics.$inferSelect,
  ): Promise<Notification | null> {
    try {
      const goal = await this.goalsService.findByUserId(userId);
      const metricDate = metric.date;
      const caloriesConsumed = metric.calories_consumed ?? 0;
      const burnedTotal = metric.burned_total ?? 0;
      const netCalories = caloriesConsumed - burnedTotal;

      if (netCalories < goal.daily_calories) {
        return null;
      }

      const alreadySent = await this.alreadySentGoalReachedToday(
        userId,
        metricDate,
      );
      if (alreadySent) {
        return null;
      }

      const isLoseGoal = goal.type === 'lose';

      const title = isLoseGoal
        ? 'Calorie Limit Reached ⚠️'
        : 'Goal Reached! 🎉';

      const message = isLoseGoal
        ? `You've hit your daily calorie limit of ${goal.daily_calories} kcal (net: ${netCalories} kcal). Consider slowing down to stay on track.`
        : `You reached your daily calorie goal of ${goal.daily_calories} kcal (net: ${netCalories} kcal). Great work!`;

      return this.notificationsService.sendNotification(
        userId,
        title,
        message,
        'goal_reached',
        {
          screen: 'goals',
          metric_date: metricDate,
          daily_calories: String(goal.daily_calories),
          calories_consumed: String(caloriesConsumed),
          burned_total: String(burnedTotal),
          net_calories: String(netCalories),
          goal_type: goal.type,
        },
      );
    } catch (error) {
      if (error instanceof NotFoundException) {
        return null;
      }
      throw error;
    }
  }
}
