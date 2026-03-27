import React, { useState, useEffect } from 'react'
import {
  Box,
  Card,
  CardContent,
  Grid,
  Button,
  Chip,
  TextField,
  Stack,
  Typography,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
} from '@mui/material'
import { Business as BusinessIcon, VerifiedUser as VerifiedIcon } from '@mui/icons-material'
import MainLayout from '../components/MainLayout'
import useStore from '../store/useStore'

interface VendorData {
  id: string
  businessName: string
  ownerName: string
  status: string
  businessReg: string
  approved: boolean
  blocked: boolean
  createdAt: string
}

const mockVendors: VendorData[] = [
  {
    id: '1',
    businessName: 'Heavy Lift Solutions',
    ownerName: 'Vikram Singh',
    status: 'approved',
    gst: '18AAGCT1234A1Z5',
    equipmentCount: 45,
    rating: 4.8,
    verified: true,
    joined: '2023-01-10',
  },
  {
    id: '2',
    businessName: 'Prime Equipments',
    ownerName: 'Anita Gupta',
    status: 'approved',
    gst: '27AABCT5678B2Z6',
    equipmentCount: 32,
    rating: 4.6,
    verified: true,
    joined: '2023-02-15',
  },
  {
    id: '3',
    businessName: 'Crane Masters',
    ownerName: 'Suresh Kumar',
    status: 'pending',
    gst: '06AABCM1234D3Z7',
    equipmentCount: 0,
    rating: 0,
    verified: false,
    joined: '2024-01-05',
  },

const VendorManagementPage: React.FC = () => {
  const { addNotification } = useStore()
  const [vendors, setVendors] = useState<VendorData[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [actionDialogOpen, setActionDialogOpen] = useState(false)
  const [actionReason, setActionReason] = useState('')
  const [selectedVendor, setSelectedVendor] = useState<VendorData | null>(null)
  const [actionType, setActionType] = useState<'approve' | 'reject' | 'suspend' | 'block' | 'verify' | null>(null)

  // Fetch vendors from API on mount
  useEffect(() => {
    const fetchVendors = async () => {
      try {
        setLoading(true)
        const response = await fetch('https://new10-yk1r.onrender.com/api/admin/vendors/list')
        const data = await response.json()
        
        if (data.success && data.vendors) {
          setVendors(data.vendors)
        }
      } catch (error) {
        console.error('Failed to fetch vendors:', error)
        addNotification({
          id: Date.now().toString(),
          type: 'error',
          message: 'Failed to load vendors',
          timestamp: new Date(),
        })
      } finally {
        setLoading(false)
      }
    }

    fetchVendors()
  }, [])

  const filteredVendors = vendors.filter((vendor) => {
    const matchesSearch =
      vendor.businessName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      vendor.ownerName.toLowerCase().includes(searchQuery.toLowerCase())

    const matchesStatus = statusFilter === 'all' || vendor.status === statusFilter

    return matchesSearch && matchesStatus
  })

  const handleActionOpen = (vendor: VendorData, type: 'approve' | 'reject' | 'suspend' | 'block' | 'verify') => {
    setSelectedVendor(vendor)
    setActionType(type)
    setActionDialogOpen(true)
    setActionReason('')
  }

  const handleActionConfirm = () => {
    if (!selectedVendor || !actionType) return

    const updatedVendors: VendorData[] = vendors.map((vendor) => {
      if (vendor.id === selectedVendor.id) {
        if (actionType === 'approve') {
          return { ...vendor, status: 'approved' as const }
        } else if (actionType === 'reject') {
          return { ...vendor, status: 'blocked' as const }
        } else if (actionType === 'suspend') {
          return { ...vendor, status: 'suspended' as const }
        } else if (actionType === 'block') {
          return { ...vendor, status: 'blocked' as const }
        } else if (actionType === 'verify') {
          return { ...vendor, verified: true }
        }
      }
      return vendor
    })

    setVendors(updatedVendors)
    setActionDialogOpen(false)

    addNotification({
      id: Date.now().toString(),
      type: 'success',
      message: `Vendor ${actionType} successful`,
      timestamp: new Date(),
    })
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'approved':
        return 'success'
      case 'pending':
        return 'warning'
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
          Vendor Management
        </Typography>
        <Typography variant="body2" sx={{ color: 'text.secondary', mb: 3 }}>
          Approve, verify, and manage vendor accounts on the platform.
        </Typography>

        {/* Filters */}
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
              <TextField
                label="Search vendors"
                variant="outlined"
                size="small"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Business name or owner"
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
                <option value="pending">Pending</option>
                <option value="approved">Approved</option>
                <option value="suspended">Suspended</option>
                <option value="blocked">Blocked</option>
              </TextField>
            </Stack>
          </CardContent>
        </Card>

        {/* Vendors Table */}
        <Card>
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow sx={{ backgroundColor: '#F4F4F4' }}>
                  <TableCell sx={{ fontWeight: 600 }}>Business Name</TableCell>
                  <TableCell sx={{ fontWeight: 600 }}>Owner</TableCell>
                  <TableCell sx={{ fontWeight: 600 }}>GST</TableCell>
                  <TableCell align="right" sx={{ fontWeight: 600 }}>
                    Equipment
                  </TableCell>
                  <TableCell sx={{ fontWeight: 600 }}>Status</TableCell>
                  <TableCell align="center" sx={{ fontWeight: 600 }}>
                    Verified
                  </TableCell>
                  <TableCell sx={{ fontWeight: 600 }}>Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredVendors.map((vendor) => (
                  <TableRow key={vendor.id} hover>
                    <TableCell sx={{ fontWeight: 500 }}>{vendor.businessName}</TableCell>
                    <TableCell>{vendor.ownerName}</TableCell>
                    <TableCell>{vendor.gst}</TableCell>
                    <TableCell align="right">{vendor.equipmentCount}</TableCell>
                    <TableCell>
                      <Chip
                        label={vendor.status}
                        size="small"
                        color={getStatusColor(vendor.status) as any}
                        variant="outlined"
                      />
                    </TableCell>
                    <TableCell align="center">
                      {vendor.verified ? (
                        <Chip label="Verified" size="small" color="success" variant="filled" />
                      ) : (
                        <Chip label="Unverified" size="small" variant="outlined" />
                      )}
                    </TableCell>
                    <TableCell>
                      <Stack direction="row" spacing={1}>
                        {vendor.status === 'pending' && (
                          <>
                            <Button
                              size="small"
                              variant="outlined"
                              onClick={() => handleActionOpen(vendor, 'approve')}
                              color="success"
                            >
                              Approve
                            </Button>
                            <Button
                              size="small"
                              variant="outlined"
                              onClick={() => handleActionOpen(vendor, 'reject')}
                              color="error"
                            >
                              Reject
                            </Button>
                          </>
                        )}
                        {vendor.status === 'approved' && !vendor.verified && (
                          <Button
                            size="small"
                            variant="outlined"
                            onClick={() => handleActionOpen(vendor, 'verify')}
                            color="success"
                          >
                            Verify
                          </Button>
                        )}
                        {vendor.status === 'approved' && (
                          <Button
                            size="small"
                            variant="outlined"
                            onClick={() => handleActionOpen(vendor, 'suspend')}
                            sx={{ color: '#FF9800', borderColor: '#FF9800' }}
                          >
                            Suspend
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
            {actionType === 'approve'
              ? 'Approve Vendor'
              : actionType === 'reject'
                ? 'Reject Vendor'
                : actionType === 'verify'
                  ? 'Verify Vendor'
                  : actionType === 'suspend'
                    ? 'Suspend Vendor'
                    : 'Block Vendor'}
          </DialogTitle>
          <DialogContent>
            <Box sx={{ pt: 2 }}>
              <Typography variant="body2" sx={{ mb: 2, fontWeight: 500 }}>
                {selectedVendor?.businessName}
              </Typography>
              {(actionType === 'reject' || actionType === 'suspend') && (
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
            <Button
              onClick={handleActionConfirm}
              variant="contained"
              color={actionType === 'approve' || actionType === 'verify' ? 'success' : 'error'}
            >
              {actionType === 'approve'
                ? 'Approve'
                : actionType === 'reject'
                  ? 'Reject'
                  : actionType === 'verify'
                    ? 'Verify'
                    : actionType === 'suspend'
                      ? 'Suspend'
                      : 'Block'}
            </Button>
          </DialogActions>
        </Dialog>
      </Box>
    </MainLayout>
  )
}

export default VendorManagementPage
