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
  Tabs,
  Tab,
} from '@mui/material'
import CloudUploadIcon from '@mui/icons-material/CloudUpload'
import LocalOfferIcon from '@mui/icons-material/LocalOffer'
import MainLayout from '../components/MainLayout'
import useStore from '../store/useStore'

interface TabPanelProps {
  children?: React.ReactNode
  index: number
  value: number
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props
  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`promo-tabpanel-${index}`}
      aria-labelledby={`promo-tab-${index}`}
      {...other}
    >
      {value === index && <Box sx={{ py: 3 }}>{children}</Box>}
    </div>
  )
}

const PromotionsPage: React.FC = () => {
  const { addNotification } = useStore()
  const [tabValue, setTabValue] = useState(0)
  
  // Banner state
  const [bannerImageUrl, setBannerImageUrl] = useState('')
  const [isBannerLoading, setIsBannerLoading] = useState(false)
  const [isBannerFetching, setIsBannerFetching] = useState(false)

  // Offer state
  const [offerCode, setOfferCode] = useState('')
  const [discountPercent, setDiscountPercent] = useState('')
  const [offerDescription, setOfferDescription] = useState('')
  const [isOfferLoading, setIsOfferLoading] = useState(false)
  const [isOfferFetching, setIsOfferFetching] = useState(false)

  // Fetch settings on mount
  useEffect(() => {
    fetchAllSettings()
  }, [])

  const fetchAllSettings = async () => {
    fetchBannerSettings()
    fetchOfferSettings()
  }

  const fetchBannerSettings = async () => {
    try {
      setIsBannerFetching(true)
      const response = await fetch('https://new10-yk1r.onrender.com/api/settings')
      if (response.ok) {
        const data = await response.json()
        setBannerImageUrl(data.bannerImageUrl || '')
      }
    } catch (error) {
      console.error('Error fetching banner settings:', error)
    } finally {
      setIsBannerFetching(false)
    }
  }

  const fetchOfferSettings = async () => {
    try {
      setIsOfferFetching(true)
      const response = await fetch('https://new10-yk1r.onrender.com/api/offer')
      if (response.ok) {
        const data = await response.json()
        setOfferCode(data.code || '')
        setDiscountPercent(data.discountPercent ? data.discountPercent.toString() : '15')
        setOfferDescription(data.description || '')
      }
    } catch (error) {
      console.error('Error fetching offer settings:', error)
      // Set default values on error
      setOfferCode('RAPIDO15')
      setDiscountPercent('15')
      setOfferDescription('Get 15% off on heavy equipment rental!')
    } finally {
      setIsOfferFetching(false)
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
      setIsBannerLoading(true)
      const response = await fetch('https://new10-yk1r.onrender.com/api/settings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ bannerImageUrl }),
      })

      if (response.ok) {
        addNotification({
          id: Date.now().toString(),
          type: 'success',
          message: 'Banner updated! All users will see it instantly.',
          timestamp: new Date(),
        })
      } else {
        const errorData = await response.json()
        throw new Error(errorData.error || 'Failed to save banner')
      }
    } catch (error) {
      addNotification({
        id: Date.now().toString(),
        type: 'error',
        message: `Failed to update banner: ${error instanceof Error ? error.message : 'Unknown error'}`,
        timestamp: new Date(),
      })
    } finally {
      setIsBannerLoading(false)
    }
  }

  const handleSaveOffer = async () => {
    if (!offerCode.trim() || !discountPercent.trim()) {
      addNotification({
        id: Date.now().toString(),
        type: 'error',
        message: 'Please fill in coupon code and discount percentage',
        timestamp: new Date(),
      })
      return
    }

    const discount = parseInt(discountPercent)
    if (isNaN(discount) || discount < 0 || discount > 100) {
      addNotification({
        id: Date.now().toString(),
        type: 'error',
        message: 'Discount must be between 0 and 100',
        timestamp: new Date(),
      })
      return
    }

    try {
      setIsOfferLoading(true)
      const response = await fetch('https://new10-yk1r.onrender.com/api/offer', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          code: offerCode,
          discountPercent: discount,
          description: offerDescription,
        }),
      })

      if (response.ok) {
        addNotification({
          id: Date.now().toString(),
          type: 'success',
          message: 'Offer updated! Users will see the coupon immediately.',
          timestamp: new Date(),
        })
      } else {
        const errorData = await response.json()
        throw new Error(errorData.error || 'Failed to save offer')
      }
    } catch (error) {
      addNotification({
        id: Date.now().toString(),
        type: 'error',
        message: `Failed to update offer: ${error instanceof Error ? error.message : 'Unknown error'}`,
        timestamp: new Date(),
      })
    } finally {
      setIsOfferLoading(false)
    }
  }

  return (
    <MainLayout>
      <Box>
        <Typography variant="h4" sx={{ fontWeight: 700, mb: 1 }}>
          Promotions & Offers
        </Typography>
        <Typography variant="body2" sx={{ color: 'text.secondary', mb: 3 }}>
          Manage banner images and coupon offers. Changes apply instantly to all users.
        </Typography>

        <Tabs value={tabValue} onChange={(e, newValue) => setTabValue(newValue)} sx={{ mb: 3 }}>
          <Tab
            label={
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <CloudUploadIcon />
                Banner Image
              </Box>
            }
            id="promo-tab-0"
          />
          <Tab
            label={
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <LocalOfferIcon />
                Coupon Offer
              </Box>
            }
            id="promo-tab-1"
          />
        </Tabs>

        {/* Banner Tab */}
        <TabPanel value={tabValue} index={0}>
          {isBannerFetching ? (
            <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
              <CircularProgress />
            </Box>
          ) : (
            <Grid container spacing={3}>
              <Grid item xs={12}>
                <Card>
                  <CardContent>
                    <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
                      Heavy Equipment On Demand Banner
                    </Typography>
                    <Divider sx={{ mb: 3 }} />

                    <Stack spacing={2}>
                      <TextField
                        fullWidth
                        label="Banner Image URL"
                        placeholder="https://example.com/banner.jpg"
                        value={bannerImageUrl}
                        onChange={(e) => setBannerImageUrl(e.target.value)}
                        disabled={isBannerLoading}
                        helperText="Enter full URL of banner image (500x350px recommended)"
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
                              height: 200,
                              borderRadius: 2,
                              overflow: 'hidden',
                              border: '2px solid #e0e0e0',
                              backgroundColor: '#f5f5f5',
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

                      <Button
                        variant="contained"
                        size="large"
                        onClick={handleSaveBanner}
                        disabled={isBannerLoading || !bannerImageUrl.trim()}
                      >
                        {isBannerLoading ? <CircularProgress size={24} /> : 'Update Banner'}
                      </Button>
                    </Stack>
                  </CardContent>
                </Card>
              </Grid>
            </Grid>
          )}
        </TabPanel>

        {/* Offer Tab */}
        <TabPanel value={tabValue} index={1}>
          {isOfferFetching ? (
            <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
              <CircularProgress />
            </Box>
          ) : (
            <Grid container spacing={3}>
              <Grid item xs={12}>
                <Card>
                  <CardContent>
                    <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
                      Coupon & Discount Settings
                    </Typography>
                    <Divider sx={{ mb: 3 }} />

                    <Stack spacing={2}>
                      <TextField
                        fullWidth
                        label="Coupon Code"
                        placeholder="e.g., SUMMER20"
                        value={offerCode}
                        onChange={(e) => setOfferCode(e.target.value.toUpperCase())}
                        disabled={isOfferLoading}
                        helperText="The code users will enter to get discount"
                      />

                      <TextField
                        fullWidth
                        label="Discount Percentage (%)"
                        type="number"
                        placeholder="e.g., 20"
                        value={discountPercent}
                        onChange={(e) => setDiscountPercent(e.target.value)}
                        disabled={isOfferLoading}
                        inputProps={{ min: 0, max: 100 }}
                        helperText="Discount percentage (0-100)"
                      />

                      <TextField
                        fullWidth
                        label="Offer Description"
                        placeholder="e.g., Get 20% off on all equipment"
                        value={offerDescription}
                        onChange={(e) => setOfferDescription(e.target.value)}
                        disabled={isOfferLoading}
                        multiline
                        rows={2}
                        helperText="Short description shown to users"
                      />

                      {offerCode && discountPercent && (
                        <Alert severity="info" sx={{ my: 2 }}>
                          <strong>Preview:</strong> Coupon "<strong>{offerCode}</strong>" - <strong>{discountPercent}% off</strong>
                          {offerDescription && <> - {offerDescription}</>}
                        </Alert>
                      )}

                      <Button
                        variant="contained"
                        size="large"
                        onClick={handleSaveOffer}
                        disabled={isOfferLoading || !offerCode.trim() || !discountPercent.trim()}
                      >
                        {isOfferLoading ? <CircularProgress size={24} /> : 'Update Offer'}
                      </Button>
                    </Stack>
                  </CardContent>
                </Card>
              </Grid>
            </Grid>
          )}
        </TabPanel>
      </Box>
    </MainLayout>
  )
}

export default PromotionsPage
