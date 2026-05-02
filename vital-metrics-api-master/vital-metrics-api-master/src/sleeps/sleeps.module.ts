import { Module } from '@nestjs/common';
import { SleepsService } from './sleeps.service';
import { SleepsController } from './sleeps.controller';
import { DrizzleModule } from '../drizzle/drizzle.module';
import { DailyMetricsModule } from '../daily-metrics/daily-metrics.module';

@Module({
  imports: [DrizzleModule, DailyMetricsModule],
  controllers: [SleepsController],
  providers: [SleepsService],
})
export class SleepsModule {}
