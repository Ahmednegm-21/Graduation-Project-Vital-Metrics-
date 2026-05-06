import { Module, forwardRef } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { DrizzleModule } from 'src/drizzle/drizzle.module';
import { GoalsModule } from '../goals/goals.module';

@Module({
  providers: [UsersService],
  controllers: [UsersController],
  imports: [DrizzleModule, forwardRef(() => GoalsModule)],
  exports: [UsersService],
})
export class UsersModule {}
