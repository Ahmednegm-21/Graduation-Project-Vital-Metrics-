import { Module } from '@nestjs/common';
import { DailyMetricsService } from './daily-metrics.service';
import { DailyMetricsController } from './daily-metrics.controller';
import { DrizzleModule } from '../drizzle/drizzle.module';
import { GoalsModule } from '../goals/goals.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [DrizzleModule, GoalsModule, NotificationsModule],
  controllers: [DailyMetricsController],
  providers: [DailyMetricsService],
  exports: [DailyMetricsService],
})
export class DailyMetricsModule {}
