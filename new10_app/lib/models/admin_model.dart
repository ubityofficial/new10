class AdminUser {
  final String id;
  final String email;
  final String password;
  final String role;
  final DateTime createdAt;
  final bool isActive;

  AdminUser({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.createdAt,
    this.isActive = true,
  });
}

class UserManagement {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String status; // active, suspended, blocked, pending_verification
  final DateTime createdAt;
  final DateTime? lastLogin;
  final int totalBookings;
  final double rating;
  final bool isVerified;
  final bool isPhoneVerified;

  UserManagement({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.status,
    required this.createdAt,
    this.lastLogin,
    this.totalBookings = 0,
    this.rating = 0.0,
    this.isVerified = false,
    this.isPhoneVerified = false,
  });
}

class VendorManagement {
  final String id;
  final String businessName;
  final String ownerName;
  final String email;
  final String phone;
  final String status; // pending, approved, suspended, rejected, blocked
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String businessLicense;
  final String gstNumber;
  final String bankAccount;
  final int totalEquipment;
  final int totalBookings;
  final double rating;
  final bool isVerified;
  final bool isPhoneVerified;

  VendorManagement({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    required this.businessLicense,
    required this.gstNumber,
    required this.bankAccount,
    this.totalEquipment = 0,
    this.totalBookings = 0,
    this.rating = 0.0,
    this.isVerified = false,
    this.isPhoneVerified = false,
  });
}

class LoginLog {
  final String id;
  final String userId;
  final String userType; // user or vendor
  final DateTime loginTime;
  final DateTime? logoutTime;
  final String ipAddress;
  final String deviceInfo;
  final String status; // success, failed
  final String? failureReason;

  LoginLog({
    required this.id,
    required this.userId,
    required this.userType,
    required this.loginTime,
    this.logoutTime,
    required this.ipAddress,
    required this.deviceInfo,
    required this.status,
    this.failureReason,
  });
}

class AdminActivityLog {
  final String id;
  final String adminId;
  final String action; // vendor_approved, user_suspended, etc.
  final String targetId;
  final String targetType; // user or vendor
  final DateTime timestamp;
  final String description;
  final Map<String, dynamic> changes;

  AdminActivityLog({
    required this.id,
    required this.adminId,
    required this.action,
    required this.targetId,
    required this.targetType,
    required this.timestamp,
    required this.description,
    required this.changes,
  });
}

class AdminDashboardStats {
  final int totalUsers;
  final int totalVendors;
  final int pendingVendorApprovals;
  final int suspendedUsers;
  final int suspendedVendors;
  final int totalBookingsCompleted;
  final double totalRevenue;
  final int newUsersThisMonth;
  final int newVendorsThisMonth;
  final double averageUserRating;
  final double averageVendorRating;

  AdminDashboardStats({
    required this.totalUsers,
    required this.totalVendors,
    required this.pendingVendorApprovals,
    required this.suspendedUsers,
    required this.suspendedVendors,
    required this.totalBookingsCompleted,
    required this.totalRevenue,
    required this.newUsersThisMonth,
    required this.newVendorsThisMonth,
    required this.averageUserRating,
    required this.averageVendorRating,
  });
}
