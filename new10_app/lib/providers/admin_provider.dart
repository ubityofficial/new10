import 'package:flutter/material.dart';
import '../models/admin_model.dart';

class AdminProvider extends ChangeNotifier {
  AdminUser? _currentAdmin;
  List<UserManagement> _users = [];
  List<VendorManagement> _vendors = [];
  List<LoginLog> _loginLogs = [];
  List<AdminActivityLog> _activityLogs = [];
  AdminDashboardStats? _stats;
  bool _isLoading = false;
  String? _error;

  // Getters
  AdminUser? get currentAdmin => _currentAdmin;
  List<UserManagement> get users => _users;
  List<VendorManagement> get vendors => _vendors;
  List<LoginLog> get loginLogs => _loginLogs;
  List<AdminActivityLog> get activityLogs => _activityLogs;
  AdminDashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentAdmin != null;

  // Initialize with mock data
  AdminProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Mock users
    _users = [
      UserManagement(
        id: 'user_001',
        fullName: 'Rajesh Kumar',
        email: 'rajesh@example.com',
        phone: '+91 98765 43210',
        status: 'active',
        createdAt: DateTime(2025, 1, 15),
        lastLogin: DateTime.now().subtract(Duration(hours: 2)),
        totalBookings: 12,
        rating: 4.5,
        isVerified: true,
        isPhoneVerified: true,
      ),
      UserManagement(
        id: 'user_002',
        fullName: 'Priya Sharma',
        email: 'priya@example.com',
        phone: '+91 87654 32109',
        status: 'active',
        createdAt: DateTime(2025, 2, 10),
        lastLogin: DateTime.now().subtract(Duration(days: 1)),
        totalBookings: 8,
        rating: 4.8,
        isVerified: true,
        isPhoneVerified: true,
      ),
      UserManagement(
        id: 'user_003',
        fullName: 'Amit Patel',
        email: 'amit@example.com',
        phone: '+91 76543 21098',
        status: 'suspended',
        createdAt: DateTime(2024, 12, 20),
        lastLogin: DateTime(2026, 3, 10),
        totalBookings: 3,
        rating: 2.1,
        isVerified: false,
        isPhoneVerified: true,
      ),
      UserManagement(
        id: 'user_004',
        fullName: 'Neha Singh',
        email: 'neha@example.com',
        phone: '+91 65432 10987',
        status: 'active',
        createdAt: DateTime(2025, 3, 1),
        lastLogin: DateTime.now(),
        totalBookings: 5,
        rating: 4.2,
        isVerified: true,
        isPhoneVerified: false,
      ),
    ];

    // Mock vendors
    _vendors = [
      VendorManagement(
        id: 'vendor_001',
        businessName: 'Heavy Lift Solutions',
        ownerName: 'Suresh Reddy',
        email: 'suresh@heavylift.com',
        phone: '+91 98765 43210',
        status: 'approved',
        createdAt: DateTime(2024, 6, 15),
        approvedAt: DateTime(2024, 7, 1),
        businessLicense: 'BL/2024/001',
        gstNumber: 'GST123456789',
        bankAccount: 'SB/ACC/001',
        totalEquipment: 45,
        totalBookings: 234,
        rating: 4.8,
        isVerified: true,
        isPhoneVerified: true,
      ),
      VendorManagement(
        id: 'vendor_002',
        businessName: 'Prime Equipments',
        ownerName: 'Vikram Singh',
        email: 'vikram@primeequip.com',
        phone: '+91 87654 32109',
        status: 'approved',
        createdAt: DateTime(2024, 8, 20),
        approvedAt: DateTime(2024, 9, 5),
        businessLicense: 'BL/2024/002',
        gstNumber: 'GST987654321',
        bankAccount: 'SB/ACC/002',
        totalEquipment: 32,
        totalBookings: 189,
        rating: 4.6,
        isVerified: true,
        isPhoneVerified: true,
      ),
      VendorManagement(
        id: 'vendor_003',
        businessName: 'Crane Masters',
        ownerName: 'Arun Verma',
        email: 'arun@cranemasters.com',
        phone: '+91 76543 21098',
        status: 'pending',
        createdAt: DateTime(2026, 2, 1),
        businessLicense: 'BL/2024/003',
        gstNumber: 'GST111222333',
        bankAccount: 'SB/ACC/003',
        totalEquipment: 0,
        totalBookings: 0,
        rating: 0.0,
        isVerified: false,
        isPhoneVerified: true,
      ),
      VendorManagement(
        id: 'vendor_004',
        businessName: 'Construction Plus',
        ownerName: 'Rajdeep Kaur',
        email: 'rajdeep@constructionplus.com',
        phone: '+91 65432 10987',
        status: 'suspended',
        createdAt: DateTime(2025, 1, 10),
        approvedAt: DateTime(2025, 2, 1),
        businessLicense: 'BL/2024/004',
        gstNumber: 'GST444555666',
        bankAccount: 'SB/ACC/004',
        totalEquipment: 28,
        totalBookings: 45,
        rating: 2.3,
        isVerified: true,
        isPhoneVerified: true,
      ),
    ];

    // Mock statistics
    _stats = AdminDashboardStats(
      totalUsers: 1243,
      totalVendors: 156,
      pendingVendorApprovals: 12,
      suspendedUsers: 8,
      suspendedVendors: 3,
      totalBookingsCompleted: 5678,
      totalRevenue: 2890000.0,
      newUsersThisMonth: 145,
      newVendorsThisMonth: 8,
      averageUserRating: 4.3,
      averageVendorRating: 4.5,
    );
  }

  // Admin login
  Future<bool> adminLogin(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mock authentication
      await Future.delayed(Duration(seconds: 1));

      if (email == 'admin@new10.com' && password == 'admin123') {
        _currentAdmin = AdminUser(
          id: 'admin_001',
          email: email,
          password: password,
          role: 'super_admin',
          createdAt: DateTime(2024, 1, 1),
          isActive: true,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Admin logout
  void adminLogout() {
    _currentAdmin = null;
    _error = null;
    notifyListeners();
  }

  // User management
  Future<void> suspendUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = UserManagement(
          id: _users[index].id,
          fullName: _users[index].fullName,
          email: _users[index].email,
          phone: _users[index].phone,
          status: 'suspended',
          createdAt: _users[index].createdAt,
          lastLogin: _users[index].lastLogin,
          totalBookings: _users[index].totalBookings,
          rating: _users[index].rating,
          isVerified: _users[index].isVerified,
          isPhoneVerified: _users[index].isPhoneVerified,
        );
        _logActivity(
          action: 'user_suspended',
          targetId: userId,
          description: 'User suspended by admin',
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to suspend user';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> blockUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = UserManagement(
          id: _users[index].id,
          fullName: _users[index].fullName,
          email: _users[index].email,
          phone: _users[index].phone,
          status: 'blocked',
          createdAt: _users[index].createdAt,
          lastLogin: _users[index].lastLogin,
          totalBookings: _users[index].totalBookings,
          rating: _users[index].rating,
          isVerified: _users[index].isVerified,
          isPhoneVerified: _users[index].isPhoneVerified,
        );
        _logActivity(
          action: 'user_blocked',
          targetId: userId,
          description: 'User blocked by admin',
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to block user';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> activateUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = UserManagement(
          id: _users[index].id,
          fullName: _users[index].fullName,
          email: _users[index].email,
          phone: _users[index].phone,
          status: 'active',
          createdAt: _users[index].createdAt,
          lastLogin: _users[index].lastLogin,
          totalBookings: _users[index].totalBookings,
          rating: _users[index].rating,
          isVerified: _users[index].isVerified,
          isPhoneVerified: _users[index].isPhoneVerified,
        );
        _logActivity(
          action: 'user_activated',
          targetId: userId,
          description: 'User activated by admin',
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to activate user';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Vendor management
  Future<void> approveVendor(String vendorId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      final index = _vendors.indexWhere((v) => v.id == vendorId);
      if (index != -1) {
        _vendors[index] = VendorManagement(
          id: _vendors[index].id,
          businessName: _vendors[index].businessName,
          ownerName: _vendors[index].ownerName,
          email: _vendors[index].email,
          phone: _vendors[index].phone,
          status: 'approved',
          createdAt: _vendors[index].createdAt,
          approvedAt: DateTime.now(),
          businessLicense: _vendors[index].businessLicense,
          gstNumber: _vendors[index].gstNumber,
          bankAccount: _vendors[index].bankAccount,
          totalEquipment: _vendors[index].totalEquipment,
          totalBookings: _vendors[index].totalBookings,
          rating: _vendors[index].rating,
          isVerified: _vendors[index].isVerified,
          isPhoneVerified: _vendors[index].isPhoneVerified,
        );
        _logActivity(
          action: 'vendor_approved',
          targetId: vendorId,
          description: 'Vendor approved by admin',
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to approve vendor';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectVendor(String vendorId, String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      final index = _vendors.indexWhere((v) => v.id == vendorId);
      if (index != -1) {
        _vendors[index] = VendorManagement(
          id: _vendors[index].id,
          businessName: _vendors[index].businessName,
          ownerName: _vendors[index].ownerName,
          email: _vendors[index].email,
          phone: _vendors[index].phone,
          status: 'rejected',
          createdAt: _vendors[index].createdAt,
          businessLicense: _vendors[index].businessLicense,
          gstNumber: _vendors[index].gstNumber,
          bankAccount: _vendors[index].bankAccount,
          totalEquipment: _vendors[index].totalEquipment,
          totalBookings: _vendors[index].totalBookings,
          rating: _vendors[index].rating,
          isVerified: _vendors[index].isVerified,
          isPhoneVerified: _vendors[index].isPhoneVerified,
        );
        _logActivity(
          action: 'vendor_rejected',
          targetId: vendorId,
          description: 'Vendor rejected: $reason',
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to reject vendor';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> suspendVendor(String vendorId, String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      final index = _vendors.indexWhere((v) => v.id == vendorId);
      if (index != -1) {
        _vendors[index] = VendorManagement(
          id: _vendors[index].id,
          businessName: _vendors[index].businessName,
          ownerName: _vendors[index].ownerName,
          email: _vendors[index].email,
          phone: _vendors[index].phone,
          status: 'suspended',
          createdAt: _vendors[index].createdAt,
          approvedAt: _vendors[index].approvedAt,
          businessLicense: _vendors[index].businessLicense,
          gstNumber: _vendors[index].gstNumber,
          bankAccount: _vendors[index].bankAccount,
          totalEquipment: _vendors[index].totalEquipment,
          totalBookings: _vendors[index].totalBookings,
          rating: _vendors[index].rating,
          isVerified: _vendors[index].isVerified,
          isPhoneVerified: _vendors[index].isPhoneVerified,
        );
        _logActivity(
          action: 'vendor_suspended',
          targetId: vendorId,
          description: 'Vendor suspended: $reason',
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to suspend vendor';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> blockVendor(String vendorId, String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      final index = _vendors.indexWhere((v) => v.id == vendorId);
      if (index != -1) {
        _vendors[index] = VendorManagement(
          id: _vendors[index].id,
          businessName: _vendors[index].businessName,
          ownerName: _vendors[index].ownerName,
          email: _vendors[index].email,
          phone: _vendors[index].phone,
          status: 'blocked',
          createdAt: _vendors[index].createdAt,
          approvedAt: _vendors[index].approvedAt,
          businessLicense: _vendors[index].businessLicense,
          gstNumber: _vendors[index].gstNumber,
          bankAccount: _vendors[index].bankAccount,
          totalEquipment: _vendors[index].totalEquipment,
          totalBookings: _vendors[index].totalBookings,
          rating: _vendors[index].rating,
          isVerified: _vendors[index].isVerified,
          isPhoneVerified: _vendors[index].isPhoneVerified,
        );
        _logActivity(
          action: 'vendor_blocked',
          targetId: vendorId,
          description: 'Vendor blocked: $reason',
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to block vendor';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyVendor(String vendorId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      final index = _vendors.indexWhere((v) => v.id == vendorId);
      if (index != -1) {
        _vendors[index] = VendorManagement(
          id: _vendors[index].id,
          businessName: _vendors[index].businessName,
          ownerName: _vendors[index].ownerName,
          email: _vendors[index].email,
          phone: _vendors[index].phone,
          status: _vendors[index].status,
          createdAt: _vendors[index].createdAt,
          approvedAt: _vendors[index].approvedAt,
          businessLicense: _vendors[index].businessLicense,
          gstNumber: _vendors[index].gstNumber,
          bankAccount: _vendors[index].bankAccount,
          totalEquipment: _vendors[index].totalEquipment,
          totalBookings: _vendors[index].totalBookings,
          rating: _vendors[index].rating,
          isVerified: true,
          isPhoneVerified: _vendors[index].isPhoneVerified,
        );
        _logActivity(
          action: 'vendor_verified',
          targetId: vendorId,
          description: 'Vendor verified by admin',
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to verify vendor';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _logActivity({
    required String action,
    required String targetId,
    required String description,
  }) {
    _activityLogs.insert(
      0,
      AdminActivityLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        adminId: _currentAdmin?.id ?? 'admin_001',
        action: action,
        targetId: targetId,
        targetType: action.startsWith('user') ? 'user' : 'vendor',
        timestamp: DateTime.now(),
        description: description,
        changes: {},
      ),
    );
  }

  List<UserManagement> filterUsers(String query) {
    if (query.isEmpty) return _users;
    return _users
        .where((user) =>
            user.fullName.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase()) ||
            user.phone.contains(query))
        .toList();
  }

  List<VendorManagement> filterVendors(String query) {
    if (query.isEmpty) return _vendors;
    return _vendors
        .where((vendor) =>
            vendor.businessName.toLowerCase().contains(query.toLowerCase()) ||
            vendor.ownerName.toLowerCase().contains(query.toLowerCase()) ||
            vendor.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<VendorManagement> getVendorsByStatus(String status) {
    return _vendors.where((v) => v.status == status).toList();
  }

  List<UserManagement> getUsersByStatus(String status) {
    return _users.where((u) => u.status == status).toList();
  }
}
