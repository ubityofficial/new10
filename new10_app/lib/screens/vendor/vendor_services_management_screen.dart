import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class VendorServicesManagementScreen extends StatefulWidget {
  const VendorServicesManagementScreen({super.key});

  @override
  State<VendorServicesManagementScreen> createState() =>
      _VendorServicesManagementScreenState();
}

class _VendorServicesManagementScreenState
    extends State<VendorServicesManagementScreen> {
  int _selectedTab = 0;

  // Mock data
  final List<Map<String, dynamic>> availableServices = [
    {
      'id': '1',
      'name': 'Excavator Rental',
      'category': 'Heavy Machinery',
      'image': '🚜',
      'description': 'Heavy-duty excavators for construction',
    },
    {
      'id': '2',
      'name': 'Water Tanker Service',
      'category': 'Utilities',
      'image': '💧',
      'description': 'Water supply & transportation',
    },
    {
      'id': '3',
      'name': 'Crane Services',
      'category': 'Heavy Machinery',
      'image': '🏗️',
      'description': 'Lifting & hoisting solutions',
    },
  ];

  final List<Map<String, dynamic>> vendorServices = [
    {
      'id': 'vs1',
      'serviceId': '1',
      'serviceName': 'Excavator Rental',
      'pricing': 5000,
      'duration': '8 hours',
      'location': 'Mumbai',
      'timings': {'start': '08:00', 'end': '18:00'},
      'availability': true,
    },
  ];

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AddServiceDialog(
        availableServices: availableServices,
        onServiceAdded: (service) {
          setState(() {
            vendorServices.add({
              ...service,
              'id': 'vs${DateTime.now().millisecondsSinceEpoch}',
            });
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditServiceDialog(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => EditServiceDialog(
        service: service,
        onServiceUpdated: (updatedService) {
          setState(() {
            final index =
                vendorServices.indexWhere((s) => s['id'] == service['id']);
            if (index != -1) {
              vendorServices[index] = updatedService;
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Services'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 0
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'My Services',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedTab == 0
                                ? AppTheme.primaryColor
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 1
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Available Services',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedTab == 1
                                ? AppTheme.primaryColor
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _selectedTab == 0
                ? _buildMyServicesTab()
                : _buildAvailableServicesTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildMyServicesTab() {
    return vendorServices.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'No services added yet',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showAddServiceDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Service'),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vendorServices.length,
            itemBuilder: (context, index) {
              final service = vendorServices[index];
              return ServiceCard(
                service: service,
                onEdit: () => _showEditServiceDialog(service),
                onDelete: () {
                  setState(() {
                    vendorServices.removeAt(index);
                  });
                },
              );
            },
          );
  }

  Widget _buildAvailableServicesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availableServices.length,
      itemBuilder: (context, index) {
        final service = availableServices[index];
        final isAdded = vendorServices.any(
          (vs) => vs['serviceId'] == service['id'],
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Row(
            children: [
              Text(service['image'], style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service['category'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: isAdded ? null : _showAddServiceDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAdded ? Colors.grey : AppTheme.primaryColor,
                  foregroundColor:
                      isAdded ? Colors.white : Colors.black,
                ),
                child: Text(isAdded ? 'Added' : 'Add'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Add Service Dialog
class AddServiceDialog extends StatefulWidget {
  final List<Map<String, dynamic>> availableServices;
  final Function(Map<String, dynamic>) onServiceAdded;

  const AddServiceDialog({
    super.key,
    required this.availableServices,
    required this.onServiceAdded,
  });

  @override
  State<AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<AddServiceDialog> {
  Map<String, dynamic>? selectedService;
  final _pricingController = TextEditingController();
  final _durationController = TextEditingController();
  final _locationController = TextEditingController();
  final _startTimeController = TextEditingController(text: '09:00');
  final _endTimeController = TextEditingController(text: '18:00');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Service'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Service',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<Map<String, dynamic>>(
                isExpanded: true,
                underline: const SizedBox(),
                value: selectedService,
                items: widget.availableServices
                    .map((service) => DropdownMenuItem(
                          value: service,
                          child: Text(service['name']),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedService = value),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pricingController,
              decoration: const InputDecoration(
                labelText: 'Pricing (₹)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (e.g., 8 hours)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: ' Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Start Time',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        _startTimeController.text = time.format(context);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(
                      labelText: 'End Time',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        _endTimeController.text = time.format(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedService != null &&
                  _pricingController.text.isNotEmpty &&
                  _durationController.text.isNotEmpty &&
                  _locationController.text.isNotEmpty
              ? () {
                  widget.onServiceAdded({
                    'serviceId': selectedService!['id'],
                    'serviceName': selectedService!['name'],
                    'pricing': int.parse(_pricingController.text),
                    'duration': _durationController.text,
                    'location': _locationController.text,
                    'timings': {
                      'start': _startTimeController.text,
                      'end': _endTimeController.text,
                    },
                    'availability': true,
                  });
                }
              : null,
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pricingController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }
}

// Edit Service Dialog
class EditServiceDialog extends StatefulWidget {
  final Map<String, dynamic> service;
  final Function(Map<String, dynamic>) onServiceUpdated;

  const EditServiceDialog({
    super.key,
    required this.service,
    required this.onServiceUpdated,
  });

  @override
  State<EditServiceDialog> createState() => _EditServiceDialogState();
}

class _EditServiceDialogState extends State<EditServiceDialog> {
  late TextEditingController _pricingController;
  late TextEditingController _durationController;
  late TextEditingController _locationController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  @override
  void initState() {
    super.initState();
    _pricingController =
        TextEditingController(text: widget.service['pricing'].toString());
    _durationController =
        TextEditingController(text: widget.service['duration']);
    _locationController = TextEditingController(text: widget.service['location']);
    _startTimeController = TextEditingController(
      text: widget.service['timings']['start'],
    );
    _endTimeController =
        TextEditingController(text: widget.service['timings']['end']);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Service'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pricingController,
              decoration: const InputDecoration(
                labelText: 'Pricing (₹)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Start Time',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        _startTimeController.text = time.format(context);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(
                      labelText: 'End Time',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        _endTimeController.text = time.format(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onServiceUpdated({
              ...widget.service,
              'pricing': int.parse(_pricingController.text),
              'duration': _durationController.text,
              'location': _locationController.text,
              'timings': {
                'start': _startTimeController.text,
                'end': _endTimeController.text,
              },
            });
          },
          child: const Text('Update'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pricingController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }
}

// Service Card Widget
class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['serviceName'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service['location'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: onEdit,
                    color: AppTheme.primaryColor,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: onDelete,
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${service['pricing']}/day',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  service['availability'] ? 'Available' : 'Unavailable',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
