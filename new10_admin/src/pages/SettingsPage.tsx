import React, { useState, useEffect } from 'react'
import {
  Box,
  Card,
  CardContent,
  Typography,
  TextField,
  Button,
  Stack,
  Divider,
  Switch,
  FormControlLabel,
  Grid,
} from '@mui/material'
import MainLayout from '../components/MainLayout'
import useStore from '../store/useStore'

const SettingsPage: React.FC = () => {
  const { auth, addNotification } = useStore()
  const [settings, setSettings] = useState({
    currentPassword: '',
    newPassword: '',
    confirmPassword: '',
    emailNotifications: true,
    smsNotifications: false,
    suspendUserNotifications: true,
    vendorApprovalNotifications: true,
    fraudAlertNotifications: true,
    platformMaintenanceNotifications: true,
    maintenanceMode: false,
    commissionsEnabled: true,
  })

  // Banner Image Settings
  const [bannerImageUrl, setBannerImageUrl] = useState('')
  const [isLoadingBanner, setIsLoadingBanner] = useState(false)

  // Fetch banner settings on component mount
  useEffect(() => {
    fetchBannerSettings()
  }, [])

  const fetchBannerSettings = async () => {
    try {
      setIsLoadingBanner(true)
      const response = await fetch('https://new10-yk1r.onrender.com/api/settings')
      if (response.ok) {
        const data = await response.json()
        setBannerImageUrl(data.bannerImageUrl || '')
      }
    } catch (error) {
      console.error('Error fetching banner settings:', error)
    } finally {
      setIsLoadingBanner(false)
    }
  }

  const handleBannerImageSave = async () => {
    if (!bannerImageUrl.trim()) {
      addNotification({
        id: Date.now().toString(),
        type: 'error',
        message: 'Please enter a valid image URL',
        timestamp: new Date(),
      })
      return
    }

    try {
      setIsLoadingBanner(true)
      const response = await fetch('https://new10-yk1r.onrender.com/api/settings', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ bannerImageUrl }),
      })

      if (response.ok) {
        addNotification({
          id: Date.now().toString(),
          type: 'success',
          message: 'Banner image URL updated successfully',
          timestamp: new Date(),
        })
      } else {
        const errorData = await response.json()
        throw new Error(errorData.error || 'Failed to update banner image URL')
      }
    } catch (error) {
      addNotification({
        id: Date.now().toString(),
        type: 'error',
        message: `Error updating banner settings: ${error instanceof Error ? error.message : 'Unknown error'}`,
        timestamp: new Date(),
      })
    } finally {
      setIsLoadingBanner(false)
    }
  }

  const handleSettingChange = (key: string, value: any) => {
    setSettings({
      ...settings,
      [key]: value,
    })
  }

  const handlePasswordChange = () => {
    if (!settings.currentPassword || !settings.newPassword || !settings.confirmPassword) {
      addNotification({
        id: Date.now().toString(),
        type: 'error',
        message: 'Please fill all password fields',
        timestamp: new Date(),
      })
      return
    }

    if (settings.newPassword !== settings.confirmPassword) {
      addNotification({
        id: Date.now().toString(),
        type: 'error',
        message: 'New passwords do not match',
        timestamp: new Date(),
      })
      return
    }

    addNotification({
      id: Date.now().toString(),
      type: 'success',
      message: 'Password changed successfully',
      timestamp: new Date(),
    })

    setSettings({
      ...settings,
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
    })
  }

  const handleNotificationsSave = () => {
    addNotification({
      id: Date.now().toString(),
      type: 'success',
      message: 'Notification preferences updated',
      timestamp: new Date(),
    })
  }

  const handlePlatformSettingsSave = () => {
    addNotification({
      id: Date.now().toString(),
      type: 'success',
      message: 'Platform settings updated',
      timestamp: new Date(),
    })
  }

  return (
    <MainLayout>
      <Box>
        <Typography variant="h4" sx={{ fontWeight: 700, mb: 1 }}>
          Settings
        </Typography>
        <Typography variant="body2" sx={{ color: 'text.secondary', mb: 3 }}>
          Manage your account and platform settings.
        </Typography>

        <Grid container spacing={3}>
          {/* Account Settings */}
          <Grid item xs={12} md={6}>
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
                  Account Settings
                </Typography>
                <Divider sx={{ mb: 2 }} />

                <Stack spacing={2} sx={{ mb: 3 }}>
                  <TextField
                    fullWidth
                    label="Full Name"
                    variant="outlined"
                    value={auth.user?.name || ''}
                    disabled
                  />
                  <TextField
                    fullWidth
                    label="Email Address"
                    variant="outlined"
                    value={auth.user?.email || ''}
                    disabled
                  />
                  <TextField
                    fullWidth
                    label="Role"
                    variant="outlined"
                    value={auth.user?.role || 'Administrator'}
                    disabled
                  />
                </Stack>

                <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 2 }}>
                  Change Password
                </Typography>

                <Stack spacing={2}>
                  <TextField
                    fullWidth
                    type="password"
                    label="Current Password"
                    variant="outlined"
                    value={settings.currentPassword}
                    onChange={(e) => handleSettingChange('currentPassword', e.target.value)}
                  />
                  <TextField
                    fullWidth
                    type="password"
                    label="New Password"
                    variant="outlined"
                    value={settings.newPassword}
                    onChange={(e) => handleSettingChange('newPassword', e.target.value)}
                  />
                  <TextField
                    fullWidth
                    type="password"
                    label="Confirm New Password"
                    variant="outlined"
                    value={settings.confirmPassword}
                    onChange={(e) => handleSettingChange('confirmPassword', e.target.value)}
                  />
                  <Button
                    fullWidth
                    variant="contained"
                    onClick={handlePasswordChange}
                    sx={{ mt: 1 }}
                  >
                    Update Password
                  </Button>
                </Stack>
              </CardContent>
            </Card>
          </Grid>

          {/* Notification Settings */}
          <Grid item xs={12} md={6}>
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
                  Notifications
                </Typography>
                <Divider sx={{ mb: 2 }} />

                <Stack spacing={1.5} sx={{ mb: 3 }}>
                  <FormControlLabel
                    control={
                      <Switch
                        checked={settings.emailNotifications}
                        onChange={(e) => handleSettingChange('emailNotifications', e.target.checked)}
                      />
                    }
                    label="Email Notifications"
                  />
                  <FormControlLabel
                    control={
                      <Switch
                        checked={settings.smsNotifications}
                        onChange={(e) => handleSettingChange('smsNotifications', e.target.checked)}
                      />
                    }
                    label="SMS Notifications"
                  />
                </Stack>

                <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 2 }}>
                  Notification Types
                </Typography>

                <Stack spacing={1.5} sx={{ mb: 3 }}>
                  <FormControlLabel
                    control={
                      <Switch
                        checked={settings.suspendUserNotifications}
                        onChange={(e) => handleSettingChange('suspendUserNotifications', e.target.checked)}
                      />
                    }
                    label="User Suspend/Block Actions"
                  />
                  <FormControlLabel
                    control={
                      <Switch
                        checked={settings.vendorApprovalNotifications}
                        onChange={(e) => handleSettingChange('vendorApprovalNotifications', e.target.checked)}
                      />
                    }
                    label="Vendor Approvals"
                  />
                  <FormControlLabel
                    control={
                      <Switch
                        checked={settings.fraudAlertNotifications}
                        onChange={(e) => handleSettingChange('fraudAlertNotifications', e.target.checked)}
                      />
                    }
                    label="Fraud Alerts"
                  />
                  <FormControlLabel
                    control={
                      <Switch
                        checked={settings.platformMaintenanceNotifications}
                        onChange={(e) => handleSettingChange('platformMaintenanceNotifications', e.target.checked)}
                      />
                    }
                    label="Platform Maintenance"
                  />
                </Stack>

                <Button
                  fullWidth
                  variant="contained"
                  onClick={handleNotificationsSave}
                >
                  Save Notification Settings
                </Button>
              </CardContent>
            </Card>
          </Grid>

          {/* Platform Settings */}
          <Grid item xs={12}>
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
                  Platform Settings
                </Typography>
                <Divider sx={{ mb: 2 }} />

                <Grid container spacing={3}>
                  <Grid item xs={12} md={6}>
                    <Stack spacing={2}>
                      <FormControlLabel
                        control={
                          <Switch
                            checked={settings.maintenanceMode}
                            onChange={(e) => handleSettingChange('maintenanceMode', e.target.checked)}
                          />
                        }
                        label={
                          <Box>
                            <Typography variant="body2" sx={{ fontWeight: 500 }}>
                              Maintenance Mode
                            </Typography>
                            <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                              Disable platform access for all users during maintenance
                            </Typography>
                          </Box>
                        }
                      />
                      <TextField
                        fullWidth
                        label="Maintenance Message"
                        multiline
                        rows={3}
                        placeholder="Message shown to users when platform is under maintenance"
                        disabled={!settings.maintenanceMode}
                      />
                    </Stack>
                  </Grid>

                  <Grid item xs={12} md={6}>
                    <Stack spacing={2}>
                      <FormControlLabel
                        control={
                          <Switch
                            checked={settings.commissionsEnabled}
                            onChange={(e) => handleSettingChange('commissionsEnabled', e.target.checked)}
                          />
                        }
                        label={
                          <Box>
                            <Typography variant="body2" sx={{ fontWeight: 500 }}>
                              Commission Calculations
                            </Typography>
                            <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                              Enable or disable automatic commission calculations
                            </Typography>
                          </Box>
                        }
                      />
                      <TextField
                        fullWidth
                        type="number"
                        label="Commission Percentage (%)"
                        variant="outlined"
                        defaultValue={10}
                        inputProps={{ step: 0.1, min: 0, max: 100 }}
                      />
                    </Stack>
                  </Grid>
                </Grid>

                <Divider sx={{ my: 2 }} />

                <Button
                  fullWidth
                  variant="contained"
                  onClick={handlePlatformSettingsSave}
                >
                  Save Platform Settings
                </Button>
              </CardContent>
            </Card>
          </Grid>

          {/* Home Page Banner Settings */}
          <Grid item xs={12}>
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
                  Home Page Banner Settings
                </Typography>
                <Divider sx={{ mb: 2 }} />

                <Grid container spacing={3}>
                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      label="Banner Image URL"
                      variant="outlined"
                      placeholder="https://example.com/image.jpg"
                      value={bannerImageUrl}
                      onChange={(e) => setBannerImageUrl(e.target.value)}
                      disabled={isLoadingBanner}
                      helperText="Enter the full URL of the image to display on the Heavy Equipment On Demand card"
                    />
                  </Grid>

                  {bannerImageUrl && (
                    <Grid item xs={12}>
                      <Box
                        sx={{
                          width: '100%',
                          height: 200,
                          borderRadius: 2,
                          overflow: 'hidden',
                          border: '1px solid #e0e0e0',
                        }}
                      >
                        <img
                          src={bannerImageUrl}
                          alt="Banner Preview"
                          style={{
                            width: '100%',
                            height: '100%',
                            objectFit: 'cover',
                          }}
                          onError={(e) => {
                            (e.target as any).src = ''
                          }}
                        />
                      </Box>
                    </Grid>
                  )}

                  <Grid item xs={12}>
                    <Button
                      fullWidth
                      variant="contained"
                      onClick={handleBannerImageSave}
                      disabled={isLoadingBanner || !bannerImageUrl.trim()}
                    >
                      {isLoadingBanner ? 'Updating...' : 'Update Banner Image'}
                    </Button>
                  </Grid>
                </Grid>
              </CardContent>
            </Card>
          </Grid>

          {/* System Information */}
          <Grid item xs={12}>
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
                  System Information
                </Typography>
                <Divider sx={{ mb: 2 }} />

                <Grid container spacing={2}>
                  <Grid item xs={12} sm={6} md={3}>
                    <Typography variant="body2" sx={{ color: 'text.secondary', mb: 0.5 }}>
                      Platform Version
                    </Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600 }}>
                      v1.0.0
                    </Typography>
                  </Grid>
                  <Grid item xs={12} sm={6} md={3}>
                    <Typography variant="body2" sx={{ color: 'text.secondary', mb: 0.5 }}>
                      API Version
                    </Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600 }}>
                      v1.0
                    </Typography>
                  </Grid>
                  <Grid item xs={12} sm={6} md={3}>
                    <Typography variant="body2" sx={{ color: 'text.secondary', mb: 0.5 }}>
                      Database Status
                    </Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600, color: 'success.main' }}>
                      Connected
                    </Typography>
                  </Grid>
                  <Grid item xs={12} sm={6} md={3}>
                    <Typography variant="body2" sx={{ color: 'text.secondary', mb: 0.5 }}>
                      Server Status
                    </Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600, color: 'success.main' }}>
                      Active
                    </Typography>
                  </Grid>
                </Grid>
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      </Box>
    </MainLayout>
  )
}

export default SettingsPage
