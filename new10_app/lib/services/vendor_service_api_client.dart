import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/vendor_service_model.dart';
import '../models/service_model.dart';

class VendorServiceApiClient {
  static const String baseUrl = 'https://new10-yk1r.onrender.com/api';

  // ===================================================
  // VENDOR'S OWN SERVICES MANAGEMENT
  // ===================================================

  /// Fetch all services added by a vendor
  /// GET /api/vendor/:vendorId/services
  static Future<List<VendorService>> getVendorServices(String vendorId) async {
    try {
      final url = '$baseUrl/vendor/$vendorId/services';
      print('🔵 Fetching vendor services from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      print('🟢 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> servicesData = jsonData['data'] ?? [];

        final services = servicesData
            .map((item) => VendorService.fromJson(item))
            .toList();

        print('🟢 Loaded ${services.length} vendor services');
        return services;
      } else {
        print('🔴 Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to load vendor services: ${response.statusCode}');
      }
    } catch (e) {
      print('🔴 Exception fetching vendor services: $e');
      return [];
    }
  }

  /// Add a new service to vendor's listings
  /// POST /api/vendor/:vendorId/services
  static Future<VendorService?> addVendorService({
    required String vendorId,
    required String serviceId,
    required double pricing,
    required String pricingUnit,
    required String location,
    required String availability,
    String? startTime,
    String? endTime,
  }) async {
    try {
      final url = '$baseUrl/vendor/$vendorId/services';
      print('🔵 Adding vendor service to: $url');

      final payload = {
        'service_id': serviceId,
        'pricing': pricing,
        'pricing_unit': pricingUnit,
        'location': location,
        'availability': availability,
        'start_time': startTime ?? '08:00',
        'end_time': endTime ?? '18:00',
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 30));

      print('🟢 Response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final service = VendorService.fromJson(jsonData['data']);
        print('🟢 Service added successfully');
        return service;
      } else {
        print('🔴 Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to add service: ${response.statusCode}');
      }
    } catch (e) {
      print('🔴 Exception adding vendor service: $e');
      return null;
    }
  }

  /// Update vendor service details
  /// PUT /api/vendor/services/:vendorServiceId
  static Future<VendorService?> updateVendorService({
    required String vendorServiceId,
    double? pricing,
    String? location,
    String? availability,
    String? startTime,
    String? endTime,
    bool? isOnline,
  }) async {
    try {
      final url = '$baseUrl/vendor/services/$vendorServiceId';
      print('🔵 Updating vendor service: $url');

      final payload = <String, dynamic>{};
      if (pricing != null) payload['pricing'] = pricing;
      if (location != null) payload['location'] = location;
      if (availability != null) payload['availability'] = availability;
      if (startTime != null) payload['start_time'] = startTime;
      if (endTime != null) payload['end_time'] = endTime;
      if (isOnline != null) payload['is_online'] = isOnline;

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 30));

      print('🟢 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final service = VendorService.fromJson(jsonData['data']);
        print('🟢 Service updated successfully');
        return service;
      } else {
        print('🔴 Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to update service: ${response.statusCode}');
      }
    } catch (e) {
      print('🔴 Exception updating vendor service: $e');
      return null;
    }
  }

  /// Remove service from vendor's listings
  /// DELETE /api/vendor/services/:vendorServiceId
  static Future<bool> deleteVendorService(String vendorServiceId) async {
    try {
      final url = '$baseUrl/vendor/services/$vendorServiceId';
      print('🔵 Deleting vendor service: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      print('🟢 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('🟢 Service deleted successfully');
        return true;
      } else {
        print('🔴 Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to delete service: ${response.statusCode}');
      }
    } catch (e) {
      print('🔴 Exception deleting vendor service: $e');
      return false;
    }
  }

  // ===================================================
  // USER DISCOVERY - Browse Vendors for Each Service
  // ===================================================

  /// Get all vendors offering a specific service
  /// GET /api/services/:serviceId/vendors?location=optional&online_only=optional
  static Future<List<dynamic>> getVendorsForService(
    String serviceId, {
    String? location,
    bool? onlineOnly,
  }) async {
    try {
      var url = '$baseUrl/services/$serviceId/vendors';

      // Build query parameters
      final params = <String, String>{};
      if (location != null && location.isNotEmpty) params['location'] = location;
      if (onlineOnly == true) params['online_only'] = 'true';

      if (params.isNotEmpty) {
        url += '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
      }

      print('🔵 Fetching vendors for service: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      print('🟢 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> vendorData = jsonData['data'] ?? [];
        print('🟢 Found ${vendorData.length} vendors');
        return vendorData;
      } else {
        print('🔴 Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('🔴 Exception fetching vendors: $e');
      return [];
    }
  }

  /// Get vendors by service name
  /// GET /api/vendors-by-service/:serviceName?location=optional
  static Future<List<dynamic>> getVendorsByServiceName(
    String serviceName, {
    String? location,
  }) async {
    try {
      var url = '$baseUrl/vendors-by-service/$serviceName';

      if (location != null && location.isNotEmpty) {
        url += '?location=$location';
      }

      print('🔵 Fetching vendors by service name: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      print('🟢 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> vendorData = jsonData['data'] ?? [];
        print('🟢 Found ${vendorData.length} vendors for $serviceName');
        return vendorData;
      } else {
        print('🔴 Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('🔴 Exception fetching vendors by name: $e');
      return [];
    }
  }

  /// Get all available services with vendor count
  /// GET /api/services
  static Future<List<Service>> getAllServices() async {
    try {
      final url = '$baseUrl/services';
      print('🔵 Fetching all services: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      print('🟢 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> servicesData = jsonData['data'] ?? [];

        final services =
            servicesData.map((item) => Service.fromJson(item)).toList();
        print('🟢 Loaded ${services.length} services');
        return services;
      } else {
        print('🔴 Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('🔴 Exception fetching services: $e');
      return [];
    }
  }

  // ===================================================
  // HELPER METHODS
  // ===================================================

  /// Get list of available locations (Karnataka districts)
  static List<String> getKarnatakaCities() {
    return [
      'Bangalore',
      'Belgaum',
      'Bellary',
      'Bidar',
      'Bijapur',
      'Chamrajnagar',
      'Chikballapur',
      'Chikmagalur',
      'Chitradurga',
      'Davanagere',
      'Dharwad',
      'Gadag',
      'Gulbarga',
      'Hassan',
      'Haveri',
      'Kolar',
      'Kodagu',
      'Kolar Gold Fields',
      'Mandya',
      'Mangalore',
      'Mysore',
      'Raichur',
      'Shimoga',
      'Tumkur',
      'Udupi',
    ];
  }
}
