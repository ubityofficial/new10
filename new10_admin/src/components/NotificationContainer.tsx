import React, { useEffect } from 'react'
import { Snackbar, Alert } from '@mui/material'
import useStore from '../store/useStore'

const NotificationContainer: React.FC = () => {
  const { notifications, removeNotification } = useStore()

  useEffect(() => {
    notifications.forEach((notification) => {
      const timer = setTimeout(() => {
        removeNotification(notification.id)
      }, notification.duration || 5000)

      return () => clearTimeout(timer)
    })
  }, [notifications, removeNotification])

  return (
    <>
      {notifications.map((notification) => (
        <Snackbar
          key={notification.id}
          open={true}
          autoHideDuration={notification.duration || 5000}
          onClose={() => removeNotification(notification.id)}
          anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
        >
          <Alert
            onClose={() => removeNotification(notification.id)}
            severity={notification.type}
            sx={{ width: '100%' }}
          >
            {notification.message}
          </Alert>
        </Snackbar>
      ))}
    </>
  )
}

export default NotificationContainer
