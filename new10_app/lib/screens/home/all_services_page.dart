import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/service_api_client.dart';
import '../../services/cache_service.dart';
import '../../models/service_model.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../widgets/cached_image.dart';
import '../listing/service_listing_page.dart';

class AllServicesPage extends StatefulWidget {
  const AllServicesPage({super.key});

  @override
  State<AllServicesPage> createState() => _AllServicesPageState();
}

class _AllServicesPageState extends State<AllServicesPage> {
  List<Service> _services = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServicesWithCache();
  }

  Future<void> _loadServicesWithCache() async {
    // Try to load from cache first
    final cachedServices = await CacheService.getCachedServices();
    if (cachedServices != null && cachedServices.isNotEmpty) {
      final services = cachedServices
          .map((s) => Service.fromJson(s as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _services = services;
          print('✅ Loaded cached services: ${_services.length}');
        });
      }
    }

    // Fetch fresh data in background
    try {
      if (_services.isEmpty) {
        setState(() => _isLoading = true);
      }

      final services = await ServiceApiClient.getServices();
      if (!mounted) return;

      setState(() {
        _services = services;
        _isLoading = false;
        _error = null;
      });

      // Cache the fresh data
      await CacheService.setCachedServices(
        services.map((s) => s.toJson()).toList() as List<dynamic>,
      );
      print('✅ Loaded and cached fresh services: ${services.length}');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error loading services: $e';
        });
      }
      print('❌ Error loading services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: const Text(
          'All Equipment & Services',
          style: TextStyle(
            fontSize: 18,
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
      body: _services.isEmpty && _isLoading
          ? const SkeletonServiceGrid(itemCount: 6)
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading services',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _loadServicesWithCache(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _services.length,
                  itemBuilder: (context, index) => _buildServiceCard(_services[index]),
                ),
    );
  }

  Widget _buildServiceCard(Service service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceListingPage(
              serviceName: service.name,
              image: service.image1,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: CachedImage(
                  imageUrl: service.image1 ?? '',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            ),
            // Title & Description
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description ?? 'Equipment',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
