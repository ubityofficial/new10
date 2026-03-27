import React, { useState } from 'react'
import {
  Drawer,
  Box,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Divider,
  Typography,
  Collapse,
  Avatar,
  Menu,
  MenuItem,
  Button,
} from '@mui/material'
import {
  Dashboard as DashboardIcon,
  People as PeopleIcon,
  Business as BusinessIcon,
  History as HistoryIcon,
  Settings as SettingsIcon,
  Logout as LogoutIcon,
  ExpandLess as ExpandLessIcon,
  ExpandMore as ExpandMoreIcon,
  ChevronLeft as ChevronLeftIcon,
  ShoppingCart as ShoppingCartIcon,
  LocalOffer as LocalOfferIcon,
} from '@mui/icons-material'
import { useNavigate, useLocation } from 'react-router-dom'
import useStore from '../store/useStore'

const DRAWER_WIDTH = 280

interface SidebarProps {
  open: boolean
  onClose: () => void
}

const Sidebar: React.FC<SidebarProps> = ({ open, onClose }) => {
  const navigate = useNavigate()
  const location = useLocation()
  const { auth, logout, addNotification } = useStore()
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null)
  const [expandedMenu, setExpandedMenu] = useState<string | null>(null)

  const handleProfileMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget)
  }

  const handleProfileMenuClose = () => {
    setAnchorEl(null)
  }

  const handleLogout = () => {
    logout()
    handleProfileMenuClose()
    addNotification({
      id: Date.now().toString(),
      type: 'success',
      message: 'Logged out successfully',
      timestamp: new Date(),
    })
    navigate('/login')
  }

  const handleMenuExpand = (menu: string) => {
    setExpandedMenu(expandedMenu === menu ? null : menu)
  }

  const navigationItems = [
    {
      label: 'Dashboard',
      icon: DashboardIcon,
      path: '/',
    },
    {
      label: 'Manage Services',
      icon: ShoppingCartIcon,
      path: '/services',
    },
    {
      label: 'Promotions & Offers',
      icon: LocalOfferIcon,
      path: '/promotions',
    },
    {
      label: 'User Management',
      icon: PeopleIcon,
      path: '/users',
    },
    {
      label: 'Vendor Management',
      icon: BusinessIcon,
      path: '/vendors',
    },
    {
      label: 'Activity Logs',
      icon: HistoryIcon,
      path: '/logs',
    },
    {
      label: 'Settings',
      icon: SettingsIcon,
      path: '/settings',
    },
  ]

  const sidebarContent = (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      {/* Header */}
      <Box sx={{ p: 2, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <Typography
          variant="h6"
          sx={{
            fontWeight: 700,
            background: 'linear-gradient(135deg, #0F62FE 0%, #0043CE 100%)',
            backgroundClip: 'text',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
          }}
        >
          New10 Admin
        </Typography>
      </Box>

      <Divider />

      {/* User Profile Section */}
      <Box sx={{ p: 2 }}>
        <Button
          fullWidth
          onClick={handleProfileMenuOpen}
          sx={{
            textTransform: 'none',
            justifyContent: 'flex-start',
            color: 'text.primary',
            '&:hover': {
              backgroundColor: 'action.hover',
            },
          }}
        >
          <Avatar
            sx={{
              width: 40,
              height: 40,
              mr: 1,
              background: 'linear-gradient(135deg, #0F62FE 0%, #0043CE 100%)',
              fontSize: '1rem',
              fontWeight: 600,
            }}
          >
            {auth.user?.name.charAt(0).toUpperCase()}
          </Avatar>
          <Box sx={{ textAlign: 'left', flex: 1 }}>
            <Typography variant="body2" sx={{ fontWeight: 600 }}>
              {auth.user?.name || 'Admin'}
            </Typography>
            <Typography variant="caption" sx={{ color: 'text.secondary' }}>
              {auth.user?.role || 'Administrator'}
            </Typography>
          </Box>
        </Button>
        <Menu
          anchorEl={anchorEl}
          open={Boolean(anchorEl)}
          onClose={handleProfileMenuClose}
          anchorOrigin={{ vertical: 'bottom', horizontal: 'left' }}
          transformOrigin={{ vertical: 'top', horizontal: 'left' }}
        >
          <MenuItem disabled>
            <Typography variant="body2">{auth.user?.email}</Typography>
          </MenuItem>
          <Divider />
          <MenuItem onClick={() => navigate('/settings')}>
            <SettingsIcon sx={{ mr: 1 }} /> Settings
          </MenuItem>
          <MenuItem onClick={handleLogout}>
            <LogoutIcon sx={{ mr: 1 }} /> Logout
          </MenuItem>
        </Menu>
      </Box>

      <Divider />

      {/* Navigation Items */}
      <List sx={{ flex: 1, overflow: 'auto', py: 1 }}>
        {navigationItems.map((item) => {
          const Icon = item.icon
          const isActive = location.pathname === item.path
          return (
            <ListItem key={item.path} disablePadding sx={{ mb: 0.5 }}>
              <ListItemButton
                onClick={() => {
                  navigate(item.path)
                  if (typeof window !== 'undefined' && window.innerWidth < 900) {
                    onClose()
                  }
                }}
                sx={{
                  mx: 1,
                  borderRadius: 1,
                  backgroundColor: isActive ? 'rgba(15, 98, 254, 0.1)' : 'transparent',
                  color: isActive ? 'primary.main' : 'text.secondary',
                  fontWeight: isActive ? 600 : 500,
                  transition: 'all 0.2s ease',
                  '&:hover': {
                    backgroundColor: isActive ? 'rgba(15, 98, 254, 0.1)' : 'action.hover',
                    color: 'primary.main',
                  },
                }}
              >
                <ListItemIcon
                  sx={{
                    minWidth: 40,
                    color: isActive ? 'primary.main' : 'inherit',
                  }}
                >
                  <Icon fontSize="small" />
                </ListItemIcon>
                <ListItemText
                  primary={item.label}
                  primaryTypographyProps={{
                    variant: 'body2',
                    sx: { fontSize: '0.9rem' },
                  }}
                />
              </ListItemButton>
            </ListItem>
          )
        })}
      </List>

      <Divider />

      {/* Footer */}
      <Box sx={{ p: 2 }}>
        <Typography variant="caption" sx={{ color: 'text.secondary', display: 'block' }}>
          New10 Admin Panel
        </Typography>
        <Typography variant="caption" sx={{ color: 'text.secondary', display: 'block' }}>
          v1.0.0
        </Typography>
      </Box>
    </Box>
  )

  return (
    <>
      {/* Mobile Drawer */}
      <Drawer
        anchor="left"
        open={open}
        onClose={onClose}
        sx={{
          display: { xs: 'block', sm: 'none' },
          '& .MuiDrawer-paper': {
            boxSizing: 'border-box',
            width: DRAWER_WIDTH,
          },
        }}
      >
        {sidebarContent}
      </Drawer>

      {/* Desktop Drawer */}
      <Drawer
        variant="permanent"
        sx={{
          display: { xs: 'none', sm: 'block' },
          width: DRAWER_WIDTH,
          flexShrink: 0,
          '& .MuiDrawer-paper': {
            width: DRAWER_WIDTH,
            boxSizing: 'border-box',
            backgroundColor: 'background.paper',
          },
        }}
      >
        {sidebarContent}
      </Drawer>
    </>
  )
}

export default Sidebar
