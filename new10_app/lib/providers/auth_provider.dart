import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isUser = true; // true for User, false for Vendor
  String _userEmail = '';
  String _userName = '';
  String _userRole = 'user';
  String _vendorId = ''; // Vendor ID for vendor users
  String _userId = ''; // User ID for regular users
  String? _errorMessage;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isUser => _isUser;
  String get userEmail => _userEmail;
  String get userName => _userName;
  String get userRole => _userRole;
  String get vendorId => _vendorId;
  String get userId => _userId;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  /// Initialize auth state from stored token
  Future<void> initializeAuth() async {
    try {
      final isLoggedIn = await AuthApiService.isLoggedIn();
      if (isLoggedIn) {
        final prefs = await SharedPreferences.getInstance();
        _userEmail = prefs.getString('user_email') ?? '';
        _userName = prefs.getString('user_name') ?? '';
        _userRole = prefs.getString('user_role') ?? 'user';
        _userId = prefs.getString('user_id') ?? '';
        _vendorId = prefs.getString('vendor_id') ?? '';
        _isUser = _userRole == 'user';
        _isAuthenticated = true;
        print('✅ Auth initialized: $_userEmail (${_isUser ? 'User' : 'Vendor'})');
        if (!_isUser) {
          print('   Vendor ID: $_vendorId');
        } else {
          print('   User ID: $_userId');
        }
      }
    } catch (e) {
      print('🔴 Auth initialization error: $e');
    }
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool isUser,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await AuthApiService.login(
        email: email,
        password: password,
      );

      if (result['success']) {
        final user = result['data']['user'];
        _userEmail = user['email'];
        _userName = user['name'];
        _userRole = user['role'];
        _isUser = user['role'] == 'user';
        _isAuthenticated = true;
        _errorMessage = null;

        // Store IDs in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', _userEmail);
        await prefs.setString('user_name', _userName);
        await prefs.setString('user_role', _userRole);

        if (!_isUser) {
          // Vendor login - extract vendor ID from vendor object
          _vendorId = result['data']['vendor']?['id'] ?? '';
          await prefs.setString('vendor_id', _vendorId);
          print('✅ Vendor login successful, ID: $_vendorId');
        } else {
          // Regular user login - extract user ID
          _userId = user['id'] ?? '';
          await prefs.setString('user_id', _userId);
          print('✅ User login successful, ID: $_userId');
        }
        return true;
      } else {
        _errorMessage = result['error'];
        _isAuthenticated = false;
        print('🔴 Login failed: $errorMessage');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login error: $e';
      _isAuthenticated = false;
      print('🔴 Exception: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required bool isUser,
    String? phone,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await AuthApiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone ?? '',
        role: isUser ? 'user' : 'vendor',
      );

      if (result['success']) {
        final user = result['data']['user'];
        _userName = user['name'];
        _userEmail = user['email'];
        _userRole = user['role'];
        _isUser = user['role'] == 'user';
        _isAuthenticated = true;
        _errorMessage = null;

        // Store IDs in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', _userEmail);
        await prefs.setString('user_name', _userName);
        await prefs.setString('user_role', _userRole);

        if (!_isUser) {
          // Vendor login - extract vendor ID from vendor object
          _vendorId = result['data']['vendor']?['id'] ?? '';
          await prefs.setString('vendor_id', _vendorId);
          print('✅ Vendor registration successful, ID: $_vendorId');
        } else {
          // Regular user registration - extract user ID
          _userId = user['id'] ?? '';
          await prefs.setString('user_id', _userId);
          print('✅ User registration successful, ID: $_userId');
        }
        return true;
      } else {
        _errorMessage = result['error'];
        _isAuthenticated = false;
        print('🔴 Registration failed: $errorMessage');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Registration error: $e';
      _isAuthenticated = false;
      print('🔴 Exception: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await AuthApiService.logout();
      _isAuthenticated = false;
      _userEmail = '';
      _userName = '';
      _userRole = 'user';
      _vendorId = '';
      _userId = '';
      _isUser = true;
      _errorMessage = null;
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_role');
      await prefs.remove('vendor_id');
      await prefs.remove('user_id');
      
      print('✅ Logged out');
    } catch (e) {
      print('🔴 Logout error: $e');
    }
    notifyListeners();
  }

  void toggleUserType(bool value) {
    _isUser = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
