import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { and, asc, count, desc, eq, inArray } from 'drizzle-orm';
import { DailyMetricsService } from '../daily-metrics/daily-metrics.service';
import { DRIZZLE } from '../drizzle/drizzle.module';
import { consumedMeals, dailyMetrics, meals } from '../drizzle/schema';
import { DrizzleDB } from '../drizzle/types/drizzle';
import { MealsService } from '../meals/meals.service';
import { ConsumeMealDto } from './dto/consume-meal.dto';

@Injectable()
export class ConsumedMealsService {
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDB,
    private readonly dailyMetricsService: DailyMetricsService,
    private readonly mealsService: MealsService,
  ) {}

  async create(userId: number, consumeMealDto: ConsumeMealDto) {
    const metric = await this.dailyMetricsService.getOrCreateForDate(
      userId,
      consumeMealDto.date,
    );

    await this.mealsService.findOne(consumeMealDto.meal_id);

    const [created] = await this.db
      .insert(consumedMeals)
      .values({
        meal_id: consumeMealDto.meal_id,
        metrics_id: metric.metrics_id,
        quantity: consumeMealDto.quantity ?? 1,
      })
      .returning();

    await this.dailyMetricsService.syncCaloriesFromConsumedMeals(
      metric.metrics_id,
      userId,
    );

    return this.findOne(userId, created.consumed_id);
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
      this.db
        .select({
          consumed_id: consumedMeals.consumed_id,
          quantity: consumedMeals.quantity,
          consumed_at: consumedMeals.consumed_at,
          metrics_id: consumedMeals.metrics_id,
          meal_id: meals.meal_id,
          meal_name: meals.name,
          meal_description: meals.description,
          calories: meals.calories,
          protein: meals.protein,
          carbs: meals.carbs,
          fat: meals.fat,
        })
        .from(consumedMeals)
        .innerJoin(meals, eq(consumedMeals.meal_id, meals.meal_id))
        .where(inArray(consumedMeals.metrics_id, metricIds))
        .orderBy(desc(consumedMeals.consumed_at))
        .limit(limit)
        .offset(offset),
      this.db
        .select({ value: count() })
        .from(consumedMeals)
        .where(inArray(consumedMeals.metrics_id, metricIds)),
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
    const row = await this.db
      .select({
        consumed_id: consumedMeals.consumed_id,
        quantity: consumedMeals.quantity,
        consumed_at: consumedMeals.consumed_at,
        metrics_id: consumedMeals.metrics_id,
        meal_id: meals.meal_id,
        meal_name: meals.name,
        meal_description: meals.description,
        calories: meals.calories,
        protein: meals.protein,
        carbs: meals.carbs,
        fat: meals.fat,
      })
      .from(consumedMeals)
      .innerJoin(meals, eq(consumedMeals.meal_id, meals.meal_id))
      .innerJoin(
        dailyMetrics,
        eq(consumedMeals.metrics_id, dailyMetrics.metrics_id),
      )
      .where(
        and(
          eq(consumedMeals.consumed_id, id),
          eq(dailyMetrics.user_id, userId),
        ),
      )
      .then((rows) => rows[0]);

    if (!row) {
      throw new NotFoundException(`Consumed meal with ID ${id} not found`);
    }

    return row;
  }

  async remove(userId: number, id: number) {
    const current = await this.findOne(userId, id);

    const deleted = await this.db
      .delete(consumedMeals)
      .where(eq(consumedMeals.consumed_id, id))
      .returning();

    await this.dailyMetricsService.syncCaloriesFromConsumedMeals(
      current.metrics_id,
      userId,
    );

    return { deleted: deleted.length > 0 };
  }
}
