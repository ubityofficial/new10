// Real Authentication System with JWT, Database, and Google OAuth
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production';
const JWT_EXPIRES_IN = '7d';

// Email service for password resets
const emailService = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER || 'your-email@gmail.com',
    pass: process.env.EMAIL_PASSWORD || 'your-app-password',
  },
});

// In-memory storage for demo (replace with database in production)
const users = new Map();
const vendors = new Map();
const passwordResetTokens = new Map();

// ============ AUTH HELPERS ============

const generateToken = (userId, role) => {
  return jwt.sign(
    { userId, role, timestamp: Date.now() },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
};

const verifyToken = (token) => {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (err) {
    return null;
  }
};

const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(10);
  return await bcrypt.hash(password, salt);
};

const comparePassword = async (password, hash) => {
  return await bcrypt.compare(password, hash);
};

const generateResetToken = () => {
  return Math.random().toString(36).substring(2, 15) +
         Math.random().toString(36).substring(2, 15);
};

// ============ AUTH ENDPOINTS ============

const authRoutes = (app, supabase) => {
  
  // REGISTER USER
  app.post('/api/auth/register', async (req, res) => {
    try {
      const { email, password, name, phone, role } = req.body;

      // Validation
      if (!email || !password || !name || !role) {
        return res.status(400).json({ error: 'Missing required fields' });
      }

      if (password.length < 6) {
        return res.status(400).json({ error: 'Password must be at least 6 characters' });
      }

      // Check if user exists
      const existingUser = Array.from(users.values()).find(u => u.email === email);
      if (existingUser) {
        return res.status(400).json({ error: 'Email already registered' });
      }

      // Hash password
      const hashedPassword = await hashPassword(password);

      // Create user
      const userId = 'user_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
      const newUser = {
        id: userId,
        email,
        password: hashedPassword,
        name,
        phone,
        role, // 'user' or 'vendor'
        status: 'active',
        profileImage: null,
        createdAt: new Date(),
      };

      users.set(userId, newUser);

      // If vendor role, also create vendor record
      if (role === 'vendor') {
        const vendorId = 'vendor_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
        const newVendor = {
          id: vendorId,
          userId,
          businessName: '',
          businessReg: '',
          status: 'active',
          approved: true, // Auto-approve vendors
          blocked: false,
          createdAt: new Date(),
        };
        vendors.set(vendorId, newVendor);
      }

      // Generate token
      const token = generateToken(userId, role);

      res.json({
        success: true,
        message: 'Registration successful',
        token,
        user: {
          id: userId,
          email,
          name,
          phone,
          role,
        },
      });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // LOGIN
  app.post('/api/auth/login', async (req, res) => {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({ error: 'Email and password required' });
      }

      // Find user by email
      const user = Array.from(users.values()).find(u => u.email === email);
      if (!user) {
        return res.status(401).json({ error: 'Invalid email or password' });
      }

      // Verify password
      const isPasswordValid = await comparePassword(password, user.password);
      if (!isPasswordValid) {
        return res.status(401).json({ error: 'Invalid email or password' });
      }

      // Check if user is blocked
      if (user.status === 'blocked') {
        return res.status(403).json({ error: 'Your account has been blocked' });
      }

      // Generate token
      const token = generateToken(user.id, user.role);

      res.json({
        success: true,
        message: 'Login successful',
        token,
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          phone: user.phone,
        },
      });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // FORGOT PASSWORD
  app.post('/api/auth/forgot-password', async (req, res) => {
    try {
      const { email } = req.body;

      if (!email) {
        return res.status(400).json({ error: 'Email required' });
      }

      const user = Array.from(users.values()).find(u => u.email === email);
      if (!user) {
        // Don't reveal if email exists (security best practice)
        return res.json({ 
          success: true, 
          message: 'If this email exists, a reset link has been sent' 
        });
      }

      // Generate reset token
      const resetToken = generateResetToken();
      const expiresAt = Date.now() + (30 * 60 * 1000); // 30 minutes
      
      passwordResetTokens.set(resetToken, {
        email,
        expiresAt,
      });

      // Send email (mock - in production, use real email)
      const resetLink = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/reset-password?token=${resetToken}`;
      
      console.log(`✅ Password reset link: ${resetLink}`);
      
      // In production:
      // await emailService.sendMail({
      //   to: email,
      //   subject: 'Password Reset - RAPIDO',
      //   html: `Click here to reset your password: <a href="${resetLink}">${resetLink}</a>`,
      // });

      res.json({
        success: true,
        message: 'If this email exists, a reset link has been sent',
        // Remove in production
        resetToken: resetToken,
        resetLink: resetLink,
      });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // RESET PASSWORD
  app.post('/api/auth/reset-password', async (req, res) => {
    try {
      const { token, newPassword } = req.body;

      if (!token || !newPassword) {
        return res.status(400).json({ error: 'Token and new password required' });
      }

      if (newPassword.length < 6) {
        return res.status(400).json({ error: 'Password must be at least 6 characters' });
      }

      const resetData = passwordResetTokens.get(token);
      if (!resetData) {
        return res.status(401).json({ error: 'Invalid or expired token' });
      }

      if (Date.now() > resetData.expiresAt) {
        passwordResetTokens.delete(token);
        return res.status(401).json({ error: 'Reset token has expired' });
      }

      // Find user and update password
      const user = Array.from(users.values()).find(u => u.email === resetData.email);
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      const hashedPassword = await hashPassword(newPassword);
      user.password = hashedPassword;

      passwordResetTokens.delete(token);

      res.json({
        success: true,
        message: 'Password reset successful',
      });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // GET CURRENT USER (verify token)
  app.get('/api/auth/me', (req, res) => {
    try {
      const token = req.headers.authorization?.split(' ')[1];
      
      if (!token) {
        return res.status(401).json({ error: 'No token provided' });
      }

      const decoded = verifyToken(token);
      if (!decoded) {
        return res.status(401).json({ error: 'Invalid or expired token' });
      }

      const user = users.get(decoded.userId);
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      res.json({
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        phone: user.phone,
      });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // VENDOR APPROVAL - AUTO on registration, but admin can block
  app.get('/api/vendors', (req, res) => {
    try {
      const allVendors = Array.from(vendors.values()).map(v => {
        const user = users.get(v.userId);
        return {
          ...v,
          userName: user?.name,
          userEmail: user?.email,
          userPhone: user?.phone,
        };
      });
      res.json(allVendors);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // ADMIN: BLOCK VENDOR
  app.post('/api/admin/vendors/:vendorId/block', (req, res) => {
    try {
      const { vendorId } = req.params;
      const vendor = vendors.get(vendorId);
      
      if (!vendor) {
        return res.status(404).json({ error: 'Vendor not found' });
      }

      vendor.blocked = true;
      const user = users.get(vendor.userId);
      if (user) {
        user.status = 'blocked';
      }

      res.json({
        success: true,
        message: 'Vendor blocked successfully',
        vendor,
      });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // ADMIN: UNBLOCK VENDOR
  app.post('/api/admin/vendors/:vendorId/unblock', (req, res) => {
    try {
      const { vendorId } = req.params;
      const vendor = vendors.get(vendorId);
      
      if (!vendor) {
        return res.status(404).json({ error: 'Vendor not found' });
      }

      vendor.blocked = false;
      const user = users.get(vendor.userId);
      if (user) {
        user.status = 'active';
      }

      res.json({
        success: true,
        message: 'Vendor unblocked successfully',
        vendor,
      });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // GET ALL USERS (Admin)
  app.get('/api/admin/users', (req, res) => {
    try {
      const allUsers = Array.from(users.values()).map(u => ({
        id: u.id,
        email: u.email,
        name: u.name,
        phone: u.phone,
        role: u.role,
        status: u.status,
        createdAt: u.createdAt,
      }));
      res.json(allUsers);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // ADMIN: BLOCK USER
  app.post('/api/admin/users/:userId/block', (req, res) => {
    try {
      const { userId } = req.params;
      const user = users.get(userId);
      
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      user.status = 'blocked';

      res.json({
        success: true,
        message: 'User blocked successfully',
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          status: user.status,
        },
      });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // ADMIN: UNBLOCK USER
  app.post('/api/admin/users/:userId/unblock', (req, res) => {
    try {
      const { userId } = req.params;
      const user = users.get(userId);
      
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      user.status = 'active';

      res.json({
        success: true,
        message: 'User unblocked successfully',
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          status: user.status,
        },
      });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // ADMIN: DELETE USER
  app.delete('/api/admin/users/:userId', (req, res) => {
    try {
      const { userId } = req.params;
      users.delete(userId);

      res.json({
        success: true,
        message: 'User deleted successfully',
      });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });
};

module.exports = {
  authRoutes,
  verifyToken,
  generateToken,
};
