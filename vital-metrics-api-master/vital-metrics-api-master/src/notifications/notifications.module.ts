import { Module } from '@nestjs/common';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { NotificationScheduler } from './notifications.scheduler';
import { DrizzleModule } from '../drizzle/drizzle.module';
import { FirebaseModule } from '../firebase/firebase.module';
import { DeviceTokensModule } from '../device-tokens/device-tokens.module';
import { NotificationPreferencesModule } from '../notification-preferences/notification-preferences.module';

@Module({
  imports: [
    DrizzleModule,
    FirebaseModule,
    DeviceTokensModule,
    NotificationPreferencesModule,
  ],
  controllers: [NotificationsController],
  providers: [NotificationsService, NotificationScheduler],
  exports: [NotificationsService],
})
export class NotificationsModule {}
