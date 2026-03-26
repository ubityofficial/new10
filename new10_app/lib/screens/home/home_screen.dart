import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/premium_equipment_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  TextEditingController searchController = TextEditingController();
  bool _isNavBarVisible = true;

  // Mock equipment data
  final List<Map<String, dynamic>> equipment = [
    {
      'id': '1',
      'name': 'Excavator - CAT 320',
      'category': 'Excavator',
      'price': 5000,
      'rating': 4.8,
      'reviews': 234,
      'image': '🚜',
      'vendor': 'Heavy Lift Solutions',
      'location': '2.5 km away',
      'available': true,
    },
    {
      'id': '2',
      'name': 'JCB 3CX Backhoe',
      'category': 'JCB',
      'price': 3500,
      'rating': 4.6,
      'reviews': 156,
      'image': '🏗️',
      'vendor': 'Prime Equipments',
      'location': '1.8 km away',
      'available': true,
    },
    {
      'id': '3',
      'name': 'Hitachi EX200 Excavator',
      'category': 'Excavator',
      'price': 5500,
      'rating': 4.9,
      'reviews': 312,
      'image': '🚜',
      'vendor': 'Construction Plus',
      'location': '3.2 km away',
      'available': false,
    },
    {
      'id': '4',
      'name': 'Water Tanker 5000L',
      'category': 'Water Tanker',
      'price': 1200,
      'rating': 4.5,
      'reviews': 89,
      'image': '💧',
      'vendor': 'Aqua Services',
      'location': '1.2 km away',
      'available': true,
    },
    {
      'id': '5',
      'name': 'Crane 25 Ton',
      'category': 'Crane',
      'price': 8000,
      'rating': 4.7,
      'reviews': 201,
      'image': '🏗️',
      'vendor': 'Heavy Lift Solutions',
      'location': '4.5 km away',
      'available': true,
    },
    {
      'id': '6',
      'name': 'Compressor - 100 CFM',
      'category': 'Machinery',
      'price': 800,
      'rating': 4.4,
      'reviews': 67,
      'image': '⚙️',
      'vendor': 'Tech Equipments',
      'location': '2.1 km away',
      'available': true,
    },
  ];

  List<Map<String, dynamic>> filteredEquipment = [];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    filteredEquipment = equipment;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterEquipment(String query, String category) {
    setState(() {
      filteredEquipment = equipment.where((item) {
        final matchesQuery = query.isEmpty ||
            item['name'].toLowerCase().contains(query.toLowerCase());
        final matchesCategory = category == 'All' || item['category'] == category;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final authProvider = context.read<AuthProvider>();
            authProvider.logout();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        title: const Text('new10'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.axis == Axis.vertical) {
            if (scrollInfo is ScrollUpdateNotification) {
              if (scrollInfo.scrollDelta! > 0 && _isNavBarVisible) {
                setState(() => _isNavBarVisible = false);
              } else if (scrollInfo.scrollDelta! < 0 && !_isNavBarVisible) {
                setState(() => _isNavBarVisible = true);
              }
            }
          }
          return false;
        },
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeContent(),
            _buildSearchContent(),
            _buildBookingsContent(),
            _buildProfileContent(),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedSlide(
        offset: _isNavBarVisible ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: AppTheme.cardBackground,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryLight,
            unselectedItemColor: Colors.grey[600],
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Bookings'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome
          Text(
            'Welcome!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Text(
                '${authProvider.userName}, find equipment near you',
                style: Theme.of(context).textTheme.bodyMedium,
              );
            },
          ),
          const SizedBox(height: 20),

          // Search Bar
          TextField(
            controller: searchController,
            onChanged: (query) => _filterEquipment(query, selectedCategory),
            decoration: InputDecoration(
              hintText: 'Search equipment...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        _filterEquipment('', selectedCategory);
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Services Browse Banner
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/services-browse');
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Browse Services',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Find professional services from trusted vendors',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Categories
          Text(
            'Categories',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Excavator', 'JCB', 'Crane', 'Water Tanker'].map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (selected) {
                      setState(() => selectedCategory = cat);
                      _filterEquipment(searchController.text, cat);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Featured Equipment
          Text(
            'Featured Equipment',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredEquipment.length,
            itemBuilder: (context, index) {
              final item = filteredEquipment[index];
              return PremiumEquipmentCard(
                id: item['id'],
                name: item['name'],
                category: item['category'],
                vendor: item['vendor'],
                price: item['price'].toDouble(),
                rating: item['rating'],
                reviews: item['reviews'],
                location: item['location'],
                available: item['available'],
                imageEmoji: item['image'],
                onTap: item['available']
                    ? () {
                        Navigator.pushNamed(
                          context,
                          '/equipment-detail',
                          arguments: item['id'],
                        );
                      }
                    : () {},
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContent() {
    return Center(
      child: Text(
        'Search Page',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _buildBookingsContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No bookings yet',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Start by booking equipment',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.userName,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          authProvider.userEmail,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Menu Items
              ...[
                ('Edit Profile', Icons.edit),
                ('My Bookings', Icons.event_note),
                ('Payment Methods', Icons.payment),
                ('Settings', Icons.settings),
                ('Help & Support', Icons.help),
              ].map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(item.$2, color: AppTheme.primaryColor),
                    title: Text(item.$1),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await authProvider.logout();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
