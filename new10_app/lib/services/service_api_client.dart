import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/service_model.dart';

class ServiceApiClient {
  static const String baseUrl = 'https://new10-yk1r.onrender.com/api';

  /// Fetch all services from the backend
  static Future<List<Service>> getServices() async {
    try {
      final url = '$baseUrl/services';
      print('🔵 Fetching services from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('🟢 Response status: ${response.statusCode}');
      print('🟢 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('🟢 Parsed ${jsonData.length} services');
        return jsonData.map((item) => Service.fromJson(item)).toList();
      } else {
        print('🔴 Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      print('🔴 Exception fetching services: $e');
      return [];
    }
  }

  /// Fetch a single service by ID
  static Future<Service?> getService(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Service.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching service: $e');
      return null;
    }
  }

  /// Fetch app settings (banner image URL, etc.)
  static Future<Map<String, dynamic>> getAppSettings() async {
    try {
      final url = '$baseUrl/settings';
      print('🔵 Fetching app settings from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('🟢 Settings response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('🟢 App settings loaded successfully');
        return jsonData;
      } else {
        print('🔴 Error fetching settings: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('🔴 Exception fetching app settings: $e');
      return {};
    }
  }
}
