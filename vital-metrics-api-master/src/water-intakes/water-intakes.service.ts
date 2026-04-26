import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { count, eq, inArray } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.module';
import { DrizzleDB } from '../drizzle/types/drizzle';
import { waterIntakes, dailyMetrics } from '../drizzle/schema';
import { CreateWaterIntakeDto } from './dto/create-water-intake.dto';
import { UpdateWaterIntakeDto } from './dto/update-water-intake.dto';
import { DailyMetricsService } from '../daily-metrics/daily-metrics.service';

@Injectable()
export class WaterIntakesService {
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDB,
    private readonly dailyMetricsService: DailyMetricsService,
  ) {}

  async create(userId: number, dto: CreateWaterIntakeDto) {
    const metric = await this.dailyMetricsService.getOrCreateForDate(
      userId,
      dto.date,
    );

    const [created] = await this.db
      .insert(waterIntakes)
      .values({
        amount_ml: dto.amount_ml,
        metrics_id: metric.metrics_id,
      })
      .returning();

    await this.dailyMetricsService.syncWaterFromIntakes(
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
      this.db.query.waterIntakes.findMany({
        where: inArray(waterIntakes.metrics_id, metricIds),
        limit,
        offset,
      }),
      this.db
        .select({ value: count() })
        .from(waterIntakes)
        .where(inArray(waterIntakes.metrics_id, metricIds)),
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
    const record = await this.db.query.waterIntakes.findFirst({
      where: eq(waterIntakes.water_id, id),
    });

    if (!record) {
      throw new NotFoundException(`Water intake with ID ${id} not found`);
    }

    await this.dailyMetricsService.assertMetricOwnership(
      record.metrics_id,
      userId,
    );
    return record;
  }

  async update(userId: number, id: number, dto: UpdateWaterIntakeDto) {
    const current = await this.findOne(userId, id);

    let metricsId = current.metrics_id;

    // If the date changed, resolve the new daily-metric
    if (dto.date) {
      const metric = await this.dailyMetricsService.getOrCreateForDate(
        userId,
        dto.date,
      );
      metricsId = metric.metrics_id;
    }

    const [updated] = await this.db
      .update(waterIntakes)
      .set({
        amount_ml: dto.amount_ml ?? current.amount_ml,
        metrics_id: metricsId,
      })
      .where(eq(waterIntakes.water_id, id))
      .returning();

    // Re-sync the old metric
    await this.dailyMetricsService.syncWaterFromIntakes(
      current.metrics_id,
      userId,
    );

    // If moved to a different day, also sync the new metric
    if (metricsId !== current.metrics_id) {
      await this.dailyMetricsService.syncWaterFromIntakes(metricsId, userId);
    }

    return updated;
  }

  async remove(userId: number, id: number) {
    const current = await this.findOne(userId, id);
    const deleted = await this.db
      .delete(waterIntakes)
      .where(eq(waterIntakes.water_id, id))
      .returning();

    await this.dailyMetricsService.syncWaterFromIntakes(
      current.metrics_id,
      userId,
    );

    return { deleted: deleted.length > 0 };
  }
}
