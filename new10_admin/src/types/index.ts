// Admin and Auth Types
export interface AdminUser {
  id: string
  email: string
  name: string
  role: 'admin' | 'superadmin'
  createdAt: Date
  lastLogin?: Date
}

export interface AuthState {
  user: AdminUser | null
  token: string | null
  isAuthenticated: boolean
  isLoading: boolean
  error: string | null
}

// User Management Types
export interface User {
  id: string
  name: string
  email: string
  phone: string
  status: 'active' | 'suspended' | 'blocked'
  rating: number
  totalBookings: number
  totalSpent: number
  createdAt: Date
  lastLogin?: Date
  documentVerified: boolean
  bankDetails?: BankDetails
}

export interface BankDetails {
  accountNumber: string
  ifscCode: string
  accountHolderName: string
}

export interface UserFilter {
  status?: 'all' | 'active' | 'suspended' | 'blocked'
  search?: string
  page?: number
  limit?: number
}

export interface UserManagementState {
  users: User[]
  totalCount: number
  isLoading: boolean
  error: string | null
  filters: UserFilter
}

// Vendor Management Types
export interface Vendor {
  id: string
  businessName: string
  ownerName: string
  ownerEmail: string
  ownerPhone: string
  status: 'pending' | 'approved' | 'suspended' | 'blocked'
  rating: number
  gstNumber: string
  panNumber: string
  businessAddress: string
  equipmentCount: number
  totalEarnings: number
  completedBookings: number
  verified: boolean
  createdAt: Date
  verifiedAt?: Date
  documents?: VendorDocument[]
}

export interface VendorDocument {
  type: 'gst' | 'pan' | 'aadhar' | 'businessLicense' | 'bankDetails'
  documentNumber: string
  verificationStatus: 'pending' | 'verified' | 'rejected'
  verifiedAt?: Date
  rejectionReason?: string
}

export interface Equipment {
  id: string
  name: string
  type: string
  rentalPricePerDay: number
  location: string
  available: boolean
}

export interface VendorFilter {
  status?: 'all' | 'pending' | 'approved' | 'suspended' | 'blocked'
  search?: string
  verified?: boolean
  page?: number
  limit?: number
}

export interface VendorManagementState {
  vendors: Vendor[]
  totalCount: number
  isLoading: boolean
  error: string | null
  filters: VendorFilter
}

// Activity Log Types
export interface ActivityLog {
  id: string
  action: string
  actionType:
    | 'user_suspended'
    | 'user_blocked'
    | 'user_activated'
    | 'vendor_approved'
    | 'vendor_rejected'
    | 'vendor_suspended'
    | 'vendor_blocked'
    | 'vendor_verified'
    | 'login'
    | 'logout'
    | 'settings_changed'
  targetId: string
  targetType: 'user' | 'vendor' | 'system'
  targetName: string
  performedBy: string
  details: Record<string, any>
  timestamp: Date
}

export interface ActivityLogFilter {
  actionType?: string
  targetType?: 'user' | 'vendor' | 'system'
  startDate?: Date
  endDate?: Date
  page?: number
  limit?: number
}

export interface ActivityLogState {
  logs: ActivityLog[]
  totalCount: number
  isLoading: boolean
  error: string | null
  filters: ActivityLogFilter
}

// Dashboard Types
export interface DashboardStats {
  totalUsers: number
  totalVendors: number
  activeUsers: number
  suspendedUsers: number
  blockedUsers: number
  pendingApprovals: number
  approvedVendors: number
  suspendedVendors: number
  totalBookings: number
  completedBookings: number
  totalRevenue: number
  currentMonthRevenue: number
  averageRating: number
}

export interface DashboardState {
  stats: DashboardStats | null
  isLoading: boolean
  error: string | null
  lastUpdated?: Date
}

// API Response Types
export interface ApiResponse<T> {
  success: boolean
  data?: T
  message?: string
  error?: string
  timestamp: Date
}

export interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  limit: number
  pages: number
}

// Store Types
export interface AppState {
  auth: AuthState
  dashboard: DashboardState
  userManagement: UserManagementState
  vendorManagement: VendorManagementState
  activityLogs: ActivityLogState
  notifications: Notification[]
}

export interface Notification {
  id: string
  type: 'success' | 'error' | 'warning' | 'info'
  message: string
  duration?: number
  timestamp: Date
}
