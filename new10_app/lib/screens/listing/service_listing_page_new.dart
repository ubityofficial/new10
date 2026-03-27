import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/locations.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/skeleton_loaders.dart';

class ServiceListingPage extends StatefulWidget {
  final String? categoryFilter;
  const ServiceListingPage({super.key, this.categoryFilter});

  @override
  State<ServiceListingPage> createState() => _ServiceListingPageState();
}

class _ServiceListingPageState extends State<ServiceListingPage> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Search and Filter Bar
            _buildSearchAndFilterBar(context),
            
            // Service Listings
            Expanded(
              child: _buildServicesList(context),
            ),
          ],
        ),
      ),
    );
  }

  // Header with back button
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
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
                  'Services & Equipment',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Find verified vendors in your area',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Search bar + Location filter dropdown
  Widget _buildSearchAndFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        spacing: 12,
        children: [
          // Search Bar
          _buildSearchBar(context),
          
          // Location Dropdown
          _buildLocationDropdown(context),
        ],
      ),
    );
  }

  // Professional Search Bar
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<ServiceProvider>().setSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'Search services, vendors...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    context.read<ServiceProvider>().setSearchQuery('');
                  },
                  child: Icon(Icons.close, color: Colors.grey.shade600),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // Location Dropdown
  Widget _buildLocationDropdown(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: DropdownButton<String>(
            value: provider.selectedDistrict,
            onChanged: (String? newValue) {
              if (newValue != null) {
                provider.setDistrict(newValue);
              }
            },
            isExpanded: true,
            underline: const SizedBox(),
            items: Locations.karnatakaDistricts.map((String district) {
              return DropdownMenuItem<String>(
                value: district,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: district == provider.selectedDistrict
                            ? AppTheme.primaryColor
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Locations.getFriendlyName(district),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: district == provider.selectedDistrict
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: district == provider.selectedDistrict
                              ? AppTheme.primaryColor
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            style: const TextStyle(color: Colors.black, fontSize: 14),
            icon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            ),
          ),
        );
      },
    );
  }

  // Service Listings
  Widget _buildServicesList(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.filteredServices.isEmpty) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SkeletonLoaders.serviceCardLoader(),
            ),
          );
        }

        if (provider.filteredServices.isEmpty) {
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
                  'No services found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search or location filters',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshServices(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: provider.filteredServices.length,
            itemBuilder: (context, index) {
              final service = provider.filteredServices[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildServiceCard(context, service),
              );
            },
          ),
        );
      },
    );
  }

  // Service Card - Professional UI
  Widget _buildServiceCard(BuildContext context, Service service) {
    return GestureDetector(
      onTap: () => _showServiceDetailSheet(context, service),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top section with emoji and info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Emoji/Icon - Small size
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.15),
                          AppTheme.primaryColor.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Center(
                      child: service.emoji != null
                          ? Text(
                              service.emoji!,
                              style: const TextStyle(fontSize: 28),
                            )
                          : Icon(
                              Icons.category,
                              size: 24,
                              color: AppTheme.primaryColor,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Vendor Name + Service Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vendor/Title
                        Text(
                          service.vendorName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Service Type
                        Text(
                          service.serviceType,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Price (Right side)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (service.pricePerDay != null)
                        Text(
                          '₹${service.pricePerDay?.toStringAsFixed(0)}/day',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      if (service.pricePerHour != null && service.pricePerDay == null)
                        Text(
                          '₹${service.pricePerHour?.toStringAsFixed(0)}/hr',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider
            Divider(height: 1, color: Colors.grey.shade200),

            // Bottom section with rating, location, and view button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Rating
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${service.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${service.reviews})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Location
                  Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      service.location,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Online Indicator
                  if (service.isOnline)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(width: 8),

                  // View Button
                  GestureDetector(
                    onTap: () => _showServiceDetailSheet(context, service),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'View',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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

  // Show Service Detail in Bottom Sheet
  void _showServiceDetailSheet(BuildContext context, Service service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildServiceDetailSheet(context, service),
    );
  }

  // Service Detail Sheet - Half Page
  Widget _buildServiceDetailSheet(BuildContext context, Service service) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Service Image/Icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.1),
                        AppTheme.primaryColor.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Center(
                    child: service.emoji != null
                        ? Text(service.emoji!, style: const TextStyle(fontSize: 56))
                        : Icon(
                            Icons.category,
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.vendorName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.serviceType,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Rating Bar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rating',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star,
                                            size: 14, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${service.rating}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${service.reviews} reviews',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Location
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    service.location,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    if (service.description.isNotEmpty) ...[
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.description,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Pricing
                    const Text(
                      'Pricing',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (service.pricePerDay != null) ...[
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Per Day',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${service.pricePerDay?.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (service.pricePerHour != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Per Hour',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${service.pricePerHour?.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Book Now Button - Sticky at bottom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to booking page
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Booking ${service.serviceType} from ${service.vendorName}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
