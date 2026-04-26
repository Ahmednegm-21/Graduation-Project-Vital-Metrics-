import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { count, eq, and, ne, lte, gte, desc, ilike, or } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.module';
import { DrizzleDB } from '../drizzle/types/drizzle';
import { meals, goals } from '../drizzle/schema';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';

@Injectable()
export class MealsService {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDB) {}

  async create(createMealDto: CreateMealDto) {
    const [created] = await this.db
      .insert(meals)
      .values({
        name: createMealDto.name,
        description: createMealDto.description ?? null,
        calories: createMealDto.calories,
        protein: createMealDto.protein.toString(),
        carbs: createMealDto.carbs.toString(),
        fat: createMealDto.fat.toString(),
        updated_at: new Date(),
      })
      .returning();

    return created;
  }

  async findAll(page: number = 1, limit: number = 20, search?: string) {
    const offset = (page - 1) * limit;

    const searchCondition = search
      ? or(
          ilike(meals.name, `%${search}%`),
          ilike(meals.description, `%${search}%`),
        )
      : undefined;

    const [data, [{ value: total }]] = await Promise.all([
      this.db.query.meals.findMany({
        where: searchCondition,
        orderBy: (table, { asc }) => [asc(table.name)],
        limit,
        offset,
      }),
      this.db
        .select({ value: count() })
        .from(meals)
        .where(searchCondition),
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

  async findOne(id: number) {
    const meal = await this.db.query.meals.findFirst({
      where: eq(meals.meal_id, id),
    });

    if (!meal) {
      throw new NotFoundException(`Meal with ID ${id} not found`);
    }

    return meal;
  }

  async update(id: number, updateMealDto: UpdateMealDto) {
    const current = await this.findOne(id);

    const [updated] = await this.db
      .update(meals)
      .set({
        name: updateMealDto.name ?? current.name,
        description:
          updateMealDto.description !== undefined
            ? updateMealDto.description
            : current.description,
        calories: updateMealDto.calories ?? current.calories,
        protein:
          updateMealDto.protein !== undefined
            ? updateMealDto.protein.toString()
            : current.protein,
        carbs:
          updateMealDto.carbs !== undefined
            ? updateMealDto.carbs.toString()
            : current.carbs,
        fat:
          updateMealDto.fat !== undefined
            ? updateMealDto.fat.toString()
            : current.fat,
        updated_at: new Date(),
      })
      .where(eq(meals.meal_id, id))
      .returning();

    return updated;
  }

  async remove(id: number) {
    await this.findOne(id);

    const deleted = await this.db
      .delete(meals)
      .where(eq(meals.meal_id, id))
      .returning();

    return { deleted: deleted.length > 0 };
  }

  async swapMeal(mealId: number, userId: number) {
    const targetMeal = await this.findOne(mealId);
    const userGoal = await this.db.query.goals.findFirst({
      where: eq(goals.user_id, userId),
    });

    const SUGGESTION_LIMIT = 5;

    let suggestions;

    if (!userGoal) {
      const lowerBound = Math.floor(targetMeal.calories * 0.9);
      const upperBound = Math.ceil(targetMeal.calories * 1.1);

      suggestions = await this.db
        .select()
        .from(meals)
        .where(
          and(
            ne(meals.meal_id, mealId),
            gte(meals.calories, lowerBound),
            lte(meals.calories, upperBound),
          ),
        )
        .orderBy(meals.calories)
        .limit(SUGGESTION_LIMIT);
    } else if (userGoal.type === 'lose') {
      suggestions = await this.db
        .select()
        .from(meals)
        .where(
          and(
            ne(meals.meal_id, mealId),
            lte(meals.calories, targetMeal.calories),
          ),
        )
        .orderBy(desc(meals.protein))
        .limit(SUGGESTION_LIMIT);
    } else {
      suggestions = await this.db
        .select()
        .from(meals)
        .where(
          and(
            ne(meals.meal_id, mealId),
            gte(meals.calories, targetMeal.calories),
          ),
        )
        .orderBy(desc(meals.protein), desc(meals.carbs), desc(meals.calories))
        .limit(SUGGESTION_LIMIT);
    }

    return {
      original_meal: targetMeal,
      goal_type: userGoal?.type ?? null,
      suggestions,
    };
  }
}
