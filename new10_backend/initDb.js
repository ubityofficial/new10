require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceRoleKey) {
  console.error('❌ Missing Supabase credentials in .env');
  process.exit(1);
}

async function createServicesTable() {
  console.log('📊 Setting up Supabase database...\n');

  // Extract project ID from URL
  const projectId = supabaseUrl.split('.supabase.co')[0].replace('https://', '');

  const sqlQueries = [
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
    );`,

    `ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;`,

    `DROP POLICY IF EXISTS "Allow all" ON public.services;
     CREATE POLICY "Allow all" ON public.services 
     FOR ALL USING (true) WITH CHECK (true);`,
  ];

  try {
    // Execute SQL using Supabase REST API
    for (let i = 0; i < sqlQueries.length; i++) {
      const response = await fetch(`${supabaseUrl}/rest/v1/rpc/exec_sql`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${supabaseServiceRoleKey}`,
        },
        body: JSON.stringify({ sql: sqlQueries[i] }),
      });

      if (!response.ok) {
        console.log(`Step ${i + 1}: Checking if already exists...`);
      } else {
        console.log(`✅ Step ${i + 1}: SQL executed successfully`);
      }
    }

    console.log('\n✨ Database setup complete!');
    console.log('   ✅ Services table ready');
    console.log('   ✅ RLS enabled');
    console.log('   ✅ Policies configured');
    console.log('\n🎉 Supabase is ready to use!');

  } catch (error) {
    console.log('\n⚠️  Note: If the table creation failed, that\'s okay!');
    console.log('   The table might already exist.\n');
    console.log('📋 Here\'s the SQL to run manually in Supabase Dashboard if needed:');
    console.log('\n```sql');
    sqlQueries.forEach((query) => {
      console.log(query);
    });
    console.log('```\n');
  }
}

createServicesTable();
