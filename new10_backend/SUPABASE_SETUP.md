# Supabase Setup Instructions

## Step 1: Create the Services Table

1. Go to your **Supabase Dashboard** → **SQL Editor**
2. Create a new query and paste this SQL:

```sql
-- Create services table
CREATE TABLE public.services (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  price NUMERIC,
  duration TEXT,
  image1 TEXT,
  image2 TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

-- Create RLS Policy (allow all for now, restrict later)
CREATE POLICY "Allow all access" ON public.services
  FOR ALL
  USING (true);
```

3. Click **Run** button

---

## Step 2: Create Storage Bucket

1. Go to **Supabase Dashboard** → **Storage**
2. Click **Create a new bucket**
3. Name it: `service-images`
4. Make it **Public** (toggle on)
5. Click **Create bucket**

---

## Step 3: Set Storage Permissions

1. Click on the `service-images` bucket
2. Click **Policies** tab
3. Click **New Policy** → **For full customization**
4. Paste this policy:

```json
{
  "views": {
    "public": {
      "service-images": ["true"]
    }
  },
  "insert": {
    "service-images": ["true"]
  },
  "update": {
    "service-images": ["true"]
  },
  "delete": {
    "service-images": ["true"]
  }
}
```

---

## Step 4: Test Connection

Backend will automatically:
- ✅ Connect to Supabase using credentials from `.env`
- ✅ Create services in the database
- ✅ Upload images to storage bucket
- ✅ Return public image URLs

---

**Once setup is complete, restart the backend and test!**
