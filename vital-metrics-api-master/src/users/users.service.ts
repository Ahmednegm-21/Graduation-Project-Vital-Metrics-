import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { eq } from 'drizzle-orm';
import { DRIZZLE } from 'src/drizzle/drizzle.module';
import { DrizzleDB } from 'src/drizzle/types/drizzle';
import { users } from '../drizzle/schema';

interface CreateUserData {
  email: string;
  password: string;
  name: string;
  gender: 'male' | 'female';
  date_of_birth: string;
  height: number;
  weight: number;
}

interface CreateUserOptions {
  isVerified?: boolean;
  googleSub?: string;
}

@Injectable()
export class UsersService {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDB) {}

  async findById(userId: number) {
    return await this.db.query.users.findFirst({
      where: (users) => eq(users.user_id, userId),
    });
  }

  async findByEmail(email: string) {
    const user = await this.db.query.users.findFirst({
      where: (users) => eq(users.email, email),
    });
    if (!user) {
      throw new NotFoundException(`User not found`);
    }
    return user;
  }

  async findByGoogleSub(googleSub: string) {
    return await this.db.query.users.findFirst({
      where: (users) => eq(users.google_sub, googleSub),
    });
  }

  async checkEmailExists(email: string): Promise<boolean> {
    const user = await this.db.query.users.findFirst({
      where: (users) => eq(users.email, email),
    });
    return !!user;
  }

  async checkUsernameExists(name: string): Promise<boolean> {
    const user = await this.db.query.users.findFirst({
      where: (users) => eq(users.name, name),
    });
    return !!user;
  }

  async createUser(
    userData: CreateUserData,
    hashedPassword: string,
    options: CreateUserOptions = {},
  ) {
    const { email, name, gender, date_of_birth, height, weight } = userData;
    const { isVerified = false, googleSub } = options;

    const [newUser] = await this.db
      .insert(users)
      .values({
        email,
        password: hashedPassword,
        name,
        google_sub: googleSub,
        gender,
        date_of_birth,
        height: height.toString(),
        weight: weight.toString(),
        is_admin: false,
        is_verified: isVerified,
      })
      .returning();

    return newUser;
  }

  async updateRefreshToken(userId: number, hashedRefreshToken: string | null) {
    await this.db
      .update(users)
      .set({ refresh_token: hashedRefreshToken })
      .where(eq(users.user_id, userId));
  }

  async updatePassword(userId: number, hashedPassword: string) {
    await this.db
      .update(users)
      .set({ password: hashedPassword })
      .where(eq(users.user_id, userId));
  }

  async markVerified(userId: number, isVerified: boolean) {
    await this.db
      .update(users)
      .set({ is_verified: isVerified })
      .where(eq(users.user_id, userId));
  }

  async updateGoogleSub(userId: number, googleSub: string) {
    await this.db
      .update(users)
      .set({ google_sub: googleSub })
      .where(eq(users.user_id, userId));
  }
}
