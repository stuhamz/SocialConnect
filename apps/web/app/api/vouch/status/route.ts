import { NextResponse } from 'next/server';
import { createServerSupabaseClient } from '@/../../packages/api/supabase';

export async function GET() {
  try {
    const supabase = await createServerSupabaseClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();

    if (authError || !user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    // Get user status
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('status')
      .eq('id', user.id)
      .single();

    if (userError || !userData) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    // Get vouches
    const { data: vouches, error: vouchError } = await supabase
      .from('vouches')
      .select(`
        id,
        decision,
        created_at,
        voucher:voucher_id (
          id,
          name,
          photo_url
        )
      `)
      .eq('candidate_id', user.id)
      .in('decision', ['know_personally', 'family_connection', 'community_acquaintance']);

    if (vouchError) {
      console.error('Vouch fetch error:', vouchError);
      return NextResponse.json(
        { error: 'Failed to fetch vouches' },
        { status: 500 }
      );
    }

    const totalVouches = vouches?.length || 0;
    const requiredVouches = 3;

    // Auto-verify if enough vouches
    if (totalVouches >= requiredVouches && userData.status === 'awaiting_vouches') {
      await supabase
        .from('users')
        .update({ status: 'verified' })
        .eq('id', user.id);

      userData.status = 'verified';
    }

    return NextResponse.json({
      totalVouches,
      requiredVouches,
      status: userData.status,
      vouchers: vouches?.map((v: any) => ({
        id: v.voucher.id,
        name: v.voucher.name,
        photo_url: v.voucher.photo_url,
        decision: v.decision,
        created_at: v.created_at,
      })) || [],
    });
  } catch (error) {
    console.error('Vouch status error:', error);
    return NextResponse.json(
      { error: 'An unexpected error occurred' },
      { status: 500 }
    );
  }
}
