ALTER TABLE "activities" DROP CONSTRAINT "activities_metrics_id_daily_metrics_metrics_id_fk";
--> statement-breakpoint
ALTER TABLE "consumed_meals" DROP CONSTRAINT "consumed_meals_meal_id_meals_meal_id_fk";
--> statement-breakpoint
ALTER TABLE "consumed_meals" DROP CONSTRAINT "consumed_meals_metrics_id_daily_metrics_metrics_id_fk";
--> statement-breakpoint
ALTER TABLE "daily_metrics" DROP CONSTRAINT "daily_metrics_user_id_users_user_id_fk";
--> statement-breakpoint
ALTER TABLE "goals" DROP CONSTRAINT "goals_user_id_users_user_id_fk";
--> statement-breakpoint
ALTER TABLE "otps" DROP CONSTRAINT "otps_user_id_users_user_id_fk";
--> statement-breakpoint
ALTER TABLE "sleeps" DROP CONSTRAINT "sleeps_metrics_id_daily_metrics_metrics_id_fk";
--> statement-breakpoint
ALTER TABLE "voice_logs" DROP CONSTRAINT "voice_logs_user_id_users_user_id_fk";
--> statement-breakpoint
ALTER TABLE "water_intakes" DROP CONSTRAINT "water_intakes_metrics_id_daily_metrics_metrics_id_fk";
--> statement-breakpoint
ALTER TABLE "activities" ADD CONSTRAINT "activities_metrics_id_daily_metrics_metrics_id_fk" FOREIGN KEY ("metrics_id") REFERENCES "public"."daily_metrics"("metrics_id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "consumed_meals" ADD CONSTRAINT "consumed_meals_meal_id_meals_meal_id_fk" FOREIGN KEY ("meal_id") REFERENCES "public"."meals"("meal_id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "consumed_meals" ADD CONSTRAINT "consumed_meals_metrics_id_daily_metrics_metrics_id_fk" FOREIGN KEY ("metrics_id") REFERENCES "public"."daily_metrics"("metrics_id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "daily_metrics" ADD CONSTRAINT "daily_metrics_user_id_users_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "goals" ADD CONSTRAINT "goals_user_id_users_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "otps" ADD CONSTRAINT "otps_user_id_users_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sleeps" ADD CONSTRAINT "sleeps_metrics_id_daily_metrics_metrics_id_fk" FOREIGN KEY ("metrics_id") REFERENCES "public"."daily_metrics"("metrics_id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "voice_logs" ADD CONSTRAINT "voice_logs_user_id_users_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "water_intakes" ADD CONSTRAINT "water_intakes_metrics_id_daily_metrics_metrics_id_fk" FOREIGN KEY ("metrics_id") REFERENCES "public"."daily_metrics"("metrics_id") ON DELETE cascade ON UPDATE no action;