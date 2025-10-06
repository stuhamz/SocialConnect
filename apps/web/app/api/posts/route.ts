import { NextRequest, NextResponse } from 'next/server';
import { createServerSupabaseClient } from '@/../../packages/api/supabase';
import { z } from 'zod';

const createPostSchema = z.object({
  text: z.string().min(1).max(5000),
  media_urls: z.array(z.string().url()).optional(),
  visibility: z.enum(['public', 'members_only', 'city_only']).default('public'),
});

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    
    // Validate request body
    const validation = createPostSchema.safeParse(body);
    if (!validation.success) {
      return NextResponse.json(
        { error: validation.error.errors[0].message },
        { status: 400 }
      );
    }

    const supabase = await createServerSupabaseClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();

    if (authError || !user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    // Check if user is verified
    const { data: userData } = await supabase
      .from('users')
      .select('status, city')
      .eq('id', user.id)
      .single();

    if (!userData || userData.status !== 'verified') {
      return NextResponse.json(
        { error: 'Only verified users can create posts' },
        { status: 403 }
      );
    }

    // Check rate limit (3 posts per day)
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const { data: todayPosts } = await supabase
      .from('posts')
      .select('id')
      .eq('author_id', user.id)
      .gte('created_at', today.toISOString());

    if (todayPosts && todayPosts.length >= 3) {
      return NextResponse.json(
        { error: 'Daily post limit reached (3 posts per day)' },
        { status: 429 }
      );
    }

    const { text, media_urls, visibility } = validation.data;

    // Create post
    const { data: post, error: createError } = await supabase
      .from('posts')
      .insert({
        author_id: user.id,
        type: media_urls && media_urls.length > 0 ? 'image' : 'text',
        text,
        media_urls: media_urls || null,
        city: userData.city,
        visibility,
      })
      .select()
      .single();

    if (createError) {
      console.error('Post creation error:', createError);
      return NextResponse.json(
        { error: 'Failed to create post' },
        { status: 500 }
      );
    }

    // Update user's post count
    await supabase.rpc('increment', {
      table_name: 'profiles',
      column_name: 'total_posts',
      row_id: user.id,
    });

    return NextResponse.json(post, { status: 201 });
  } catch (error) {
    console.error('Create post error:', error);
    return NextResponse.json(
      { error: 'An unexpected error occurred' },
      { status: 500 }
    );
  }
}
