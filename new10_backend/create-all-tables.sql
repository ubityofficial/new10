-- ============================================================
-- COMPLETE DATABASE SCHEMA FOR NEW10 EQUIPMENT RENTAL APP
-- Run this SQL in your Supabase SQL Editor to create all tables
-- ============================================================

-- 1. USERS TABLE (Authentication)
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  role TEXT NOT NULL CHECK (role IN ('user', 'vendor', 'admin')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'blocked', 'suspended')),
  profile_image TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);

-- 2. VENDORS TABLE (Vendor Business Info)
CREATE TABLE IF NOT EXISTS vendors (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  business_name TEXT NOT NULL,
  business_registration TEXT,
  gst TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'pending')),
  approved BOOLEAN DEFAULT false,
  blocked BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vendors_user_id ON vendors(user_id);
CREATE INDEX IF NOT EXISTS idx_vendors_status ON vendors(status);
CREATE INDEX IF NOT EXISTS idx_vendors_blocked ON vendors(blocked);
CREATE INDEX IF NOT EXISTS idx_vendors_approved ON vendors(approved);

-- 3. SERVICES TABLE (Equipment Services - Already exists in your DB)
-- This table already has: name, description, category, price, duration, image1, image2, created_at, updated_at

-- 4. VENDOR_SERVICES TABLE (Relation between vendors and services)
CREATE TABLE IF NOT EXISTS vendor_services (
  id TEXT PRIMARY KEY,
  vendor_id TEXT NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
  service_id TEXT NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  pricing DECIMAL(10, 2),
  duration TEXT,
  location TEXT,
  availability BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(vendor_id, service_id)
);

CREATE INDEX IF NOT EXISTS idx_vendor_services_vendor_id ON vendor_services(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_services_service_id ON vendor_services(service_id);

-- 5. BOOKINGS TABLE (User Equipment Bookings)
CREATE TABLE IF NOT EXISTS bookings (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  vendor_id TEXT NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
  service_id TEXT NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  booking_date DATE NOT NULL,
  start_time TEXT,
  end_time TEXT,
  quantity INTEGER DEFAULT 1,
  total_price DECIMAL(10, 2),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'ongoing', 'completed', 'cancelled')),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_vendor_id ON bookings(vendor_id);
CREATE INDEX IF NOT EXISTS idx_bookings_service_id ON bookings(service_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_booking_date ON bookings(booking_date);

-- 6. REVIEWS TABLE (User Reviews for Vendors)
CREATE TABLE IF NOT EXISTS reviews (
  id TEXT PRIMARY KEY,
  booking_id TEXT NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  vendor_id TEXT NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reviews_booking_id ON reviews(booking_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_vendor_id ON reviews(vendor_id);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON reviews(rating);

-- 7. PASSWORD_RESETS TABLE (Password Reset Tokens)
CREATE TABLE IF NOT EXISTS password_resets (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reset_token TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  used BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_password_resets_token ON password_resets(reset_token);
CREATE INDEX IF NOT EXISTS idx_password_resets_user_id ON password_resets(user_id);
CREATE INDEX IF NOT EXISTS idx_password_resets_expires_at ON password_resets(expires_at);

-- 8. PROMOTIONS TABLE (Banners, Offers, Coupons)
CREATE TABLE IF NOT EXISTS promotions (
  id TEXT PRIMARY KEY,
  promoType TEXT CHECK (promoType IN ('banner', 'offer', 'coupon')),
  code TEXT UNIQUE,
  banner_url TEXT,
  discountPercent DECIMAL(5, 2),
  description TEXT,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_promotions_promoType ON promotions(promoType);
CREATE INDEX IF NOT EXISTS idx_promotions_active ON promotions(active);
CREATE INDEX IF NOT EXISTS idx_promotions_code ON promotions(code);

-- ============================================================
-- FINAL STATUS
-- ============================================================
-- Tables created:
-- ✅ users - User accounts and authentication
-- ✅ vendors - Vendor business information
-- ✅ services - Equipment services (already existed)
-- ✅ vendor_services - Vendor service mappings
-- ✅ bookings - Equipment booking transactions
-- ✅ reviews - User reviews for vendors
-- ✅ password_resets - Password reset tokens
-- ✅ promotions - Banners, offers, coupons
-- ============================================================
