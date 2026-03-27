import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/locations.dart';

class VendorListingPage extends StatefulWidget {
  final String serviceName;
  
  const VendorListingPage({
    super.key,
    required this.serviceName,
  });

  @override
  State<VendorListingPage> createState() => _VendorListingPageState();
}

class _VendorListingPageState extends State<VendorListingPage> {
  late String selectedLocation;
  bool isLoading = true;
  Map<String, dynamic>? serviceData;
  List<dynamic> allVendors = [];
  List<dynamic> filteredVendors = [];
  String? errorMessage;

  // Karnataka districts
  final List<String> karnatakDistricts = [
    'All Districts',
    'Bangalore',
    'Mysore',
    'Mangalore',
    'Hassan',
    'Tumkur',
    'Gulbarga',
    'Belgaum',
    'Chitradurga',
    'Hubballi',
    'Davangere',
    'Kolar',
    'Chikmagalur',
    'Shimoga',
    'Kodagu',
    'Uttara Kannada',
    'Yadgir',
    'Raichur',
  ];

  @override
  void initState() {
    super.initState();
    selectedLocation = 'All Districts';
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    try {
      setState(() => isLoading = true);
      
      final provider = Provider.of<ServiceProvider>(context, listen: false);
      final response = await provider.fetchVendorsByService(widget.serviceName);
      
      setState(() {
        serviceData = response['service'];
        allVendors = response['vendors'] ?? [];
        filteredVendors = List.from(allVendors);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load vendors: $e';
        isLoading = false;
      });
    }
  }

  void _filterByLocation(String? location) {
    if (location == null) return;
    
    setState(() {
      selectedLocation = location;
      
      if (location == 'All Districts') {
        filteredVendors = List.from(allVendors);
      } else {
        filteredVendors = allVendors.where((vendor) {
          final vendorLocation = vendor['location']?.toString() ?? '';
          return vendorLocation.toLowerCase().contains(location.toLowerCase());
        }).toList();
      }
    });
  }

  void _showVendorDetails(Map<String, dynamic> vendor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildVendorDetailsSheet(vendor),
    );
  }

  Widget _buildVendorDetailsSheet(Map<String, dynamic> vendor) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            // Service Image/Emoji
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  serviceData?['emoji'] ?? '🏗️',
                  style: const TextStyle(fontSize: 80),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Vendor Business Name
            Text(
              vendor['business_name'] ?? 'Unknown Vendor',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            
            // Availability Status
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: vendor['isOnline'] == true ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  vendor['isOnline'] == true ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: vendor['isOnline'] == true ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Service Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rating',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '4.5',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Pricing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Price Per Day',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '₹${vendor['pricing'] ?? '0'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        vendor['location'] ?? 'Not specified',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Book Now Button
            ElevatedButton(
              onPressed: () {
                // TODO: Implement booking functionality
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorCard(Map<String, dynamic> vendor) {
    return GestureDetector(
      onTap: () => _showVendorDetails(vendor),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Service Emoji
            Text(
              serviceData?['emoji'] ?? '🏗️',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 8),
            
            // Vendor business name (truncated)
            Text(
              vendor['business_name'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            
            // Rating (stars)
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                const Text(
                  '4.5',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Pricing
            Text(
              '₹${vendor['pricing'] ?? '0'}/day',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            
            // Online/Offline indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: vendor['isOnline'] == true ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      vendor['isOnline'] == true ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 10,
                        color: vendor['isOnline'] == true ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showVendorDetails(vendor),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceData?['name'] ?? widget.serviceName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${filteredVendors.length} vendors available',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Location Filter Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedLocation,
                      isExpanded: true,
                      underline: Container(),
                      items: karnatakDistricts.map((district) {
                        return DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                      onChanged: _filterByLocation,
                    ),
                  ),
                ],
              ),
            ),
            
            // Vendors Grid
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(child: Text(errorMessage!))
                      : filteredVendors.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.business, size: 64, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  const Text('No vendors found'),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try selecting a different location',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                              itemCount: filteredVendors.length,
                              itemBuilder: (context, index) {
                                return _buildVendorCard(
                                  filteredVendors[index] as Map<String, dynamic>,
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
