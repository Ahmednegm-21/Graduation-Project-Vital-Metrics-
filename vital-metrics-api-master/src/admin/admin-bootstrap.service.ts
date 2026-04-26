import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { UsersService } from '../users/users.service';
import { AUTH_CONFIG } from '../auth/constants/auth.constants';

@Injectable()
export class AdminBootstrapService implements OnApplicationBootstrap {
  private readonly logger = new Logger(AdminBootstrapService.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly usersService: UsersService,
  ) {}

  async onApplicationBootstrap(): Promise<void> {
    const adminEmail = this.configService.get<string>('ADMIN_EMAIL');
    const adminPassword = this.configService.get<string>('ADMIN_PASSWORD');

    if (!adminEmail || !adminPassword) {
      this.logger.warn(
        'ADMIN_EMAIL or ADMIN_PASSWORD not set — skipping admin bootstrap.',
      );
      return;
    }

    const existingAdmin =
      await this.usersService.findByEmailOptional(adminEmail);

    if (existingAdmin) {
      this.logger.log(
        `Admin user already exists (email: ${adminEmail}). Skipping bootstrap.`,
      );
      return;
    }

    const hashedPassword = await bcrypt.hash(
      adminPassword,
      AUTH_CONFIG.SALT_ROUNDS,
    );

    await this.usersService.createSystemAdmin(adminEmail, hashedPassword);

    this.logger.log(
      `✅  Admin user bootstrapped successfully (email: ${adminEmail}).`,
    );
  }
}
