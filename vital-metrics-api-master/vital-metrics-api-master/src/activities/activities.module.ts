import { Module } from '@nestjs/common';
import { ActivitiesService } from './activities.service';
import { ActivitiesController } from './activities.controller';
import { DrizzleModule } from '../drizzle/drizzle.module';
import { DailyMetricsModule } from '../daily-metrics/daily-metrics.module';

@Module({
  imports: [DrizzleModule, DailyMetricsModule],
  controllers: [ActivitiesController],
  providers: [ActivitiesService],
})
export class ActivitiesModule {}
