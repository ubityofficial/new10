import React, { ReactNode } from 'react'
import { CssBaseline, ThemeProvider } from '@mui/material'
import theme from './theme'

const Layout: React.FC<{ children: ReactNode }> = ({ children }) => {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      {children}
    </ThemeProvider>
  )
}

export default Layout
