-- ============================================================
-- MIGRATION: Rename promotions table columns to snake_case
-- Run this in Supabase SQL Editor if your promotions table 
-- still uses camelCase column names
-- ============================================================

-- Check current schema (will show which columns exist)
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'promotions';

-- If you see 'createdAt' and 'updatedAt', run these commands:

-- 1. Rename createdAt to created_at
ALTER TABLE promotions RENAME COLUMN "createdAt" TO created_at;

-- 2. Rename updatedAt to updated_at
ALTER TABLE promotions RENAME COLUMN "updatedAt" TO updated_at;

-- 3. Rename bannerUrl to banner_url
ALTER TABLE promotions RENAME COLUMN "bannerUrl" TO banner_url;

-- 4. Verify the changes
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'promotions'
ORDER BY ordinal_position;

-- ============================================================
-- Expected columns after migration:
-- id, promoType, code, banner_url, discountPercent, 
-- description, active, created_at, updated_at
-- ============================================================
