import { Module } from '@nestjs/common';
import { DailyMetricsModule } from '../daily-metrics/daily-metrics.module';
import { DrizzleModule } from '../drizzle/drizzle.module';
import { MealsModule } from '../meals/meals.module';
import { ConsumedMealsController } from './consumed-meals.controller';
import { ConsumedMealsService } from './consumed-meals.service';

@Module({
  imports: [DrizzleModule, DailyMetricsModule, MealsModule],
  controllers: [ConsumedMealsController],
  providers: [ConsumedMealsService],
})
export class ConsumedMealsModule {}
