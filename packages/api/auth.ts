import { createServerSupabaseClient, createServiceRoleClient } from './supabase';
import crypto from 'crypto';

// OTP Configuration
const OTP_LENGTH = 6;
const OTP_EXPIRY_MINUTES = 10;
const MAX_OTP_ATTEMPTS = 5;

// Rate limiting configuration
const RATE_LIMIT_WINDOW_MS = 15 * 60 * 1000; // 15 minutes
const MAX_OTP_REQUESTS_PER_WINDOW = 5;

// Generate OTP code
export const generateOTP = (): string => {
  return crypto.randomInt(100000, 999999).toString();
};

// Hash OTP for storage
export const hashOTP = (otp: string): string => {
  return crypto.createHash('sha256').update(otp).digest('hex');
};

// Verify OTP hash
export const verifyOTPHash = (otp: string, hash: string): boolean => {
  return hashOTP(otp) === hash;
};

// Generate secure token
export const generateSecureToken = (length: number = 32): string => {
  return crypto.randomBytes(length).toString('hex');
};

// Check rate limit for OTP requests
export const checkOTPRateLimit = async (
  identifier: string // email or phone
): Promise<{ allowed: boolean; remainingAttempts: number }> => {
  const supabase = createServiceRoleClient();
  
  const windowStart = new Date(Date.now() - RATE_LIMIT_WINDOW_MS);
  
  const { data, error } = await supabase
    .from('otp_codes')
    .select('id')
    .or(`email.eq.${identifier},phone.eq.${identifier}`)
    .gte('created_at', windowStart.toISOString());

  if (error) {
    console.error('Rate limit check error:', error);
    return { allowed: true, remainingAttempts: MAX_OTP_REQUESTS_PER_WINDOW };
  }

  const requestCount = data?.length || 0;
  const remainingAttempts = Math.max(0, MAX_OTP_REQUESTS_PER_WINDOW - requestCount);
  
  return {
    allowed: requestCount < MAX_OTP_REQUESTS_PER_WINDOW,
    remainingAttempts,
  };
};

// Send email OTP
export const sendEmailOTP = async (
  email: string,
  userId?: string
): Promise<{ success: boolean; error?: string }> => {
  try {
    // Check rate limit
    const rateLimit = await checkOTPRateLimit(email);
    if (!rateLimit.allowed) {
      return {
        success: false,
        error: `Too many requests. Please try again later. (${rateLimit.remainingAttempts} attempts remaining)`,
      };
    }

    const otp = generateOTP();
    const expiresAt = new Date(Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000);

    // Store OTP in database
    const supabase = createServiceRoleClient();
    const { error: dbError } = await supabase.from('otp_codes').insert({
      user_id: userId || null,
      email,
      code: hashOTP(otp),
      type: userId ? 'login' : 'email_verify',
      expires_at: expiresAt.toISOString(),
    });

    if (dbError) {
      console.error('OTP storage error:', dbError);
      return { success: false, error: 'Failed to generate OTP' };
    }

    // Send email via Brevo or Resend
    const emailSent = await sendOTPEmail(email, otp);
    
    if (!emailSent) {
      return { success: false, error: 'Failed to send OTP email' };
    }

    return { success: true };
  } catch (error) {
    console.error('Send OTP error:', error);
    return { success: false, error: 'An unexpected error occurred' };
  }
};

// Verify email OTP
export const verifyEmailOTP = async (
  email: string,
  otp: string
): Promise<{ success: boolean; userId?: string; error?: string }> => {
  try {
    const supabase = createServiceRoleClient();
    
    // Get the most recent unused OTP for this email
    const { data: otpRecord, error: fetchError } = await supabase
      .from('otp_codes')
      .select('*')
      .eq('email', email)
      .is('used_at', null)
      .gte('expires_at', new Date().toISOString())
      .order('created_at', { ascending: false })
      .limit(1)
      .single();

    if (fetchError || !otpRecord) {
      return { success: false, error: 'Invalid or expired OTP' };
    }

    // Verify OTP
    if (!verifyOTPHash(otp, otpRecord.code)) {
      return { success: false, error: 'Invalid OTP' };
    }

    // Mark OTP as used
    await supabase
      .from('otp_codes')
      .update({ used_at: new Date().toISOString() })
      .eq('id', otpRecord.id);

    return {
      success: true,
      userId: otpRecord.user_id || undefined,
    };
  } catch (error) {
    console.error('Verify OTP error:', error);
    return { success: false, error: 'An unexpected error occurred' };
  }
};

// Send OTP email using configured provider
const sendOTPEmail = async (email: string, otp: string): Promise<boolean> => {
  try {
    // Try Brevo first
    if (process.env.BREVO_API_KEY) {
      return await sendBrevoEmail(email, otp);
    }
    
    // Fallback to Resend
    if (process.env.RESEND_API_KEY) {
      return await sendResendEmail(email, otp);
    }

    console.error('No email provider configured');
    return false;
  } catch (error) {
    console.error('Email sending error:', error);
    return false;
  }
};

// Send email via Brevo
const sendBrevoEmail = async (email: string, otp: string): Promise<boolean> => {
  try {
    const response = await fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'api-key': process.env.BREVO_API_KEY!,
      },
      body: JSON.stringify({
        sender: {
          name: process.env.BREVO_SENDER_NAME || 'AbbasiConnect',
          email: process.env.BREVO_SENDER_EMAIL || 'noreply@abbasiconnect.com',
        },
        to: [{ email }],
        subject: 'Your AbbasiConnect Verification Code',
        htmlContent: `
          <!DOCTYPE html>
          <html>
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
            </head>
            <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
              <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
                <h1 style="color: white; margin: 0;">AbbasiConnect</h1>
              </div>
              <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
                <h2 style="color: #333; margin-top: 0;">Verification Code</h2>
                <p>Your verification code is:</p>
                <div style="background: white; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
                  <h1 style="color: #667eea; font-size: 36px; letter-spacing: 8px; margin: 0;">${otp}</h1>
                </div>
                <p>This code will expire in ${OTP_EXPIRY_MINUTES} minutes.</p>
                <p style="color: #666; font-size: 14px;">If you didn't request this code, please ignore this email.</p>
                <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
                <p style="color: #999; font-size: 12px; text-align: center;">
                  © ${new Date().getFullYear()} AbbasiConnect. All rights reserved.
                </p>
              </div>
            </body>
          </html>
        `,
      }),
    });

    return response.ok;
  } catch (error) {
    console.error('Brevo email error:', error);
    return false;
  }
};

// Send email via Resend
const sendResendEmail = async (email: string, otp: string): Promise<boolean> => {
  try {
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: process.env.BREVO_SENDER_EMAIL || 'noreply@abbasiconnect.com',
        to: [email],
        subject: 'Your AbbasiConnect Verification Code',
        html: `
          <!DOCTYPE html>
          <html>
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
            </head>
            <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
              <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
                <h1 style="color: white; margin: 0;">AbbasiConnect</h1>
              </div>
              <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
                <h2 style="color: #333; margin-top: 0;">Verification Code</h2>
                <p>Your verification code is:</p>
                <div style="background: white; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
                  <h1 style="color: #667eea; font-size: 36px; letter-spacing: 8px; margin: 0;">${otp}</h1>
                </div>
                <p>This code will expire in ${OTP_EXPIRY_MINUTES} minutes.</p>
                <p style="color: #666; font-size: 14px;">If you didn't request this code, please ignore this email.</p>
                <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
                <p style="color: #999; font-size: 12px; text-align: center;">
                  © ${new Date().getFullYear()} AbbasiConnect. All rights reserved.
                </p>
              </div>
            </body>
          </html>
        `,
      }),
    });

    return response.ok;
  } catch (error) {
    console.error('Resend email error:', error);
    return false;
  }
};

// Create user session
export const createUserSession = async (
  userId: string,
  ipAddress?: string,
  userAgent?: string
): Promise<{ token: string; expiresAt: Date }> => {
  const token = generateSecureToken(64);
  const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
  const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days

  const supabase = createServiceRoleClient();
  await supabase.from('user_sessions').insert({
    user_id: userId,
    token_hash: tokenHash,
    ip_address: ipAddress,
    user_agent: userAgent,
    expires_at: expiresAt.toISOString(),
  });

  return { token, expiresAt };
};

// Verify user session
export const verifyUserSession = async (
  token: string
): Promise<{ valid: boolean; userId?: string }> => {
  const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
  
  const supabase = createServiceRoleClient();
  const { data, error } = await supabase
    .from('user_sessions')
    .select('user_id, expires_at')
    .eq('token_hash', tokenHash)
    .gte('expires_at', new Date().toISOString())
    .single();

  if (error || !data) {
    return { valid: false };
  }

  // Update last activity
  await supabase
    .from('user_sessions')
    .update({ last_activity_at: new Date().toISOString() })
    .eq('token_hash', tokenHash);

  return { valid: true, userId: data.user_id };
};

// Invalidate user session
export const invalidateUserSession = async (token: string): Promise<void> => {
  const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
  
  const supabase = createServiceRoleClient();
  await supabase
    .from('user_sessions')
    .delete()
    .eq('token_hash', tokenHash);
};

// Clean up expired OTPs and sessions (run as cron job)
export const cleanupExpiredData = async (): Promise<void> => {
  const supabase = createServiceRoleClient();
  
  // Delete expired OTPs
  await supabase
    .from('otp_codes')
    .delete()
    .lt('expires_at', new Date().toISOString());

  // Delete expired sessions
  await supabase
    .from('user_sessions')
    .delete()
    .lt('expires_at', new Date().toISOString());
};
