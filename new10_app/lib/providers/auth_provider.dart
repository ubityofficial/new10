import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isUser = true; // true for User, false for Vendor
  String _userEmail = '';
  String _userName = '';

  bool get isAuthenticated => _isAuthenticated;
  bool get isUser => _isUser;
  String get userEmail => _userEmail;
  String get userName => _userName;

  Future<bool> login({
    required String email,
    required String password,
    required bool isUser,
  }) async {
    try {
      // TODO: Implement actual API call
      // For now, simulate login
      await Future.delayed(const Duration(seconds: 1));

      _userEmail = email;
      _userName = email.split('@')[0];
      _isUser = isUser;
      _isAuthenticated = true;

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required bool isUser,
  }) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      _userName = name;
      _userEmail = email;
      _isUser = isUser;
      _isAuthenticated = true;

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userEmail = '';
    _userName = '';
    notifyListeners();
  }

  void toggleUserType(bool value) {
    _isUser = value;
    notifyListeners();
  }
}
