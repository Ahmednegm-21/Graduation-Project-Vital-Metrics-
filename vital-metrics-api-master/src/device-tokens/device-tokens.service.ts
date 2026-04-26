import { Inject, Injectable, Logger } from '@nestjs/common';
import { eq, and, inArray, lt } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.module';
import { DrizzleDB } from '../drizzle/types/drizzle';
import { deviceTokens, DeviceToken } from '../drizzle/schema';
import { RegisterDeviceDto } from './dto';

@Injectable()
export class DeviceTokensService {
  private readonly logger = new Logger(DeviceTokensService.name);

  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDB) {}

  /**
   * Register a new device token or update if it already exists
   */
  async registerToken(
    userId: number,
    dto: RegisterDeviceDto,
  ): Promise<DeviceToken> {
    // Check if token already exists for any user
    const existingToken = await this.db.query.deviceTokens.findFirst({
      where: eq(deviceTokens.token, dto.token),
    });

    // If token exists for a different user, transfer it
    if (existingToken && existingToken.user_id !== userId) {
      this.logger.log(
        `Transferring token ${dto.token} from user ${existingToken.user_id} to user ${userId}`,
      );
      const [updated] = await this.db
        .update(deviceTokens)
        .set({
          user_id: userId,
          platform: dto.platform,
          device_name: dto.device_name,
          is_active: true,
          updated_at: new Date(),
        })
        .where(eq(deviceTokens.token_id, existingToken.token_id))
        .returning();
      return updated;
    }

    // If token exists for the same user, update it
    if (existingToken && existingToken.user_id === userId) {
      const [updated] = await this.db
        .update(deviceTokens)
        .set({
          platform: dto.platform,
          device_name: dto.device_name,
          is_active: true,
          updated_at: new Date(),
        })
        .where(eq(deviceTokens.token_id, existingToken.token_id))
        .returning();
      return updated;
    }

    // Create new token
    const [newToken] = await this.db
      .insert(deviceTokens)
      .values({
        token: dto.token,
        platform: dto.platform,
        device_name: dto.device_name,
        user_id: userId,
      })
      .returning();

    this.logger.log(`Registered new device token for user ${userId}`);
    return newToken;
  }

  /**
   * Get all active device tokens for a user
   */
  async getActiveTokens(userId: number): Promise<DeviceToken[]> {
    return this.db.query.deviceTokens.findMany({
      where: and(
        eq(deviceTokens.user_id, userId),
        eq(deviceTokens.is_active, true),
      ),
    });
  }

  /**
   * Get all device tokens for a user (active and inactive)
   */
  async getUserTokens(userId: number): Promise<DeviceToken[]> {
    return this.db.query.deviceTokens.findMany({
      where: eq(deviceTokens.user_id, userId),
    });
  }

  /**
   * Deactivate a specific device token
   */
  async deactivateToken(
    tokenId: number,
    userId: number,
  ): Promise<DeviceToken | null> {
    const [updated] = await this.db
      .update(deviceTokens)
      .set({ is_active: false, updated_at: new Date() })
      .where(
        and(
          eq(deviceTokens.token_id, tokenId),
          eq(deviceTokens.user_id, userId),
        ),
      )
      .returning();

    if (updated) {
      this.logger.log(`Deactivated token ${tokenId} for user ${userId}`);
    }

    return updated || null;
  }

  /**
   * Deactivate multiple tokens by their IDs (used for stale token cleanup)
   */
  async deactivateTokens(tokenIds: number[]): Promise<void> {
    if (tokenIds.length === 0) return;

    await this.db
      .update(deviceTokens)
      .set({ is_active: false, updated_at: new Date() })
      .where(
        and(
          eq(deviceTokens.is_active, true),
          inArray(deviceTokens.token_id, tokenIds),
        ),
      );

    this.logger.log(`Deactivated ${tokenIds.length} stale tokens`);
  }

  /**
   * Delete a device token
   */
  async deleteToken(tokenId: number, userId: number): Promise<boolean> {
    const result = await this.db
      .delete(deviceTokens)
      .where(
        and(
          eq(deviceTokens.token_id, tokenId),
          eq(deviceTokens.user_id, userId),
        ),
      )
      .returning();

    if (result.length > 0) {
      this.logger.log(`Deleted token ${tokenId} for user ${userId}`);
      return true;
    }

    return false;
  }

  /**
   * Cleanup inactive tokens older than 30 days
   */
  async cleanupInactiveTokens(): Promise<number> {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const result = await this.db
      .delete(deviceTokens)
      .where(
        and(
          eq(deviceTokens.is_active, false),
          lt(deviceTokens.updated_at, thirtyDaysAgo),
        ),
      )
      .returning();

    this.logger.log(`Cleaned up ${result.length} inactive tokens`);
    return result.length;
  }
}
