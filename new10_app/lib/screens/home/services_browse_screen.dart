import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/service_api_client.dart';
import '../../services/cache_service.dart';
import '../../models/service_model.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../widgets/cached_image.dart';

class ServicesBrowseScreen extends StatefulWidget {
  const ServicesBrowseScreen({super.key});

  @override
  State<ServicesBrowseScreen> createState() => _ServicesBrowseScreenState();
}

class _ServicesBrowseScreenState extends State<ServicesBrowseScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  
  late List<Map<String, dynamic>> _filteredServices = [];
  List<Service> _allServices = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServicesWithCache();
  }

  Future<void> _loadServicesWithCache() async {
    // Load cached data first
    final cachedServices = await CacheService.getCachedServices();
    if (cachedServices != null && cachedServices.isNotEmpty) {
      final services = cachedServices
          .map((s) => Service.fromJson(s as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _allServices = services;
          _filteredServices = services
              .map((service) => service.toMap())
              .toList();
          print('✅ Loaded cached services: ${_allServices.length}');
        });
      }
    }

    // Fetch fresh data in background
    try {
      if (_allServices.isEmpty) {
        setState(() => _isLoading = true);
      }

      final services = await ServiceApiClient.getServices();
      if (!mounted) return;

      setState(() {
        _allServices = services;
        _filteredServices = services
            .map((service) => service.toMap())
            .toList();
        _isLoading = false;
        _error = null;
      });

      // Cache fresh data
      await CacheService.setCachedServices(
        services.map((s) => s.toJson()).toList() as List<dynamic>,
      );
      print('✅ Loaded and cached fresh services: ${services.length}');
      
      _filterServices();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load services: $e';
          _isLoading = false;
        });
      }
      print('❌ Error loading services: $e');
    }
  }

  // Mock vendor services data
  final Map<String, List<Map<String, dynamic>>> vendorServicesList = {
    '1': [
      {
        'id': 'vs1',
        'vendorName': 'Kumar Construction',
        'vendorRating': 4.8,
        'vendorReviews': 156,
        'vendorImage': '👷',
        'pricing': 5000,
        'duration': '8 hours',
        'location': 'Mumbai',
        'timings': {'start': '08:00', 'end': '18:00'},
        'availability': true,
      },
      {
        'id': 'vs2',
        'vendorName': 'Raj Equipment Rentals',
        'vendorRating': 4.6,
        'vendorReviews': 98,
        'vendorImage': '👨‍🔧',
        'pricing': 4500,
        'duration': '8 hours',
        'location': 'Mumbai',
        'timings': {'start': '09:00', 'end': '17:00'},
        'availability': true,
      },
    ],
    '2': [
      {
        'id': 'vs3',
        'vendorName': 'AquaMart Supplies',
        'vendorRating': 4.7,
        'vendorReviews': 89,
        'vendorImage': '💼',
        'pricing': 2000,
        'duration': 'per trip',
        'location': 'Mumbai',
        'timings': {'start': '06:00', 'end': '20:00'},
        'availability': true,
      },
    ],
    '3': [
      {
        'id': 'vs4',
        'vendorName': 'Premier Lifting Solutions',
        'vendorRating': 4.9,
        'vendorReviews': 203,
        'vendorImage': '🦺',
        'pricing': 8000,
        'duration': '12 hours',
        'location': 'Mumbai',
        'timings': {'start': '07:00', 'end': '19:00'},
        'availability': true,
      },
      {
        'id': 'vs5',
        'vendorName': 'SkyHooks Crane Rentals',
        'vendorRating': 4.7,
        'vendorReviews': 145,
        'vendorImage': '👷',
        'pricing': 7500,
        'duration': '12 hours',
        'location': 'Mumbai',
        'timings': {'start': '06:00', 'end': '18:00'},
        'availability': false,
      },
    ],
  };

  void _filterServices() {
    setState(() {
      _filteredServices = _allServices.where((service) {
        final matchesCategory =
            _selectedCategory == 'All' || service.category == _selectedCategory;
        final matchesSearch = _searchController.text.isEmpty ||
            service.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
        return matchesCategory && matchesSearch;
      }).map((service) => service.toMap()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Browse Services',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => _filterServices(),
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            // Categories
            Container(
              color: Colors.white,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: 8),
                  ...[
                    'All',
                    'Heavy Machinery',
                    'Water Supply',
                    'Equipment',
                  ].map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                            _filterServices();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedCategory == category
                                ? AppTheme.primaryColor
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  _selectedCategory == category
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                              color: _selectedCategory == category
                                  ? Colors.black
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
            // Services List
            Expanded(
              child: _isLoading && _filteredServices.isEmpty
                  ? const SkeletonServiceGrid(itemCount: 6)
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadServices,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _filteredServices.isEmpty
                          ? Center(
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
                                    'No services found',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredServices.length,
                              itemBuilder: (context, index) {
                                final service = _filteredServices[index];
                                return ServiceListCard(
                                  service: service,
                                  vendorList: vendorServicesList[service['id']] ?? [],
                                  onTap: () {
                                    _showVendorsList(service);
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVendorsList(Map<String, dynamic> service) {
    final vendors = vendorServicesList[service['id']] ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${service['rating']} (${service['reviews']} reviews)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Vendors list
            Expanded(
              child: vendors.isEmpty
                  ? Center(
                      child: Text(
                        'No vendors available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: vendors.length,
                      itemBuilder: (context, index) {
                        final vendor = vendors[index];
                        return VendorCard(vendor: vendor);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Service List Card
class ServiceListCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final List<Map<String, dynamic>> vendorList;
  final VoidCallback onTap;

  const ServiceListCard({
    super.key,
    required this.service,
    required this.vendorList,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            // Images section
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryLight.withOpacity(0.3),
                    AppTheme.primaryColor.withOpacity(0.2),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      service['image1'],
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Text(
                      service['image2'],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            // Details section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            service['category'],
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${service['rating']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${vendorList.length} vendor${vendorList.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Vendor Card
class VendorCard extends StatelessWidget {
  final Map<String, dynamic> vendor;

  const VendorCard({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vendor header
          Row(
            children: [
              Text(
                vendor['vendorImage'],
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor['vendorName'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${vendor['vendorRating']} • ${vendor['vendorReviews']} reviews',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: vendor['availability']
                      ? AppTheme.successColor.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  vendor['availability'] ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: vendor['availability']
                        ? AppTheme.successColor
                        : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Pricing and details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${vendor['pricing']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  Text(
                    vendor['duration'],
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(
                            vendor['location'],
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${vendor['timings']['start']} - ${vendor['timings']['end']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: vendor['availability']
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Booking feature coming soon')),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: vendor['availability']
                      ? AppTheme.primaryColor
                      : Colors.grey,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Book',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
