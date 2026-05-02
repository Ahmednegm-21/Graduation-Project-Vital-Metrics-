import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { AdminBootstrapService } from './admin-bootstrap.service';
import { UsersModule } from '../users/users.module';
import { MealsModule } from '../meals/meals.module';
import { DrizzleModule } from '../drizzle/drizzle.module';

@Module({
  imports: [ConfigModule, UsersModule, MealsModule, DrizzleModule],
  controllers: [AdminController],
  providers: [AdminService, AdminBootstrapService],
})
export class AdminModule {}
