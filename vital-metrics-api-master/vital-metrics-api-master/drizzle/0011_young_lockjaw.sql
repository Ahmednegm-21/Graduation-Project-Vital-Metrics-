CREATE TABLE "consumed_meals" (
	"consumed_id" serial PRIMARY KEY NOT NULL,
	"quantity" integer DEFAULT 1 NOT NULL,
	"consumed_at" timestamp DEFAULT now() NOT NULL,
	"meal_id" integer NOT NULL,
	"metrics_id" integer NOT NULL
);
--> statement-breakpoint
ALTER TABLE "meals" DROP CONSTRAINT "meals_metrics_id_daily_metrics_metrics_id_fk";
--> statement-breakpoint
ALTER TABLE "meals" ADD COLUMN "description" text;--> statement-breakpoint
ALTER TABLE "meals" ADD COLUMN "created_at" timestamp DEFAULT now() NOT NULL;--> statement-breakpoint
ALTER TABLE "meals" ADD COLUMN "updated_at" timestamp DEFAULT now() NOT NULL;--> statement-breakpoint
INSERT INTO "consumed_meals" ("meal_id", "metrics_id", "quantity")
SELECT "meal_id", "metrics_id", 1
FROM "meals";
--> statement-breakpoint
ALTER TABLE "consumed_meals" ADD CONSTRAINT "consumed_meals_meal_id_meals_meal_id_fk" FOREIGN KEY ("meal_id") REFERENCES "public"."meals"("meal_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "consumed_meals" ADD CONSTRAINT "consumed_meals_metrics_id_daily_metrics_metrics_id_fk" FOREIGN KEY ("metrics_id") REFERENCES "public"."daily_metrics"("metrics_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "daily_metrics" DROP COLUMN "total_calories";--> statement-breakpoint
ALTER TABLE "meals" DROP COLUMN "metrics_id";