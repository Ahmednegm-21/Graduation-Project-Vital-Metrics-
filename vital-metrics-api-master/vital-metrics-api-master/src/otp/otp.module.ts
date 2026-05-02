import { Module } from '@nestjs/common';
import { OtpService } from './otp.service';
import { DrizzleModule } from 'src/drizzle/drizzle.module';

@Module({
  imports: [DrizzleModule],
  providers: [OtpService],
  exports: [OtpService],
})
export class OtpModule {}
