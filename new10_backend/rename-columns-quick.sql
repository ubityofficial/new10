-- Quick migration: Rename promotions columns to snake_case
-- Copy and paste this into Supabase SQL Editor

ALTER TABLE promotions RENAME COLUMN "createdAt" TO created_at;
ALTER TABLE promotions RENAME COLUMN "updatedAt" TO updated_at;
ALTER TABLE promotions RENAME COLUMN "bannerUrl" TO banner_url;
