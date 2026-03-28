const express = require('express');
const cors = require('cors');
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const { createClient } = require('@supabase/supabase-js');
const authRoutes = require('./auth');
const { initializeDatabase } = require('./initializeDatabase');
const vendorServicesRouter = require('./routes/vendorServices');
require('dotenv').config();

const app = express();

// Supabase Client
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb' }));

// Multer config (for temporary file handling)
const storage = multer.memoryStorage();
const upload = multer({ storage });

// ============ INITIALIZE DATABASE ============
console.log('🚀 Initializing database tables...');
initializeDatabase().catch(err => console.error('⚠️ Database init warning:', err.message));

// ============ INITIALIZE AUTH ROUTES ============
authRoutes(app, supabase);

// ============ INITIALIZE VENDOR SERVICES ROUTES ============
app.use('/api', vendorServicesRouter);


// ============ SERVICES CRUD (Supabase) ============

// GET all services
// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date(), version: 'e927007-services-fix' });
});

// Test endpoint to verify new code is deployed
app.get('/api/services-test', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('services')
      .select('id, name')
      .limit(3);
    
    if (error) {
      return res.json({ success: false, error: error.message });
    }
    
    res.json({ 
      success: true, 
      count: data?.length || 0,
      services: data || []
    });
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// TEST: Add dummy vendor service directly
app.post('/api/test/add-dummy-vendor-service', async (req, res) => {
  try {
    console.log('🧪 TEST: Adding dummy vendor service...');

    // Get first vendor and first service
    const { data: vendors } = await supabase
      .from('vendors')
      .select('id, status')
      .limit(1);

    if (!vendors || vendors.length === 0) {
      return res.status(400).json({ error: 'No vendors found. Add a vendor first.' });
    }

    const vendorId = vendors[0].id;
    console.log('✅ Using vendor:', vendorId, 'status:', vendors[0].status);

    const { data: services } = await supabase
      .from('services')
      .select('id, name')
      .limit(1);

    if (!services || services.length === 0) {
      return res.status(400).json({ error: 'No services found. Add services first.' });
    }

    const serviceId = services[0].id;
    console.log('✅ Using service:', serviceId, 'name:', services[0].name);

    // Try to insert into vendor_services
    const { data: inserted, error: insertError } = await supabase
      .from('vendor_services')
      .insert([
        {
          vendor_id: vendorId,
          service_id: serviceId,
          pricing: 500.00,
          pricing_unit: 'per day',
          location: 'Bangalore',
          availability: 'available',
          is_online: true,
          is_active: true,
          // Note: start_time and end_time are optional, removed to avoid schema cache issues
        },
      ])
      .select();

    if (insertError) {
      console.error('❌ INSERT ERROR:', insertError);
      return res.status(500).json({ 
        success: false,
        error: insertError.message,
        code: insertError.code,
        details: insertError
      });
    }

    console.log('✅ INSERTED:', inserted);
    res.json({
      success: true,
      message: 'Dummy vendor service created successfully!',
      data: inserted
    });

  } catch (err) {
    console.error('❌ UNEXPECTED ERROR:', err);
    res.status(500).json({ 
      success: false,
      error: err.message 
    });
  }
});


app.get('/api/services', async (req, res) => {
  try {
    const { search } = req.query;

    console.log('Fetching services...');

    // Fetch ALL services from services table - careful with columns
    const { data: allServices, error: sError } = await supabase
      .from('services')
      .select('id, name, description, category, image1, image2, created_at')
      .order('created_at', { ascending: false });

    if (sError) {
      console.error('Error fetching services:', sError);
      return res.status(500).json({ error: 'DB Error: ' + sError.message });
    }

    console.log('Found services:', allServices?.length || 0);

    if (!allServices || allServices.length === 0) {
      return res.json([]);
    }

    // Format services - simple version
    let formatted = allServices.map(service => ({
      id: service.id || '',
      name: service.name || '',
      description: service.description || '',
      category: service.category || '',
      image1: service.image1 || '',
      image2: service.image2 || '',
      rating: 0,
      reviews: 0,
      vendorId: null,
      vendorName: 'System Service',
      location: 'All Districts',
      pricePerDay: null,
      pricePerHour: null,
      isOnline: true,
      emoji: '🏗️',
      serviceType: service.category || '',
    }));

    // Apply search filter if provided
    if (search && typeof search === 'string' && search.trim()) {
      const searchLower = search.toLowerCase();
      formatted = formatted.filter(s =>
        (s.name && s.name.toLowerCase().includes(searchLower)) ||
        (s.description && s.description.toLowerCase().includes(searchLower))
      );
    }

    console.log('Returning formatted services:', formatted.length);
    res.json(formatted);
  } catch (err) {
    console.error('Error in /api/services catch:', err);
    res.status(500).json({ error: 'Error: ' + err.message });
  }
});

// GET single service
app.get('/api/services/:id', async (req, res) => {
  try {
    const serviceId = req.params.id;

    // First, fetch the service itself
    const { data: service, error: sError } = await supabase
      .from('services')
      .select('id, name, description, category, image1, image2, rating, reviews')
      .eq('id', serviceId)
      .single();

    if (sError || !service) {
      return res.status(404).json({ error: 'Service not found' });
    }

    // Try to fetch vendor_services entry if it exists
    const { data: vendorService } = await supabase
      .from('vendor_services')
      .select('vendor_id, pricing, duration, location, availability')
      .eq('service_id', serviceId)
      .limit(1);

    let vendor = null;
    let vendorInfo = { id: null, business_name: 'System Service', status: 'active' };

    if (vendorService && vendorService.length > 0) {
      const vs = vendorService[0];
      // Fetch vendor details
      const { data: vendorRecord } = await supabase
        .from('vendors')
        .select('id, business_name, status')
        .eq('id', vs.vendor_id)
        .single();
      
      vendorInfo = vendorRecord || vendorInfo;
      vendor = vs;
    }

    // Format response
    const formatted = {
      id: service.id,
      name: service.name,
      description: service.description,
      category: service.category,
      image1: service.image1,
      image2: service.image2,
      rating: service.rating || 0,
      reviews: service.reviews || 0,
      vendorId: vendorInfo.id,
      vendorName: vendorInfo.business_name,
      location: vendor?.location ||'All Districts',
      pricePerDay: vendor?.pricing || null,
      pricePerHour: null,
      isOnline: vendorInfo.status === 'active',
      emoji: '🏗️',
      serviceType: service.category,
    };

    res.json(formatted);
  } catch (err) {
    console.error('Error in /api/services/:id:', err);
    res.status(500).json({ error: err.message });
  }
});

// CREATE service (with Supabase storage)
app.post('/api/services', upload.fields([{ name: 'image1' }, { name: 'image2' }]), async (req, res) => {
  try {
    const { name, description, category, price, duration } = req.body;
    
    if (!name || !description || !category) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    if (!req.files || !req.files.image1 || !req.files.image2) {
      return res.status(400).json({ error: 'Both images required' });
    }

    const serviceId = Date.now().toString();
    const image1FileName = `services/${serviceId}_image1_${Date.now()}`;
    const image2FileName = `services/${serviceId}_image2_${Date.now() + 1}`;

    // Upload Image 1
    const { error: uploadError1 } = await supabase.storage
      .from('service-images')
      .upload(image1FileName, req.files.image1[0].buffer, {
        contentType: req.files.image1[0].mimetype,
      });

    if (uploadError1) {
      return res.status(400).json({ error: 'Failed to upload image 1: ' + uploadError1.message });
    }

    // Upload Image 2
    const { error: uploadError2 } = await supabase.storage
      .from('service-images')
      .upload(image2FileName, req.files.image2[0].buffer, {
        contentType: req.files.image2[0].mimetype,
      });

    if (uploadError2) {
      return res.status(400).json({ error: 'Failed to upload image 2: ' + uploadError2.message });
    }

    // Get public URLs
    const { data: image1Data } = supabase.storage
      .from('service-images')
      .getPublicUrl(image1FileName);

    const { data: image2Data } = supabase.storage
      .from('service-images')
      .getPublicUrl(image2FileName);

    // Insert service record
    const { data: newService, error: insertError } = await supabase
      .from('services')
      .insert([
        {
          id: serviceId,
          name,
          description,
          category,
          price: price || 0,
          duration: duration || '',
          image1: image1Data.publicUrl,
          image2: image2Data.publicUrl,
          created_at: new Date().toISOString(),
        },
      ])
      .select()
      .single();

    if (insertError) {
      return res.status(400).json({ error: insertError.message });
    }

    res.status(201).json(newService);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// UPDATE service
app.put('/api/services/:id', upload.fields([{ name: 'image1' }, { name: 'image2' }]), async (req, res) => {
  try {
    const { name, description, category, price, duration } = req.body;
    const serviceId = req.params.id;

    // Get existing service
    const { data: existingService, error: fetchError } = await supabase
      .from('services')
      .select('*')
      .eq('id', serviceId)
      .single();

    if (fetchError) {
      return res.status(404).json({ error: 'Service not found' });
    }

    let image1Url = existingService.image1;
    let image2Url = existingService.image2;

    // Upload new images if provided
    if (req.files?.image1) {
      const image1FileName = `services/${serviceId}_image1_${Date.now()}`;
      const { error: uploadError } = await supabase.storage
        .from('service-images')
        .upload(image1FileName, req.files.image1[0].buffer, {
          contentType: req.files.image1[0].mimetype,
        });

      if (!uploadError) {
        const { data } = supabase.storage
          .from('service-images')
          .getPublicUrl(image1FileName);
        image1Url = data.publicUrl;
      }
    }

    if (req.files?.image2) {
      const image2FileName = `services/${serviceId}_image2_${Date.now()}`;
      const { error: uploadError } = await supabase.storage
        .from('service-images')
        .upload(image2FileName, req.files.image2[0].buffer, {
          contentType: req.files.image2[0].mimetype,
        });

      if (!uploadError) {
        const { data } = supabase.storage
          .from('service-images')
          .getPublicUrl(image2FileName);
        image2Url = data.publicUrl;
      }
    }

    // Update service
    const { data: updatedService, error: updateError } = await supabase
      .from('services')
      .update({
        name: name || existingService.name,
        description: description || existingService.description,
        category: category || existingService.category,
        price: price !== undefined ? price : existingService.price,
        duration: duration || existingService.duration,
        image1: image1Url,
        image2: image2Url,
      })
      .eq('id', serviceId)
      .select()
      .single();

    if (updateError) {
      return res.status(400).json({ error: updateError.message });
    }

    res.json(updatedService);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// DELETE service
app.delete('/api/services/:id', async (req, res) => {
  try {
    const { data: deletedService, error: deleteError } = await supabase
      .from('services')
      .delete()
      .eq('id', req.params.id)
      .select()
      .single();

    if (deleteError) {
      return res.status(404).json({ error: 'Service not found' });
    }

    vendorServices = vendorServices.filter(vs => vs.serviceId !== req.params.id);
    res.json(deletedService);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ VENDOR SERVICES (Now in routes/vendorServices.js) ============
// All vendor service endpoints are registered via the vendorServicesRouter above
// This includes:
// - GET /api/vendor/:vendorId/services
// - POST /api/vendor/:vendorId/services
// - PUT /api/vendor/services/:vendorServiceId
// - DELETE /api/vendor/services/:vendorServiceId
// - GET /api/services/:serviceId/vendors
// - GET /api/services
// - GET /api/vendors-by-service/:serviceName


// ============ USER BROWSING (Now in routes/vendorServices.js) ============

// All vendor browsing endpoints are now handled by vendorServicesRouter:
// - GET /api/services/:serviceId/vendors (find vendors for a service)
// - GET /api/services (all services with vendor counts)
// - GET /api/vendors-by-service/:serviceName (search vendors by service name)

// ============ APP SETTINGS (Supabase Database) ============

// GET app settings from database
app.get('/api/settings', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('promotions')
      .select('*')
      .eq('promotype', 'banner')
      .order('createdat', { ascending: false })
      .limit(1);

    if (error || !data || data.length === 0) {
      // Return default settings
      return res.json({
        bannerImageUrl: 'https://images.unsplash.com/photo-1581092163562-40f08642c5bc?w=500&h=350&fit=crop&q=80',
        updated_at: new Date(),
      });
    }

    res.json({
      bannerImageUrl: data[0].bannerurl,
      updated_at: data[0].updatedat,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// UPDATE app settings (Admin only) in database
app.post('/api/settings', async (req, res) => {
  try {
    const { bannerImageUrl } = req.body;

    if (!bannerImageUrl) {
      return res.status(400).json({ error: 'Missing bannerImageUrl' });
    }

    // Validate URL format
    try {
      new URL(bannerImageUrl);
    } catch (e) {
      return res.status(400).json({ error: 'Invalid URL format' });
    }

    // Get existing banner or create new one
    const { data: existing } = await supabase
      .from('promotions')
      .select('id')
      .eq('promotype', 'banner')
      .limit(1);

    let result;

    if (existing && existing.length > 0) {
      result = await supabase
        .from('promotions')
        .update({
          bannerurl: bannerImageUrl,
          updatedat: new Date().toISOString(),
        })
        .eq('id', existing[0].id)
        .select()
        .single();
    } else {
      result = await supabase
        .from('promotions')
        .insert([
          {
            id: uuidv4(),
            promotype: 'banner',
            bannerurl: bannerImageUrl,
            createdat: new Date().toISOString(),
            updatedat: new Date().toISOString(),
          },
        ])
        .select()
        .single();
    }

    if (result.error) {
      return res.status(400).json({ error: result.error.message });
    }

    res.json({
      message: 'Settings updated successfully',
      settings: {
        bannerImageUrl: result.data.bannerurl,
        updated_at: result.data.updatedat,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ============ OFFERS & COUPONS (Supabase Database) ============
// Function to initialize default offer if table is empty
async function initializeDefaultOffer() {
  try {
    const { data, error } = await supabase
      .from('promotions')
      .select('*')
      .limit(1);
    
    if (error) {
      console.log('⚠️ Promotions table might not exist yet');
      return;
    }

    if (!data || data.length === 0) {
      // Insert default offer
      await supabase
        .from('promotions')
        .insert([
          {
            promotype: 'offer',
            code: 'RAPIDO15',
            discountpercent: 15,
            description: 'Get 15% off on heavy equipment rental!',
            active: true,
            createdAt: new Date().toISOString(),
          },
        ]);
      console.log('✅ Default offer initialized');
    }
  } catch (err) {
    console.log('⚠️ Could not initialize default offer:', err.message);
  }
}

// Removed: initializeDefaultOffer() was resetting promotions on every restart
// The API endpoints have fallback defaults, so this is not needed

// GET offer data from database
app.get('/api/offer', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('promotions')
      .select('*')
      .eq('promotype', 'offer')
      .eq('active', true)
      .order('createdat', { ascending: false })
      .limit(1);

    if (error) {
      console.log('⚠️ Error fetching offer:', error.message);
      // Return default offer
      return res.json({
        code: 'RAPIDO15',
        discountPercent: 15,
        description: 'Get 15% off on heavy equipment rental!',
        active: true,
      });
    }

    if (data && data.length > 0) {
      res.json({
        code: data[0].code,
        discountPercent: data[0].discountpercent,
        description: data[0].description,
        active: data[0].active,
      });
    } else {
      // Return default offer if none found
      res.json({
        code: 'RAPIDO15',
        discountPercent: 15,
        description: 'Get 15% off on heavy equipment rental!',
        active: true,
      });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// UPDATE offer data in database
app.post('/api/offer', async (req, res) => {
  try {
    const { code, discountPercent, description } = req.body;

    if (!code || !code.trim()) {
      return res.status(400).json({ error: 'Coupon code is required' });
    }

    const discount = parseInt(discountPercent);
    if (isNaN(discount) || discount < 0 || discount > 100) {
      return res.status(400).json({ error: 'Discount must be between 0 and 100' });
    }

    // Get existing offer or create new one
    const { data: existing } = await supabase
      .from('promotions')
      .select('id')
      .eq('promotype', 'offer')
      .limit(1);

    let result;

    if (existing && existing.length > 0) {
      // Update existing offer
      result = await supabase
        .from('promotions')
        .update({
          code: code.trim().toUpperCase(),
          discountpercent: discount,
          description: description || 'Special discount offer',
          active: true,
          updatedat: new Date().toISOString(),
        })
        .eq('id', existing[0].id)
        .select()
        .single();
    } else {
      // Create new offer
      result = await supabase
        .from('promotions')
        .insert([
          {
            id: uuidv4(),
            promotype: 'offer',
            code: code.trim().toUpperCase(),
            discountpercent: discount,
            description: description || 'Special discount offer',
            active: true,
            createdat: new Date().toISOString(),
            updatedat: new Date().toISOString(),
          },
        ])
        .select()
        .single();
    }

    if (result.error) {
      return res.status(400).json({ error: result.error.message });
    }

    console.log(`✅ Offer updated: ${code.toUpperCase()} - ${discount}% in database`);
    res.json({
      message: 'Offer updated successfully',
      offer: result.data,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET combined promotions (banner + offer) from database
app.get('/api/promotions', async (req, res) => {
  try {
    // Get banner
    const { data: bannerData, error: bannerError } = await supabase
      .from('promotions')
      .select('*')
      .eq('promotype', 'banner')
      .order('createdat', { ascending: false })
      .limit(1);

    // Get active offer
    const { data: offerData, error: offerError } = await supabase
      .from('promotions')
      .select('*')
      .eq('promotype', 'offer')
      .eq('active', true)
      .order('createdat', { ascending: false })
      .limit(1);

    // Provide fallback values if queries fail
    const banner = bannerData && bannerData.length > 0 
      ? { url: bannerData[0].bannerurl, updated_at: bannerData[0].updatedat }
      : { url: 'https://images.unsplash.com/photo-1581092163562-40f08642c5bc?w=500&h=350&fit=crop&q=80', updated_at: new Date() };

    const offer = offerData && offerData.length > 0
      ? offerData[0]
      : { code: 'RAPIDO15', discountpercent: 15, description: 'Get 15% off on heavy equipment rental!', active: true };

    res.json({ banner, offer });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// UPDATE banner via promotions (database)
app.post('/api/promotions/banner', async (req, res) => {
  try {
    const { url } = req.body;

    if (!url || !url.trim()) {
      return res.status(400).json({ error: 'Banner URL is required' });
    }

    // Validate URL format
    try {
      new URL(url);
    } catch (e) {
      return res.status(400).json({ error: 'Invalid URL format' });
    }

    // Get existing banner or create new one
    const { data: existing } = await supabase
      .from('promotions')
      .select('id')
      .eq('promotype', 'banner')
      .limit(1);

    let result;

    if (existing && existing.length > 0) {
      // Update existing banner
      result = await supabase
        .from('promotions')
        .update({
          banner_url: url.trim(),
          updated_at: new Date().toISOString(),
        })
        .eq('id', existing[0].id)
        .select()
        .single();
    } else {
      // Create new banner
      result = await supabase
        .from('promotions')
        .insert([
          {
            promotype: 'banner',
            banner_url: url.trim(),
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          },
        ])
        .select()
        .single();
    }

    if (result.error) {
      return res.status(400).json({ error: result.error.message });
    }

    console.log(`✅ Banner updated in database: ${url.trim()}`);
    res.json({
      message: 'Banner updated successfully',
      banner: {
        url: result.data.bannerurl,
        updated_at: result.data.updatedat,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// UPDATE offer via promotions (database)
app.post('/api/promotions/offer', async (req, res) => {
  try {
    const { couponCode, discountpercent, description, active } = req.body;

    if (!couponCode || !couponCode.trim()) {
      return res.status(400).json({ error: 'Coupon code is required' });
    }

    const discount = parseInt(discountpercent);
    if (isNaN(discount) || discount < 0 || discount > 100) {
      return res.status(400).json({ error: 'Discount must be between 0 and 100' });
    }

    // Get existing offer or create new one
    const { data: existing } = await supabase
      .from('promotions')
      .select('id')
      .eq('promotype', 'offer')
      .limit(1);

    let result;

    if (existing && existing.length > 0) {
      // Update existing offer
      result = await supabase
        .from('promotions')
        .update({
          code: couponCode.trim().toUpperCase(),
          discountpercent: discount,
          description: description || 'Special discount offer',
          active: active !== false,
          updatedAt: new Date().toISOString(),
        })
        .eq('id', existing[0].id)
        .select()
        .single();
    } else {
      // Create new offer
      result = await supabase
        .from('promotions')
        .insert([
          {
            promotype: 'offer',
            code: couponCode.trim().toUpperCase(),
            discountpercent: discount,
            description: description || 'Special discount offer',
            active: active !== false,
            createdAt: new Date().toISOString(),
          },
        ])
        .select()
        .single();
    }

    if (result.error) {
      return res.status(400).json({ error: result.error.message });
    }

    console.log(`✅ Offer updated in database: ${couponCode.toUpperCase()} - ${discount}%`);
    res.json({
      message: 'Offer updated successfully',
      offer: result.data,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ============ ADMIN ENDPOINTS ============

// GET all users (for admin panel) - excludes vendors
app.get('/api/admin/users', async (req, res) => {
  try {
    const { data: users, error } = await supabase
      .from('users')
      .select('id, email, name, phone, role, status, profile_image, created_at')
      .eq('role', 'user');

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    res.json({
      success: true,
      users: users || [],
      count: (users || []).length,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET all vendors (for admin panel)
app.get('/api/admin/vendors/list', async (req, res) => {
  try {
    const { data: vendors, error: vendorError } = await supabase
      .from('vendors')
      .select(`
        id,
        user_id,
        business_name,
        business_registration,
        gst,
        status,
        approved,
        blocked,
        created_at,
        users (id, email, name, phone, role)
      `);

    if (vendorError) {
      return res.status(400).json({ error: vendorError.message });
    }

    // Filter to ensure we only get vendors (users with role='vendor')
    const filteredVendors = (vendors || []).filter(v => v.users && v.users.role === 'vendor');

    res.json({
      success: true,
      vendors: filteredVendors,
      count: filteredVendors.length,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET user by ID (admin details view)
app.get('/api/admin/users/:userId', async (req, res) => {
  try {
    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', req.params.userId)
      .single();

    if (error) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      success: true,
      user,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// UPDATE user status (block/unblock)
app.put('/api/admin/users/:userId/status', async (req, res) => {
  try {
    const { status } = req.body;

    if (!['active', 'blocked', 'suspended'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const { data: updatedUser, error } = await supabase
      .from('users')
      .update({ status, updated_at: new Date().toISOString() })
      .eq('id', req.params.userId)
      .select()
      .single();

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    res.json({
      success: true,
      message: `User status updated to ${status}`,
      user: updatedUser,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET vendor by ID
app.get('/api/admin/vendors/:vendorId', async (req, res) => {
  try {
    const { data: vendor, error } = await supabase
      .from('vendors')
      .select(`
        *,
        users (id, email, name, phone)
      `)
      .eq('id', req.params.vendorId)
      .single();

    if (error) {
      return res.status(404).json({ error: 'Vendor not found' });
    }

    res.json({
      success: true,
      vendor,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// UPDATE vendor approval status
app.put('/api/admin/vendors/:vendorId/approve', async (req, res) => {
  try {
    const { approved } = req.body;

    const { data: updatedVendor, error } = await supabase
      .from('vendors')
      .update({ approved, updated_at: new Date().toISOString() })
      .eq('id', req.params.vendorId)
      .select()
      .single();

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    res.json({
      success: true,
      message: `Vendor ${approved ? 'approved' : 'unapproved'}`,
      vendor: updatedVendor,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// UPDATE vendor block status
app.put('/api/admin/vendors/:vendorId/block', async (req, res) => {
  try {
    const { blocked } = req.body;

    const { data: updatedVendor, error } = await supabase
      .from('vendors')
      .update({ blocked, updated_at: new Date().toISOString() })
      .eq('id', req.params.vendorId)
      .select()
      .single();

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    res.json({
      success: true,
      message: `Vendor ${blocked ? 'blocked' : 'unblocked'}`,
      vendor: updatedVendor,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// UPDATE vendor suspend status
app.put('/api/admin/vendors/:vendorId/suspend', async (req, res) => {
  try {
    const { suspended } = req.body;

    const newStatus = suspended ? 'suspended' : 'active';

    const { data: updatedVendor, error } = await supabase
      .from('vendors')
      .update({ status: newStatus, updated_at: new Date().toISOString() })
      .eq('id', req.params.vendorId)
      .select()
      .single();

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    res.json({
      success: true,
      message: `Vendor ${suspended ? 'suspended' : 'activated'}`,
      vendor: updatedVendor,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ===== SPONSORSHIP SYSTEM ENDPOINTS =====

// GET all active sponsored services (for public display)
app.get('/api/sponsored-services', async (req, res) => {
  try {
    const now = new Date().toISOString();

    // Get active sponsorships with their services and vendor info
    const { data: sponsorships, error } = await supabase
      .from('vendor_sponsorships')
      .select(`
        *,
        vendor_services (
          id,
          vendor_id,
          service_id,
          pricing,
          duration,
          location,
          availability,
          services (
            id,
            name,
            category,
            description
          ),
          vendors (
            id,
            business_name,
            gst,
            status,
            approved
          )
        )
      `)
      .eq('status', 'active')
      .lte('start_date', now)
      .gte('end_date', now)
      .order('priority', { ascending: true })
      .order('created_at', { ascending: false });

    if (error) {
      console.log('Error fetching sponsored services:', error);
      return res.json([]); // Return empty array if no sponsorships
    }

    // Format response with flattened data
    const formattedData = (sponsorships || []).map(sponsorship => ({
      sponsorshipId: sponsorship.id,
      vendorId: sponsorship.vendor_services?.vendor_id,
      serviceId: sponsorship.vendor_services?.service_id,
      serviceName: sponsorship.vendor_services?.services?.name,
      serviceCategory: sponsorship.vendor_services?.services?.category,
      serviceDescription: sponsorship.vendor_services?.services?.description,
      businessName: sponsorship.vendor_services?.vendors?.business_name,
      pricing: sponsorship.vendor_services?.pricing,
      duration: sponsorship.vendor_services?.duration,
      location: sponsorship.vendor_services?.location,
      availability: sponsorship.vendor_services?.availability,
      isSponsored: true,
      sponsorshipPriority: sponsorship.priority,
      sponsorshipEndDate: sponsorship.end_date,
    }));

    res.json(formattedData);
  } catch (err) {
    console.error('Error in /api/sponsored-services:', err);
    res.json([]);
  }
});

// GET vendor's own sponsorships
app.get('/api/vendor/sponsorships', async (req, res) => {
  try {
    const vendorId = req.headers['x-vendor-id'];

    if (!vendorId) {
      return res.status(401).json({ error: 'Vendor ID required' });
    }

    const { data: sponsorships, error } = await supabase
      .from('vendor_sponsorships')
      .select(`
        *,
        vendor_services (
          id,
          service_id,
          services (id, name, category)
        )
      `)
      .eq('vendor_id', vendorId)
      .order('created_at', { ascending: false });

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    res.json({
      success: true,
      sponsorships: sponsorships || [],
      totalActive: (sponsorships || []).filter(s => s.status === 'active').length,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST vendor request sponsorship
app.post('/api/vendor/sponsorship-request', async (req, res) => {
  try {
    const { vendorId, serviceId, packageDays = 30 } = req.body;

    if (!vendorId || !serviceId) {
      return res.status(400).json({ error: 'Vendor ID and Service ID required' });
    }

    // Verify vendor exists
    const { data: vendor, error: vendorError } = await supabase
      .from('vendors')
      .select('id')
      .eq('id', vendorId)
      .single();

    if (vendorError || !vendor) {
      return res.status(404).json({ error: 'Vendor not found' });
    }

    // Create sponsorship request (starts as 'pending')
    const startDate = new Date();
    const endDate = new Date(startDate.getTime() + packageDays * 24 * 60 * 60 * 1000);

    const { data: newSponsorship, error: createError } = await supabase
      .from('vendor_sponsorships')
      .insert([
        {
          id: uuidv4(),
          vendor_id: vendorId,
          service_id: serviceId,
          status: 'pending', // Requires admin approval
          start_date: startDate.toISOString(),
          end_date: endDate.toISOString(),
          amount_paid: 0,
          payment_status: 'pending',
          priority: 3, // Default priority (1 = highest)
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        },
      ])
      .select()
      .single();

    if (createError) {
      return res.status(400).json({ error: createError.message });
    }

    res.json({
      success: true,
      message: 'Sponsorship request submitted. Awaiting admin approval.',
      sponsorship: newSponsorship,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET all sponsorships (admin only)
app.get('/api/admin/sponsorships', async (req, res) => {
  try {
    const { status, vendor_id } = req.query;

    let query = supabase
      .from('vendor_sponsorships')
      .select(`
        *,
        vendor_services (
          id,
          service_id,
          services (id, name, category),
          vendors (id, business_name, user_id)
        )
      `)
      .order('created_at', { ascending: false });

    if (status) {
      query = query.eq('status', status);
    }

    if (vendor_id) {
      query = query.eq('vendor_id', vendor_id);
    }

    const { data: sponsorships, error } = await query;

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    res.json({
      success: true,
      total: sponsorships?.length || 0,
      pending: sponsorships?.filter(s => s.status === 'pending').length || 0,
      active: sponsorships?.filter(s => s.status === 'active').length || 0,
      sponsorships: sponsorships || [],
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST admin approve sponsorship
app.post('/api/admin/sponsorships/:sponsorshipId/approve', async (req, res) => {
  try {
    const { sponsorshipId } = req.params;
    const { amountPaid, priority = 2 } = req.body;

    const { data: updated, error } = await supabase
      .from('vendor_sponsorships')
      .update({
        status: 'active',
        amount_paid: amountPaid || 0,
        payment_status: 'completed',
        priority,
        updated_at: new Date().toISOString(),
      })
      .eq('id', sponsorshipId)
      .select()
      .single();

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    res.json({
      success: true,
      message: 'Sponsorship approved and activated',
      sponsorship: updated,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST admin reject sponsorship
app.post('/api/admin/sponsorships/:sponsorshipId/reject', async (req, res) => {
  try {
    const { sponsorshipId } = req.params;
    const { reason = 'Rejected by admin' } = req.body;

    const { data: updated, error } = await supabase
      .from('vendor_sponsorships')
      .update({
        status: 'rejected',
        updated_at: new Date().toISOString(),
      })
      .eq('id', sponsorshipId)
      .select()
      .single();

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    res.json({
      success: true,
      message: 'Sponsorship rejected',
      sponsorship: updated,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET Karnataka districts for location dropdown
app.get('/api/districts', (req, res) => {
  const districts = [
    'Bangalore Urban',
    'Bangalore Rural',
    'Belagavi',
    'Ballari',
    'Belgaum',
    'Bidar',
    'Bijapurnagar',
    'Chamarajanagar',
    'Chikballapur',
    'Chikmagalur',
    'Chitradurga',
    'Dakshina Kannada',
    'Davanagere',
    'Dharwad',
    'Gadag',
    'Gulbarga',
    'Hassan',
    'Haveri',
    'Kalaburagi',
    'Kodagu',
    'Kolar',
    'Koppal',
    'Mandya',
    'Mangalore',
    'Mysore',
    'Mysuru',
    'Raichur',
    'Shivamogga',
    'Tumkur',
    'Udupi',
    'Uttara Kannada',
    'Yadgir',
  ];

  res.json({
    success: true,
    districts: ['All Districts', ...districts],
    total: districts.length,
  });
});

// CLEAN TEST DATA (for development)
app.delete('/api/seed-test-data', async (req, res) => {
  try {
    console.log('🗑️  Cleaning test data...');

    // Delete all vendor_services
    await supabase.from('vendor_services').delete().like('location', '%');

    // Delete all services created for testing
    await supabase.from('services').delete().like('category', 'Heavy Equipment');

    // Delete test vendors
    await supabase.from('vendors').delete().like('business_name', '%Machineries%');

    // Delete test user
    await supabase.from('users').delete().like('email', '%test%');

    res.json({ success: true, message: 'Test data cleaned' });
  } catch (err) {
    console.error('Clean error:', err);
    res.status(500).json({ error: err.message });
  }
});

// SEED TEST DATA (for development)
app.post('/api/seed-test-data', async (req, res) => {
  try {
    console.log('🌱 Seeding test data...');

    // Use provided email or generate a unique one
    const email = req.body.email || `test-vendor-${Date.now()}@example.com`;
    
    // Create test user first (vendor owner)
    const { data: user, error: userError } = await supabase
      .from('users')
      .insert([
        {
          id: uuidv4(),
          email: email,
          password: 'TestVendor123!', // Plain text for demo - should be hashed in production
          name: 'Test Vendor',
          phone: '9876543210',
          role: 'vendor',
          status: 'active',
        },
      ])
      .select()
      .single();

    if (userError) {
      console.error('Error creating user:', userError);
      return res.status(500).json({ error: 'Failed to create user: ' + userError.message });
    }

    // Create test vendor linked to the user
    const { data: vendor, error: vendorError } = await supabase
      .from('vendors')
      .insert([
        {
          id: uuidv4(),
          user_id: user.id,
          business_name: 'SLV Machineries',
          status: 'active',
          approved: true,
          created_at: new Date(),
        },
      ])
      .select()
      .single();

    if (vendorError) {
      console.error('Error creating vendor:', vendorError);
      return res.status(500).json({ error: 'Failed to create vendor: ' + vendorError.message });
    }

    // Create test services
    const serviceNames = ['Excavator', 'Bulldozer', 'Crane', 'Compressor', 'Generator'];
    const services = [];
    const serviceErrors = [];

    for (const name of serviceNames) {
      const { data: service, error: serviceError } = await supabase
        .from('services')
        .insert([
          {
            id: uuidv4(),
            name: name,
            description: `High-quality ${name.toLowerCase()} for rent`,
            category: 'Heavy Equipment',
            image1: 'https://via.placeholder.com/400?text=' + name,
            image2: 'https://via.placeholder.com/400?text=' + name + '2',
            rating: 4.5,
            reviews: Math.floor(Math.random() * 100) + 10,
          },
        ])
        .select()
        .single();

      if (serviceError) {
        console.error('❌ Error creating service:', name, serviceError);
        serviceErrors.push({ name, error: serviceError.message });
      } else if (service) {
        console.log('✅ Created service:', name);
        services.push(service);
      }
    }

    // Create vendor_services entries for each service
    const vendorServices = [];
    const vsErrors = [];
    const districts = ['Bangalore', 'Hyderabad', 'Chennai', 'Pune', 'Delhi'];

    for (let i = 0; i < services.length; i++) {
      const { data: vs, error: vsError } = await supabase
        .from('vendor_services')
        .insert([
          {
            id: uuidv4(),
            vendor_id: vendor.id,
            service_id: services[i].id,
            pricing: 5000 + (i * 1000),
            duration: '8 hours',
            location: districts[i % districts.length],
            availability: true,
          },
        ])
        .select()
        .single();

      if (vsError) {
        console.error('❌ Error creating vendor_service:', vsError);
        vsErrors.push({ serviceId: services[i].id, error: vsError.message });
      } else if (vs) {
        console.log('✅ Created vendor_service for:', services[i].name);
        vendorServices.push(vs);
      }
    }

    res.json({
      success: true,
      message: 'Test data seeded successfully',
      user: user,
      vendor: vendor,
      servicesCreated: services.length,
      vendorServicesCreated: vendorServices.length,
      serviceErrors: serviceErrors.length > 0 ? serviceErrors : undefined,
      vsErrors: vsErrors.length > 0 ? vsErrors : undefined,
    });
  } catch (err) {
    console.error('Seed error:', err);
    res.status(500).json({ error: err.message });
  }
});

// DIAGNOSTIC ENDPOINT - Check what's in the database
app.get('/api/diagnostic', async (req, res) => {
  try {
    console.log('📊 Running diagnostic...');

    // Check services table
    const { data: services, error: sError } = await supabase
      .from('services')
      .select('id, name, category')
      .limit(100);

    // Check vendor_services table
    const { data: vendorServices, error: vsError } = await supabase
      .from('vendor_services')
      .select('id, vendor_id, service_id')
      .limit(100);

    // Check vendors table
    const { data: vendors, error: vError } = await supabase
      .from('vendors')
      .select('id, business_name, status')
      .limit(100);

    // Check users table
    const { data: users, error: uError } = await supabase
      .from('users')
      .select('id, email, role')
      .limit(100);

    res.json({
      status: 'diagnostic',
      tables: {
        services: {
          count: services?.length || 0,
          error: sError?.message,
          sampleData: services?.slice(0, 3),
        },
        vendor_services: {
          count: vendorServices?.length || 0,
          error: vsError?.message,
          sampleData: vendorServices?.slice(0, 3),
        },
        vendors: {
          count: vendors?.length || 0,
          error: vError?.message,
          sampleData: vendors?.slice(0, 3),
        },
        users: {
          count: users?.length || 0,
          error: uError?.message,
          sampleData: users?.slice(0, 3),
        },
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date() });
});

// Quick endpoint to add services to existing vendor
app.post('/api/add-services', async (req, res) => {
  try {
    console.log('📦 Adding services to existing vendor...');

    // Get any existing vendor
    const { data: vendors, error: vendorsFetchError } = await supabase
      .from('vendors')
      .select('id')
      .eq('status', 'active')
      .limit(1);

    if (vendorsFetchError || !vendors || vendors.length === 0) {
      return res.status(400).json({ error: 'No active vendors found. Run /api/seed-test-data first.' });
    }

    const vendorId = vendors[0].id;

    // Create services
    const serviceNames = ['Excavator', 'Bulldozer', 'Crane', 'Compressor', 'Generator'];
    const createdServices = [];
    const serviceErrors = [];

    for (const name of serviceNames) {
      const { data: service, error: serviceError } = await supabase
        .from('services')
        .insert({
          id: uuidv4(),
          name: name,
          description: `High-quality ${name.toLowerCase()} for rent`,
          category: 'Heavy Equipment',
          image1: 'https://via.placeholder.com/400?text=' + name,
          image2: 'https://via.placeholder.com/400?text=' + name + '2',
          rating: 4.5,
          reviews: Math.floor(Math.random() * 100) + 10,
        })
        .select()
        .single();

      if (serviceError) {
        console.error('❌ Service insert error:', serviceError);
        serviceErrors.push({ name, error: serviceError.message });
      } else {
        createdServices.push(service);
        console.log('✅ Service created:', name, service.id);
      }
    }

    // Create vendor_services for each service
    const districts = ['Bangalore', 'Hyderabad', 'Chennai', 'Pune', 'Delhi'];
    let vsCreated = 0;

    for (let i = 0; i < createdServices.length; i++) {
      const { error: vsError } = await supabase
        .from('vendor_services')
        .insert({
          id: uuidv4(),
          vendor_id: vendorId,
          service_id: createdServices[i].id,
          pricing: 5000 + (i * 1000),
          duration: '8 hours',
          location: districts[i % districts.length],
          availability: true,
        });

      if (!vsError) {
        vsCreated++;
        console.log('✅ Vendor-service link created for:', createdServices[i].name);
      } else {
        console.error('❌ VS error:', vsError);
      }
    }

    res.json({
      success: true,
      vendor_id: vendorId,
      services_created: createdServices.length,
      vendor_services_created: vsCreated,
      service_errors: serviceErrors.length > 0 ? serviceErrors : undefined,
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(500).json({ error: err.message });
  }
});

// GET vendors offering a specific service
app.get('/api/vendors-by-service/:serviceName', async (req, res) => {
  try {
    const serviceName = req.params.serviceName;
    const location = req.query.location; // Optional location filter

    // Mock vendor data for JCB, Trucks, Road Roller
    const mockVendorData = {
      'JCB': {
        vendors: [
          { vendor_id: 'mock-1', business_name: 'SLV Cranes & Machinery', pricing: 5000, location: 'Bangalore', availability: true, isOnline: true },
          { vendor_id: 'mock-2', business_name: 'Balaji Equipment Rentals', pricing: 4500, location: 'Mysore', availability: true, isOnline: true },
          { vendor_id: 'mock-3', business_name: 'Krishna Heavy Machinery', pricing: 5500, location: 'Bangalore', availability: true, isOnline: false },
        ]
      },
      'Trucks': {
        vendors: [
          { vendor_id: 'mock-4', business_name: 'Balaji Trucks Transport', pricing: 2500, location: 'Bangalore', availability: true, isOnline: true },
          { vendor_id: 'mock-5', business_name: 'Fast Logistics Pvt Ltd', pricing: 2800, location: 'Mangalore', availability: true, isOnline: true },
          { vendor_id: 'mock-6', business_name: 'SafeMove Transporters', pricing: 3000, location: 'Bangalore', availability: true, isOnline: true },
        ]
      },
      'Road Roller': {
        vendors: [
          { vendor_id: 'mock-7', business_name: 'Metro Construction Equipment', pricing: 6000, location: 'Bangalore', availability: true, isOnline: true },
          { vendor_id: 'mock-8', business_name: 'Tata Road Solutions', pricing: 6500, location: 'Bangalore', availability: true, isOnline: false },
          { vendor_id: 'mock-9', business_name: 'Pavement Experts Inc', pricing: 5800, location: 'Hassan', availability: true, isOnline: true },
        ]
      }
    };

    // First, get the service by name
    const { data: service, error: serviceError } = await supabase
      .from('services')
      .select('id, name, category, image1, image2, emoji')
      .ilike('name', serviceName)
      .single();

    if (serviceError || !service) {
      // If service not found, return mock service with mock vendors
      const mockData = mockVendorData[serviceName] || { vendors: [] };
      const emoji = serviceName === 'JCB' ? '🏗️' : serviceName === 'Trucks' ? '🚚' : '⚙️';
      
      return res.json({
        service: {
          id: `mock-${serviceName}`,
          name: serviceName,
          category: 'Heavy Equipment',
          image1: null,
          image2: null,
          emoji: emoji,
        },
        vendors: mockData.vendors,
      });
    }

    // Get all vendors offering this service
    const { data: vendorServices, error: vsError } = await supabase
      .from('vendor_services')
      .select('vendor_id, pricing, duration, location, availability')
      .eq('service_id', service.id);

    if (vsError) {
      return res.status(500).json({ error: vsError.message });
    }

    if (!vendorServices || vendorServices.length === 0) {
      return res.json({
        service: {
          id: service.id,
          name: service.name,
          category: service.category,
          image1: service.image1,
          image2: service.image2,
          emoji: service.emoji || '🏗️',
        },
        vendors: []
      });
    }

    // Get vendor details
    const vendorIds = vendorServices.map(vs => vs.vendor_id);
    const { data: vendors, error: vendorsError } = await supabase
      .from('vendors')
      .select('id, business_name, status, profile_image')
      .in('id', vendorIds);

    if (vendorsError) {
      return res.status(500).json({ error: vendorsError.message });
    }

    // Merge vendor services with vendor details
    let vendorList = vendorServices.map(vs => {
      const vendorDetail = vendors.find(v => v.id === vs.vendor_id) || {};
      return {
        vendor_id: vs.vendor_id,
        business_name: vendorDetail.business_name || 'Unknown',
        status: vendorDetail.status || 'inactive',
        pricing: vs.pricing,
        duration: vs.duration,
        location: vs.location,
        availability: vs.availability,
        isOnline: vendorDetail.status === 'active',
      };
    });

    // Filter by location if provided
    if (location) {
      vendorList = vendorList.filter(v => 
        v.location && v.location.toLowerCase().includes(location.toLowerCase())
      );
    }

    res.json({
      service: {
        id: service.id,
        name: service.name,
        category: service.category,
        image1: service.image1,
        image2: service.image2,
        emoji: service.emoji || '🏗️',
      },
      vendors: vendorList
    });
  } catch (err) {
    console.error('Error in /api/vendors-by-service:', err);
    res.status(500).json({ error: err.message });
  }
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 new10 Backend running on port ${PORT}`);
});

