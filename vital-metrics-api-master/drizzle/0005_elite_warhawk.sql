CREATE TABLE "device_tokens" (
	"token_id" serial PRIMARY KEY NOT NULL,
	"token" text NOT NULL,
	"platform" text NOT NULL,
	"device_name" text,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	"user_id" integer NOT NULL,
	CONSTRAINT "device_tokens_token_unique" UNIQUE("token")
);
--> statement-breakpoint
CREATE TABLE "notification_preferences" (
	"preference_id" serial PRIMARY KEY NOT NULL,
	"push_enabled" boolean DEFAULT true NOT NULL,
	"daily_reminder" boolean DEFAULT true NOT NULL,
	"goal_alerts" boolean DEFAULT true NOT NULL,
	"water_reminders" boolean DEFAULT true NOT NULL,
	"meal_reminders" boolean DEFAULT true NOT NULL,
	"activity_reminders" boolean DEFAULT true NOT NULL,
	"sleep_reminders" boolean DEFAULT true NOT NULL,
	"quiet_hours_start" text,
	"quiet_hours_end" text,
	"user_id" integer NOT NULL,
	CONSTRAINT "notification_preferences_user_id_unique" UNIQUE("user_id")
);
--> statement-breakpoint
ALTER TABLE "notifications" DROP CONSTRAINT "notifications_user_id_users_user_id_fk";
--> statement-breakpoint
ALTER TABLE "notifications" ADD COLUMN "title" text NOT NULL;--> statement-breakpoint
ALTER TABLE "notifications" ADD COLUMN "type" text NOT NULL;--> statement-breakpoint
ALTER TABLE "notifications" ADD COLUMN "data" text;--> statement-breakpoint
ALTER TABLE "notifications" ADD COLUMN "push_sent" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "notifications" ADD COLUMN "push_sent_at" timestamp;--> statement-breakpoint
ALTER TABLE "device_tokens" ADD CONSTRAINT "device_tokens_user_id_users_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "notification_preferences" ADD CONSTRAINT "notification_preferences_user_id_users_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_users_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE cascade ON UPDATE no action;