import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/service_model.dart';
import '../../models/vendor_service_model.dart';
import '../../theme/app_theme.dart';
import '../../services/service_api_client.dart';

class VendorServicesManagementScreenNew extends StatefulWidget {
  const VendorServicesManagementScreenNew({super.key});

  @override
  State<VendorServicesManagementScreenNew> createState() =>
      _VendorServicesManagementScreenNewState();
}

class _VendorServicesManagementScreenNewState
    extends State<VendorServicesManagementScreenNew>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Available services (from admin)
  List<Service> _availableServices = [];
  bool _isLoadingAvailable = false;
  String? _availableError;

  // Vendor's selected services
  List<VendorService> _myServices = [];
  bool _isLoadingMyServices = false;

  // Temporary vendor ID (in real app, from auth)
  final String _vendorId = 'vendor_123';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAvailableServices();
    _loadMyServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableServices() async {
    if (!mounted) return;
    setState(() => _isLoadingAvailable = true);
    
    try {
      final services = await ServiceApiClient().fetchAllServices();
      if (mounted) {
        setState(() {
          _availableServices = services;
          _isLoadingAvailable = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availableError = 'Failed to load services: $e';
          _isLoadingAvailable = false;
        });
      }
    }
  }

  Future<void> _loadMyServices() async {
    if (!mounted) return;
    setState(() => _isLoadingMyServices = true);
    
    // In real app, fetch from backend: /api/vendor/:vendorId/services
    // For now, load from shared prefs or mock
    if (mounted) {
      setState(() => _isLoadingMyServices = false);
    }
  }

  void _openAddServiceForm(Service service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddServiceFormSheet(
        service: service,
        vendorId: _vendorId,
        onAdd: (vendorService) {
          setState(() {
            _myServices.add(vendorService);
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${service.name} added to your services'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        title: const Text('Manage Services'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            const Tab(text: 'My Services'),
            const Tab(text: 'Available Services'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Services Tab
          _buildMyServicesTab(),
          // Available Services Tab
          _buildAvailableServicesTab(),
        ],
      ),
    );
  }

  Widget _buildMyServicesTab() {
    if (_isLoadingMyServices) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No services added yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Go to "Available Services" to add',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myServices.length,
      itemBuilder: (context, index) {
        final service = _myServices[index];
        return _buildMyServiceCard(service, index);
      },
    );
  }

  Widget _buildAvailableServicesTab() {
    if (_isLoadingAvailable) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              _availableError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAvailableServices,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_availableServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No services available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _availableServices.length,
      itemBuilder: (context, index) {
        final service = _availableServices[index];
        final isAlreadyAdded =
            _myServices.any((vs) => vs.serviceId == service.id);

        return _buildAvailableServiceCard(
          service,
          isAlreadyAdded,
        );
      },
    );
  }

  Widget _buildMyServiceCard(VendorService service, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Emoji/Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    service.emoji ?? '📦',
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.serviceName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: service.availability == 'available'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        service.availability.capitalize(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: service.availability == 'available'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Details Grid
          Row(
            children: [
              Expanded(
                child: _buildDetailField(
                  '₹${service.pricing.toStringAsFixed(0)}',
                  service.pricingUnit,
                  '💰',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDetailField(
                  '📍',
                  service.location,
                  '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Time Row
          Row(
            children: [
              Expanded(
                child: _buildDetailField(
                  service.startTime ?? '--',
                  'Start',
                  '🕐',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDetailField(
                  service.endTime ?? '--',
                  'End',
                  '🕐',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Online Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: service.isOnline
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: service.isOnline ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  service.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: service.isOnline
                        ? Colors.green.shade700
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Edit service
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit coming soon'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _myServices.removeAt(index));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${service.serviceName} removed'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableServiceCard(Service service, bool isAdded) {
    return GestureDetector(
      onTap: isAdded ? null : () => _openAddServiceForm(service),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAdded
                ? AppTheme.primaryColor.withOpacity(0.3)
                : Colors.grey.shade200,
            width: isAdded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Service Image/Icon
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  service.emoji ?? '📦',
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),

            // Service Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    service.category,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Add Button
                  if (!isAdded)
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => _openAddServiceForm(service),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check,
                            size: 14,
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Added',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(String value, String label, String emoji) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

// Add Service Form Sheet
class _AddServiceFormSheet extends StatefulWidget {
  final Service service;
  final String vendorId;
  final Function(VendorService) onAdd;

  const _AddServiceFormSheet({
    required this.service,
    required this.vendorId,
    required this.onAdd,
  });

  @override
  State<_AddServiceFormSheet> createState() => _AddServiceFormSheetState();
}

class _AddServiceFormSheetState extends State<_AddServiceFormSheet> {
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  String _pricingUnit = 'per day';
  String _availability = 'available';
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _locationController = TextEditingController();
    _startTimeController = TextEditingController(text: '08:00');
    _endTimeController = TextEditingController(text: '18:00');
  }

  @override
  void dispose() {
    _priceController.dispose();
    _locationController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_priceController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final vendorService = VendorService(
      id: const Uuid().v4(),
      vendorId: widget.vendorId,
      serviceId: widget.service.id,
      serviceName: widget.service.name,
      emoji: widget.service.emoji,
      pricing: double.parse(_priceController.text),
      pricingUnit: _pricingUnit,
      location: _locationController.text,
      availability: _availability,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      isOnline: _isOnline,
      createdAt: DateTime.now().toString(),
    );

    widget.onAdd(vendorService);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Text(
                  widget.service.emoji ?? '📦',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add ${widget.service.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Set your pricing and availability',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pricing
            Text(
              'Pricing *',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter price',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _pricingUnit,
                    onChanged: (value) {
                      setState(() => _pricingUnit = value ?? 'per day');
                    },
                    items: ['per day', 'per hour', 'per unit']
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ))
                        .toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location
            Text(
              'Service Location *',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'e.g., Mumbai, Bangalore',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Working Hours
            Text(
              'Working Hours',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startTimeController,
                    decoration: InputDecoration(
                      hintText: 'Start time',
                      prefixIcon: const Icon(Icons.schedule),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _endTimeController,
                    decoration: InputDecoration(
                      hintText: 'End time',
                      prefixIcon: const Icon(Icons.schedule),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Availability
            Text(
              'Availability',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _availability,
              onChanged: (value) {
                setState(() => _availability = value ?? 'available');
              },
              items: ['available', 'limited', 'unavailable']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.capitalize()),
                      ))
                  .toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Online Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Go Online',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Switch(
                  value: _isOnline,
                  onChanged: (value) {
                    setState(() => _isOnline = value);
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Add Service'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
