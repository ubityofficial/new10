import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  Box,
  Container,
  Paper,
  TextField,
  Button,
  Typography,
  CircularProgress,
  InputAdornment,
  IconButton,
  Alert,
  Divider,
} from '@mui/material'
import { Visibility, VisibilityOff } from '@mui/icons-material'
import useStore from '../store/useStore'

const LoginPage: React.FC = () => {
  const navigate = useNavigate()
  const { setAuthUser, setAuthToken, setAuthLoading, addNotification } = useStore()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState('')

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setIsLoading(true)

    try {
      // Mock login - Replace with actual API call
      if (email === 'admin@new10.com' && password === 'admin123') {
        // Simulate API delay
        await new Promise((resolve) => setTimeout(resolve, 1500))

        const mockAdmin = {
          id: '1',
          email: 'admin@new10.com',
          name: 'Admin User',
          role: 'superadmin' as const,
          createdAt: new Date(),
          lastLogin: new Date(),
        }

        setAuthUser(mockAdmin)
        setAuthToken('mock-token-12345')
        addNotification({
          id: Date.now().toString(),
          type: 'success',
          message: 'Login successful!',
          timestamp: new Date(),
        })
        navigate('/')
      } else {
        setError('Invalid email or password')
        addNotification({
          id: Date.now().toString(),
          type: 'error',
          message: 'Invalid credentials',
          timestamp: new Date(),
        })
      }
    } catch (err) {
      setError('An error occurred. Please try again.')
      addNotification({
        id: Date.now().toString(),
        type: 'error',
        message: 'Login failed',
        timestamp: new Date(),
      })
    } finally {
      setIsLoading(false)
    }
  }

  const handleTogglePasswordVisibility = () => {
    setShowPassword(!showPassword)
  }

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'linear-gradient(135deg, #0F62FE 0%, #0043CE 100%)',
      }}
    >
      <Container component="main" maxWidth="sm">
        <Paper
          elevation={8}
          sx={{
            p: 4,
            display: 'flex',
            flexDirection: 'column',
            gap: 3,
            borderRadius: 2,
          }}
        >
          {/* Header */}
          <Box sx={{ textAlign: 'center' }}>
            <Typography
              variant="h4"
              sx={{
                fontWeight: 700,
                background: 'linear-gradient(135deg, #0F62FE 0%, #0043CE 100%)',
                backgroundClip: 'text',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                mb: 1,
              }}
            >
              New10 Admin
            </Typography>
            <Typography variant="body2" sx={{ color: 'text.secondary' }}>
              Equipment Booking Management Platform
            </Typography>
          </Box>

          <Divider />

          {/* Error Alert */}
          {error && <Alert severity="error">{error}</Alert>}

          {/* Demo Credentials Info */}
          <Alert severity="info" sx={{ fontSize: '0.85rem' }}>
            <Typography variant="caption" sx={{ display: 'block', fontWeight: 600, mb: 0.5 }}>
              Demo Credentials:
            </Typography>
            <Typography variant="caption" sx={{ display: 'block' }}>
              Email: admin@new10.com
            </Typography>
            <Typography variant="caption">Password: admin123</Typography>
          </Alert>

          {/* Form */}
          <form onSubmit={handleSubmit}>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
              {/* Email Field */}
              <TextField
                fullWidth
                label="Email Address"
                type="email"
                variant="outlined"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                disabled={isLoading}
                required
                placeholder="admin@new10.com"
              />

              {/* Password Field */}
              <TextField
                fullWidth
                label="Password"
                type={showPassword ? 'text' : 'password'}
                variant="outlined"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                disabled={isLoading}
                required
                placeholder="••••••••"
                InputProps={{
                  endAdornment: (
                    <InputAdornment position="end">
                      <IconButton
                        type="button"
                        onClick={handleTogglePasswordVisibility}
                        edge="end"
                        disabled={isLoading}
                      >
                        {showPassword ? <VisibilityOff /> : <Visibility />}
                      </IconButton>
                    </InputAdornment>
                  ),
                }}
              />

              {/* Submit Button */}
              <Button
                fullWidth
                variant="contained"
                size="large"
                type="submit"
                disabled={isLoading || !email || !password}
                sx={{
                  mt: 2,
                  py: 1.5,
                  fontWeight: 600,
                  fontSize: '1rem',
                  background: isLoading
                    ? 'linear-gradient(135deg, #0F62FE 0%, #0043CE 100%)'
                    : 'linear-gradient(135deg, #0F62FE 0%, #0043CE 100%)',
                }}
              >
                {isLoading ? (
                  <>
                    <CircularProgress size={20} sx={{ mr: 1, color: 'white' }} />
                    Logging in...
                  </>
                ) : (
                  'Login'
                )}
              </Button>
            </Box>
          </form>

          {/* Footer */}
          <Box sx={{ textAlign: 'center', mt: 2 }}>
            <Typography variant="caption" sx={{ color: 'text.secondary' }}>
              New10 Admin Dashboard v1.0.0
            </Typography>
          </Box>
        </Paper>
      </Container>
    </Box>
  )
}

export default LoginPage
