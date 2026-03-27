// Real Authentication System with JWT, Supabase Database, and Email
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');
const crypto = require('crypto');
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

// ============ AUTH HELPERS ============

const generateToken = (userId, role, email) => {
  return jwt.sign(
    { userId, role, email, timestamp: Date.now() },
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
  return crypto.randomBytes(32).toString('hex');
};

// ============ AUTH ENDPOINTS ============

const authRoutes = (app, supabase) => {
  
  // REGISTER USER
  app.post('/api/auth/register', async (req, res) => {
    try {
      const { email, password, name, phone, role } = req.body;

      // Validation
      if (!email || !password || !name || !role) {
        return res.status(400).json({ error: 'Missing required fields: email, password, name, role' });
      }

      if (password.length < 6) {
        return res.status(400).json({ error: 'Password must be at least 6 characters' });
      }

      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        return res.status(400).json({ error: 'Invalid email format' });
      }

      if (!['user', 'vendor'].includes(role)) {
        return res.status(400).json({ error: 'Role must be "user" or "vendor"' });
      }

      // Check if user already exists in Supabase
      const { data: existingUser } = await supabase
        .from('users')
        .select('id')
        .eq('email', email.toLowerCase())
        .single();

      if (existingUser) {
        return res.status(400).json({ error: 'Email already registered' });
      }

      // Hash password
      const hashedPassword = await hashPassword(password);

      // Create user in Supabase
      const userId = 'usr_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
      const { data: newUser, error: insertError } = await supabase
        .from('users')
        .insert([
          {
            id: userId,
            email: email.toLowerCase(),
            password: hashedPassword,
            name,
            phone: phone || null,
            role,
            status: 'active',
            profile_image: null,
          }
        ])
        .select()
        .single();

      if (insertError) {
        console.error('❌ Error registering user:', insertError);
        return res.status(500).json({ error: 'Failed to register user: ' + insertError.message });
      }

      // If vendor role, also create vendor record
      if (role === 'vendor') {
        const vendorId = 'vnd_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
        const { data: newVendor, error: vendorError } = await supabase
          .from('vendors')
          .insert([
            {
              id: vendorId,
              user_id: userId,
              business_name: name,
              business_registration: null,
              gst: null,
              status: 'approved',
              approved: true,
              blocked: false,
            }
          ])
          .select()
          .single();

        if (vendorError) {
          console.error('❌ Error creating vendor record:', vendorError);
          // Delete the user record since vendor creation failed
          await supabase.from('users').delete().eq('id', userId);
          return res.status(500).json({ error: 'Failed to create vendor record: ' + vendorError.message });
        }

        console.log(`✅ Vendor created: ${vendorId} for user ${userId}`);
      }

      // Generate token
      const token = generateToken(userId, role, email);

      console.log(`✅ User registered: ${email} (${role})`);

      const response = {
        success: true,
        message: 'User registered successfully',
        user: {
          id: userId,
          email: newUser.email,
          name: newUser.name,
          role: newUser.role,
        },
        token,
      };

      // If vendor, include vendor data in response
      if (role === 'vendor' && newVendor) {
        response.vendor = {
          id: newVendor.id,
          business_name: newVendor.business_name,
          status: newVendor.status,
          approved: newVendor.approved,
        };
      }

      return res.json(response);

    } catch (error) {
      console.error('❌ Register error:', error);
      res.status(500).json({ error: 'Internal server error: ' + error.message });
    }
  });

  // LOGIN USER
  app.post('/api/auth/login', async (req, res) => {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({ error: 'Email and password required' });
      }

      // Fetch user from Supabase
      const { data: user, error: fetchError } = await supabase
        .from('users')
        .select('*')
        .eq('email', email.toLowerCase())
        .single();

      if (!user) {
        return res.status(401).json({ error: 'Invalid email or password' });
      }

      // Check if user is blocked
      if (user.status === 'blocked') {
        return res.status(403).json({ error: 'This account has been blocked' });
      }

      // Compare password
      const isPasswordValid = await comparePassword(password, user.password);
      if (!isPasswordValid) {
        return res.status(401).json({ error: 'Invalid email or password' });
      }

      // Generate token
      const token = generateToken(user.id, user.role, user.email);

      console.log(`✅ User logged in: ${email}`);

      return res.json({
        success: true,
        message: 'Login successful',
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          phone: user.phone,
          role: user.role,
          profile_image: user.profile_image,
        },
        token,
      });

    } catch (error) {
      console.error('❌ Login error:', error);
      res.status(500).json({ error: 'Internal server error: ' + error.message });
    }
  });

  // FORGOT PASSWORD
  app.post('/api/auth/forgot-password', async (req, res) => {
    try {
      const { email } = req.body;

      if (!email) {
        return res.status(400).json({ error: 'Email is required' });
      }

      // Find user in Supabase
      const { data: user } = await supabase
        .from('users')
        .select('id, email, name')
        .eq('email', email.toLowerCase())
        .single();

      if (!user) {
        // Don't reveal if email exists (security), return success anyway
        return res.json({
          success: true,
          message: 'If email exists, a reset link has been sent',
        });
      }

      // Generate reset token
      const resetToken = generateResetToken();
      const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(); // 24 hours

      // Store reset token in Supabase
      const { error: tokenError } = await supabase
        .from('password_resets')
        .insert([
          {
            id: 'prt_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9),
            user_id: user.id,
            reset_token: resetToken,
            expires_at: expiresAt,
            used: false,
          }
        ]);

      if (tokenError) {
        console.error('❌ Error storing reset token:', tokenError);
        return res.status(500).json({ error: 'Failed to generate reset token' });
      }

      // Send email with reset link
      const resetLink = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/reset-password?token=${resetToken}`;

      try {
        await emailService.sendMail({
          from: process.env.EMAIL_USER,
          to: email,
          subject: 'Reset Your Password - New10 Equipment Rental',
          html: `
            <h2>Password Reset Request</h2>
            <p>Hi ${user.name},</p>
            <p>We received a request to reset your password. Click the link below to create a new password:</p>
            <p><a href="${resetLink}" style="padding: 10px 20px; background: #2196F3; color: white; text-decoration: none; border-radius: 4px;">Reset Password</a></p>
            <p>This link will expire in 24 hours.</p>
            <p>If you didn't request this, you can ignore this email.</p>
            <hr>
            <p><small>New10 Equipment Rental - www.new10.com</small></p>
          `,
        });
        console.log(`✅ Reset email sent to: ${email}`);
      } catch (emailError) {
        console.error('⚠️ Email send failed:', emailError.message);
        // Still return success so user knows to check email
      }

      return res.json({
        success: true,
        message: 'If email exists, a reset link has been sent',
      });

    } catch (error) {
      console.error('❌ Forgot password error:', error);
      res.status(500).json({ error: 'Internal server error: ' + error.message });
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

      // Find valid reset token in Supabase
      const { data: resetRecord } = await supabase
        .from('password_resets')
        .select('*')
        .eq('reset_token', token)
        .eq('used', false)
        .single();

      if (!resetRecord) {
        return res.status(400).json({ error: 'Invalid or expired reset token' });
      }

      // Check if token is expired
      if (new Date(resetRecord.expires_at) < new Date()) {
        return res.status(400).json({ error: 'Reset token has expired' });
      }

      // Hash new password
      const hashedPassword = await hashPassword(newPassword);

      // Update user password in Supabase
      const { error: updateError } = await supabase
        .from('users')
        .update({ password: hashedPassword, updated_at: new Date().toISOString() })
        .eq('id', resetRecord.user_id);

      if (updateError) {
        console.error('❌ Error updating password:', updateError);
        return res.status(500).json({ error: 'Failed to reset password' });
      }

      // Mark token as used
      await supabase
        .from('password_resets')
        .update({ used: true })
        .eq('id', resetRecord.id);

      console.log(`✅ Password reset for user: ${resetRecord.user_id}`);

      return res.json({
        success: true,
        message: 'Password reset successfully',
      });

    } catch (error) {
      console.error('❌ Reset password error:', error);
      res.status(500).json({ error: 'Internal server error: ' + error.message });
    }
  });

  // VERIFY TOKEN / GET CURRENT USER
  app.get('/api/auth/me', async (req, res) => {
    try {
      const authHeader = req.headers.authorization;

      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'No token provided' });
      }

      const token = authHeader.substring(7);
      const decoded = verifyToken(token);

      if (!decoded) {
        return res.status(401).json({ error: 'Invalid or expired token' });
      }

      // Fetch user from Supabase
      const { data: user, error: fetchError } = await supabase
        .from('users')
        .select('id, email, name, phone, role, profile_image, status, created_at')
        .eq('id', decoded.userId)
        .single();

      if (!user) {
        return res.status(401).json({ error: 'User not found' });
      }

      return res.json({
        success: true,
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          phone: user.phone,
          role: user.role,
          profile_image: user.profile_image,
          status: user.status,
          createdAt: user.created_at,
        },
      });

    } catch (error) {
      console.error('❌ Auth verification error:', error);
      res.status(500).json({ error: 'Internal server error: ' + error.message });
    }
  });

  console.log('✅ Auth routes configured (using Supabase for persistent storage)');
};

module.exports = authRoutes;
