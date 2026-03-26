import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/service_model.dart';

class ServiceApiClient {
  static const String baseUrl = 'https://new10-yk1r.onrender.com/api';

  /// Fetch all services from the backend
  static Future<List<Service>> getServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => Service.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching services: $e');
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
}
