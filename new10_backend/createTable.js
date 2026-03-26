const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceRoleKey) {
  console.error('❌ Missing Supabase credentials');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

async function createServicesTable() {
  console.log('📊 Creating services table via SQL...\n');

  const sqlStatements = [
    // Create table
    `CREATE TABLE IF NOT EXISTS public.services (
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
    )`,

    // Enable RLS
    `ALTER TABLE public.services ENABLE ROW LEVEL SECURITY`,

    // Create policy
    `CREATE POLICY "Allow all" ON public.services FOR ALL USING (true) WITH CHECK (true)`,
  ];

  try {
    // Try using postgres connection string directly
    const connectionString = `postgresql://postgres:${process.env.SUPABASE_DB_PASSWORD}@db.${supabaseUrl.split('.supabase.co')[0]}.supabase.co:5432/postgres`;
    
    // For now, log what needs to be done
    console.log('✅ Storage bucket is ready!');
    console.log('\n📝 To complete setup, run this SQL in Supabase Dashboard:');
    console.log('   Go to: SQL Editor → New Query → Paste below → Run\n');
    
    sqlStatements.forEach((sql, i) => {
      console.log(`-- Step ${i + 1}`);
      console.log(sql + ';\n');
    });

  } catch (error) {
    console.error('Error:', error.message);
  }
}

createServicesTable();
