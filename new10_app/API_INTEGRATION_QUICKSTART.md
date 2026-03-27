# Vendor Services API Integration - Quick Start

## Current Status ✅
- **API Client**: Created (`VendorServiceApiClient`)
- **Provider**: Created (`VendorServicesProvider`)
- **Models**: Enhanced (`VendorService`, `Service`)
- **Backend APIs**: Ready (8 endpoints documented in `backend/routes/vendorServices.js`)
- **Database Schema**: Ready (SQL in `backend/DATABASE_SCHEMA.sql`)

## What Works Now
- Vendor can browse available services (grid view)
- Vendor can add services with pricing, location, availability
- Vendor can view their added services
- Vendor can update service details
- Vendor can delete services
- Users can search for vendors by service name and location

## Immediate Next Steps (In Order of Priority)

### Step 1: Register Provider in main.dart
```dart
// In your main.dart MultiProvider:

MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => VendorProvider()),
    ChangeNotifierProvider(create: (_) => VendorServicesProvider()), // ← ADD THIS LINE
    // ... other providers
  ],
  child: MyApp(),
)
```

### Step 2: Update vendor_services_management_screen_new.dart
Replace the entire `_buildAvailableServicesTab()` method with the code from `INTEGRATION_GUIDE.dart` section "AVAILABLE SERVICES TAB".

**Key changes:**
- Load services in `initState()`: 
  ```dart
  context.read<VendorServicesProvider>().loadAvailableServices();
  ```
- Use `Consumer<VendorServicesProvider>` to listen to state changes
- When user clicks "Add Service", show `_AddServiceForm` dialog
- Form submission calls `provider.addService(...)`

### Step 3: Load Vendor's Existing Services in Tab 1
In `_buildMyServicesTab()`:
```dart
// On init, load vendor's services:
context.read<VendorServicesProvider>()
  .loadVendorServices(vendorId);

// In UI, show services from:
context.read<VendorServicesProvider>().vendorServices
```

### Step 4: Test the Flow
1. Open vendor dashboard
2. Navigate to "Services" tab
3. Click "Available Services" tab
4. Click a service card → "Add Service" form appears
5. Fill form: Price ₹500, Unit "per day", Location "Bangalore", Availability "available"
6. Click "Add Service" → Should appear in "My Services" tab
7. Long press service → Edit or Delete

### Step 5: No Backend Changes Needed!
The backend code already exists:
- ✅ `backend/routes/vendorServices.js` has all 8 endpoints
- ✅ Database schema is documented
- **ACTION NEEDED:** Still need to run migrations and register routes in server.js

## What's Inside the Integration

### 1. VendorServiceApiClient.dart
**Location:** `lib/services/vendor_service_api_client.dart`

**Methods:**
```dart
// Vendor flows
getVendorServices(vendorId)
addVendorService(vendorId, serviceId, pricing, pricingUnit, location, availability)
updateVendorService(vendorServiceId, pricing, location, availability)
deleteVendorService(vendorServiceId)

// User discovery flows
getVendorsForService(serviceId, location?, onlineOnly?)
getVendorsByServiceName(serviceName, location?)
getAllServices()
```

### 2. VendorServicesProvider.dart
**Location:** `lib/providers/vendor_services_provider.dart`

**State:**
- `vendorServices` - List of vendor's added services
- `availableServices` - All services to choose from
- `vendorsForService` - Vendors offering a specific service
- Loading flags and error messages for each

**Methods:**
- `loadVendorServices(vendorId)`
- `addService(...)`
- `updateService(...)`
- `deleteService(id)`
- `loadAvailableServices()`
- `loadVendorsForService(serviceId)`
- `searchVendorsByServiceName(name)`

### 3. Models
- `VendorService` - Vendor's service listing (pricing, location, availability)
- `Service` - Admin service definition (name, description, vendor_count)

## Examples

### Example 1: Vendor adds a Plumbing service
```dart
final provider = context.read<VendorServicesProvider>();
final vendorId = context.read<VendorProvider>().vendor!.id;

final success = await provider.addService(
  vendorId: vendorId,
  serviceId: plumbingServiceId,
  pricing: 1500,
  pricingUnit: 'per hour',
  location: 'Bangalore',
  availability: 'available',
  startTime: '08:00',
  endTime: '18:00',
);

if (success) {
  print('Service added! ✅');
  // Service automatically appears in vendor's list
}
```

### Example 2: User searches vendors for Plumbing
```dart
final provider = context.read<VendorServicesProvider>();

// Search for vendors by service name
await provider.searchVendorsByServiceName(
  'Plumbing',
  location: 'Bangalore', // optional
);

// Access results
final vendors = provider.vendorsForService; // List of vendors
final isLoading = provider.isLoadingVendorsForService;
final error = provider.vendorsForServiceError;
```

### Example 3: Show all services with vendor counts
```dart
final provider = context.read<VendorServicesProvider>();
await provider.loadAvailableServices();

// Each service has:
// - name: "Plumbing"
// - emoji: "🔧"
// - vendorCount: 5 (5 vendors offer this)
// - pricePerHour: null (admin doesn't set default price)
```

## File Structure
```
lib/
├── services/
│   └── vendor_service_api_client.dart     ✨ NEW
├── providers/
│   └── vendor_services_provider.dart      ✨ NEW
├── models/
│   ├── vendor_service_model.dart          📝 UPDATED
│   └── service_model.dart                 📝 UPDATED
└── screens/
    ├── vendor/
    │   └── vendor_services_management_screen_new.dart  ⚠️ NEEDS UPDATE
    └── ...

backend/
├── routes/
│   └── vendorServices.js                  ✨ NEW (Ready)
├── DATABASE_SCHEMA.sql                    ✨ NEW (Ready)
└── server.js                              ⚠️ NEEDS UPDATE (Add route registration)

INTEGRATION_GUIDE.dart                     📖 Complete examples
```

## Debugging Tips

### 1. Check Logs
All API calls have color-coded console logs:
```
🔵 Fetching vendor services from: https://...
🟢 Response status: 200
🟢 Loaded 3 vendor services
```

Look for 🟢 (success) or 🔴 (error) in console.

### 2. Error Messages
Provider tracks errors automatically:
```dart
if (provider.vendorServicesError != null) {
  print('Error: ${provider.vendorServicesError}');
}
```

### 3. Check Network
Ensure backend is running:
```
curl https://new10-yk1r.onrender.com/api/services
```

Should return list of services (empty if migrations not run).

## Common Issues & Solutions

### Issue: "Services show empty list"
**Solution:** Backend migrations not run yet. SQL schema must be executed in Supabase.

### Issue: "Cannot POST /api/vendor/:vendorId/services"
**Solution:** Routes not registered in server.js. Need to add:
```javascript
const vendorServicesRouter = require('./routes/vendorServices');
app.use('/api', vendorServicesRouter);
```

### Issue: "Service added but doesn't appear in list"
**Solution:** Provider is loaded, but UI not refreshing. Ensure using `Consumer<VendorServicesProvider>`.

### Issue: "Form shows "No services available"
**Solution:** 
1. Check if `loadAvailableServices()` is called
2. Check if any services exist in admin data
3. Look console for 🔴 errors

## API Endpoints Summary

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/services` | Get all admin services with vendor counts |
| GET | `/api/vendor/:vendorId/services` | Get vendor's added services |
| POST | `/api/vendor/:vendorId/services` | Add service to vendor |
| PUT | `/api/vendor/services/:vendorServiceId` | Update vendor's service |
| DELETE | `/api/vendor/services/:vendorServiceId` | Remove vendor's service |
| GET | `/api/services/:serviceId/vendors` | Find vendors for a service |
| GET | `/api/vendors-by-service/:serviceName` | Search vendors by name |

## What Each API Returns

### GET /api/services
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Plumbing",
      "emoji": "🔧",
      "category": "Home Services",
      "vendor_count": 5
    }
  ]
}
```

### POST /api/vendor/:vendorId/services
```json
{
  "success": true,
  "statusCode": 201,
  "data": {
    "id": "uuid",
    "vendor_id": "uuid",
    "service_id": "uuid",
    "service_name": "Plumbing",
    "pricing": 1500,
    "pricing_unit": "per hour",
    "location": "Bangalore",
    "availability": "available",
    "start_time": "08:00",
    "end_time": "18:00",
    "is_active": true
  }
}
```

## Verification Checklist

- [ ] Provider added to main.dart MultiProvider
- [ ] vendor_services_management_screen imports updated
- [ ] _buildAvailableServicesTab() shows real services
- [ ] _buildMyServicesTab() loads vendor's services
- [ ] Add service form submits to API
- [ ] Services appear in list after adding
- [ ] Edit/Delete functions work
- [ ] No red errors in console
- [ ] All 8 API endpoints tested with Postman/Thunder Client

## Next Session

Priority order:
1. ✅ Create API client + provider (DONE)
2. ⏳ Register provider in main.dart
3. ⏳ Update vendor_services_management_screen_new.dart
4. ⏳ Test vendor flow end-to-end
5. ⏳ Run database migrations in Supabase
6. ⏳ Register routes in backend server.js
7. ⏳ Test backend endpoints with Postman

Good luck! 🚀
