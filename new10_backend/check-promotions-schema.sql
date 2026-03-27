-- Check the actual column names in your promotions table
-- Run this in Supabase SQL Editor to see what columns exist

SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'promotions'
ORDER BY ordinal_position;
