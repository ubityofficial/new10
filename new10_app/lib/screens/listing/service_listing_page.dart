import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ServiceListingPage extends StatefulWidget {
  final String serviceName;
  final String? image;

  const ServiceListingPage({
    required this.serviceName,
    this.image,
    super.key,
  });

  @override
  State<ServiceListingPage> createState() => _ServiceListingPageState();
}

class _ServiceListingPageState extends State<ServiceListingPage> {
  // Dummy vendor data
  final List<Map<String, dynamic>> dummyVendors = [
    {
      'name': 'Prime Equipment Rentals',
      'rating': 4.8,
      'reviews': 324,
      'price': '₹5,000/day',
      'location': '5.2 km away',
      'image': 'https://via.placeholder.com/300x200?text=Vendor+1',
    },
    {
      'name': 'Heavy Machinery Co.',
      'rating': 4.6,
      'reviews': 215,
      'price': '₹4,500/day',
      'location': '8.7 km away',
      'image': 'https://via.placeholder.com/300x200?text=Vendor+2',
    },
    {
      'name': 'Elite Construction Services',
      'rating': 4.9,
      'reviews': 456,
      'price': '₹6,000/day',
      'location': '3.1 km away',
      'image': 'https://via.placeholder.com/300x200?text=Vendor+3',
    },
    {
      'name': 'Quick Rent Equipment',
      'rating': 4.5,
      'reviews': 189,
      'price': '₹4,200/day',
      'location': '12.4 km away',
      'image': 'https://via.placeholder.com/300x200?text=Vendor+4',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: Text(
          widget.serviceName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.filter_list,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: dummyVendors.length,
        itemBuilder: (context, index) {
          final vendor = dummyVendors[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                // Navigate to vendor details
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vendor Image (SIMPLE ANIMATED GRADIENT)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getColorByIndex(index).shade300,
                              _getColorByIndex(index).shade600,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getIconByIndex(index),
                                size: 40,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                vendor['name'].split(' ').first,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Vendor Info (COMPACT & PROFESSIONAL)
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  vendor['name'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Online Indicator (Green dot)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green.shade500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${vendor['rating']}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                ' (${vendor['reviews']})',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.location_on,
                                size: 10,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                vendor['location'],
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                vendor['price'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'View',
                                  style: TextStyle(
                                    fontSize: 10,
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to get color by vendor index
  MaterialColor _getColorByIndex(int index) {
    final colors = [Colors.blue, Colors.orange, Colors.purple, Colors.teal];
    return colors[index % colors.length];
  }

  // Helper method to get icon by vendor index
  IconData _getIconByIndex(int index) {
    final icons = [
      Icons.construction,
      Icons.precision_manufacturing,
      Icons.build,
      Icons.engineering,
    ];
    return icons[index % icons.length];
  }
}
