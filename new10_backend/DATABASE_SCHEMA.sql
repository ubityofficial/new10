/**
 * DATABASE SCHEMA FOR VENDOR SERVICES
 * 
 * This document defines the complete database structure, relationships,
 * and proper indexing for the vendor services system.
 */

-- ===========================================
-- 1. VENDORS TABLE (Already Exists)
-- ===========================================
CREATE TABLE IF NOT EXISTS vendors (
  id UUID PRIMARY KEY,
  user_id UUID UNIQUE,
  business_name VARCHAR(255) NOT NULL,
  owner_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20) NOT NULL,
  gst_number VARCHAR(15),
  business_license VARCHAR(255),
  
  -- Status & Verification
  status VARCHAR(50) DEFAULT 'pending', -- pending, approved, suspended, blocked, rejected
  is_verified BOOLEAN DEFAULT FALSE,
  is_phone_verified BOOLEAN DEFAULT FALSE,
  
  -- Ratings & Performance
  rating DECIMAL(3,2) DEFAULT 0,
  total_bookings INTEGER DEFAULT 0,
  total_equipment INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  approval_date TIMESTAMP,
  
  -- Indexes
  CONSTRAINT vendors_status_check CHECK (status IN ('pending', 'approved', 'suspended', 'blocked', 'rejected'))
);

CREATE INDEX IF NOT EXISTS idx_vendors_status ON vendors(status);
CREATE INDEX IF NOT EXISTS idx_vendors_created_at ON vendors(created_at);

-- ===========================================
-- 2. SERVICES TABLE (Already Exists)
-- ===========================================
CREATE TABLE IF NOT EXISTS services (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  description TEXT,
  category VARCHAR(100),
  emoji VARCHAR(10),
  image1 VARCHAR(500),
  image2 VARCHAR(500),
  price_per_hour DECIMAL(10,2),
  price_per_day DECIMAL(10,2),
  service_type VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_services_name ON services(name);
CREATE INDEX IF NOT EXISTS idx_services_category ON services(category);

-- ===========================================
-- 3. VENDOR_SERVICES TABLE (Main Relationship)
-- ===========================================
CREATE TABLE IF NOT EXISTS vendor_services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign Keys
  vendor_id UUID NOT NULL,
  service_id UUID NOT NULL,
  
  -- Service Details Set by Vendor
  pricing DECIMAL(10,2) NOT NULL,
  pricing_unit VARCHAR(50) DEFAULT 'per day', -- per day, per hour, per unit
  location VARCHAR(255) NOT NULL, -- Karnataka district
  availability VARCHAR(50) DEFAULT 'available', -- available, limited, unavailable
  
  -- Working Hours
  start_time TIME,
  end_time TIME,
  
  -- Vendor Status for This Service
  is_online BOOLEAN DEFAULT TRUE,
  is_active BOOLEAN DEFAULT TRUE,
  
  -- Rating for This Service
  service_rating DECIMAL(3,2) DEFAULT 0,
  num_reviews INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  -- Constraints
  UNIQUE(vendor_id, service_id),
  CONSTRAINT vendor_services_pricing_check CHECK (pricing > 0),
  CONSTRAINT vendor_services_availability_check CHECK (availability IN ('available', 'limited', 'unavailable')),
  CONSTRAINT vendor_services_pricing_unit_check CHECK (pricing_unit IN ('per day', 'per hour', 'per unit'))
);

-- Add missing columns if table already exists
ALTER TABLE IF EXISTS vendor_services ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;
ALTER TABLE IF EXISTS vendor_services ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT TRUE;
ALTER TABLE IF EXISTS vendor_services ADD COLUMN IF NOT EXISTS service_rating DECIMAL(3,2) DEFAULT 0;
ALTER TABLE IF EXISTS vendor_services ADD COLUMN IF NOT EXISTS num_reviews INTEGER DEFAULT 0;

-- INDEXES for Fast Queries (now safe to create after columns exist)
CREATE INDEX IF NOT EXISTS idx_vendor_services_vendor_id ON vendor_services(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_services_service_id ON vendor_services(service_id);
CREATE INDEX IF NOT EXISTS idx_vendor_services_location ON vendor_services(location);
CREATE INDEX IF NOT EXISTS idx_vendor_services_availability ON vendor_services(availability);
CREATE INDEX IF NOT EXISTS idx_vendor_services_is_active ON vendor_services(is_active);
CREATE INDEX IF NOT EXISTS idx_vendor_services_is_online ON vendor_services(is_online);
CREATE INDEX IF NOT EXISTS idx_vendor_services_created_at ON vendor_services(created_at);

-- Composite Indexes for Common Queries
CREATE INDEX IF NOT EXISTS idx_vendor_services_vendor_active ON vendor_services(vendor_id, is_active);
CREATE INDEX IF NOT EXISTS idx_vendor_services_service_location ON vendor_services(service_id, location);
CREATE INDEX IF NOT EXISTS idx_vendor_services_vendor_online ON vendor_services(vendor_id, is_online);

-- ===========================================
-- 4. VENDOR_SERVICE_REVIEWS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS vendor_service_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign Keys
  vendor_service_id UUID NOT NULL,
  user_id UUID NOT NULL,
  
  -- Review Data
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  review_text TEXT,
  cleanliness INTEGER CHECK (cleanliness >= 1 AND cleanliness <= 5),
  condition INTEGER CHECK (condition >= 1 AND condition <= 5),
  punctuality INTEGER CHECK (punctuality >= 1 AND punctuality <= 5),
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vendor_service_reviews_vendor_service ON vendor_service_reviews(vendor_service_id);
CREATE INDEX IF NOT EXISTS idx_vendor_service_reviews_user ON vendor_service_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_vendor_service_reviews_rating ON vendor_service_reviews(rating);
CREATE INDEX IF NOT EXISTS idx_vendor_service_reviews_created_at ON vendor_service_reviews(created_at);

-- ===========================================
-- 5. VENDOR_SERVICE_AVAILABILITY TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS vendor_service_availability (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign Key
  vendor_service_id UUID NOT NULL,
  
  -- Availability Info
  day_of_week INTEGER CHECK (day_of_week >= 0 AND day_of_week <= 6), -- 0=Sunday, 6=Saturday
  available BOOLEAN DEFAULT TRUE,
  start_time TIME,
  end_time TIME,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vendor_service_availability_vendor_service ON vendor_service_availability(vendor_service_id);

-- ===========================================
-- 6. DATABASE RELATIONSHIPS DIAGRAM
-- ===========================================
/*
┌─────────────────────────────────────────────────────────────┐
│                        USERS                                │
│  (id, email, phone, name, profile_pic, etc.)               │
└─────────────────────────────────────────────────────────────┘
                    │
                    │ (1 user can be 1 vendor)
                    │
                    ↓
┌─────────────────────────────────────────────────────────────┐
│                       VENDORS                               │
│  (id, user_id, business_name, status, rating, etc.)        │
└─────────────────────────────────────────────────────────────┘
                    │
                    │ (1 vendor has many services)
                    │
                    ↓
┌──────────────────────────────────────────────────────────────┐
│                  VENDOR_SERVICES                             │
│  (id, vendor_id→, service_id→, pricing, location, hours)    │
│                                                              │
│  ├─→ SERVICES (service details like name, description)      │
│  ├─→ VENDOR_SERVICE_REVIEWS (customer ratings)             │
│  └─→ VENDOR_SERVICE_AVAILABILITY (weekly schedule)         │
└──────────────────────────────────────────────────────────────┘

KEY RELATIONSHIPS:
- 1 User → 1 Vendor (user_id in vendors table)
- 1 Vendor → Many Vendor_Services (vendor_id in vendor_services)
- 1 Service → Many Vendor_Services (service_id in vendor_services)
- 1 Vendor_Service → Many Reviews (vendor_service_id in reviews)
*/

-- ===========================================
-- 7. VIEW FOR VENDOR SERVICE LISTING
-- ===========================================
CREATE OR REPLACE VIEW vendor_service_details AS
SELECT 
  vs.id as vendor_service_id,
  vs.vendor_id,
  vs.service_id,
  v.business_name as vendor_name,
  s.name as service_name,
  s.description
FROM vendor_services vs
JOIN vendors v ON vs.vendor_id = v.id
JOIN services s ON vs.service_id = s.id
WHERE v.status = 'approved';

-- ===========================================
-- 8. MIGRATION NOTES
-- ===========================================
/*
✅ EXISTING TABLES:
- vendors, services, users are already created

⚠️ RUN THESE MIGRATIONS:
1. Create vendor_services table (if not exists)
2. Create vendor_service_reviews table
3. Create vendor_service_availability table
4. Create indexes for optimal query performance
5. Create vendor_service_details view

📝 NO DATA LOSS:
- These tables are new, so no existing data affected
- Previous in-memory mock data will move to database
*/
