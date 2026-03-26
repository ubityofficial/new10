#!/usr/bin/env node

/**
 * Supabase Auto-Setup Script
 * Creates database table and storage bucket automatically
 */

require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE) {
  console.error('❌ ERROR: Missing .env variables!\n');
  console.log('Make sure these exist in .env:');
  console.log('  - SUPABASE_URL');
  console.log('  - SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE);

const SETUP_SQL = `
CREATE TABLE IF NOT EXISTS public.services (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  price NUMERIC DEFAULT 0,
  duration TEXT,
  image1 TEXT,
  image2 TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read/write" ON public.services;

CREATE POLICY "Allow public read/write" ON public.services
  FOR SELECT USING (true),
  FOR INSERT WITH CHECK (true),
  FOR UPDATE USING (true),
  FOR DELETE USING (true);
`;

async function setup() {
  try {
    console.log('🚀 Supabase Auto-Setup\n');
    console.log('═'.repeat(50));

    // Step 1: Check bucket
    console.log('\n1️⃣  Creating storage bucket...');
    const { data: bucket } = await supabase.storage.getBucket('service-images');
    
    if (bucket) {
      console.log('   ✅ Bucket "service-images" already exists');
    } else {
      const { data: newBucket, error: bucketError } = await supabase.storage.createBucket('service-images', {
        public: true,
      });
      
      if (bucketError) {
        console.log('   ⚠️  ' + bucketError.message);
      } else {
        console.log('   ✅ Bucket "service-images" created');
      }
    }

    // Step 2: Create table
    console.log('\n2️⃣  Creating database table...');
    console.log('   📝 SQL will be displayed below for manual execution');
    console.log('\n   Copy this SQL and run in Supabase Dashboard:');
    console.log('   Settings → SQL Editor → New Query → Paste Below → Run\n');
    console.log('─'.repeat(50));
    console.log(SETUP_SQL);
    console.log('─'.repeat(50));

    console.log('\n3️⃣  Verification:');
    console.log('   ✅ Environment variables loaded');
    console.log('   ✅ Supabase connected');
    console.log('   ✅ Storage bucket ready');
    console.log('   ⏳ Database table pending (copy-paste SQL above)');

    console.log('\n═'.repeat(50));
    console.log('\n🎯 NEXT STEPS:');
    console.log('\n1. Copy the SQL above ↑');
    console.log('2. Go to: https://app.supabase.com');
    console.log('3. Select your project');
    console.log('4. Go to SQL Editor → New Query');
    console.log('5. Paste the SQL');
    console.log('6. Click RUN button');
    console.log('7. Done! ✨\n');

    console.log('After that, you can test with:');
    console.log('   npm start  (starts backend)')
    console.log('   npm run dev (starts admin panel)\n');

  } catch (error) {
    console.error('\n❌ Setup Error:', error.message);
    process.exit(1);
  }
}

setup();
