import {
  Injectable,
  Inject,
  ConflictException,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { eq } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.module';
import { DrizzleDB } from '../drizzle/types/drizzle';
import { goals, User } from '../drizzle/schema';
import { UsersService } from '../users/users.service';
import { CreateGoalDto } from './dto/create-goal.dto';
import { UpdateGoalDto } from './dto/update-goal.dto';
import { GoalCalculationResultDto } from './dto/goal-response.dto';

// Constants for calorie calculations
const CALORIES_PER_KG = 7700;
const ACTIVITY_MULTIPLIER = 1.2;
const MIN_DAILY_CALORIES = 1200;
const MAX_DAILY_CALORIES = 5000;

@Injectable()
export class GoalsService {
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDB,
    private readonly usersService: UsersService,
  ) {}

  private calculateAge(dateOfBirth: string): number {
    const today = new Date();
    const birthDate = new Date(dateOfBirth);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();

    if (
      monthDiff < 0 ||
      (monthDiff === 0 && today.getDate() < birthDate.getDate())
    ) {
      age--;
    }

    return age;
  }

  /**
   * Calculate BMR using Mifflin-St Jeor formula
   * Men: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) + 5
   * Women: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) - 161
   */
  private calculateBMR(
    weight: number,
    height: number,
    age: number,
    gender: 'male' | 'female',
  ): number {
    const baseBMR = 10 * weight + 6.25 * height - 5 * age;
    return gender === 'male' ? baseBMR + 5 : baseBMR - 161;
  }

  // Calculate TDEE by multiplying BMR with activity multiplier
  private calculateTDEE(bmr: number): number {
    return Math.round(bmr * ACTIVITY_MULTIPLIER);
  }

  private calculateDailyCalorieAdjustment(
    weeklyRate: number,
    goalType: 'lose' | 'gain',
  ): number {
    const weeklyCalories = weeklyRate * CALORIES_PER_KG;
    const dailyAdjustment = Math.round(weeklyCalories / 7);
    return goalType === 'lose' ? -dailyAdjustment : dailyAdjustment;
  }

  //calc target date based on weight difference and weekly rate
  private calculateTargetDate(
    currentWeight: number,
    targetWeight: number,
    weeklyRate: number,
  ): { weeks: number; targetDate: string } {
    const weightDifference = Math.abs(currentWeight - targetWeight);
    const weeks = Math.ceil(weightDifference / weeklyRate);

    const targetDate = new Date();
    targetDate.setDate(targetDate.getDate() + weeks * 7);

    return {
      weeks,
      targetDate: targetDate.toISOString().split('T')[0],
    };
  }


  private validateGoal(
    currentWeight: number,
    targetWeight: number,
    goalType: 'lose' | 'gain',
  ): void {
    if (goalType === 'lose' && targetWeight >= currentWeight) {
      throw new BadRequestException(
        'Target weight must be less than current weight for a "lose" goal',
      );
    }

    if (goalType === 'gain' && targetWeight <= currentWeight) {
      throw new BadRequestException(
        'Target weight must be greater than current weight for a "gain" goal',
      );
    }
  }


  private calculateGoalParameters(
    user: User,
    createGoalDto: CreateGoalDto,
  ): GoalCalculationResultDto {
    const currentWeight = parseFloat(user.weight);
    const height = parseFloat(user.height);
    const age = this.calculateAge(user.date_of_birth);
    const { type, target_weight, weekly_rate } = createGoalDto;

    // Validate goal type matches weight direction
    this.validateGoal(currentWeight, target_weight, type);

    // Calculate BMR
    const bmr = Math.round(
      this.calculateBMR(currentWeight, height, age, user.gender),
    );

    // Calculate TDEE
    const tdee = this.calculateTDEE(bmr);

    // Calculate daily calorie adjustment
    const dailyCalorieAdjustment = this.calculateDailyCalorieAdjustment(
      weekly_rate,
      type,
    );

    // Calculate recommended daily calories
    let dailyCalories = tdee + dailyCalorieAdjustment;

    // Ensure calories are within safe range
    dailyCalories = Math.max(MIN_DAILY_CALORIES, dailyCalories);
    dailyCalories = Math.min(MAX_DAILY_CALORIES, dailyCalories);

    // Calculate target date
    const { weeks, targetDate } = this.calculateTargetDate(
      currentWeight,
      target_weight,
      weekly_rate,
    );

    return {
      type,
      current_weight: currentWeight,
      target_weight,
      weight_to_change: Math.abs(currentWeight - target_weight),
      weekly_rate,
      estimated_weeks: weeks,
      target_date: targetDate,
      bmr,
      tdee,
      daily_calorie_adjustment: dailyCalorieAdjustment,
      daily_calories: dailyCalories,
    };
  }

  async create(userId: number, createGoalDto: CreateGoalDto) {
    // Check if user already has a goal
    const existingGoal = await this.db.query.goals.findFirst({
      where: eq(goals.user_id, userId),
    });

    if (existingGoal) {
      throw new ConflictException(
        'User already has a goal. Use update or delete the existing goal first.',
      );
    }

    // Fetch user data
    const user = await this.usersService.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Calculate goal parameters
    const calculation = this.calculateGoalParameters(user, createGoalDto);

    // Create goal in database
    const [newGoal] = await this.db
      .insert(goals)
      .values({
        type: createGoalDto.type,
        target_weight: createGoalDto.target_weight.toString(),
        weekly_rate: createGoalDto.weekly_rate.toString(),
        daily_calories: calculation.daily_calories,
        target_date: calculation.target_date,
        user_id: userId,
      })
      .returning();

    return {
      goal: newGoal,
      calculation,
    };
  }

  async findByUserId(userId: number) {
    const goal = await this.db.query.goals.findFirst({
      where: eq(goals.user_id, userId),
    });

    if (!goal) {
      throw new NotFoundException('Goal not found for this user');
    }

    return goal;
  }

  async findAll() {
    return this.db.query.goals.findMany();
  }

  async findOne(goalId: number) {
    const goal = await this.db.query.goals.findFirst({
      where: eq(goals.goal_id, goalId),
    });

    if (!goal) {
      throw new NotFoundException(`Goal with ID ${goalId} not found`);
    }

    return goal;
  }

  async update(userId: number, updateGoalDto: UpdateGoalDto) {
    // Check if user has a goal
    const existingGoal = await this.db.query.goals.findFirst({
      where: eq(goals.user_id, userId),
    });

    if (!existingGoal) {
      throw new NotFoundException('Goal not found for this user');
    }

    // Fetch user data for recalculation
    const user = await this.usersService.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Merge existing values with updates
    const mergedGoal: CreateGoalDto = {
      type: updateGoalDto.type ?? (existingGoal.type as 'lose' | 'gain'),
      target_weight:
        updateGoalDto.target_weight ?? parseFloat(existingGoal.target_weight),
      weekly_rate:
        updateGoalDto.weekly_rate ?? parseFloat(existingGoal.weekly_rate),
    };

    // Recalculate goal parameters
    const calculation = this.calculateGoalParameters(user, mergedGoal);

    // Update goal in database
    const [updatedGoal] = await this.db
      .update(goals)
      .set({
        type: mergedGoal.type,
        target_weight: mergedGoal.target_weight.toString(),
        weekly_rate: mergedGoal.weekly_rate.toString(),
        daily_calories: calculation.daily_calories,
        target_date: calculation.target_date,
      })
      .where(eq(goals.user_id, userId))
      .returning();

    return {
      goal: updatedGoal,
      calculation,
    };
  }

  async remove(userId: number) {
    const existingGoal = await this.db.query.goals.findFirst({
      where: eq(goals.user_id, userId),
    });

    if (!existingGoal) {
      throw new NotFoundException('Goal not found for this user');
    }

    await this.db.delete(goals).where(eq(goals.user_id, userId));

    return { message: 'Goal deleted successfully' };
  }

}
