ALTER TABLE "user_meals" DISABLE ROW LEVEL SECURITY;--> statement-breakpoint
DROP TABLE IF EXISTS "user_meals" CASCADE;--> statement-breakpoint
ALTER TABLE "meals" DROP CONSTRAINT IF EXISTS "meals_name_unique";--> statement-breakpoint
ALTER TABLE "meals" DROP CONSTRAINT IF EXISTS "meals_user_meal_id_user_meals_user_meal_id_fk";
--> statement-breakpoint
ALTER TABLE "meals" ADD COLUMN IF NOT EXISTS "metrics_id" integer NOT NULL;--> statement-breakpoint
ALTER TABLE "meals" ADD CONSTRAINT "meals_metrics_id_daily_metrics_metrics_id_fk" FOREIGN KEY ("metrics_id") REFERENCES "public"."daily_metrics"("metrics_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "meals" DROP COLUMN IF EXISTS "user_meal_id";