ALTER TABLE "daily_metrics" ADD COLUMN "calories_consumed" integer DEFAULT 0 NOT NULL;--> statement-breakpoint
ALTER TABLE "daily_metrics" ADD COLUMN "burned_total" integer DEFAULT 0 NOT NULL;