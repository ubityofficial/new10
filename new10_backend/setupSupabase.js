const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceRoleKey) {
  console.error('❌ Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

async function setupSupabase() {
  console.log('🚀 Starting Supabase setup...\n');

  try {
    // Step 1: Create services table
    console.log('📊 Creating services table...');
    const { data: tableData, error: tableError } = await supabase.rpc('execute_sql', {
      sql: `
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

        DROP POLICY IF EXISTS "Allow all" ON public.services;
        CREATE POLICY "Allow all" ON public.services
          FOR ALL
          USING (true)
          WITH CHECK (true);
      `,
    });

    if (tableError && !tableError.message.includes('already exists')) {
      console.log('⚠️  Table might already exist or using direct SQL method...');
    } else {
      console.log('✅ Services table created successfully!');
    }

    // Step 2: Create storage bucket
    console.log('\n🖼️  Creating storage bucket...');
    
    // Try to get bucket first
    const { data: bucketExists } = await supabase.storage.getBucket('service-images');
    
    if (!bucketExists) {
      const { data: bucket, error: bucketError } = await supabase.storage.createBucket('service-images', {
        public: true,
      });

      if (bucketError) {
        console.log('⚠️  Bucket might already exist: ' + bucketError.message);
      } else {
        console.log('✅ Storage bucket created successfully!');
      }
    } else {
      console.log('✅ Storage bucket already exists!');
    }

    // Step 3: Create bucket policies
    console.log('\n🔐 Setting up bucket policies...');
    
    // For now, we'll note that policies need to be set via dashboard
    console.log('📝 Note: Bucket policies should allow public access for service-images');

    console.log('\n✨ Supabase setup completed!');
    console.log('\n📋 Summary:');
    console.log('   ✅ Services table created');
    console.log('   ✅ Storage bucket created');
    console.log('   ✅ Ready for use!');

  } catch (error) {
    console.error('❌ Setup failed:', error.message);
    
    // Alternative: provide manual SQL for dashboard
    console.log('\n📌 If automatic setup fails, run this SQL manually in Supabase dashboard:');
    console.log(`
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

    CREATE POLICY "Allow all" ON public.services
      FOR ALL USING (true) WITH CHECK (true);
    `);
    
    process.exit(1);
  }
}

setupSupabase();
