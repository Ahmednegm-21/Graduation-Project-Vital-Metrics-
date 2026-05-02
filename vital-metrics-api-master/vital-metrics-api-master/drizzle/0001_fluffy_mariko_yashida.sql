CREATE TABLE "activities" (
	"activity_id" serial PRIMARY KEY NOT NULL,
	"type" text NOT NULL,
	"duration" integer NOT NULL,
	"calories_burned" integer NOT NULL,
	"metrics_id" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "daily_metrics" (
	"metrics_id" serial PRIMARY KEY NOT NULL,
	"date" date NOT NULL,
	"total_steps" integer DEFAULT 0,
	"total_calories" integer DEFAULT 0,
	"user_id" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "meals" (
	"meal_id" serial PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"calories" integer NOT NULL,
	"protein" numeric(5, 2) NOT NULL,
	"carbs" numeric(5, 2) NOT NULL,
	"fat" numeric(5, 2) NOT NULL,
	"user_meal_id" integer,
	CONSTRAINT "meals_name_unique" UNIQUE("name")
);
--> statement-breakpoint
CREATE TABLE "notifications" (
	"notification_id" serial PRIMARY KEY NOT NULL,
	"message" text NOT NULL,
	"time" timestamp DEFAULT now() NOT NULL,
	"is_read" boolean DEFAULT false NOT NULL,
	"user_id" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sleeps" (
	"sleep_id" serial PRIMARY KEY NOT NULL,
	"duration" integer NOT NULL,
	"quality" text NOT NULL,
	"metrics_id" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "user_meals" (
	"user_meal_id" serial PRIMARY KEY NOT NULL,
	"user_id" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "voice_logs" (
	"log_id" serial PRIMARY KEY NOT NULL,
	"transcript" text NOT NULL,
	"time" timestamp DEFAULT now() NOT NULL,
	"user_id" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "water_intakes" (
	"water_id" serial PRIMARY KEY NOT NULL,
	"amount_ml" integer NOT NULL,
	"time" timestamp DEFAULT now() NOT NULL,
	"metrics_id" integer NOT NULL
);
--> statement-breakpoint
ALTER TABLE "activities" ADD CONSTRAINT "activities_metrics_id_daily_metrics_metrics_id_fk" FOREIGN KEY ("metrics_id") REFERENCES "public"."daily_metrics"("metrics_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "daily_metrics" ADD CONSTRAINT "daily_metrics_user_id_users_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "meals" ADD CONSTRAINT "meals_user_meal_id_user_meals_user_meal_id_fk" FOREIGN KEY ("user_meal_id") REFERENCES "public"."user_meals"("user_meal_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_users_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sleeps" ADD CONSTRAINT "sleeps_metrics_id_daily_metrics_metrics_id_fk" FOREIGN KEY ("metrics_id") REFERENCES "public"."daily_metrics"("metrics_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_meals" ADD CONSTRAINT "user_meals_user_id_users_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "voice_logs" ADD CONSTRAINT "voice_logs_user_id_users_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "water_intakes" ADD CONSTRAINT "water_intakes_metrics_id_daily_metrics_metrics_id_fk" FOREIGN KEY ("metrics_id") REFERENCES "public"."daily_metrics"("metrics_id") ON DELETE no action ON UPDATE no action;