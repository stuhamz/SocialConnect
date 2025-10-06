'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Button from '@/components/ui/Button';
import Avatar from '@/components/ui/Avatar';
import Textarea from '@/components/ui/Textarea';
import Modal from '@/components/ui/Modal';
import { 
  PlusIcon, 
  PhotoIcon, 
  HeartIcon, 
  ChatBubbleLeftIcon,
  FlagIcon,
  EllipsisHorizontalIcon 
} from '@heroicons/react/24/outline';
import { HeartIcon as HeartSolidIcon } from '@heroicons/react/24/solid';

interface Post {
  id: string;
  author: {
    id: string;
    name: string;
    photo_url: string | null;
    city: string;
  };
  text: string;
  media_urls: string[] | null;
  likes_count: number;
  comments_count: number;
  created_at: string;
  is_liked: boolean;
}

export default function FeedPage() {
  const router = useRouter();
  const [posts, setPosts] = useState<Post[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showComposer, setShowComposer] = useState(false);
  const [newPostText, setNewPostText] = useState('');
  const [isPosting, setIsPosting] = useState(false);

  useEffect(() => {
    loadPosts();
  }, []);

  const loadPosts = async () => {
    try {
      const response = await fetch('/api/posts/feed');
      const data = await response.json();
      setPosts(data);
    } catch (err) {
      console.error('Failed to load posts:', err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleCreatePost = async () => {
    if (!newPostText.trim()) return;

    setIsPosting(true);
    try {
      const response = await fetch('/api/posts', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: newPostText }),
      });

      if (response.ok) {
        setNewPostText('');
        setShowComposer(false);
        loadPosts();
      }
    } catch (err) {
      console.error('Failed to create post:', err);
    } finally {
      setIsPosting(false);
    }
  };

  const handleLike = async (postId: string) => {
    try {
      const post = posts.find(p => p.id === postId);
      if (!post) return;

      const response = await fetch(`/api/posts/${postId}/like`, {
        method: post.is_liked ? 'DELETE' : 'POST',
      });

      if (response.ok) {
        setPosts(posts.map(p => 
          p.id === postId 
            ? { 
                ...p, 
                is_liked: !p.is_liked,
                likes_count: p.is_liked ? p.likes_count - 1 : p.likes_count + 1
              }
            : p
        ));
      }
    } catch (err) {
      console.error('Failed to like post:', err);
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading feed...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div className="max-w-3xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-primary-600 to-secondary-600 text-white font-bold text-lg flex items-center justify-center">
                A
              </div>
              <h1 className="text-xl font-bold text-gray-900">AbbasiConnect</h1>
            </div>
            <Button
              variant="primary"
              size="sm"
              leftIcon={<PlusIcon className="h-4 w-4" />}
              onClick={() => setShowComposer(true)}
            >
              Post
            </Button>
          </div>
        </div>
      </header>

      {/* Feed */}
      <main className="max-w-3xl mx-auto px-4 py-6">
        {posts.length === 0 ? (
          <div className="card card-body text-center py-12">
            <div className="inline-flex items-center justify-center h-16 w-16 rounded-full bg-gray-100 text-gray-400 mb-4 mx-auto">
              <ChatBubbleLeftIcon className="h-8 w-8" />
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">
              No posts yet
            </h3>
            <p className="text-gray-600 mb-6">
              Be the first to share something with the community!
            </p>
            <Button
              variant="primary"
              onClick={() => setShowComposer(true)}
            >
              Create First Post
            </Button>
          </div>
        ) : (
          <div className="space-y-4">
            {posts.map((post) => (
              <div key={post.id} className="card card-body">
                {/* Post Header */}
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <Avatar
                      src={post.author.photo_url}
                      name={post.author.name}
                      size="md"
                    />
                    <div>
                      <h3 className="font-semibold text-gray-900">
                        {post.author.name}
                      </h3>
                      <p className="text-sm text-gray-600">
                        {post.author.city} • {new Date(post.created_at).toLocaleDateString()}
                      </p>
                    </div>
                  </div>
                  <button className="p-2 hover:bg-gray-100 rounded-lg transition-colors">
                    <EllipsisHorizontalIcon className="h-5 w-5 text-gray-400" />
                  </button>
                </div>

                {/* Post Content */}
                <div className="mb-4">
                  <p className="text-gray-900 whitespace-pre-wrap">{post.text}</p>
                </div>

                {/* Post Images */}
                {post.media_urls && post.media_urls.length > 0 && (
                  <div className="mb-4 rounded-lg overflow-hidden">
                    <img
                      src={post.media_urls[0]}
                      alt="Post image"
                      className="w-full h-auto"
                    />
                  </div>
                )}

                {/* Post Actions */}
                <div className="flex items-center gap-6 pt-4 border-t border-gray-200">
                  <button
                    onClick={() => handleLike(post.id)}
                    className="flex items-center gap-2 text-gray-600 hover:text-primary-600 transition-colors"
                  >
                    {post.is_liked ? (
                      <HeartSolidIcon className="h-5 w-5 text-danger-500" />
                    ) : (
                      <HeartIcon className="h-5 w-5" />
                    )}
                    <span className="text-sm font-medium">{post.likes_count}</span>
                  </button>
                  <button
                    onClick={() => router.push(`/post/${post.id}`)}
                    className="flex items-center gap-2 text-gray-600 hover:text-primary-600 transition-colors"
                  >
                    <ChatBubbleLeftIcon className="h-5 w-5" />
                    <span className="text-sm font-medium">{post.comments_count}</span>
                  </button>
                  <button className="flex items-center gap-2 text-gray-600 hover:text-danger-600 transition-colors ml-auto">
                    <FlagIcon className="h-5 w-5" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {/* Post Composer Modal */}
      <Modal
        isOpen={showComposer}
        onClose={() => setShowComposer(false)}
        title="Create Post"
        size="lg"
      >
        <div className="space-y-4">
          <Textarea
            placeholder="What's on your mind?"
            value={newPostText}
            onChange={(e) => setNewPostText(e.target.value)}
            rows={6}
            maxLength={5000}
            showCount
            disabled={isPosting}
          />

          <div className="flex items-center gap-3">
            <button
              className="flex items-center gap-2 px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
              disabled={isPosting}
            >
              <PhotoIcon className="h-5 w-5" />
              <span className="text-sm font-medium">Add Photo</span>
            </button>
          </div>

          <div className="flex gap-3">
            <Button
              variant="ghost"
              onClick={() => setShowComposer(false)}
              disabled={isPosting}
              className="flex-1"
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              onClick={handleCreatePost}
              isLoading={isPosting}
              disabled={!newPostText.trim()}
              className="flex-1"
            >
              Post
            </Button>
          </div>
        </div>
      </Modal>

      {/* Bottom Navigation */}
      <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 md:hidden">
        <div className="flex items-center justify-around py-2">
          <button className="flex flex-col items-center gap-1 px-4 py-2 text-primary-600">
            <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
            </svg>
            <span className="text-xs font-medium">Feed</span>
          </button>
          <button className="flex flex-col items-center gap-1 px-4 py-2 text-gray-600">
            <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <span className="text-xs font-medium">Search</span>
          </button>
          <button className="flex flex-col items-center gap-1 px-4 py-2 text-gray-600">
            <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
            </svg>
            <span className="text-xs font-medium">Alerts</span>
          </button>
          <button className="flex flex-col items-center gap-1 px-4 py-2 text-gray-600">
            <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
            </svg>
            <span className="text-xs font-medium">Profile</span>
          </button>
        </div>
      </nav>
    </div>
  );
}
