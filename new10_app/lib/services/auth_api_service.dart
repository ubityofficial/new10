import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApiService {
  static const String baseUrl = 'https://new10-yk1r.onrender.com/api';

  /// Register a new user or vendor
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role, // 'user' or 'vendor'
  }) async {
    try {
      print('🔵 Registering: $email with role: $role');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
          'role': role,
        }),
      ).timeout(const Duration(seconds: 15));

      print('🟢 Register response: ${response.statusCode}');
      print('🟢 Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (data['token'] != null) {
          // Save token to shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);
          await prefs.setString('user_email', data['user']['email']);
          await prefs.setString('user_name', data['user']['name']);
          await prefs.setString('user_role', data['user']['role']);
          print('✅ Token saved: ${data['token'].substring(0, 20)}...');
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      print('🔴 Registration error: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Login with email and password
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 Logging in: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      print('🟢 Login response: ${response.statusCode}');
      print('🟢 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          // Save token to shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);
          await prefs.setString('user_email', data['user']['email']);
          await prefs.setString('user_name', data['user']['name']);
          await prefs.setString('user_role', data['user']['role']);
          print('✅ Login successful. Token saved: ${data['token'].substring(0, 20)}...');
        }
        return {'success': true, 'data': data};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'error': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      print('🔴 Login error: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Get current user (verify token)
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }

      print('🔵 Fetching current user');
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('🟢 Get user response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await prefs.remove('auth_token');
        return {'success': false, 'error': 'Token expired'};
      } else {
        return {'success': false, 'error': 'Failed to fetch user'};
      }
    } catch (e) {
      print('🔴 Get user error: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Logout (clear local token)
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_role');
      print('✅ Logged out successfully');
    } catch (e) {
      print('🔴 Logout error: $e');
    }
  }

  /// Get stored token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get user role from local storage
  static Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_role');
    } catch (e) {
      return null;
    }
  }
}
