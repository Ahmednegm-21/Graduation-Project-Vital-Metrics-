import { Module } from '@nestjs/common';
import { WaterIntakesService } from './water-intakes.service';
import { WaterIntakesController } from './water-intakes.controller';
import { DrizzleModule } from '../drizzle/drizzle.module';
import { DailyMetricsModule } from '../daily-metrics/daily-metrics.module';

@Module({
  imports: [DrizzleModule, DailyMetricsModule],
  controllers: [WaterIntakesController],
  providers: [WaterIntakesService],
})
export class WaterIntakesModule {}
