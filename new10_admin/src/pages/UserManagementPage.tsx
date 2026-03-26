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
  Button,
  Chip,
  TextField,
  Stack,
  Typography,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
} from '@mui/material'
import MainLayout from '../components/MainLayout'
import useStore from '../store/useStore'

interface UserData {
  id: string
  name: string
  email: string
  phone: string
  status: 'active' | 'suspended' | 'blocked'
  rating: number
  bookings: number
  joined: string
}

const mockUsers: UserData[] = [
  {
    id: '1',
    name: 'Rajesh Kumar',
    email: 'rajesh@email.com',
    phone: '+91-9876543210',
    status: 'active',
    rating: 4.5,
    bookings: 23,
    joined: '2023-01-15',
  },
  {
    id: '2',
    name: 'Priya Sharma',
    email: 'priya@email.com',
    phone: '+91-9876543211',
    status: 'active',
    rating: 4.8,
    bookings: 34,
    joined: '2023-02-20',
  },
  {
    id: '3',
    name: 'Amit Patel',
    email: 'amit@email.com',
    phone: '+91-9876543212',
    status: 'suspended',
    rating: 2.1,
    bookings: 5,
    joined: '2023-03-10',
  },
  {
    id: '4',
    name: 'Neha Singh',
    email: 'neha@email.com',
    phone: '+91-9876543213',
    status: 'active',
    rating: 4.2,
    bookings: 18,
    joined: '2023-04-05',
  },
]

const UserManagementPage: React.FC = () => {
  const { addNotification } = useStore()
  const [users, setUsers] = useState(mockUsers)
  const [searchQuery, setSearchQuery] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [actionDialogOpen, setActionDialogOpen] = useState(false)
  const [actionReason, setActionReason] = useState('')
  const [selectedUser, setSelectedUser] = useState<UserData | null>(null)
  const [actionType, setActionType] = useState<'suspend' | 'block' | 'activate' | null>(null)

  const filteredUsers = users.filter((user) => {
    const matchesSearch =
      user.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      user.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
      user.phone.includes(searchQuery)

    const matchesStatus = statusFilter === 'all' || user.status === statusFilter

    return matchesSearch && matchesStatus
  })

  const handleActionOpen = (user: UserData, type: 'suspend' | 'block' | 'activate') => {
    setSelectedUser(user)
    setActionType(type)
    setActionDialogOpen(true)
    setActionReason('')
  }

  const handleActionConfirm = () => {
    if (!selectedUser || !actionType) return

    const updatedUsers: UserData[] = users.map((user) => {
      if (user.id === selectedUser.id) {
        if (actionType === 'activate') {
          return { ...user, status: 'active' as const }
        } else if (actionType === 'suspend') {
          return { ...user, status: 'suspended' as const }
        } else if (actionType === 'block') {
          return { ...user, status: 'blocked' as const }
        }
      }
      return user
    })

    setUsers(updatedUsers)
    setActionDialogOpen(false)

    addNotification({
      id: Date.now().toString(),
      type: 'success',
      message: `User ${actionType === 'activate' ? 'activated' : actionType === 'suspend' ? 'suspended' : 'blocked'} successfully`,
      timestamp: new Date(),
    })
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return 'success'
      case 'suspended':
        return 'warning'
      case 'blocked':
        return 'error'
      default:
        return 'default'
    }
  }

  return (
    <MainLayout onSearch={(query) => setSearchQuery(query)}>
      <Box>
        <Typography variant="h4" sx={{ fontWeight: 700, mb: 1 }}>
          User Management
        </Typography>
        <Typography variant="body2" sx={{ color: 'text.secondary', mb: 3 }}>
          Manage users, view their activity, and control access to the platform.
        </Typography>

        {/* Filters */}
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
              <TextField
                label="Search users"
                variant="outlined"
                size="small"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Name, email, or phone"
                sx={{ flex: 1 }}
              />
              <TextField
                select
                label="Status"
                variant="outlined"
                size="small"
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                SelectProps={{
                  native: true,
                }}
              >
                <option value="all">All Status</option>
                <option value="active">Active</option>
                <option value="suspended">Suspended</option>
                <option value="blocked">Blocked</option>
              </TextField>
            </Stack>
          </CardContent>
        </Card>

        {/* Users Table */}
        <Card>
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow sx={{ backgroundColor: '#F4F4F4' }}>
                  <TableCell sx={{ fontWeight: 600 }}>Name</TableCell>
                  <TableCell sx={{ fontWeight: 600 }}>Email</TableCell>
                  <TableCell sx={{ fontWeight: 600 }}>Phone</TableCell>
                  <TableCell sx={{ fontWeight: 600 }}>Status</TableCell>
                  <TableCell align="right" sx={{ fontWeight: 600 }}>
                    Rating
                  </TableCell>
                  <TableCell align="right" sx={{ fontWeight: 600 }}>
                    Bookings
                  </TableCell>
                  <TableCell sx={{ fontWeight: 600 }}>Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredUsers.map((user) => (
                  <TableRow key={user.id} hover>
                    <TableCell sx={{ fontWeight: 500 }}>{user.name}</TableCell>
                    <TableCell>{user.email}</TableCell>
                    <TableCell>{user.phone}</TableCell>
                    <TableCell>
                      <Chip
                        label={user.status}
                        size="small"
                        color={getStatusColor(user.status) as any}
                        variant="outlined"
                      />
                    </TableCell>
                    <TableCell align="right">⭐ {user.rating.toFixed(1)}</TableCell>
                    <TableCell align="right">{user.bookings}</TableCell>
                    <TableCell>
                      <Stack direction="row" spacing={1}>
                        {user.status === 'active' && (
                          <>
                            <Button
                              size="small"
                              variant="outlined"
                              onClick={() => handleActionOpen(user, 'suspend')}
                              sx={{ color: '#FF9800', borderColor: '#FF9800' }}
                            >
                              Suspend
                            </Button>
                            <Button
                              size="small"
                              variant="outlined"
                              onClick={() => handleActionOpen(user, 'block')}
                              color="error"
                            >
                              Block
                            </Button>
                          </>
                        )}
                        {user.status !== 'active' && (
                          <Button
                            size="small"
                            variant="outlined"
                            onClick={() => handleActionOpen(user, 'activate')}
                            color="success"
                          >
                            Activate
                          </Button>
                        )}
                      </Stack>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </Card>

        {/* Action Dialog */}
        <Dialog open={actionDialogOpen} onClose={() => setActionDialogOpen(false)} maxWidth="sm" fullWidth>
          <DialogTitle>
            {actionType === 'activate'
              ? 'Activate User'
              : actionType === 'suspend'
                ? 'Suspend User'
                : 'Block User'}
          </DialogTitle>
          <DialogContent>
            <Box sx={{ pt: 2 }}>
              <Typography variant="body2" sx={{ mb: 2 }}>
                {selectedUser?.name}
              </Typography>
              {actionType !== 'activate' && (
                <TextField
                  fullWidth
                  multiline
                  rows={3}
                  label="Reason"
                  variant="outlined"
                  value={actionReason}
                  onChange={(e) => setActionReason(e.target.value)}
                  placeholder="Provide reason for this action"
                />
              )}
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setActionDialogOpen(false)}>Cancel</Button>
            <Button onClick={handleActionConfirm} variant="contained">
              {actionType === 'activate' ? 'Activate' : actionType === 'suspend' ? 'Suspend' : 'Block'}
            </Button>
          </DialogActions>
        </Dialog>
      </Box>
    </MainLayout>
  )
}

export default UserManagementPage
