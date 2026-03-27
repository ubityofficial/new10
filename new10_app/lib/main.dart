import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/home/rapido_home_screen.dart';
import 'screens/home/services_browse_screen.dart';
import 'screens/listing/vendor_listing_page.dart';
import 'screens/address/address_management_screen.dart';
import 'screens/search/location_search_screen.dart';
import 'screens/vendor/vendor_dashboard_screen_new.dart';
import 'screens/equipment/equipment_detail_screen.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/bookings/my_bookings_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/service_provider.dart';
import 'theme/app_theme.dart';
import 'services/image_preload_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set full-screen immersive mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // 🚀 Start aggressive image preloading IMMEDIATELY
  print('⚡ Preloading images BEFORE app launch...');
  ImagePreloadService.preloadAllImages().then((_) {
    print('✅ Image preload task started in background');
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initializeAuth(),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'new10 - Equipment Booking',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            // Show loading while auth is initializing
            if (!authProvider.isAuthenticated) {
              return const LoginScreen();
            }
            // Route to respective dashboard based on user type
            return authProvider.isUser
                ? const RapidoHomeScreen()
                : const VendorDashboardScreenNew();
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/home': (context) => const RapidoHomeScreen(),
          '/addresses': (context) => const AddressManagementScreen(),
          '/search-location': (context) => const LocationSearchScreen(),
          '/services-browse': (context) => const ServicesBrowseScreen(),
          '/vendor': (context) => const VendorDashboardScreenNew(),
          '/profile': (context) => const ProfileScreen(),
          '/my-bookings': (context) => const MyBookingsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/equipment-detail') {
            final equipmentId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => EquipmentDetailScreen(equipmentId: equipmentId),
            );
          }
          if (settings.name == '/booking') {
            final equipmentId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => BookingScreen(equipmentId: equipmentId),
            );
          }
          if (settings.name == '/checkout') {
            final bookingData = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => CheckoutScreen(bookingData: bookingData),
            );
          }
          if (settings.name == '/vendor-listing') {
            final serviceName = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => VendorListingPage(serviceName: serviceName),
            );
          }
          return null;
        },
      ),
    );
  }
}
