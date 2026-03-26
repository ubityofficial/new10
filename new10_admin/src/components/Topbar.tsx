import React from 'react'
import {
  AppBar,
  Toolbar,
  Box,
  IconButton,
  TextField,
  InputAdornment,
  Badge,
  Menu,
  MenuItem,
  Typography,
  Divider,
} from '@mui/material'
import {
  Menu as MenuIcon,
  Search as SearchIcon,
  Notifications as NotificationsIcon,
  MoreVert as MoreVertIcon,
} from '@mui/icons-material'

interface TopbarProps {
  onMenuOpen: () => void
  onSearch?: (query: string) => void
}

const Topbar: React.FC<TopbarProps> = ({ onMenuOpen, onSearch }) => {
  const [notificationAnchorEl, setNotificationAnchorEl] = React.useState<null | HTMLElement>(null)
  const [moreAnchorEl, setMoreAnchorEl] = React.useState<null | HTMLElement>(null)
  const [searchQuery, setSearchQuery] = React.useState('')

  const handleNotificationOpen = (event: React.MouseEvent<HTMLElement>) => {
    setNotificationAnchorEl(event.currentTarget)
  }

  const handleNotificationClose = () => {
    setNotificationAnchorEl(null)
  }

  const handleMoreOpen = (event: React.MouseEvent<HTMLElement>) => {
    setMoreAnchorEl(event.currentTarget)
  }

  const handleMoreClose = () => {
    setMoreAnchorEl(null)
  }

  const handleSearch = (event: React.ChangeEvent<HTMLInputElement>) => {
    const query = event.target.value
    setSearchQuery(query)
    onSearch?.(query)
  }

  return (
    <>
      <AppBar
        position="sticky"
        sx={{
          backgroundColor: 'background.paper',
          color: 'text.primary',
          boxShadow: '0 1px 3px rgba(0, 0, 0, 0.12)',
        }}
      >
        <Toolbar sx={{ justifyContent: 'space-between' }}>
          {/* Left Section - Menu Button */}
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <IconButton
              onClick={onMenuOpen}
              sx={{ display: { sm: 'none' }, mr: 1 }}
              color="inherit"
            >
              <MenuIcon />
            </IconButton>
          </Box>

          {/* Center Section - Search */}
          <Box sx={{ flex: 1, mx: 2, display: { xs: 'none', sm: 'block' } }}>
            <TextField
              size="small"
              placeholder="Search users, vendors..."
              value={searchQuery}
              onChange={handleSearch}
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <SearchIcon sx={{ color: 'text.secondary' }} fontSize="small" />
                  </InputAdornment>
                ),
              }}
              sx={{
                width: '100%',
                maxWidth: 400,
                '& .MuiOutlinedInput-root': {
                  backgroundColor: 'background.default',
                  '&:hover': {
                    backgroundColor: '#EBEBEB',
                  },
                },
              }}
            />
          </Box>

          {/* Right Section - Icons */}
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <IconButton
              onClick={handleNotificationOpen}
              color="inherit"
              sx={{
                '&:hover': {
                  backgroundColor: 'action.hover',
                },
              }}
            >
              <Badge badgeContent={3} color="error">
                <NotificationsIcon />
              </Badge>
            </IconButton>

            <IconButton
              onClick={handleMoreOpen}
              color="inherit"
              sx={{
                '&:hover': {
                  backgroundColor: 'action.hover',
                },
              }}
            >
              <MoreVertIcon />
            </IconButton>
          </Box>
        </Toolbar>
      </AppBar>

      {/* Notification Menu */}
      <Menu
        anchorEl={notificationAnchorEl}
        open={Boolean(notificationAnchorEl)}
        onClose={handleNotificationClose}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
        transformOrigin={{ vertical: 'top', horizontal: 'right' }}
      >
        <MenuItem disabled>
          <Typography variant="body2" sx={{ fontWeight: 600 }}>
            Notifications
          </Typography>
        </MenuItem>
        <Divider />
        <MenuItem>New vendor registration pending approval</MenuItem>
        <MenuItem>User account flagged for suspicious activity</MenuItem>
        <MenuItem>Monthly revenue report is ready</MenuItem>
        <Divider />
        <MenuItem sx={{ justifyContent: 'center', py: 1 }}>
          <Typography variant="caption" sx={{ color: 'primary.main' }}>
            View all notifications
          </Typography>
        </MenuItem>
      </Menu>

      {/* More Menu */}
      <Menu
        anchorEl={moreAnchorEl}
        open={Boolean(moreAnchorEl)}
        onClose={handleMoreClose}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
        transformOrigin={{ vertical: 'top', horizontal: 'right' }}
      >
        <MenuItem onClick={handleMoreClose}>Help & Support</MenuItem>
        <MenuItem onClick={handleMoreClose}>Documentation</MenuItem>
        <Divider />
        <MenuItem onClick={handleMoreClose}>System Status</MenuItem>
        <MenuItem onClick={handleMoreClose}>About</MenuItem>
      </Menu>
    </>
  )
}

export default Topbar
