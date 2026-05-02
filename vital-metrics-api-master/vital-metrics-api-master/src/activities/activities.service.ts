import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { count, eq, inArray } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.module';
import { DrizzleDB } from '../drizzle/types/drizzle';
import { activities, dailyMetrics } from '../drizzle/schema';
import { CreateActivityDto } from './dto/create-activity.dto';
import { UpdateActivityDto } from './dto/update-activity.dto';
import { DailyMetricsService } from '../daily-metrics/daily-metrics.service';

@Injectable()
export class ActivitiesService {
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDB,
    private readonly dailyMetricsService: DailyMetricsService,
  ) {}

  async create(userId: number, createActivityDto: CreateActivityDto) {
    const metric = await this.dailyMetricsService.getOrCreateForDate(
      userId,
      createActivityDto.date,
    );

    const [created] = await this.db
      .insert(activities)
      .values({
        type: createActivityDto.type,
        duration: createActivityDto.duration,
        calories_burned: createActivityDto.calories_burned,
        metrics_id: metric.metrics_id,
      })
      .returning();

    await this.dailyMetricsService.syncCaloriesFromActivities(
      metric.metrics_id,
      userId,
    );

    return created;
  }

  async findAll(userId: number, page: number = 1, limit: number = 20) {
    const offset = (page - 1) * limit;

    const metrics = await this.db.query.dailyMetrics.findMany({
      where: eq(dailyMetrics.user_id, userId),
    });
    const metricIds = metrics.map((item) => item.metrics_id);

    if (metricIds.length === 0) {
      return {
        data: [],
        meta: { total: 0, page, limit, totalPages: 0 },
      };
    }

    const [data, [{ value: total }]] = await Promise.all([
      this.db.query.activities.findMany({
        where: inArray(activities.metrics_id, metricIds),
        limit,
        offset,
      }),
      this.db
        .select({ value: count() })
        .from(activities)
        .where(inArray(activities.metrics_id, metricIds)),
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
    const activity = await this.db.query.activities.findFirst({
      where: eq(activities.activity_id, id),
    });

    if (!activity) {
      throw new NotFoundException(`Activity with ID ${id} not found`);
    }

    await this.dailyMetricsService.assertMetricOwnership(
      activity.metrics_id,
      userId,
    );
    return activity;
  }

  async update(
    userId: number,
    id: number,
    updateActivityDto: UpdateActivityDto,
  ) {
    const current = await this.findOne(userId, id);

    let metricsId = current.metrics_id;

    // If the date changed, resolve the new daily-metric
    if (updateActivityDto.date) {
      const metric = await this.dailyMetricsService.getOrCreateForDate(
        userId,
        updateActivityDto.date,
      );
      metricsId = metric.metrics_id;
    }

    const [updated] = await this.db
      .update(activities)
      .set({
        type: updateActivityDto.type ?? current.type,
        duration: updateActivityDto.duration ?? current.duration,
        calories_burned:
          updateActivityDto.calories_burned ?? current.calories_burned,
        metrics_id: metricsId,
      })
      .where(eq(activities.activity_id, id))
      .returning();

    // Re-sync the old metric
    await this.dailyMetricsService.syncCaloriesFromActivities(
      current.metrics_id,
      userId,
    );

    // If moved to a different day, also sync the new metric
    if (metricsId !== current.metrics_id) {
      await this.dailyMetricsService.syncCaloriesFromActivities(
        metricsId,
        userId,
      );
    }

    return updated;
  }

  async remove(userId: number, id: number) {
    const current = await this.findOne(userId, id);
    const deleted = await this.db
      .delete(activities)
      .where(eq(activities.activity_id, id))
      .returning();

    await this.dailyMetricsService.syncCaloriesFromActivities(
      current.metrics_id,
      userId,
    );

    return { deleted: deleted.length > 0 };
  }
}
