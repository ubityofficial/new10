import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/service_api_client.dart';
import '../../services/image_cache_service.dart';
import '../../services/cache_service.dart';
import '../../models/service_model.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../widgets/cached_image.dart';
import '../listing/service_listing_page.dart';
import 'all_services_page.dart';

class RapidoHomeScreen extends StatefulWidget {
  const RapidoHomeScreen({super.key});

  @override
  State<RapidoHomeScreen> createState() => _RapidoHomeScreenState();
}

class _RapidoHomeScreenState extends State<RapidoHomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  bool _showPromoCard = true;
  
  // API State
  List<Service> _apiServices = [];
  bool _isLoadingServices = false;
  bool _isRefreshingServices = false; // For background refresh (non-blocking)
  String? _servicesError;

  // Banner Settings
  String _bannerImageUrl = 'https://images.unsplash.com/photo-1581092163562-40f08642c5bc?w=500&h=350&fit=crop&q=80';
  bool _isLoadingBannerSettings = false;
  bool _isRefreshingBanner = false;

  // Offer/Promotion Data
  String? _offerCode;
  int? _discountPercent;
  String? _offerDescription;
  bool _isLoadingOffer = false;
  bool _isRefreshingOffer = false;

  // Sponsored Services Data
  List<Map<String, dynamic>> _sponsoredServices = [];
  bool _isLoadingSponsored = false;
  bool _isRefreshingSponsored = false;

  // Mock data
  final List<Map<String, dynamic>> categories = [
    {'name': 'Excavators', 'id': 1},
    {'name': 'Cranes', 'id': 2},
    {'name': 'Water Tankers', 'id': 3},
    {'name': 'Bulldozers', 'id': 4},
    {'name': 'Road Rollers', 'id': 5},
  ];

  final List<Map<String, dynamic>> popularServices = [
    {
      'title': 'Excavator CAT 320',
      'tag': 'Most booked',
      'rating': 4.8,
      'price': '₹5000/day',
    },
    {
      'title': 'Crane Service',
      'tag': 'Premium',
      'rating': 4.9,
      'price': '₹8000/day',
    },
    {
      'title': 'Water Tanker 5000L',
      'tag': 'Popular',
      'rating': 4.7,
      'price': '₹1200/day',
    },
    {
      'title': 'Road Roller',
      'tag': '',
      'rating': 4.6,
      'price': '₹3500/day',
    },
  ];

  final List<Map<String, dynamic>> quickServices = [
    {'title': 'JCB 3CX', 'description': 'Backhoe Loader'},
    {'title': 'Crane 25T', 'description': 'Tower Crane'},
    {'title': 'Compressor', 'description': '100 CFM'},
  ];

  @override
  void initState() {
    super.initState();
    // Load cached data immediately for instant UI
    _loadCachedData();
    // Fetch fresh data in background (non-blocking)
    _fetchFreshDataInBackground();
  }

  // Load cached data instantly (no waiting)
  Future<void> _loadCachedData() async {
    print('📦 Loading cached data...');
   
    // Load services from cache
    final cachedServices = await CacheService.getCachedServices();
    if (cachedServices != null && cachedServices.isNotEmpty) {
      final services = cachedServices
          .map((s) => Service.fromJson(s as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _apiServices = services;
          print('✅ Loaded ${_apiServices.length} services from cache');
        });
      }
    }

    // Load banner from cache
    final cachedBanner = await CacheService.getCachedBanner();
    if (cachedBanner != null && cachedBanner['bannerImageUrl'] != null) {
      if (mounted) {
        setState(() {
          _bannerImageUrl = cachedBanner['bannerImageUrl'];
          print('✅ Loaded banner from cache');
        });
      }
    }

    // Load promotions from cache
    final cachedPromos = await CacheService.getCachedPromotions();
    if (cachedPromos != null) {
      if (mounted) {
        setState(() {
          _offerCode = cachedPromos['code'];
          _discountPercent = cachedPromos['discountPercent'];
          _offerDescription = cachedPromos['description'];
          print('✅ Loaded promotions from cache: $_offerCode');
        });
      }
    }
  }

  // Fetch fresh data in background (non-blocking)
  Future<void> _fetchFreshDataInBackground() async {
    print('🔄 Fetching fresh data in background...');
    
    // Start all 4 fetches in parallel
    await Future.wait([
      _loadServicesFresh(),
      _loadBannerFresh(),
      _loadPromotionsFresh(),
      _loadSponsoredServicesFresh(),
    ], eagerError: false);
    
    print('✅ Background data fetch complete');
  }

  // Fetch fresh services (updates UI if data changed)
  Future<void> _loadServicesFresh() async {
    if (!mounted) return;
    try {
      // Only show loading if we don't have cached data
      if (_apiServices.isEmpty) {
        setState(() => _isLoadingServices = true);
      } else {
        setState(() => _isRefreshingServices = true);
      }

      final services = await ServiceApiClient.getServices();
      if (!mounted) return;

      setState(() {
        _apiServices = services;
        _isLoadingServices = false;
        _isRefreshingServices = false;
      });

      // Cache the freshl loaded data
      await CacheService.setCachedServices(
        services.map((s) => s.toJson()).toList() as List<dynamic>,
      );

      print('✅ Fresh services loaded and cached: ${services.length}');
      _preloadServiceImages(services);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _servicesError = 'Failed to load services: $e';
        _isLoadingServices = false;
        _isRefreshingServices = false;
      });
      print('❌ Error loading fresh services: $e');
    }
  }

  // Fetch fresh banner (updates UI if data changed)
  Future<void> _loadBannerFresh() async {
    if (!mounted) return;
    try {
      if (_bannerImageUrl.isEmpty) {
        setState(() => _isLoadingBannerSettings = true);
      } else {
        setState(() => _isRefreshingBanner = true);
      }

      final response = await ServiceApiClient.getAppSettings();
      if (!mounted) return;

      setState(() {
        final newUrl = response['bannerImageUrl'] as String?;
        if (newUrl != null && newUrl.isNotEmpty) {
          _bannerImageUrl = newUrl;
        }
        _isLoadingBannerSettings = false;
        _isRefreshingBanner = false;
      });

      // Cache banner
      await CacheService.setCachedBanner(response);
      print('✅ Fresh banner loaded and cached');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingBannerSettings = false;
        _isRefreshingBanner = false;
      });
      print('⚠️ Error loading fresh banner: $e');
    }
  }

  // Fetch fresh promotions (updates UI if data changed)
  Future<void> _loadPromotionsFresh() async {
    if (!mounted) return;
    try {
      if (_offerCode == null) {
        setState(() => _isLoadingOffer = true);
      } else {
        setState(() => _isRefreshingOffer = true);
      }

      final response = await http
          .get(
            Uri.parse('https://new10-yk1r.onrender.com/api/promotions'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        setState(() {
          _offerCode = data['offer']?['code'];
          _discountPercent = data['offer']?['discountPercent'];
          _offerDescription = data['offer']?['description'];
          _isLoadingOffer = false;
          _isRefreshingOffer = false;
        });

        // Cache promotions
        await CacheService.setCachedPromotions({
          'code': _offerCode,
          'discountPercent': _discountPercent,
          'description': _offerDescription,
        });
        
        print('✅ Fresh promotions loaded and cached: $_offerCode');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingOffer = false;
          _isRefreshingOffer = false;
        });
      }
      print('⚠️ Error loading fresh promotions: $e');
    }
  }

  // Fetch sponsored vendor services
  Future<void> _loadSponsoredServicesFresh() async {
    if (!mounted) return;
    try {
      setState(() => _isLoadingSponsored = true);

      final response = await http
          .get(
            Uri.parse('https://new10-yk1r.onrender.com/api/sponsored-services'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        final List<dynamic> sponsoredList = data is List ? data : [];
        
        setState(() {
          _sponsoredServices = sponsoredList
              .map((item) => {
                    'title': item['serviceName'] ?? 'Sponsored Service',
                    'tag': 'Sponsored',
                    'rating': 4.5, // Default rating
                    'price': '₹${item['pricing'] ?? 'N/A'}/day',
                    'businessName': item['businessName'] ?? 'Vendor',
                    'isSponsored': true,
                    'vendorId': item['vendorId'],
                  })
              .cast<Map<String, dynamic>>()
              .toList();
          _isLoadingSponsored = false;
        });
        
        print('✅ Loaded ${_sponsoredServices.length} sponsored services');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSponsored = false);
      }
      print('⚠️ Error loading sponsored services: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedTabIndex,
            children: [
              _buildExploreContent(),
              _buildSearchContent(),
              _buildBookingsContent(),
              _buildProfileContent(),
            ],
          ),
          // Bottom Navigation with safe area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _buildBottomNavigation(),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EXPLORE TAB ====================
  Widget _buildExploreContent() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.primaryColor,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildSearchBar(),
              ),
              const SizedBox(height: 16),

              // "Everything in minutes" Grid Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Everything in minutes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEverythingGrid(),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Promo Banner
              if (_showPromoCard)
                _isLoadingOffer && _offerCode == null
                    ? const SkeletonPromoCard()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildPromoBanner(),
                      ),
              if (_showPromoCard) const SizedBox(height: 28),

              // "Go Places with Rapido" Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Book Your Equipments now',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to all services page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllServicesPage(),
                              ),
                            );
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _apiServices.isEmpty && _isLoadingServices
                        ? SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              itemCount: 4,
                              itemBuilder: (context, index) =>
                                  const SkeletonServiceCard(),
                            ),
                          )
                        : _buildCategoryScroll(),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Popular Services
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popular Equipment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPopularServices(),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Extra padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _preloadServiceImages(List<Service> services) async {
    // Preload ALL service images in parallel for faster display
    final futures = <Future>[];
    
    for (var service in services) {
      if (service.image1 != null && service.image1!.isNotEmpty) {
        futures.add(
          precacheImage(
            NetworkImage(service.image1!),
            context,
          ).catchError((e) => print('Image preload failed: $e')),
        );
      }
    }
    
    // Wait for all images to preload in parallel
    try {
      await Future.wait(futures, eagerError: false);
      print('✅ All ${futures.length} service images preloaded successfully');
    } catch (e) {
      print('Preload error: $e');
    }
  }

  // Handle refresh - reload all data from server
  Future<void> _handleRefresh() async {
    print('🔄 Refreshing home screen data...');
    await _fetchFreshDataInBackground();
    print('✅ Home screen data refreshed');
  }

  // Search Bar Widget - Location Search for Home Screen
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        // Navigate to location search screen
        Navigator.pushNamed(context, '/search-location');
      },
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.grey.shade600,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Enter pickup location',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // "Everything in minutes" Grid Section
  Widget _buildEverythingGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Large card (left) - 60% - CLEAN & NEAT
        Expanded(
          flex: 6,
          child: GestureDetector(
            onTap: () {
              // Navigate to explore equipment
            },
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade700, // Fallback color while loading
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background Image with caching & shimmer loading
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedImage(
                      imageUrl: _bannerImageUrl,
                      width: double.infinity,
                      height: 160,
                      borderRadius: BorderRadius.circular(20),
                      backgroundColor: Colors.grey.shade700,
                    ),
                  ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Light overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.25),
                        ],
                      ),
                    ),
                  ),

                  // Content - MINIMAL
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Only - Single Line
                        const Text(
                          'Heavy Equipment On Demand',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        // Explore Button - Very Small
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to All Services
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllServicesPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 4,
                            minimumSize: const Size(0, 0),
                          ),
                          child: const Text(
                            'Explore',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Small cards (right) - 40%
        Expanded(
          flex: 4,
          child: _apiServices.isEmpty && _isLoadingServices
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    3,
                    (index) => const SkeletonListTile(),
                  ),
                )
              : _servicesError != null
                  ? Center(
                      child: Text(
                        _servicesError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    )
                  : _apiServices.isEmpty
                      ? const Center(child: Text('No services available'))
                      : Column(
                          children: _apiServices.take(3).map((service) {
                            return Column(
                              children: [
                                _buildQuickServiceCardWithImage(service),
                                if (_apiServices.indexOf(service) < 2)
                                  const SizedBox(height: 10),
                              ],
                            );
                          }).toList(),
                        ),
        ),
      ],
    );
  }

  // Quick Service Card
  Widget _buildQuickServiceCard(String title, IconData icon, {Service? service}) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  if (service != null && service.category.isNotEmpty)
                    Text(
                      service.category,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 10,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // Quick Service Card with Image - For top 3 services (VERY SMALL)
  Widget _buildQuickServiceCardWithImage(Service service) {
    return GestureDetector(
      onTap: () {
        // Navigate to listing page
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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            // Very Small Image (like services cards)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Container(
                height: 60,
                width: 60,
                color: Colors.grey.shade200,
                child: service.image1 != null && service.image1!.isNotEmpty
                    ? Image.network(
                        service.image1!,
                        fit: BoxFit.cover,
                        cacheHeight: 140,
                        cacheWidth: 140,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                          );
                        },
                      )
                    : Icon(
                        Icons.category,
                        size: 24,
                        color: Colors.grey.shade600,
                      ),
              ),
            ),
            // Title Only - No description
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Promo Banner
  Widget _buildPromoBanner() {
    final discount = _discountPercent ?? 15;
    final code = _offerCode ?? 'RAPIDO15';
    
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get $discount% off',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _offerDescription ?? 'Your first booking',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        // Copy code to clipboard
                        Clipboard.setData(ClipboardData(text: code)).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ Copied: $code'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.green.shade600,
                            ),
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Code: $code',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.content_copy,
                              size: 9,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Icon(
                    Icons.card_giftcard,
                    size: 26,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => setState(() => _showPromoCard = false),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Category Scroll
  Widget _buildCategoryScroll() {
    // Display services in 2 horizontal scrollable rows
    if (_apiServices.isEmpty) {
      return SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          itemCount: 4,
          itemBuilder: (context, index) => const SkeletonServiceCard(),
        ),
      );
    }

    if (_servicesError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error loading services',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade600),
          ),
        ),
      );
    }

    if (_apiServices.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('No services available'),
        ),
      );
    }

    // Split services into 2 rows
    int itemsPerRow = (_apiServices.length / 2).ceil();
    List<Service> row1 = _apiServices.take(itemsPerRow).toList();
    List<Service> row2 = _apiServices.skip(itemsPerRow).toList();

    return Column(
      children: [
        // Row 1
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(row1.length, (index) {
              final service = row1[index];
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 12 : 6,
                  right: index == row1.length - 1 ? 12 : 6,
                ),
                child: _buildServiceCard(service),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),
        // Row 2
        if (row2.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(row2.length, (index) {
                final service = row2[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 12 : 6,
                    right: index == row2.length - 1 ? 12 : 6,
                  ),
                  child: _buildServiceCard(service),
                );
              }),
            ),
          ),
      ],
    );
  }

  // Helper widget to build service card
  Widget _buildServiceCard(Service service) {
    return GestureDetector(
      onTap: () {
        // Navigate to listing page
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
      child: Column(
        children: [
          // Service Icon/Image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                ),
              ],
            ),
            child: service.image1 != null && service.image1!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedImage(
                      imageUrl: service.image1!,
                      width: 56,
                      height: 56,
                      borderRadius: BorderRadius.circular(12),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  )
                : Container(
                    color: Colors.grey.shade300,
                    child: Icon(
                      Icons.category,
                      size: 26,
                      color: Colors.grey.shade600,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          // Service Title Only
          SizedBox(
            width: 56,
            child: Text(
              service.name,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Popular Services (includes sponsored vendors)
  Widget _buildPopularServices() {
    final serviceIcons = {
      'Excavator CAT 320': Icons.construction,
      'Crane Service': Icons.apartment,
      'Water Tanker 5000L': Icons.water,
      'Road Roller': Icons.engineering,
    };

    // Merge sponsored services (first) with popular services
    final List<Map<String, dynamic>> allServices = [
      ..._sponsoredServices,
      ...popularServices,
    ];

    return Column(
      children: List.generate(
        allServices.length,
        (index) {
          final service = allServices[index];
          final icon = serviceIcons[service['title']] ?? Icons.category;
          final isSponsored = service['isSponsored'] ?? false;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                // Navigate to service details or listing
                if (isSponsored && service['vendorId'] != null) {
                  // Navigate to vendor profile or service listing
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Sponsored service from ${service['businessName']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.blue.shade600,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isSponsored 
                      ? Colors.blue.shade50 // Slightly blue tint for sponsored
                      : Colors.grey.shade50,
                  border: Border.all(
                    color: isSponsored 
                        ? Colors.blue.shade200
                        : Colors.grey.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Image/Icon Container
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isSponsored
                              ? [
                                  Colors.blue.shade300.withOpacity(0.15),
                                  Colors.blue.shade300.withOpacity(0.05),
                                ]
                              : [
                                  AppTheme.primaryColor.withOpacity(0.15),
                                  AppTheme.primaryColor.withOpacity(0.05),
                                ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: 28,
                          color: isSponsored
                              ? Colors.blue.shade600
                              : AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  service['title'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isSponsored
                                      ? Colors.blue.shade600
                                      : AppTheme.primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  service['tag'] ?? '',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSponsored
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${service['rating']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              if (isSponsored && service['businessName'] != null) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    service['businessName'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ] else
                                const Spacer(),
                              Text(
                                service['price'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSponsored
                                      ? Colors.blue.shade600
                                      : AppTheme.primaryDark,
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

  // ==================== SEARCH TAB ====================
  Widget _buildSearchContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildServiceSearchBar(),
            ),
            const SizedBox(height: 24),

            // Popular Searches Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Popular Searches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSearchChip('Excavators'),
                      _buildSearchChip('Cranes'),
                      _buildSearchChip('Water Tankers'),
                      _buildSearchChip('Bulldozers'),
                      _buildSearchChip('Road Rollers'),
                      _buildSearchChip('Compressors'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Bottom padding for nav bar
          ],
        ),
      ),
    );
  }

  // Service Search Bar
  Widget _buildServiceSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.grey.shade600,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search services...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search Chip Widget
  Widget _buildSearchChip(String text) {
    return GestureDetector(
      onTap: () {
        // Implement search functionality
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // ==================== BOOKINGS TAB ====================
  Widget _buildBookingsContent() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No bookings yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start booking equipment today',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PROFILE TAB ====================
  Widget _buildProfileContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor,
                          ),
                          child: Center(
                            child: Text(
                              authProvider.userName.isNotEmpty
                                  ? authProvider.userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProvider.userName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authProvider.userEmail,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Menu Items
              Column(
                children: [
                  _buildMenuItemProfile(
                    icon: Icons.location_on,
                    title: 'Addresses',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItemProfile(
                    icon: Icons.payment,
                    title: 'Payment Methods',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItemProfile(
                    icon: Icons.history,
                    title: 'Booking History',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItemProfile(
                    icon: Icons.settings,
                    title: 'Settings',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthProvider>().logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Bottom padding for nav bar
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemProfile({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: color, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  // ==================== MORE TAB ====================
  Widget _buildMoreContent() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apps, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'More options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Additional features coming soon',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== BOTTOM NAVIGATION ====================
  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, 'Explore', Icons.explore),
                  _buildNavItem(1, 'Search', Icons.search),
                  _buildNavItem(2, 'Bookings', Icons.event_note),
                  _buildNavItem(3, 'Settings', Icons.settings),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? AppTheme.primaryColor : Colors.grey.shade600,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppTheme.primaryColor : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
