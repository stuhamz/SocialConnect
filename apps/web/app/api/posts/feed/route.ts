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

    // Get posts with author info and like status
    const { data: posts, error: postsError } = await supabase
      .from('posts')
      .select(`
        id,
        text,
        media_urls,
        likes_count,
        comments_count,
        created_at,
        author:author_id (
          id,
          name,
          photo_url,
          city
        )
      `)
      .is('deleted_at', null)
      .order('created_at', { ascending: false })
      .limit(50);

    if (postsError) {
      console.error('Posts fetch error:', postsError);
      return NextResponse.json(
        { error: 'Failed to fetch posts' },
        { status: 500 }
      );
    }

    // Get user's likes
    const postIds = posts?.map((p: any) => p.id) || [];
    const { data: likes } = await supabase
      .from('post_reactions')
      .select('post_id')
      .eq('user_id', user.id)
      .in('post_id', postIds);

    const likedPostIds = new Set(likes?.map((l: any) => l.post_id) || []);

    // Add is_liked flag to posts
    const postsWithLikes = posts?.map((post: any) => ({
      ...post,
      is_liked: likedPostIds.has(post.id),
    })) || [];

    return NextResponse.json(postsWithLikes);
  } catch (error) {
    console.error('Feed error:', error);
    return NextResponse.json(
      { error: 'An unexpected error occurred' },
      { status: 500 }
    );
  }
}
