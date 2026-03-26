import React, { useEffect } from 'react'
import {
  Box,
  Grid,
  Card,
  CardContent,
  Typography,
  LinearProgress,
  Button,
  Stack,
} from '@mui/material'
import {
  TrendingUp as TrendingUpIcon,
  People as PeopleIcon,
  Business as BusinessIcon,
  ShoppingCart as ShoppingCartIcon,
  AttachMoney as AttachMoneyIcon,
  PendingActions as PendingActionsIcon,
} from '@mui/icons-material'
import { useNavigate } from 'react-router-dom'
import MainLayout from '../components/MainLayout'
import useStore from '../store/useStore'

const DashboardPage: React.FC = () => {
  const navigate = useNavigate()
  const { setDashboardStats } = useStore()

  // Mock dashboard data
  const mockStats = {
    totalUsers: 1243,
    totalVendors: 156,
    activeUsers: 1087,
    suspendedUsers: 128,
    blockedUsers: 28,
    pendingApprovals: 12,
    approvedVendors: 132,
    suspendedVendors: 8,
    totalBookings: 5678,
    completedBookings: 5234,
    totalRevenue: 2890000,
    currentMonthRevenue: 456000,
    averageRating: 4.58,
  }

  useEffect(() => {
    // Initialize dashboard
    setDashboardStats(mockStats)
  }, [setDashboardStats])

  const StatCard: React.FC<{
    title: string
    value: string | number
    icon: React.ReactNode
    color: string
    subtitle?: string
  }> = ({ title, value, icon, color, subtitle }) => (
    <Card sx={{ height: '100%' }}>
      <CardContent>
        <Box sx={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
          <Box>
            <Typography color="textSecondary" gutterBottom variant="body2" sx={{ fontWeight: 500 }}>
              {title}
            </Typography>
            <Typography variant="h5" sx={{ fontWeight: 700, my: 1 }}>
              {typeof value === 'number' && value > 1000
                ? `${(value / 1000).toFixed(1)}k`
                : value}
            </Typography>
            {subtitle && (
              <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                {subtitle}
              </Typography>
            )}
          </Box>
          <Box
            sx={{
              p: 1.5,
              backgroundColor: `${color}20`,
              borderRadius: 1,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: color,
            }}
          >
            {icon}
          </Box>
        </Box>
      </CardContent>
    </Card>
  )

  const ActionCard: React.FC<{
    title: string
    description: string
    value: string | number
    action: string
    onClick: () => void
    pending?: boolean
  }> = ({ title, description, value, action, onClick, pending }) => (
    <Card
      sx={{
        cursor: 'pointer',
        transition: 'all 0.2s ease',
        '&:hover': {
          boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
          transform: 'translateY(-2px)',
        },
        border: pending ? '2px solid #F1C21B' : undefined,
      }}
    >
      <CardContent>
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 1 }}>
          <Typography variant="h6" sx={{ fontWeight: 600 }}>
            {title}
          </Typography>
          {pending && (
            <Box
              sx={{
                px: 1,
                py: 0.5,
                backgroundColor: '#FFF3CD',
                borderRadius: 0.5,
              }}
            >
              <Typography variant="caption" sx={{ color: '#856404', fontWeight: 600 }}>
                Pending
              </Typography>
            </Box>
          )}
        </Box>
        <Typography variant="body2" sx={{ color: 'text.secondary', mb: 2 }}>
          {description}
        </Typography>
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <Typography variant="h6" sx={{ fontWeight: 700, color: 'primary.main' }}>
            {value}
          </Typography>
          <Button size="small" variant="outlined" onClick={onClick}>
            {action}
          </Button>
        </Box>
      </CardContent>
    </Card>
  )

  return (
    <MainLayout>
      <Box>
        {/* Page Header */}
        <Box sx={{ mb: 4 }}>
          <Typography variant="h4" sx={{ fontWeight: 700, mb: 0.5 }}>
            Dashboard
          </Typography>
          <Typography variant="body2" sx={{ color: 'text.secondary' }}>
            Welcome back! Here's your platform overview.
          </Typography>
        </Box>

        {/* Key Metrics */}
        <Grid container spacing={2} sx={{ mb: 4 }}>
          <Grid item xs={12} sm={6} md={3}>
            <StatCard
              title="Total Users"
              value={mockStats.totalUsers}
              icon={<PeopleIcon />}
              color="#0F62FE"
              subtitle={`${mockStats.activeUsers} active`}
            />
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <StatCard
              title="Total Vendors"
              value={mockStats.totalVendors}
              icon={<BusinessIcon />}
              color="#24A148"
              subtitle={`${mockStats.approvedVendors} approved`}
            />
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <StatCard
              title="Completed Bookings"
              value={mockStats.completedBookings}
              icon={<ShoppingCartIcon />}
              color="#FF6B6B"
              subtitle={`${((mockStats.completedBookings / mockStats.totalBookings) * 100).toFixed(1)}% completion`}
            />
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <StatCard
              title="Total Revenue"
              value={`₹${mockStats.totalRevenue / 100000}`}
              icon={<AttachMoneyIcon />}
              color="#854CE6"
              subtitle={`₹${mockStats.currentMonthRevenue / 100000}L this month`}
            />
          </Grid>
        </Grid>

        {/* Action Cards */}
        <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
          Quick Actions
        </Typography>
        <Grid container spacing={2} sx={{ mb: 4 }}>
          <Grid item xs={12} sm={6} md={4}>
            <ActionCard
              title="Pending Approvals"
              description="Vendors waiting for verification"
              value={mockStats.pendingApprovals}
              action="Review"
              onClick={() => navigate('/vendors?status=pending')}
              pending={true}
            />
          </Grid>
          <Grid item xs={12} sm={6} md={4}>
            <ActionCard
              title="Suspended Users"
              description="Users temporarily blocked from platform"
              value={mockStats.suspendedUsers}
              action="Review"
              onClick={() => navigate('/users?status=suspended')}
            />
          </Grid>
          <Grid item xs={12} sm={6} md={4}>
            <ActionCard
              title="Blocked Users"
              description="Users permanently blocked from platform"
              value={mockStats.blockedUsers}
              action="Manage"
              onClick={() => navigate('/users?status=blocked')}
            />
          </Grid>
        </Grid>

        {/* Statistics Section */}
        <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
          Detailed Statistics
        </Typography>
        <Grid container spacing={2}>
          {/* Users Breakdown */}
          <Grid item xs={12} md={6}>
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
                  Users Breakdown
                </Typography>
                <Box sx={{ mb: 2 }}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                    <Typography variant="body2">Active Users</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600 }}>
                      {mockStats.activeUsers} ({((mockStats.activeUsers / mockStats.totalUsers) * 100).toFixed(1)}%)
                    </Typography>
                  </Box>
                  <LinearProgress
                    variant="determinate"
                    value={(mockStats.activeUsers / mockStats.totalUsers) * 100}
                    sx={{ height: 8, borderRadius: 4 }}
                  />
                </Box>
                <Box sx={{ mb: 2 }}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                    <Typography variant="body2">Suspended Users</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600 }}>
                      {mockStats.suspendedUsers} ({((mockStats.suspendedUsers / mockStats.totalUsers) * 100).toFixed(1)}%)
                    </Typography>
                  </Box>
                  <LinearProgress
                    variant="determinate"
                    value={(mockStats.suspendedUsers / mockStats.totalUsers) * 100}
                    sx={{ height: 8, borderRadius: 4, backgroundColor: '#FFE0B2' }}
                  />
                </Box>
                <Box>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                    <Typography variant="body2">Blocked Users</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600 }}>
                      {mockStats.blockedUsers} ({((mockStats.blockedUsers / mockStats.totalUsers) * 100).toFixed(1)}%)
                    </Typography>
                  </Box>
                  <LinearProgress
                    variant="determinate"
                    value={(mockStats.blockedUsers / mockStats.totalUsers) * 100}
                    sx={{ height: 8, borderRadius: 4 }}
                    color="error"
                  />
                </Box>
              </CardContent>
            </Card>
          </Grid>

          {/* Vendors Breakdown */}
          <Grid item xs={12} md={6}>
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
                  Vendors Breakdown
                </Typography>
                <Box sx={{ mb: 2 }}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                    <Typography variant="body2">Approved Vendors</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600 }}>
                      {mockStats.approvedVendors} ({((mockStats.approvedVendors / mockStats.totalVendors) * 100).toFixed(1)}%)
                    </Typography>
                  </Box>
                  <LinearProgress
                    variant="determinate"
                    value={(mockStats.approvedVendors / mockStats.totalVendors) * 100}
                    sx={{ height: 8, borderRadius: 4 }}
                  />
                </Box>
                <Box sx={{ mb: 2 }}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                    <Typography variant="body2">Pending Approvals</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600 }}>
                      {mockStats.pendingApprovals} ({((mockStats.pendingApprovals / mockStats.totalVendors) * 100).toFixed(1)}%)
                    </Typography>
                  </Box>
                  <LinearProgress
                    variant="determinate"
                    value={(mockStats.pendingApprovals / mockStats.totalVendors) * 100}
                    sx={{ height: 8, borderRadius: 4, backgroundColor: '#FFE0B2' }}
                  />
                </Box>
                <Box>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                    <Typography variant="body2">Suspended Vendors</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600 }}>
                      {mockStats.suspendedVendors} ({((mockStats.suspendedVendors / mockStats.totalVendors) * 100).toFixed(1)}%)
                    </Typography>
                  </Box>
                  <LinearProgress
                    variant="determinate"
                    value={(mockStats.suspendedVendors / mockStats.totalVendors) * 100}
                    sx={{ height: 8, borderRadius: 4 }}
                    color="error"
                  />
                </Box>
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      </Box>
    </MainLayout>
  )
}

export default DashboardPage
