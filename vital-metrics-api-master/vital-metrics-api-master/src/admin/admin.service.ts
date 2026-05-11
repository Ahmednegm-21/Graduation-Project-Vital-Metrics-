import {
  Injectable,
  Inject,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { count, eq, and, or, ilike } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.module';
import { DrizzleDB } from '../drizzle/types/drizzle';
import {
  users,
  goals,
  meals,
  dailyMetrics,
} from '../drizzle/schema';
import { MealsService } from '../meals/meals.service';
import { CreateMealDto } from '../meals/dto/create-meal.dto';
import { UpdateMealDto } from '../meals/dto/update-meal.dto';

@Injectable()
export class AdminService {
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDB,
    private readonly mealsService: MealsService,
  ) {}

  // ─── Users ───────────────────────────────────────────────────────────────

  async getUsers(page: number, limit: number, search?: string) {
    const offset = (page - 1) * limit;

    let condition = eq(users.is_admin, false);

    if (search) {
      condition = and(
        condition,
        or(
          ilike(users.name, `%${search}%`),
          ilike(users.email, `%${search}%`),
        ),
      );
    }

    const [allUsers, [{ value: total }]] = await Promise.all([
      this.db.query.users.findMany({
        offset,
        limit,
        columns: {
          password: false,
          refresh_token: false,
          google_sub: false,
        },
        where: condition,
        orderBy: (table, { asc }) => [asc(table.user_id)],
      }),
      this.db
        .select({ value: count() })
        .from(users)
        .where(condition),
    ]);

    return {
      data: allUsers,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async deleteUser(targetId: number, requestingAdminId: number) {
    if (targetId === requestingAdminId) {
      throw new ForbiddenException('Admin cannot delete their own account.');
    }

    const user = await this.db.query.users.findFirst({
      where: eq(users.user_id, targetId),
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${targetId} not found.`);
    }

    if (user.is_admin) {
      throw new ForbiddenException('Cannot delete another admin account.');
    }

    await this.db.delete(users).where(eq(users.user_id, targetId));

    return { message: `User ${targetId} deleted successfully.` };
  }

  // ─── Platform Metrics Overview ────────────────────────────────────────────

  async getMetricsOverview() {
    const [
      [{ value: totalUsers }],
      [{ value: totalGoals }],
      [{ value: totalMeals }],
      [{ value: totalMetricsRecords }],
    ] = await Promise.all([
      this.db.select({ value: count() }).from(users),
      this.db.select({ value: count() }).from(goals),
      this.db.select({ value: count() }).from(meals),
      this.db.select({ value: count() }).from(dailyMetrics),
    ]);

    return {
      totalUsers,
      totalGoals,
      totalMeals,
      totalDailyMetricsRecords: totalMetricsRecords,
    };
  }

  // ─── Meals Catalog ────────────────────────────────────────────────────────

  createMeal(dto: CreateMealDto) {
    return this.mealsService.create(dto);
  }

  updateMeal(id: number, dto: UpdateMealDto) {
    return this.mealsService.update(id, dto);
  }

  deleteMeal(id: number) {
    return this.mealsService.remove(id);
  }
}
