-- AbbasiConnect Database Schema
-- PostgreSQL with Row Level Security (RLS)

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- ENUMS
-- ============================================================================

-- User account status
CREATE TYPE user_status AS ENUM (
  'created',
  'phone_verified',
  'awaiting_vouches',
  'verified',
  'restricted',
  'banned'
);

-- Vouch decision types
CREATE TYPE vouch_decision AS ENUM (
  'know_personally',
  'family_connection',
  'community_acquaintance',
  'do_not_recognise'
);

-- Post types
CREATE TYPE post_type AS ENUM ('text', 'image', 'poll');

-- Post visibility
CREATE TYPE visibility_type AS ENUM ('public', 'members_only', 'city_only', 'private');

-- Reaction types
CREATE TYPE reaction_type AS ENUM ('like', 'love', 'support', 'celebrate', 'insightful');

-- Report status
CREATE TYPE report_status AS ENUM ('pending', 'reviewing', 'resolved', 'dismissed');

-- Help request categories
CREATE TYPE help_category AS ENUM ('financial', 'medical', 'education', 'housing', 'employment', 'other');

-- Help request status
CREATE TYPE help_status AS ENUM ('open', 'pledged', 'closed', 'cancelled');

-- Pledge status
CREATE TYPE pledge_status AS ENUM ('pending', 'fulfilled', 'cancelled');

-- Group member roles
CREATE TYPE group_role AS ENUM ('owner', 'admin', 'moderator', 'member');

-- Group member status
CREATE TYPE member_status AS ENUM ('pending', 'approved', 'rejected', 'removed');

-- Event RSVP status
CREATE TYPE rsvp_status AS ENUM ('going', 'maybe', 'not_going');

-- Notification types
CREATE TYPE notification_type AS ENUM (
  'vouch_request',
  'vouch_approved',
  'account_verified',
  'post_like',
  'post_comment',
  'comment_reply',
  'help_pledge',
  'help_fulfilled',
  'group_invite',
  'group_approved',
  'event_invite',
  'event_reminder',
  'badge_earned',
  'mention',
  'report_update',
  'system'
);

-- ============================================================================
-- CORE TABLES
-- ============================================================================

-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  phone TEXT UNIQUE,
  name TEXT NOT NULL,
  photo_url TEXT,
  city TEXT NOT NULL,
  pincode TEXT NOT NULL,
  profession TEXT,
  lineage_note TEXT,
  bio TEXT,
  status user_status DEFAULT 'created' NOT NULL,
  trust_score INTEGER DEFAULT 0 NOT NULL,
  is_admin BOOLEAN DEFAULT false NOT NULL,
  email_verified BOOLEAN DEFAULT false NOT NULL,
  phone_verified BOOLEAN DEFAULT false NOT NULL,
  last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  deleted_at TIMESTAMP WITH TIME ZONE,
  
  CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  CONSTRAINT valid_phone CHECK (phone IS NULL OR phone ~* '^\+?[1-9]\d{1,14}$'),
  CONSTRAINT valid_trust_score CHECK (trust_score >= 0 AND trust_score <= 1000)
);

-- User credentials (for WebAuthn/Passkeys)
CREATE TABLE user_credentials (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  credential_id TEXT UNIQUE NOT NULL,
  public_key TEXT NOT NULL,
  counter BIGINT DEFAULT 0 NOT NULL,
  device_type TEXT,
  backed_up BOOLEAN DEFAULT false,
  transports TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  last_used_at TIMESTAMP WITH TIME ZONE
);

-- OTP codes for email/phone verification
CREATE TABLE otp_codes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  email TEXT,
  phone TEXT,
  code TEXT NOT NULL,
  type TEXT NOT NULL, -- 'email_verify', 'phone_verify', 'login'
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  used_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  CONSTRAINT otp_target CHECK (email IS NOT NULL OR phone IS NOT NULL)
);

-- Vouches table
CREATE TABLE vouches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidate_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  voucher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  decision vouch_decision NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  CONSTRAINT unique_vouch UNIQUE (candidate_id, voucher_id),
  CONSTRAINT no_self_vouch CHECK (candidate_id != voucher_id)
);

-- User profiles (extended info)
CREATE TABLE profiles (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  badges_json JSONB DEFAULT '[]'::jsonb,
  login_streak INTEGER DEFAULT 0,
  last_login_date DATE,
  total_posts INTEGER DEFAULT 0,
  total_comments INTEGER DEFAULT 0,
  total_helps INTEGER DEFAULT 0,
  total_vouches_given INTEGER DEFAULT 0,
  settings_json JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ============================================================================
-- SOCIAL FEATURES
-- ============================================================================

-- Posts table
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type post_type DEFAULT 'text' NOT NULL,
  text TEXT,
  media_urls TEXT[],
  city TEXT,
  visibility visibility_type DEFAULT 'public' NOT NULL,
  is_pinned BOOLEAN DEFAULT false,
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  deleted_at TIMESTAMP WITH TIME ZONE,
  
  CONSTRAINT post_has_content CHECK (
    text IS NOT NULL OR 
    (media_urls IS NOT NULL AND array_length(media_urls, 1) > 0)
  )
);

-- Post reactions
CREATE TABLE post_reactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type reaction_type DEFAULT 'like' NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  CONSTRAINT unique_post_reaction UNIQUE (post_id, user_id)
);

-- Comments table
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES comments(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  likes_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  deleted_at TIMESTAMP WITH TIME ZONE,
  
  CONSTRAINT comment_not_empty CHECK (length(trim(text)) > 0)
);

-- Comment reactions
CREATE TABLE comment_reactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  comment_id UUID NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type reaction_type DEFAULT 'like' NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  CONSTRAINT unique_comment_reaction UNIQUE (comment_id, user_id)
);

-- Reports table
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  entity_type TEXT NOT NULL, -- 'post', 'comment', 'user', 'group', 'event'
  entity_id UUID NOT NULL,
  reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  description TEXT,
  status report_status DEFAULT 'pending' NOT NULL,
  reviewed_by UUID REFERENCES users(id),
  reviewed_at TIMESTAMP WITH TIME ZONE,
  resolution_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  CONSTRAINT valid_entity_type CHECK (entity_type IN ('post', 'comment', 'user', 'group', 'event', 'help_request'))
);

-- ============================================================================
-- HELP HUB
-- ============================================================================

-- Help requests table
CREATE TABLE help_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category help_category NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  city TEXT NOT NULL,
  target_amount DECIMAL(10, 2),
  current_amount DECIMAL(10, 2) DEFAULT 0,
  proof_urls TEXT[],
  status help_status DEFAULT 'open' NOT NULL,
  visibility visibility_type DEFAULT 'public' NOT NULL,
  pledges_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  closed_at TIMESTAMP WITH TIME ZONE,
  
  CONSTRAINT valid_amounts CHECK (
    target_amount IS NULL OR 
    (target_amount > 0 AND current_amount >= 0 AND current_amount <= target_amount)
  )
);

-- Pledges table
CREATE TABLE pledges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  help_request_id UUID NOT NULL REFERENCES help_requests(id) ON DELETE CASCADE,
  pledger_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  amount DECIMAL(10, 2) NOT NULL,
  status pledge_status DEFAULT 'pending' NOT NULL,
  notes TEXT,
  fulfilled_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  CONSTRAINT positive_amount CHECK (amount > 0)
);

-- ============================================================================
-- GROUPS & FORUMS
-- ============================================================================

-- Groups table
CREATE TABLE groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  is_private BOOLEAN DEFAULT false NOT NULL,
  city TEXT,
  cover_url TEXT,
  owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  members_count INTEGER DEFAULT 1,
  posts_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  CONSTRAINT valid_slug CHECK (slug ~* '^[a-z0-9-]+$')
);

-- Group members table
CREATE TABLE group_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role group_role DEFAULT 'member' NOT NULL,
  status member_status DEFAULT 'approved' NOT NULL,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  CONSTRAINT unique_group_member UNIQUE (group_id, user_id)
);

-- Group threads (forum topics)
CREATE TABLE threads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  is_pinned BOOLEAN DEFAULT false,
  is_locked BOOLEAN DEFAULT false,
  posts_count INTEGER DEFAULT 0,
  views_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Thread posts
CREATE TABLE thread_posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  thread_id UUID NOT NULL REFERENCES threads(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  media_urls TEXT[],
  likes_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  deleted_at TIMESTAMP WITH TIME ZONE,
  
  CONSTRAINT post_not_empty CHECK (length(trim(text)) > 0)
);

-- ============================================================================
-- EVENTS
-- ============================================================================

-- Events table
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organiser_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  city TEXT NOT NULL,
  location_details TEXT,
  event_date DATE NOT NULL,
  event_time TIME,
  rsvp_limit INTEGER,
  rsvp_count INTEGER DEFAULT 0,
  visibility visibility_type DEFAULT 'public' NOT NULL,
  cover_url TEXT,
  gallery_urls TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  CONSTRAINT valid_rsvp_limit CHECK (rsvp_limit IS NULL OR rsvp_limit > 0),
  CONSTRAINT valid_rsvp_count CHECK (rsvp_count >= 0 AND (rsvp_limit IS NULL OR rsvp_count <= rsvp_limit))
);

-- Event RSVPs
CREATE TABLE event_rsvps (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status rsvp_status DEFAULT 'going' NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  CONSTRAINT unique_event_rsvp UNIQUE (event_id, user_id)
);

-- ============================================================================
-- NOTIFICATIONS
-- ============================================================================

-- Notifications table
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type notification_type NOT NULL,
  title TEXT NOT NULL,
  message TEXT,
  payload_json JSONB DEFAULT '{}'::jsonb,
  is_read BOOLEAN DEFAULT false NOT NULL,
  read_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  CONSTRAINT valid_payload CHECK (jsonb_typeof(payload_json) = 'object')
);

-- ============================================================================
-- GAMIFICATION
-- ============================================================================

-- Badges table
CREATE TABLE badges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  icon_url TEXT,
  criteria_json JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  CONSTRAINT valid_code CHECK (code ~* '^[A-Z_]+$')
);

-- User badges table
CREATE TABLE user_badges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  badge_id UUID NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
  awarded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  CONSTRAINT unique_user_badge UNIQUE (user_id, badge_id)
);

-- ============================================================================
-- LOCATION DATA
-- ============================================================================

-- Indian pincodes table (offline data)
CREATE TABLE pincodes (
  pincode TEXT PRIMARY KEY,
  city TEXT NOT NULL,
  district TEXT,
  state TEXT NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  
  CONSTRAINT valid_pincode CHECK (pincode ~* '^\d{6}$'),
  CONSTRAINT valid_coordinates CHECK (
    latitude >= -90 AND latitude <= 90 AND
    longitude >= -180 AND longitude <= 180
  )
);

-- ============================================================================
-- AUDIT & MODERATION
-- ============================================================================

-- Moderation actions log
CREATE TABLE moderation_actions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  moderator_id UUID NOT NULL REFERENCES users(id),
  target_type TEXT NOT NULL,
  target_id UUID NOT NULL,
  action TEXT NOT NULL,
  reason TEXT,
  metadata_json JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- User sessions (for tracking and security)
CREATE TABLE user_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL,
  ip_address INET,
  user_agent TEXT,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Users indexes
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_phone ON users(phone) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_status ON users(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_city ON users(city) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_pincode ON users(pincode) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- Vouches indexes
CREATE INDEX idx_vouches_candidate ON vouches(candidate_id);
CREATE INDEX idx_vouches_voucher ON vouches(voucher_id);

-- Posts indexes
CREATE INDEX idx_posts_author ON posts(author_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_posts_created_at ON posts(created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_posts_city ON posts(city) WHERE deleted_at IS NULL;

-- Comments indexes
CREATE INDEX idx_comments_post ON comments(post_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_comments_user ON comments(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_comments_parent ON comments(parent_id) WHERE deleted_at IS NULL;

-- Help requests indexes
CREATE INDEX idx_help_requests_user ON help_requests(user_id);
CREATE INDEX idx_help_requests_status ON help_requests(status);
CREATE INDEX idx_help_requests_city ON help_requests(city);
CREATE INDEX idx_help_requests_created_at ON help_requests(created_at DESC);

-- Groups indexes
CREATE INDEX idx_groups_owner ON groups(owner_id);
CREATE INDEX idx_groups_city ON groups(city);
CREATE INDEX idx_groups_slug ON groups(slug);

-- Group members indexes
CREATE INDEX idx_group_members_group ON group_members(group_id);
CREATE INDEX idx_group_members_user ON group_members(user_id);
CREATE INDEX idx_group_members_status ON group_members(status);

-- Events indexes
CREATE INDEX idx_events_organiser ON events(organiser_id);
CREATE INDEX idx_events_city ON events(city);
CREATE INDEX idx_events_date ON events(event_date);

-- Notifications indexes
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- OTP codes indexes
CREATE INDEX idx_otp_codes_email ON otp_codes(email) WHERE used_at IS NULL;
CREATE INDEX idx_otp_codes_expires ON otp_codes(expires_at) WHERE used_at IS NULL;

-- Pincodes indexes
CREATE INDEX idx_pincodes_city ON pincodes(city);
CREATE INDEX idx_pincodes_state ON pincodes(state);
CREATE INDEX idx_pincodes_coordinates ON pincodes(latitude, longitude);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_help_requests_updated_at BEFORE UPDATE ON help_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_groups_updated_at BEFORE UPDATE ON groups
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Increment counters
CREATE OR REPLACE FUNCTION increment_post_likes()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER increment_post_likes_trigger AFTER INSERT ON post_reactions
  FOR EACH ROW EXECUTE FUNCTION increment_post_likes();

CREATE OR REPLACE FUNCTION decrement_post_likes()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE posts SET likes_count = likes_count - 1 WHERE id = OLD.post_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER decrement_post_likes_trigger AFTER DELETE ON post_reactions
  FOR EACH ROW EXECUTE FUNCTION decrement_post_likes();

-- Similar triggers for comments count
CREATE OR REPLACE FUNCTION increment_post_comments()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER increment_post_comments_trigger AFTER INSERT ON comments
  FOR EACH ROW EXECUTE FUNCTION increment_post_comments();

CREATE OR REPLACE FUNCTION decrement_post_comments()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE posts SET comments_count = comments_count - 1 WHERE id = OLD.post_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER decrement_post_comments_trigger AFTER DELETE ON comments
  FOR EACH ROW EXECUTE FUNCTION decrement_post_comments();

-- Auto-create profile on user creation
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (user_id) VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_user_profile_trigger AFTER INSERT ON users
  FOR EACH ROW EXECUTE FUNCTION create_user_profile();
