import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { eq } from 'drizzle-orm';
import { DRIZZLE } from 'src/drizzle/drizzle.module';
import { DrizzleDB } from 'src/drizzle/types/drizzle';
import { users } from '../drizzle/schema';
import { UpdateProfileDto } from './dtos/update-profile.dto';

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

  /** Finds a user by email without throwing — returns null when not found. */
  async findByEmailOptional(email: string) {
    return this.db.query.users.findFirst({
      where: (users) => eq(users.email, email),
    });
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

  async updateProfile(userId: number, dto: UpdateProfileDto) {
    const updateData: Record<string, any> = {};

    if (dto.name !== undefined) updateData.name = dto.name;
    if (dto.gender !== undefined) updateData.gender = dto.gender;
    if (dto.date_of_birth !== undefined) updateData.date_of_birth = dto.date_of_birth;
    if (dto.height !== undefined) updateData.height = dto.height.toString();
    if (dto.weight !== undefined) updateData.weight = dto.weight.toString();

    if (Object.keys(updateData).length === 0) {
      return this.findById(userId);
    }

    const [updated] = await this.db
      .update(users)
      .set(updateData)
      .where(eq(users.user_id, userId))
      .returning();

    return updated;
  }

  /**
   * Creates the bootstrapped system admin user.
   * Always sets is_admin=true and is_verified=true.
   * Uses dummy defaults for profile fields that are required by the schema
   * but irrelevant for the admin account.
   */
  async createSystemAdmin(email: string, hashedPassword: string) {
    const [admin] = await this.db
      .insert(users)
      .values({
        email,
        password: hashedPassword,
        name: 'System Admin',
        gender: 'male',
        date_of_birth: '1990-01-01',
        height: '175',
        weight: '70',
        is_admin: true,
        is_verified: true,
      })
      .returning();

    return admin;
  }
}
