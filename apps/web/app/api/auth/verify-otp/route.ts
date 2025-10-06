import { NextRequest, NextResponse } from 'next/server';
import { verifyEmailOTP, createUserSession } from '@/../../packages/api/auth';
import { createServiceRoleClient } from '@/../../packages/api/supabase';
import { z } from 'zod';

const verifyOTPSchema = z.object({
  email: z.string().email('Invalid email address'),
  otp: z.string().length(6, 'OTP must be 6 digits'),
});

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    
    // Validate request body
    const validation = verifyOTPSchema.safeParse(body);
    if (!validation.success) {
      return NextResponse.json(
        { error: validation.error.errors[0].message },
        { status: 400 }
      );
    }

    const { email, otp } = validation.data;

    // Verify OTP
    const result = await verifyEmailOTP(email, otp);

    if (!result.success) {
      return NextResponse.json(
        { error: result.error || 'Invalid OTP' },
        { status: 400 }
      );
    }

    const supabase = createServiceRoleClient();

    // Check if user exists
    const { data: existingUser } = await supabase
      .from('users')
      .select('id, status, email_verified')
      .eq('email', email)
      .single();

    let userId = result.userId || existingUser?.id;

    // If user doesn't exist, create new user
    if (!existingUser) {
      const { data: newUser, error: createError } = await supabase
        .from('users')
        .insert({
          email,
          email_verified: true,
          status: 'created',
          name: '', // Will be filled in onboarding
          city: '',
          pincode: '',
        })
        .select('id')
        .single();

      if (createError || !newUser) {
        return NextResponse.json(
          { error: 'Failed to create user account' },
          { status: 500 }
        );
      }

      userId = newUser.id;
    } else if (!existingUser.email_verified) {
      // Mark email as verified
      await supabase
        .from('users')
        .update({ email_verified: true })
        .eq('id', existingUser.id);
    }

    // Create session
    const ipAddress = request.headers.get('x-forwarded-for') || 
                     request.headers.get('x-real-ip') || 
                     'unknown';
    const userAgent = request.headers.get('user-agent') || 'unknown';

    const session = await createUserSession(userId!, ipAddress, userAgent);

    // Set session cookie
    const response = NextResponse.json(
      { 
        message: 'OTP verified successfully',
        userId,
        isNewUser: !existingUser,
      },
      { status: 200 }
    );

    response.cookies.set('session_token', session.token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 30 * 24 * 60 * 60, // 30 days
      path: '/',
    });

    return response;
  } catch (error) {
    console.error('Verify OTP error:', error);
    return NextResponse.json(
      { error: 'An unexpected error occurred' },
      { status: 500 }
    );
  }
}
