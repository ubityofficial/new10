/**
 * VENDOR SERVICES API ENDPOINTS
 * Clean, structured API for managing vendor service listings
 * 
 * All endpoints use Supabase PostgreSQL with proper validation & error handling
 */

const express = require('express');
const { createClient } = require('@supabase/supabase-js');

const router = express.Router();

// Initialize Supabase
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

// ===================================================
// VENDOR SERVICES - CREATE, READ, UPDATE, DELETE
// ===================================================

/**
 * GET /api/vendor/:vendorId/services
 * Fetch all services added by a specific vendor
 * 
 * @param {string} vendorId - UUID of vendor
 * @returns {Array} List of vendor's services with details
 */
router.get('/vendor/:vendorId/services', async (req, res) => {
  try {
    const { vendorId } = req.params;

    // Validate vendor exists
    const { data: vendor, error: vendorError } = await supabase
      .from('vendors')
      .select('id, business_name, status')
      .eq('id', vendorId)
      .single();

    if (vendorError || !vendor) {
      return res.status(404).json({ error: 'Vendor not found' });
    }

    // Fetch vendor's services using the view for clean data
    const { data: vendorServices, error: servicesError } = await supabase
      .from('vendor_service_details')
      .select('*')
      .eq('vendor_id', vendorId)
      .order('created_at', { ascending: false });

    if (servicesError) {
      console.error('Error fetching vendor services:', servicesError);
      return res.status(500).json({ error: 'Failed to fetch services' });
    }

    return res.json({
      success: true,
      count: vendorServices?.length || 0,
      data: vendorServices || [],
    });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /api/vendor/:vendorId/services
 * Add a new service to vendor's listing
 * 
 * @body {string} service_id - UUID of service (admin created)
 * @body {number} pricing - Price amount
 * @body {string} pricing_unit - 'per day', 'per hour', or 'per unit'
 * @body {string} location - Karnataka district
 * @body {string} availability - 'available', 'limited', or 'unavailable'
 * @body {string} start_time - Working hours start (HH:MM format)
 * @body {string} end_time - Working hours end (HH:MM format)
 */
router.post('/vendor/:vendorId/services', async (req, res) => {
  try {
    const { vendorId } = req.params;
    const {
      service_id,
      pricing,
      pricing_unit,
      location,
      availability,
      start_time,
      end_time,
    } = req.body;

    // Validation
    if (!service_id || !pricing || !location) {
      return res.status(400).json({
        error: 'Missing required fields: service_id, pricing, location',
      });
    }

    if (pricing <= 0) {
      return res.status(400).json({ error: 'Pricing must be greater than 0' });
    }

    if (!['per day', 'per hour', 'per unit'].includes(pricing_unit)) {
      return res.status(400).json({
        error: 'Invalid pricing_unit. Must be: per day, per hour, or per unit',
      });
    }

    // Verify vendor exists and is approved
    const { data: vendor, error: vendorError } = await supabase
      .from('vendors')
      .select('id, status')
      .eq('id', vendorId)
      .single();

    if (vendorError || !vendor) {
      return res.status(404).json({ error: 'Vendor not found' });
    }

    if (vendor.status !== 'approved') {
      return res.status(403).json({
        error: 'Only approved vendors can add services',
      });
    }

    // Verify service exists
    const { data: service, error: serviceError } = await supabase
      .from('services')
      .select('id, name')
      .eq('id', service_id)
      .single();

    if (serviceError || !service) {
      return res.status(404).json({ error: 'Service not found' });
    }

    // Check for duplicates
    const { data: existing } = await supabase
      .from('vendor_services')
      .select('id')
      .eq('vendor_id', vendorId)
      .eq('service_id', service_id)
      .single();

    if (existing) {
      return res.status(409).json({
        error: 'This service is already in your listings',
      });
    }

    // Insert vendor service
    const { data: newService, error: insertError } = await supabase
      .from('vendor_services')
      .insert([
        {
          vendor_id: vendorId,
          service_id: service_id,
          pricing: parseFloat(pricing),
          pricing_unit: pricing_unit || 'per day',
          location: location.trim(),
          availability: availability || 'available',
          start_time: start_time || '08:00',
          end_time: end_time || '18:00',
          is_online: true,
          is_active: true,
        },
      ])
      .select();

    if (insertError) {
      console.error('Insert error:', insertError);
      return res.status(500).json({ error: 'Failed to add service' });
    }

    return res.status(201).json({
      success: true,
      message: `${service.name} added to your listings`,
      data: newService[0],
    });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * PUT /api/vendor/services/:vendorServiceId
 * Update vendor's service details (pricing, location, hours, availability)
 */
router.put('/vendor/services/:vendorServiceId', async (req, res) => {
  try {
    const { vendorServiceId } = req.params;
    const { pricing, location, availability, start_time, end_time, is_online } =
      req.body;

    // Validation
    if (pricing && pricing <= 0) {
      return res.status(400).json({ error: 'Pricing must be greater than 0' });
    }

    // Build update object - only include provided fields
    const updateData = {};
    if (pricing !== undefined) updateData.pricing = parseFloat(pricing);
    if (location !== undefined) updateData.location = location.trim();
    if (availability !== undefined) updateData.availability = availability;
    if (start_time !== undefined) updateData.start_time = start_time;
    if (end_time !== undefined) updateData.end_time = end_time;
    if (is_online !== undefined) updateData.is_online = is_online;
    updateData.updated_at = new Date().toISOString();

    // Update service
    const { data: updatedService, error: updateError } = await supabase
      .from('vendor_services')
      .update(updateData)
      .eq('id', vendorServiceId)
      .select();

    if (updateError) {
      console.error('Update error:', updateError);
      return res.status(500).json({ error: 'Failed to update service' });
    }

    if (!updatedService || updatedService.length === 0) {
      return res.status(404).json({ error: 'Service not found' });
    }

    return res.json({
      success: true,
      message: 'Service updated',
      data: updatedService[0],
    });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * DELETE /api/vendor/services/:vendorServiceId
 * Remove a service from vendor's listings (soft delete - sets is_active to false)
 */
router.delete('/vendor/services/:vendorServiceId', async (req, res) => {
  try {
    const { vendorServiceId } = req.params;

    // Soft delete - mark as inactive
    const { data: deletedService, error: deleteError } = await supabase
      .from('vendor_services')
      .update({
        is_active: false,
        updated_at: new Date().toISOString(),
      })
      .eq('id', vendorServiceId)
      .select();

    if (deleteError) {
      console.error('Delete error:', deleteError);
      return res.status(500).json({ error: 'Failed to remove service' });
    }

    if (!deletedService || deletedService.length === 0) {
      return res.status(404).json({ error: 'Service not found' });
    }

    return res.json({
      success: true,
      message: 'Service removed from your listings',
    });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ===================================================
// VENDOR SERVICE DISCOVERY (For Users browsing services)
// ===================================================

/**
 * GET /api/services/:serviceId/vendors
 * Get all vendors offering a specific service by location
 * 
 * @query {string} location - Optional: Filter by location (district name)
 * @query {boolean} online_only - Optional: Show only online vendors
 * @returns {Array} Vendors offering this service
 */
router.get('/services/:serviceId/vendors', async (req, res) => {
  try {
    const { serviceId } = req.params;
    const { location, online_only } = req.query;

    // Start with base query
    let query = supabase
      .from('vendor_service_details')
      .select('*')
      .eq('service_id', serviceId)
      .eq('availability', 'available');

    // Apply location filter if provided
    if (location) {
      query = query.eq('location', location);
    }

    // Apply online filter if requested
    if (online_only === 'true') {
      query = query.eq('is_online', true);
    }

    // Order by rating (highest first)
    query = query.order('service_rating', { ascending: false });

    const { data: vendors, error } = await query;

    if (error) {
      console.error('Query error:', error);
      return res.status(500).json({ error: 'Failed to fetch vendors' });
    }

    // Group by vendor and include details
    const vendorMap = {};
    vendors?.forEach((vendor) => {
      if (!vendorMap[vendor.vendor_id]) {
        vendorMap[vendor.vendor_id] = {
          vendor_id: vendor.vendor_id,
          vendor_name: vendor.vendor_name,
          vendor_rating: vendor.vendor_rating,
          services: [],
        };
      }
      vendorMap[vendor.vendor_id].services.push({
        vendor_service_id: vendor.vendor_service_id,
        service_name: vendor.service_name,
        emoji: vendor.emoji,
        pricing: vendor.pricing,
        pricing_unit: vendor.pricing_unit,
        location: vendor.location,
        start_time: vendor.start_time,
        end_time: vendor.end_time,
        is_online: vendor.is_online,
        service_rating: vendor.service_rating,
        num_reviews: vendor.num_reviews,
      });
    });

    const vendorList = Object.values(vendorMap);

    return res.json({
      success: true,
      count: vendorList.length,
      service_id: serviceId,
      location_filter: location || 'all',
      data: vendorList,
    });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * GET /api/services
 * Get all available services with vendor count
 */
router.get('/services', async (req, res) => {
  try {
    const { data: services, error } = await supabase
      .from('services')
      .select('*')
      .order('name', { ascending: true });

    if (error) {
      console.error('Query error:', error);
      return res.status(500).json({ error: 'Failed to fetch services' });
    }

    // Count vendors for each service
    const servicesWithVendorCount = await Promise.all(
      services.map(async (service) => {
        const { count, error: countError } = await supabase
          .from('vendor_services')
          .select('*', { count: 'exact', head: true })
          .eq('service_id', service.id)
          .eq('is_active', true);

        return {
          ...service,
          vendor_count: count || 0,
        };
      })
    );

    return res.json({
      success: true,
      count: servicesWithVendorCount.length,
      data: servicesWithVendorCount,
    });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * GET /api/vendors-by-service/:serviceName
 * Get vendors for a specific service by name
 */
router.get('/vendors-by-service/:serviceName', async (req, res) => {
  try {
    const { serviceName } = req.params;
    const { location } = req.query;

    // Find service
    const { data: service, error: serviceError } = await supabase
      .from('services')
      .select('id')
      .ilike('name', `%${serviceName}%`)
      .single();

    if (serviceError || !service) {
      return res.status(404).json({ error: 'Service not found' });
    }

    // Get vendors for this service
    let query = supabase
      .from('vendor_service_details')
      .select('*')
      .eq('service_id', service.id)
      .eq('availability', 'available');

    if (location) {
      query = query.eq('location', location);
    }

    const { data: vendors, error } = await query.order('service_rating', {
      ascending: false,
    });

    if (error) {
      console.error('Query error:', error);
      return res.status(500).json({ error: 'Failed to fetch vendors' });
    }

    return res.json({
      success: true,
      service_name: serviceName,
      count: vendors?.length || 0,
      data: vendors || [],
    });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
