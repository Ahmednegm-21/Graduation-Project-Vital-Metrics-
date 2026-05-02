ALTER TABLE "goals" ADD COLUMN "weekly_rate" numeric(3, 2) NOT NULL;--> statement-breakpoint
ALTER TABLE "goals" ADD COLUMN "target_date" date NOT NULL;--> statement-breakpoint
ALTER TABLE "goals" ADD COLUMN "created_at" timestamp DEFAULT now() NOT NULL;