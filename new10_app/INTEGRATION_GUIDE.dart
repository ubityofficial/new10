/**
 * INTEGRATION GUIDE: Vendor Service APIs with Flutter UI
 * 
 * This guide demonstrates how to integrate the new VendorServiceApiClient
 * and VendorServicesProvider with existing vendor screens.
 */

// ===================================================
// 1. VENDOR SERVICES MANAGEMENT SCREEN
// ===================================================

/**
 * FILE: vendor_services_management_screen_new.dart
 * 
 * CHANGES NEEDED:
 * 1. Add provider listener in initState
 * 2. Replace mock service grid with real API data
 * 3. Connect form submission to API call
 * 4. Display vendor's services from database
 */

class VendorServicesManagementScreen extends StatefulWidget {
  @override
  State<VendorServicesManagementScreen> createState() =>
      _VendorServicesManagementScreenState();
}

class _VendorServicesManagementScreenState
    extends State<VendorServicesManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data on init
    final provider =
        context.read<VendorServicesProvider>();
    final vendorProvider = context.read<VendorProvider>();

    // Load vendor's existing services
    provider.loadVendorServices(vendorProvider.vendor!.id);

    // Load available services to show in grid
    provider.loadAvailableServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Services',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Services'),
            Tab(text: 'Available Services'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: MY SERVICES (vendor's added services)
          _buildMyServicesTab(),

          // TAB 2: AVAILABLE SERVICES (all services to add)
          _buildAvailableServicesTab(),
        ],
      ),
    );
  }

  // ==================================================
  // MY SERVICES TAB
  // ==================================================
  Widget _buildMyServicesTab() {
    return Consumer<VendorServicesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingVendorServices) {
          return const Center(child: CircularProgressIndicator());
        }

        final services = provider.vendorServices;

        if (services.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.service_outline,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No services added yet',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(1),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Service'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return Card(
              child: ListTile(
                leading: Text(service.emoji ?? '🛠️', style: const TextStyle(fontSize: 24)),
                title: Text(service.serviceName),
                subtitle: Text('${service.formattedPrice} @ ${service.location}'),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Edit'),
                      onTap: () => _showEditServiceDialog(
                        context,
                        service,
                      ),
                    ),
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () => _deleteService(context, service.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================================================
  // AVAILABLE SERVICES TAB
  // ==================================================
  Widget _buildAvailableServicesTab() {
    return Consumer<VendorServicesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingAvailableServices) {
          return const Center(child: CircularProgressIndicator());
        }

        final services = provider.availableServices;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return GestureDetector(
              onTap: () => _showAddServiceDialog(context, service),
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(service.emoji ?? '🛠️',
                        style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text(service.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      '${service.vendorCount ?? 0} vendors',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================================================
  // ADD SERVICE DIALOG
  // ==================================================
  void _showAddServiceDialog(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${service.name}'),
        content: SingleChildScrollView(
          child: _AddServiceForm(service: service),
        ),
      ),
    );
  }

  // ==================================================
  // EDIT SERVICE DIALOG
  // ==================================================
  void _showEditServiceDialog(
    BuildContext context,
    VendorService service,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${service.serviceName}'),
        content: SingleChildScrollView(
          child: _EditServiceForm(service: service),
        ),
      ),
    );
  }

  // ==================================================
  // DELETE SERVICE
  // ==================================================
  void _deleteService(BuildContext context, String vendorServiceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service?'),
        content: const Text(
            'This will remove the service from your listings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<VendorServicesProvider>()
                  .deleteService(vendorServiceId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service removed')),
              );
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// ===================================================
// 2. ADD SERVICE FORM WIDGET
// ===================================================

class _AddServiceForm extends StatefulWidget {
  final Service service;

  const _AddServiceForm({required this.service});

  @override
  State<_AddServiceForm> createState() => _AddServiceFormState();
}

class _AddServiceFormState extends State<_AddServiceForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _priceController;
  String _pricingUnit = 'per day';
  String _location = 'Bangalore';
  String _availability = 'available';
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _startTimeController = TextEditingController(text: '08:00');
    _endTimeController = TextEditingController(text: '18:00');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Price input
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Pricing',
              prefixText: '₹',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (double.tryParse(value!) == null)
                return 'Invalid price';
              return null;
            },
            filled: true,
            fillColor: Colors.white,
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 16),

          // Pricing unit dropdown
          DropdownButtonFormField<String>(
            value: _pricingUnit,
            items: ['per hour', 'per day', 'per unit']
                .map((unit) =>
                    DropdownMenuItem(value: unit, child: Text(unit)))
                .toList(),
            onChanged: (value) =>
                setState(() => _pricingUnit = value ?? 'per day'),
            decoration: const InputDecoration(
              labelText: 'Pricing Unit',
              border: OutlineInputBorder(),
            ),
            isDense: true,
            isExpanded: true,
            filled: true,
            fillColor: Colors.white,
          ),
          const SizedBox(height: 16),

          // Location dropdown (25 Karnataka cities)
          DropdownButtonFormField<String>(
            value: _location,
            items: VendorServiceApiClient.getKarnatakaCities()
                .map((city) =>
                    DropdownMenuItem(value: city, child: Text(city)))
                .toList(),
            onChanged: (value) =>
                setState(() => _location = value ?? 'Bangalore'),
            decoration: const InputDecoration(
              labelText: 'Service Location',
              border: OutlineInputBorder(),
            ),
            isDense: true,
            isExpanded: true,
            filled: true,
            fillColor: Colors.white,
          ),
          const SizedBox(height: 16),

          // Availability dropdown
          DropdownButtonFormField<String>(
            value: _availability,
            items: ['available', 'limited', 'unavailable']
                .map((status) =>
                    DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: (value) =>
                setState(() => _availability = value ?? 'available'),
            decoration: const InputDecoration(
              labelText: 'Availability',
              border: OutlineInputBorder(),
            ),
            isDense: true,
            isExpanded: true,
            filled: true,
            fillColor: Colors.white,
          ),
          const SizedBox(height: 16),

          // Start and end times
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _startTimeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Start Time',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () => _selectTime(context, _startTimeController),
                  filled: true,
                  fillColor: Colors.white,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _endTimeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'End Time',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () => _selectTime(context, _endTimeController),
                  filled: true,
                  fillColor: Colors.white,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Submit button
          ElevatedButton(
            onPressed: _submitAddService,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Add Service',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _selectTime(BuildContext context, TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      controller.text = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  void _submitAddService() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<VendorServicesProvider>();
    final vendorProvider = context.read<VendorProvider>();

    final success = await provider.addService(
      vendorId: vendorProvider.vendor!.id,
      serviceId: widget.service.id,
      pricing: double.parse(_priceController.text),
      pricingUnit: _pricingUnit,
      location: _location,
      availability: _availability,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
    );

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service added: ${widget.service.name}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.vendorServicesError}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }
}

// ===================================================
// 3. EDIT SERVICE FORM WIDGET
// ===================================================

class _EditServiceForm extends StatefulWidget {
  final VendorService service;

  const _EditServiceForm({required this.service});

  @override
  State<_EditServiceForm> createState() => _EditServiceFormState();
}

class _EditServiceFormState extends State<_EditServiceForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _priceController;
  late String _location;
  late String _availability;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
        text: widget.service.pricing.toStringAsFixed(0));
    _location = widget.service.location;
    _availability = widget.service.availability;
    _startTimeController =
        TextEditingController(text: widget.service.startTime ?? '08:00');
    _endTimeController =
        TextEditingController(text: widget.service.endTime ?? '18:00');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Pricing',
              prefixText: '₹',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (double.tryParse(value!) == null) return 'Invalid';
              return null;
            },
            filled: true,
            fillColor: Colors.white,
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _location,
            items: VendorServiceApiClient.getKarnatakaCities()
                .map((city) =>
                    DropdownMenuItem(value: city, child: Text(city)))
                .toList(),
            onChanged: (value) => setState(() => _location = value ?? ''),
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
            isDense: true,
            isExpanded: true,
            filled: true,
            fillColor: Colors.white,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _availability,
            items: ['available', 'limited', 'unavailable']
                .map((status) =>
                    DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: (value) =>
                setState(() => _availability = value ?? 'available'),
            decoration: const InputDecoration(
              labelText: 'Availability',
              border: OutlineInputBorder(),
            ),
            isDense: true,
            isExpanded: true,
            filled: true,
            fillColor: Colors.white,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Update Service',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<VendorServicesProvider>();

    final success = await provider.updateService(
      vendorServiceId: widget.service.id,
      pricing: double.parse(_priceController.text),
      location: _location,
      availability: _availability,
    );

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service updated')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.vendorServicesError}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }
}

// ===================================================
// 4. UPDATE MAIN.DART - REGISTER PROVIDER
// ===================================================

/**
 * In your main.dart MultiProvider, add:
 * 
 * MultiProvider(
 *   providers: [
 *     ChangeNotifierProvider(create: (_) => UserProvider()),
 *     ChangeNotifierProvider(create: (_) => VendorProvider()),
 *     ChangeNotifierProvider(create: (_) => VendorServicesProvider()), // ADD THIS
 *     ChangeNotifierProvider(create: (_) => ServiceProvider()),
 *     // ... other providers
 *   ],
 *   child: MyApp(),
 * )
 */

// ===================================================
// 5. USER SERVICES BROWSING EXAMPLE
// ===================================================

/**
 * For user side - when viewing vendors for a service:
 * 
 * In services_page.dart or vendor_listing_page.dart:
 * 
 * Future<void> _loadVendorsForService(String serviceId) async {
 *   final provider = context.read<VendorServicesProvider>();
 *   await provider.loadVendorsForService(
 *     serviceId,
 *     location: selectedLocation, // optional filter
 *   );
 * }
 * 
 * Then display provider.vendorsForService as list of vendors
 * Each item has vendor info + their pricing/availability for that service
 */
