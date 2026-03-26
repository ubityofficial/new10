import axios, { AxiosInstance, AxiosError } from 'axios'
import { ApiResponse, PaginatedResponse } from '../types'

class ApiClient {
  private client: AxiosInstance

  constructor() {
    const baseURL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api'

    this.client = axios.create({
      baseURL,
      headers: {
        'Content-Type': 'application/json',
      },
    })

    // Request interceptor to add auth token
    this.client.interceptors.request.use(
      (config) => {
        const token = localStorage.getItem('adminToken')
        if (token) {
          config.headers.Authorization = `Bearer ${token}`
        }
        return config
      },
      (error) => {
        return Promise.reject(error)
      }
    )

    // Response interceptor to handle errors
    this.client.interceptors.response.use(
      (response) => response,
      (error: AxiosError<ApiResponse<any>>) => {
        // Handle 401 Unauthorized - token expired
        if (error.response?.status === 401) {
          localStorage.removeItem('adminToken')
          window.location.href = '/login'
        }
        return Promise.reject(error)
      }
    )
  }

  // Auth endpoints
  async login(email: string, password: string): Promise<ApiResponse<{ token: string; user: any }>> {
    const response = await this.client.post('/auth/login', { email, password })
    return response.data
  }

  async logout(): Promise<ApiResponse<null>> {
    const response = await this.client.post('/auth/logout')
    return response.data
  }

  // User endpoints
  async getUsers(page: number = 1, limit: number = 10, filters?: any): Promise<PaginatedResponse<any>> {
    const response = await this.client.get('/users', {
      params: { page, limit, ...filters },
    })
    return response.data
  }

  async getUser(id: string): Promise<ApiResponse<any>> {
    const response = await this.client.get(`/users/${id}`)
    return response.data
  }

  async suspendUser(id: string, reason: string): Promise<ApiResponse<any>> {
    const response = await this.client.patch(`/users/${id}/suspend`, { reason })
    return response.data
  }

  async blockUser(id: string, reason: string): Promise<ApiResponse<any>> {
    const response = await this.client.patch(`/users/${id}/block`, { reason })
    return response.data
  }

  async activateUser(id: string): Promise<ApiResponse<any>> {
    const response = await this.client.patch(`/users/${id}/activate`)
    return response.data
  }

  // Vendor endpoints
  async getVendors(page: number = 1, limit: number = 10, filters?: any): Promise<PaginatedResponse<any>> {
    const response = await this.client.get('/vendors', {
      params: { page, limit, ...filters },
    })
    return response.data
  }

  async getVendor(id: string): Promise<ApiResponse<any>> {
    const response = await this.client.get(`/vendors/${id}`)
    return response.data
  }

  async approveVendor(id: string): Promise<ApiResponse<any>> {
    const response = await this.client.patch(`/vendors/${id}/approve`)
    return response.data
  }

  async rejectVendor(id: string, reason: string): Promise<ApiResponse<any>> {
    const response = await this.client.patch(`/vendors/${id}/reject`, { reason })
    return response.data
  }

  async suspendVendor(id: string, reason: string): Promise<ApiResponse<any>> {
    const response = await this.client.patch(`/vendors/${id}/suspend`, { reason })
    return response.data
  }

  async blockVendor(id: string, reason: string): Promise<ApiResponse<any>> {
    const response = await this.client.patch(`/vendors/${id}/block`, { reason })
    return response.data
  }

  async verifyVendor(id: string): Promise<ApiResponse<any>> {
    const response = await this.client.patch(`/vendors/${id}/verify`)
    return response.data
  }

  // Dashboard endpoints
  async getDashboardStats(): Promise<ApiResponse<any>> {
    const response = await this.client.get('/dashboard/stats')
    return response.data
  }

  // Activity logs endpoints
  async getActivityLogs(page: number = 1, limit: number = 20, filters?: any): Promise<PaginatedResponse<any>> {
    const response = await this.client.get('/activity-logs', {
      params: { page, limit, ...filters },
    })
    return response.data
  }
}

export default new ApiClient()
