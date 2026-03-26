import React, { useState } from 'react'
import {
  Box,
  Card,
  CardContent,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  TextField,
  Stack,
  Typography,
  Grid,
  Pagination,
} from '@mui/material'
import {
  Block as BlockIcon,
  CheckCircle as CheckCircleIcon,
  Info as InfoIcon,
  Warning as WarningIcon,
} from '@mui/icons-material'
import MainLayout from '../components/MainLayout'

interface ActivityLogData {
  id: string
  action: string
  actionType: string
  target: string
  targetType: string
  admin: string
  timestamp: string
  status: 'success' | 'warning' | 'error' | 'info'
}

const mockActivityLogs: ActivityLogData[] = [
  {
    id: '1',
    action: 'User Suspended',
    actionType: 'user_suspended',
    target: 'Amit Patel',
    targetType: 'user',
    admin: 'Admin User',
    timestamp: '2024-01-15 14:30:00',
    status: 'warning',
  },
  {
    id: '2',
    action: 'Vendor Approved',
    actionType: 'vendor_approved',
    target: 'Heavy Lift Solutions',
    targetType: 'vendor',
    admin: 'Admin User',
    timestamp: '2024-01-15 13:45:00',
    status: 'success',
  },
  {
    id: '3',
    action: 'User Blocked',
    actionType: 'user_blocked',
    target: 'John Doe',
    targetType: 'user',
    admin: 'Admin User',
    timestamp: '2024-01-15 12:20:00',
    status: 'error',
  },
  {
    id: '4',
    action: 'Vendor Verified',
    actionType: 'vendor_verified',
    target: 'Prime Equipments',
    targetType: 'vendor',
    admin: 'Admin User',
    timestamp: '2024-01-15 11:10:00',
    status: 'success',
  },
  {
    id: '5',
    action: 'User Activated',
    actionType: 'user_activated',
    target: 'Neha Singh',
    targetType: 'user',
    admin: 'Admin User',
    timestamp: '2024-01-15 10:00:00',
    status: 'success',
  },
  {
    id: '6',
    action: 'Vendor Rejected',
    actionType: 'vendor_rejected',
    target: 'Unknown Vendor',
    targetType: 'vendor',
    admin: 'Admin User',
    timestamp: '2024-01-14 16:30:00',
    status: 'error',
  },
  {
    id: '7',
    action: 'Login',
    actionType: 'login',
    target: 'Admin Panel',
    targetType: 'system',
    admin: 'Admin User',
    timestamp: '2024-01-14 09:00:00',
    status: 'info',
  },
  {
    id: '8',
    action: 'Settings Changed',
    actionType: 'settings_changed',
    target: 'Platform Settings',
    targetType: 'system',
    admin: 'Admin User',
    timestamp: '2024-01-13 15:45:00',
    status: 'info',
  },
]

const ActivityLogsPage: React.FC = () => {
  const [searchQuery, setSearchQuery] = useState('')
  const [actionTypeFilter, setActionTypeFilter] = useState('all')
  const [currentPage, setCurrentPage] = useState(1)
  const itemsPerPage = 10

  const filteredLogs = mockActivityLogs.filter((log) => {
    const matchesSearch =
      log.target.toLowerCase().includes(searchQuery.toLowerCase()) ||
      log.action.toLowerCase().includes(searchQuery.toLowerCase()) ||
      log.admin.toLowerCase().includes(searchQuery.toLowerCase())

    const matchesActionType = actionTypeFilter === 'all' || log.actionType === actionTypeFilter

    return matchesSearch && matchesActionType
  })

  const totalPages = Math.ceil(filteredLogs.length / itemsPerPage)
  const paginatedLogs = filteredLogs.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage)

  const getActionIcon = (status: string) => {
    switch (status) {
      case 'success':
        return <CheckCircleIcon sx={{ fontSize: '1.2rem', color: 'success.main' }} />
      case 'error':
        return <BlockIcon sx={{ fontSize: '1.2rem', color: 'error.main' }} />
      case 'warning':
        return <WarningIcon sx={{ fontSize: '1.2rem', color: 'warning.main' }} />
      default:
        return <InfoIcon sx={{ fontSize: '1.2rem', color: 'info.main' }} />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'success':
        return 'success'
      case 'error':
        return 'error'
      case 'warning':
        return 'warning'
      default:
        return 'info'
    }
  }

  return (
    <MainLayout onSearch={(query) => setSearchQuery(query)}>
      <Box>
        <Typography variant="h4" sx={{ fontWeight: 700, mb: 1 }}>
          Activity Logs
        </Typography>
        <Typography variant="body2" sx={{ color: 'text.secondary', mb: 3 }}>
          Track all administrative actions and system events.
        </Typography>

        {/* Statistics */}
        <Grid container spacing={2} sx={{ mb: 3 }}>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent sx={{ textAlign: 'center' }}>
                <Typography variant="body2" sx={{ color: 'text.secondary', mb: 0.5 }}>
                  Total Actions
                </Typography>
                <Typography variant="h5" sx={{ fontWeight: 700 }}>
                  {mockActivityLogs.length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent sx={{ textAlign: 'center' }}>
                <Typography variant="body2" sx={{ color: 'text.secondary', mb: 0.5 }}>
                  Success
                </Typography>
                <Typography variant="h5" sx={{ fontWeight: 700, color: 'success.main' }}>
                  {mockActivityLogs.filter((l) => l.status === 'success').length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent sx={{ textAlign: 'center' }}>
                <Typography variant="body2" sx={{ color: 'text.secondary', mb: 0.5 }}>
                  Warnings
                </Typography>
                <Typography variant="h5" sx={{ fontWeight: 700, color: 'warning.main' }}>
                  {mockActivityLogs.filter((l) => l.status === 'warning').length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent sx={{ textAlign: 'center' }}>
                <Typography variant="body2" sx={{ color: 'text.secondary', mb: 0.5 }}>
                  Errors
                </Typography>
                <Typography variant="h5" sx={{ fontWeight: 700, color: 'error.main' }}>
                  {mockActivityLogs.filter((l) => l.status === 'error').length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        {/* Filters */}
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
              <TextField
                label="Search logs"
                variant="outlined"
                size="small"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Target, action, or admin"
                sx={{ flex: 1 }}
              />
              <TextField
                select
                label="Action Type"
                variant="outlined"
                size="small"
                value={actionTypeFilter}
                onChange={(e) => setActionTypeFilter(e.target.value)}
                SelectProps={{
                  native: true,
                }}
              >
                <option value="all">All Types</option>
                <option value="user_suspended">User Suspended</option>
                <option value="user_blocked">User Blocked</option>
                <option value="user_activated">User Activated</option>
                <option value="vendor_approved">Vendor Approved</option>
                <option value="vendor_verified">Vendor Verified</option>
                <option value="vendor_rejected">Vendor Rejected</option>
                <option value="login">Login</option>
                <option value="settings_changed">Settings Changed</option>
              </TextField>
            </Stack>
          </CardContent>
        </Card>

        {/* Activity Logs Table */}
        <Card sx={{ mb: 3 }}>
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow sx={{ backgroundColor: '#F4F4F4' }}>
                  <TableCell sx={{ fontWeight: 600 }}>Status</TableCell>
                  <TableCell sx={{ fontWeight: 600 }}>Action</TableCell>
                  <TableCell sx={{ fontWeight: 600 }}>Target</TableCell>
                  <TableCell sx={{ fontWeight: 600 }}>Type</TableCell>
                  <TableCell sx={{ fontWeight: 600 }}>Performed By</TableCell>
                  <TableCell sx={{ fontWeight: 600 }}>Timestamp</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {paginatedLogs.map((log) => (
                  <TableRow key={log.id} hover>
                    <TableCell align="center">{getActionIcon(log.status)}</TableCell>
                    <TableCell sx={{ fontWeight: 500 }}>{log.action}</TableCell>
                    <TableCell>{log.target}</TableCell>
                    <TableCell>
                      <Chip
                        label={log.targetType}
                        size="small"
                        variant="outlined"
                        sx={{ textTransform: 'capitalize' }}
                      />
                    </TableCell>
                    <TableCell>{log.admin}</TableCell>
                    <TableCell sx={{ fontSize: '0.85rem', color: 'text.secondary' }}>
                      {log.timestamp}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </Card>

        {/* Pagination */}
        {totalPages > 1 && (
          <Box sx={{ display: 'flex', justifyContent: 'center' }}>
            <Pagination
              count={totalPages}
              page={currentPage}
              onChange={(e, page) => setCurrentPage(page)}
              color="primary"
            />
          </Box>
        )}
      </Box>
    </MainLayout>
  )
}

export default ActivityLogsPage
