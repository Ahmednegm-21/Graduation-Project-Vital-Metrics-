import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DrizzleModule } from './drizzle/drizzle.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { OtpModule } from './otp/otp.module';
import { MailModule } from './mail/mail.module';
import { FirebaseModule } from './firebase/firebase.module';
import { NotificationsModule } from './notifications/notifications.module';
import { DeviceTokensModule } from './device-tokens/device-tokens.module';
import { NotificationPreferencesModule } from './notification-preferences/notification-preferences.module';
import { GoalsModule } from './goals/goals.module';
import { DailyMetricsModule } from './daily-metrics/daily-metrics.module';
import { ActivitiesModule } from './activities/activities.module';
import { MealsModule } from './meals/meals.module';
import { ConsumedMealsModule } from './consumed-meals/consumed-meals.module';
import { WaterIntakesModule } from './water-intakes/water-intakes.module';
import { SleepsModule } from './sleeps/sleeps.module';
import { AdminModule } from './admin/admin.module';

@Module({
  imports: [
    DrizzleModule,
    ConfigModule.forRoot({ isGlobal: true }),
    ScheduleModule.forRoot(),
    AuthModule,
    UsersModule,
    OtpModule,
    MailModule,
    FirebaseModule,
    NotificationsModule,
    DeviceTokensModule,
    NotificationPreferencesModule,
    GoalsModule,
    DailyMetricsModule,
    ActivitiesModule,
    MealsModule,
    ConsumedMealsModule,
    WaterIntakesModule,
    SleepsModule,
    AdminModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
