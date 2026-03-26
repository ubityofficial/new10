import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/admin_model.dart';
import '../../providers/admin_provider.dart';

class AdminVendorManagementScreen extends StatefulWidget {
  const AdminVendorManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminVendorManagementScreen> createState() =>
      _AdminVendorManagementScreenState();
}

class _AdminVendorManagementScreenState
    extends State<AdminVendorManagementScreen> {
  late TextEditingController _searchController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Management'),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          List<VendorManagement> displayVendors =
              _getFilteredVendors(adminProvider);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search vendors by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: _selectedFilter == 'all',
                      onTap: () => setState(() => _selectedFilter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Pending',
                      isSelected: _selectedFilter == 'pending',
                      onTap: () =>
                          setState(() => _selectedFilter = 'pending'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Approved',
                      isSelected: _selectedFilter == 'approved',
                      onTap: () =>
                          setState(() => _selectedFilter = 'approved'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Suspended',
                      isSelected: _selectedFilter == 'suspended',
                      onTap: () =>
                          setState(() => _selectedFilter = 'suspended'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Vendors list
              Expanded(
                child: displayVendors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.business,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text('No vendors found'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: displayVendors.length,
                        itemBuilder: (context, index) {
                          final vendor = displayVendors[index];
                          return _VendorCard(
                            vendor: vendor,
                            onApprove: vendor.status == 'pending'
                                ? () => _confirmAction(
                                      context,
                                      'Approve Vendor',
                                      'Are you sure you want to approve "${vendor.businessName}"?',
                                      () =>
                                          adminProvider.approveVendor(vendor.id),
                                    )
                                : null,
                            onReject: vendor.status == 'pending'
                                ? () => _showRejectDialog(
                                      context,
                                      vendor,
                                      adminProvider,
                                    )
                                : null,
                            onSuspend: vendor.status == 'approved'
                                ? () => _showSuspendDialog(
                                      context,
                                      vendor,
                                      adminProvider,
                                    )
                                : null,
                            onBlock: () => _showBlockDialog(
                              context,
                              vendor,
                              adminProvider,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<VendorManagement> _getFilteredVendors(AdminProvider adminProvider) {
    List<VendorManagement> vendors;

    if (_selectedFilter == 'all') {
      vendors = adminProvider.vendors;
    } else {
      vendors = adminProvider.getVendorsByStatus(_selectedFilter);
    }

    if (_searchController.text.isNotEmpty) {
      vendors = adminProvider.filterVendors(_searchController.text);
    }

    return vendors;
  }

  void _confirmAction(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title successful')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    VendorManagement vendor,
    AdminProvider adminProvider,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Vendor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter reason for rejection:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              adminProvider.rejectVendor(
                vendor.id,
                reasonController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vendor rejected')),
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showSuspendDialog(
    BuildContext context,
    VendorManagement vendor,
    AdminProvider adminProvider,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend Vendor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter reason for suspension:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              adminProvider.suspendVendor(
                vendor.id,
                reasonController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vendor suspended')),
              );
            },
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(
    BuildContext context,
    VendorManagement vendor,
    AdminProvider adminProvider,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block Vendor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter reason for blocking:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              adminProvider.blockVendor(
                vendor.id,
                reasonController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vendor blocked')),
              );
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1976D2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1976D2)
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final VendorManagement vendor;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onSuspend;
  final VoidCallback? onBlock;

  const _VendorCard({
    required this.vendor,
    this.onApprove,
    this.onReject,
    this.onSuspend,
    this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getStatusColor(vendor.status).withOpacity(0.2),
                  child: Icon(
                    _getStatusIcon(vendor.status),
                    color: _getStatusColor(vendor.status),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.businessName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Owner: ${vendor.ownerName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(vendor.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    vendor.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(vendor.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  vendor.email,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  vendor.phone,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'GST: ${vendor.gstNumber}',
                    style: const TextStyle(fontSize: 11, color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${vendor.totalEquipment} equipment',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.green),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star,
                          size: 12, color: Colors.amber.shade700),
                      const SizedBox(width: 2),
                      Text(
                        vendor.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                if (onApprove != null)
                  Expanded(
                    child: _ActionButton(
                      label: 'Approve',
                      onPressed: onApprove!,
                      color: Colors.green,
                    ),
                  ),
                if (onReject != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'Reject',
                      onPressed: onReject!,
                      color: Colors.red,
                    ),
                  ),
                ],
                if (onSuspend != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'Suspend',
                      onPressed: onSuspend!,
                      color: Colors.orange,
                    ),
                  ),
                ],
                if (onBlock != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'Block',
                      onPressed: onBlock!,
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'suspended':
        return Colors.amber;
      case 'blocked':
        return Colors.red;
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'suspended':
        return Icons.pause_circle;
      case 'blocked':
        return Icons.block;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        side: BorderSide(color: color),
      ),
      child: Text(label),
    );
  }
}
