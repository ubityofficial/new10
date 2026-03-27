const express = require('express');
const cors = require('cors');
const multer = require('multer');
const { createClient } = require('@supabase/supabase-js');
const { authRoutes } = require('./auth');
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

// ============ INITIALIZE AUTH ROUTES ============
authRoutes(app, supabase);

// Mock database (for vendor services)
let vendorServices = [
  {
    id: '1',
    vendorId: 'vendor1',
    serviceId: '1',
    pricing: 5000,
    duration: '8 hours',
    location: 'Mumbai',
    timings: { start: '08:00', end: '18:00' },
    availability: true,
    createdAt: new Date(),
  },
];

// ============ SERVICES CRUD (Supabase) ============

// GET all services
app.get('/api/services', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('services')
      .select('*');
    
    if (error) return res.status(400).json({ error: error.message });
    res.json(data || []);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET single service
app.get('/api/services/:id', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('services')
      .select('*')
      .eq('id', req.params.id)
      .single();
    
    if (error) return res.status(404).json({ error: 'Service not found' });
    res.json(data);
  } catch (err) {
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

// ============ VENDOR SERVICES ============

// GET vendor's services
app.get('/api/vendor/:vendorId/services', (req, res) => {
  const vs = vendorServices.filter(vs => vs.vendorId === req.params.vendorId);
  
  // Enrich with service details
  const enriched = vs.map(vendorService => {
    const service = services.find(s => s.id === vendorService.serviceId);
    return { ...vendorService, service };
  });
  
  res.json(enriched);
});

// ADD service to vendor
app.post('/api/vendor/:vendorId/services', (req, res) => {
  try {
    const { serviceId, pricing, duration, location, timings } = req.body;

    if (!serviceId || !pricing || !duration || !location) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Check if service exists
    if (!services.find(s => s.id === serviceId)) {
      return res.status(404).json({ error: 'Service not found' });
    }

    // Check if vendor already has this service
    if (vendorServices.find(vs => vs.vendorId === req.params.vendorId && vs.serviceId === serviceId)) {
      return res.status(400).json({ error: 'Vendor already has this service' });
    }

    const newVendorService = {
      id: Date.now().toString(),
      vendorId: req.params.vendorId,
      serviceId,
      pricing,
      duration,
      location,
      timings: timings || { start: '09:00', end: '18:00' },
      availability: true,
      createdAt: new Date(),
    };

    vendorServices.push(newVendorService);
    res.status(201).json(newVendorService);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// UPDATE vendor service
app.put('/api/vendor/:vendorId/services/:vendorServiceId', (req, res) => {
  try {
    const vs = vendorServices.find(
      v => v.id === req.params.vendorServiceId && v.vendorId === req.params.vendorId
    );

    if (!vs) return res.status(404).json({ error: 'Vendor service not found' });

    const { pricing, duration, location, timings, availability } = req.body;
    if (pricing !== undefined) vs.pricing = pricing;
    if (duration) vs.duration = duration;
    if (location) vs.location = location;
    if (timings) vs.timings = timings;
    if (availability !== undefined) vs.availability = availability;

    res.json(vs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// DELETE vendor service
app.delete('/api/vendor/:vendorId/services/:vendorServiceId', (req, res) => {
  const index = vendorServices.findIndex(
    v => v.id === req.params.vendorServiceId && v.vendorId === req.params.vendorId
  );

  if (index === -1) return res.status(404).json({ error: 'Vendor service not found' });

  const deleted = vendorServices.splice(index, 1);
  res.json(deleted[0]);
});

// ============ USER BROWSING ============

// GET all services (user browsing)
app.get('/api/user/services', async (req, res) => {
  try {
    const category = req.query.category;
    let query = supabase.from('services').select('*');

    if (category) {
      query = query.eq('category', category);
    }

    const { data, error } = await query;
    if (error) return res.status(400).json({ error: error.message });
    res.json(data || []);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET vendors offering a specific service
app.get('/api/services/:serviceId/vendors', (req, res) => {
  const venforServices = vendorServices.filter(vs => vs.serviceId === req.params.serviceId);
  
  // Enrich with service and vendor details (mock)
  const enriched = venforServices.map(vs => ({
    ...vs,
    vendorName: `Vendor ${vs.vendorId}`,
    vendorRating: 4.5,
    vendorReviews: 120,
  }));

  res.json(enriched);
});

// ============ APP SETTINGS (In-Memory) ============
let appSettings = {
  bannerImageUrl: 'https://images.unsplash.com/photo-1581092163562-40f08642c5bc?w=500&h=350&fit=crop&q=80',
  updatedAt: new Date(),
};

// GET app settings
app.get('/api/settings', (req, res) => {
  try {
    res.json(appSettings);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// UPDATE app settings (Admin only)
app.post('/api/settings', (req, res) => {
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

    appSettings = {
      bannerImageUrl,
      updatedAt: new Date(),
    };

    res.json({
      message: 'Settings updated successfully',
      settings: appSettings,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ============ OFFERS & COUPONS (In-Memory) ============
let offerData = {
  code: 'RAPIDO15',
  discountPercent: 15,
  description: 'Get 15% off on heavy equipment rental!',
  active: true,
  createdAt: new Date(),
};

// GET offer data
app.get('/api/offer', (req, res) => {
  try {
    res.json(offerData);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// UPDATE offer data
app.post('/api/offer', (req, res) => {
  try {
    const { code, discountPercent, description } = req.body;

    if (!code || !code.trim()) {
      return res.status(400).json({ error: 'Coupon code is required' });
    }

    const discount = parseInt(discountPercent);
    if (isNaN(discount) || discount < 0 || discount > 100) {
      return res.status(400).json({ error: 'Discount must be between 0 and 100' });
    }

    offerData = {
      code: code.trim().toUpperCase(),
      discountPercent: discount,
      description: description || 'Special discount offer',
      active: true,
      createdAt: new Date(),
    };

    console.log(`✅ Offer updated: ${offerData.code} - ${offerData.discountPercent}% off`);
    res.json({
      message: 'Offer updated successfully',
      offer: offerData,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET combined promotions (banner + offer)
app.get('/api/promotions', (req, res) => {
  try {
    res.json({
      banner: {
        url: appSettings.bannerImageUrl,
        updatedAt: appSettings.updatedAt,
      },
      offer: offerData,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// UPDATE banner via promotions
app.post('/api/promotions/banner', (req, res) => {
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

    appSettings.bannerImageUrl = url.trim();
    appSettings.updatedAt = new Date();

    console.log(`✅ Banner updated: ${appSettings.bannerImageUrl}`);
    res.json({
      message: 'Banner updated successfully',
      banner: {
        url: appSettings.bannerImageUrl,
        updatedAt: appSettings.updatedAt,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// UPDATE offer via promotions
app.post('/api/promotions/offer', (req, res) => {
  try {
    const { couponCode, discountPercent, description, active } = req.body;

    if (!couponCode || !couponCode.trim()) {
      return res.status(400).json({ error: 'Coupon code is required' });
    }

    const discount = parseInt(discountPercent);
    if (isNaN(discount) || discount < 0 || discount > 100) {
      return res.status(400).json({ error: 'Discount must be between 0 and 100' });
    }

    offerData = {
      code: couponCode.trim().toUpperCase(),
      discountPercent: discount,
      description: description || 'Special discount offer',
      active: active !== false,
      createdAt: new Date(),
    };

    console.log(`✅ Offer updated: ${offerData.code} - ${offerData.discountPercent}%`);
    res.json({
      message: 'Offer updated successfully',
      offer: offerData,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date() });
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
