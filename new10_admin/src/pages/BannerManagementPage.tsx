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
  Grid,
  CircularProgress,
  Alert,
} from '@mui/material'
import CloudUploadIcon from '@mui/icons-material/CloudUpload'
import MainLayout from '../components/MainLayout'
import useStore from '../store/useStore'

const BannerManagementPage: React.FC = () => {
  const { addNotification } = useStore()
  const [bannerImageUrl, setBannerImageUrl] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [isFetching, setIsFetching] = useState(false)

  // Fetch current banner settings on mount
  useEffect(() => {
    fetchBannerSettings()
  }, [])

  const fetchBannerSettings = async () => {
    try {
      setIsFetching(true)
      const response = await fetch('https://new10-yk1r.onrender.com/api/settings')
      if (response.ok) {
        const data = await response.json()
        setBannerImageUrl(data.bannerImageUrl || '')
      }
    } catch (error) {
      console.error('Error fetching banner settings:', error)
      addNotification({
        id: Date.now().toString(),
        type: 'error',
        message: 'Failed to fetch current banner settings',
        timestamp: new Date(),
      })
    } finally {
      setIsFetching(false)
    }
  }

  const handleSaveBanner = async () => {
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
      setIsLoading(true)
      const response = await fetch('https://new10-yk1r.onrender.com/api/settings', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ bannerImageUrl }),
      })

      if (response.ok) {
        const data = await response.json()
        addNotification({
          id: Date.now().toString(),
          type: 'success',
          message: 'Banner image updated successfully! All users will see the new banner.',
          timestamp: new Date(),
        })
      } else {
        throw new Error('Failed to save banner')
      }
    } catch (error) {
      addNotification({
        id: Date.now().toString(),
        type: 'error',
        message: 'Failed to update banner image. Please try again.',
        timestamp: new Date(),
      })
    } finally {
      setIsLoading(false)
    }
  }

  const handleRefresh = () => {
    fetchBannerSettings()
    addNotification({
      id: Date.now().toString(),
      type: 'info',
      message: 'Banner settings refreshed',
      timestamp: new Date(),
    })
  }

  return (
    <MainLayout>
      <Box>
        <Typography variant="h4" sx={{ fontWeight: 700, mb: 1 }}>
          Banner Management
        </Typography>
        <Typography variant="body2" sx={{ color: 'text.secondary', mb: 3 }}>
          Update the home page banner image. Changes apply instantly to all users.
        </Typography>

        <Grid container spacing={3}>
          {/* Banner URL Input */}
          <Grid item xs={12}>
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
                  <CloudUploadIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                  Banner Image URL
                </Typography>
                <Divider sx={{ mb: 3 }} />

                <Stack spacing={2}>
                  <TextField
                    fullWidth
                    label="Image URL"
                    placeholder="https://example.com/banner.jpg"
                    value={bannerImageUrl}
                    onChange={(e) => setBannerImageUrl(e.target.value)}
                    disabled={isLoading}
                    helperText="Enter the full URL of the image to display on the Heavy Equipment On Demand card. Recommended: 500x350px or similar aspect ratio."
                    multiline
                    rows={2}
                  />

                  {bannerImageUrl && (
                    <Box>
                      <Typography variant="subtitle2" sx={{ mb: 1, fontWeight: 600 }}>
                        Preview
                      </Typography>
                      <Box
                        sx={{
                          width: '100%',
                          height: 250,
                          borderRadius: 2,
                          overflow: 'hidden',
                          border: '2px solid #e0e0e0',
                          backgroundColor: '#f5f5f5',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
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
                    </Box>
                  )}

                  <Stack direction="row" spacing={2}>
                    <Button
                      variant="contained"
                      size="large"
                      onClick={handleSaveBanner}
                      disabled={isLoading || !bannerImageUrl.trim()}
                      sx={{ flex: 1 }}
                    >
                      {isLoading ? <CircularProgress size={24} /> : 'Update Banner'}
                    </Button>
                    <Button
                      variant="outlined"
                      size="large"
                      onClick={handleRefresh}
                      disabled={isFetching}
                    >
                      Refresh
                    </Button>
                  </Stack>
                </Stack>
              </CardContent>
            </Card>
          </Grid>

          {/* Quick Links */}
          <Grid item xs={12}>
            <Card sx={{ backgroundColor: '#f5f9ff' }}>
              <CardContent>
                <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
                  Quick Tips
                </Typography>
                <Stack spacing={1}>
                  <Typography variant="body2">
                    ✓ Use high-quality images for better appearance
                  </Typography>
                  <Typography variant="body2">
                    ✓ Image size: 500×350px or wider aspect ratio
                  </Typography>
                  <Typography variant="body2">
                    ✓ Use images with text overlay for professional look
                  </Typography>
                  <Typography variant="body2">
                    ✓ Changes apply instantly to all users' home pages
                  </Typography>
                  <Typography variant="body2">
                    ✓ Recommended: Use CDN links for faster loading (Cloudinary, Imgix, etc.)
                  </Typography>
                </Stack>
              </CardContent>
            </Card>
          </Grid>

          {/* Current Banner Info */}
          {isFetching ? (
            <Grid item xs={12}>
              <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
                <CircularProgress />
              </Box>
            </Grid>
          ) : bannerImageUrl ? (
            <Grid item xs={12}>
              <Alert severity="success">
                Current banner is active and visible to all users
              </Alert>
            </Grid>
          ) : (
            <Grid item xs={12}>
              <Alert severity="info">
                No banner image set. Add one to display the Heavy Equipment On Demand banner.
              </Alert>
            </Grid>
          )}
        </Grid>
      </Box>
    </MainLayout>
  )
}

export default BannerManagementPage
