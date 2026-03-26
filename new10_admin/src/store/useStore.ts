import { create } from 'zustand'
import { AppState, AdminUser, User, Vendor, ActivityLog, DashboardStats, Notification } from '../types'

interface Store extends AppState {
  // Auth actions
  setAuthUser: (user: AdminUser | null) => void
  setAuthToken: (token: string | null) => void
  setAuthLoading: (isLoading: boolean) => void
  setAuthError: (error: string | null) => void
  logout: () => void

  // Dashboard actions
  setDashboardStats: (stats: DashboardStats | null) => void
  setDashboardLoading: (isLoading: boolean) => void
  setDashboardError: (error: string | null) => void

  // User Management actions
  setUsers: (users: User[]) => void
  setUsersLoading: (isLoading: boolean) => void
  setUsersError: (error: string | null) => void
  updateUserFilter: (filter: any) => void
  removeUser: (userId: string) => void
  updateUser: (user: User) => void
  setUsersTotalCount: (count: number) => void

  // Vendor Management actions
  setVendors: (vendors: Vendor[]) => void
  setVendorsLoading: (isLoading: boolean) => void
  setVendorsError: (error: string | null) => void
  updateVendorFilter: (filter: any) => void
  removeVendor: (vendorId: string) => void
  updateVendor: (vendor: Vendor) => void
  setVendorsTotalCount: (count: number) => void

  // Activity Logs actions
  setActivityLogs: (logs: ActivityLog[]) => void
  setActivityLogsLoading: (isLoading: boolean) => void
  setActivityLogsError: (error: string | null) => void
  setActivityLogsTotalCount: (count: number) => void

  // Notification actions
  addNotification: (notification: Notification) => void
  removeNotification: (notificationId: string) => void
  clearNotifications: () => void
}

const useStore = create<Store>((set) => ({
  // Initial state
  auth: {
    user: null,
    token: localStorage.getItem('adminToken'),
    isAuthenticated: !!localStorage.getItem('adminToken'),
    isLoading: false,
    error: null,
  },
  dashboard: {
    stats: null,
    isLoading: false,
    error: null,
  },
  userManagement: {
    users: [],
    totalCount: 0,
    isLoading: false,
    error: null,
    filters: { status: 'all', search: '', page: 1, limit: 10 },
  },
  vendorManagement: {
    vendors: [],
    totalCount: 0,
    isLoading: false,
    error: null,
    filters: { status: 'all', search: '', page: 1, limit: 10 },
  },
  activityLogs: {
    logs: [],
    totalCount: 0,
    isLoading: false,
    error: null,
    filters: { page: 1, limit: 20 },
  },
  notifications: [],

  // Auth actions
  setAuthUser: (user) =>
    set((state) => ({
      auth: { ...state.auth, user, isAuthenticated: !!user },
    })),

  setAuthToken: (token) => {
    if (token) {
      localStorage.setItem('adminToken', token)
    } else {
      localStorage.removeItem('adminToken')
    }
    set((state) => ({
      auth: { ...state.auth, token, isAuthenticated: !!token },
    }))
  },

  setAuthLoading: (isLoading) =>
    set((state) => ({
      auth: { ...state.auth, isLoading },
    })),

  setAuthError: (error) =>
    set((state) => ({
      auth: { ...state.auth, error },
    })),

  logout: () => {
    localStorage.removeItem('adminToken')
    set((state) => ({
      auth: {
        user: null,
        token: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,
      },
      userManagement: { ...state.userManagement, users: [] },
      vendorManagement: { ...state.vendorManagement, vendors: [] },
      activityLogs: { ...state.activityLogs, logs: [] },
    }))
  },

  // Dashboard actions
  setDashboardStats: (stats) =>
    set((state) => ({
      dashboard: { ...state.dashboard, stats, lastUpdated: new Date() },
    })),

  setDashboardLoading: (isLoading) =>
    set((state) => ({
      dashboard: { ...state.dashboard, isLoading },
    })),

  setDashboardError: (error) =>
    set((state) => ({
      dashboard: { ...state.dashboard, error },
    })),

  // User Management actions
  setUsers: (users) =>
    set((state) => ({
      userManagement: { ...state.userManagement, users },
    })),

  setUsersLoading: (isLoading) =>
    set((state) => ({
      userManagement: { ...state.userManagement, isLoading },
    })),

  setUsersError: (error) =>
    set((state) => ({
      userManagement: { ...state.userManagement, error },
    })),

  updateUserFilter: (filter) =>
    set((state) => ({
      userManagement: {
        ...state.userManagement,
        filters: { ...state.userManagement.filters, ...filter },
      },
    })),

  removeUser: (userId) =>
    set((state) => ({
      userManagement: {
        ...state.userManagement,
        users: state.userManagement.users.filter((u) => u.id !== userId),
      },
    })),

  updateUser: (user) =>
    set((state) => ({
      userManagement: {
        ...state.userManagement,
        users: state.userManagement.users.map((u) => (u.id === user.id ? user : u)),
      },
    })),

  setUsersTotalCount: (totalCount) =>
    set((state) => ({
      userManagement: { ...state.userManagement, totalCount },
    })),

  // Vendor Management actions
  setVendors: (vendors) =>
    set((state) => ({
      vendorManagement: { ...state.vendorManagement, vendors },
    })),

  setVendorsLoading: (isLoading) =>
    set((state) => ({
      vendorManagement: { ...state.vendorManagement, isLoading },
    })),

  setVendorsError: (error) =>
    set((state) => ({
      vendorManagement: { ...state.vendorManagement, error },
    })),

  updateVendorFilter: (filter) =>
    set((state) => ({
      vendorManagement: {
        ...state.vendorManagement,
        filters: { ...state.vendorManagement.filters, ...filter },
      },
    })),

  removeVendor: (vendorId) =>
    set((state) => ({
      vendorManagement: {
        ...state.vendorManagement,
        vendors: state.vendorManagement.vendors.filter((v) => v.id !== vendorId),
      },
    })),

  updateVendor: (vendor) =>
    set((state) => ({
      vendorManagement: {
        ...state.vendorManagement,
        vendors: state.vendorManagement.vendors.map((v) => (v.id === vendor.id ? vendor : v)),
      },
    })),

  setVendorsTotalCount: (totalCount) =>
    set((state) => ({
      vendorManagement: { ...state.vendorManagement, totalCount },
    })),

  // Activity Logs actions
  setActivityLogs: (logs) =>
    set((state) => ({
      activityLogs: { ...state.activityLogs, logs },
    })),

  setActivityLogsLoading: (isLoading) =>
    set((state) => ({
      activityLogs: { ...state.activityLogs, isLoading },
    })),

  setActivityLogsError: (error) =>
    set((state) => ({
      activityLogs: { ...state.activityLogs, error },
    })),

  setActivityLogsTotalCount: (totalCount) =>
    set((state) => ({
      activityLogs: { ...state.activityLogs, totalCount },
    })),

  // Notification actions
  addNotification: (notification) =>
    set((state) => ({
      notifications: [...state.notifications, notification],
    })),

  removeNotification: (notificationId) =>
    set((state) => ({
      notifications: state.notifications.filter((n) => n.id !== notificationId),
    })),

  clearNotifications: () =>
    set({
      notifications: [],
    }),
}))

export default useStore
