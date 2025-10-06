-- AbbasiConnect Row Level Security (RLS) Policies
-- These policies ensure users can only access data they're authorized to see

-- ============================================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_credentials ENABLE ROW LEVEL SECURITY;
ALTER TABLE otp_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE vouches ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE comment_reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE help_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE pledges ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE threads ENABLE ROW LEVEL SECURITY;
ALTER TABLE thread_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_rsvps ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE pincodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE moderation_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Get current user ID from JWT
CREATE OR REPLACE FUNCTION auth.user_id()
RETURNS UUID AS $$
  SELECT COALESCE(
    current_setting('request.jwt.claims', true)::json->>'sub',
    current_setting('request.jwt.claims', true)::json->>'user_id'
  )::uuid;
$$ LANGUAGE sql STABLE;

-- Check if user is admin
CREATE OR REPLACE FUNCTION auth.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.user_id() 
    AND is_admin = true 
    AND deleted_at IS NULL
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Check if user is verified
CREATE OR REPLACE FUNCTION auth.is_verified()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.user_id() 
    AND status = 'verified' 
    AND deleted_at IS NULL
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Check if user is in same city
CREATE OR REPLACE FUNCTION auth.same_city(target_city TEXT)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.user_id() 
    AND city = target_city 
    AND deleted_at IS NULL
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Check if user is group member
CREATE OR REPLACE FUNCTION auth.is_group_member(group_uuid UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM group_members 
    WHERE group_id = group_uuid 
    AND user_id = auth.user_id() 
    AND status = 'approved'
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Check if user is group admin
CREATE OR REPLACE FUNCTION auth.is_group_admin(group_uuid UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM group_members 
    WHERE group_id = group_uuid 
    AND user_id = auth.user_id() 
    AND role IN ('owner', 'admin', 'moderator')
    AND status = 'approved'
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ============================================================================
-- USERS TABLE POLICIES
-- ============================================================================

-- Users can read their own profile and verified users' profiles
CREATE POLICY "Users can read verified profiles"
  ON users FOR SELECT
  USING (
    id = auth.user_id() OR
    (status = 'verified' AND deleted_at IS NULL) OR
    auth.is_admin()
  );

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (id = auth.user_id())
  WITH CHECK (id = auth.user_id());

-- Only system can insert users (handled by auth)
CREATE POLICY "System can insert users"
  ON users FOR INSERT
  WITH CHECK (true);

-- Users cannot delete themselves (soft delete only)
CREATE POLICY "No direct user deletion"
  ON users FOR DELETE
  USING (false);

-- ============================================================================
-- USER CREDENTIALS POLICIES
-- ============================================================================

CREATE POLICY "Users can manage own credentials"
  ON user_credentials FOR ALL
  USING (user_id = auth.user_id())
  WITH CHECK (user_id = auth.user_id());

-- ============================================================================
-- OTP CODES POLICIES
-- ============================================================================

-- Users can only see their own OTP codes
CREATE POLICY "Users can read own OTP codes"
  ON otp_codes FOR SELECT
  USING (user_id = auth.user_id() OR email = (SELECT email FROM users WHERE id = auth.user_id()));

-- System can insert OTP codes
CREATE POLICY "System can insert OTP codes"
  ON otp_codes FOR INSERT
  WITH CHECK (true);

-- System can update OTP codes (mark as used)
CREATE POLICY "System can update OTP codes"
  ON otp_codes FOR UPDATE
  USING (true);

-- ============================================================================
-- VOUCHES POLICIES
-- ============================================================================

-- Verified users can read vouches for candidates they can vouch for
CREATE POLICY "Verified users can read relevant vouches"
  ON vouches FOR SELECT
  USING (
    voucher_id = auth.user_id() OR
    candidate_id = auth.user_id() OR
    auth.is_admin()
  );

-- Verified users can create vouches
CREATE POLICY "Verified users can create vouches"
  ON vouches FOR INSERT
  WITH CHECK (
    voucher_id = auth.user_id() AND
    auth.is_verified()
  );

-- Users cannot update or delete vouches
CREATE POLICY "No vouch updates"
  ON vouches FOR UPDATE
  USING (false);

CREATE POLICY "No vouch deletions"
  ON vouches FOR DELETE
  USING (false);

-- ============================================================================
-- PROFILES POLICIES
-- ============================================================================

-- Users can read verified users' profiles
CREATE POLICY "Users can read verified profiles"
  ON profiles FOR SELECT
  USING (
    user_id = auth.user_id() OR
    EXISTS (SELECT 1 FROM users WHERE id = profiles.user_id AND status = 'verified' AND deleted_at IS NULL) OR
    auth.is_admin()
  );

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (user_id = auth.user_id())
  WITH CHECK (user_id = auth.user_id());

-- ============================================================================
-- POSTS POLICIES
-- ============================================================================

-- Users can read posts based on visibility
CREATE POLICY "Users can read posts"
  ON posts FOR SELECT
  USING (
    deleted_at IS NULL AND (
      visibility = 'public' OR
      (visibility = 'members_only' AND auth.is_verified()) OR
      (visibility = 'city_only' AND auth.same_city(city)) OR
      author_id = auth.user_id() OR
      auth.is_admin()
    )
  );

-- Verified users can create posts (with rate limiting handled in app)
CREATE POLICY "Verified users can create posts"
  ON posts FOR INSERT
  WITH CHECK (
    author_id = auth.user_id() AND
    auth.is_verified()
  );

-- Users can update their own posts
CREATE POLICY "Users can update own posts"
  ON posts FOR UPDATE
  USING (author_id = auth.user_id() AND deleted_at IS NULL)
  WITH CHECK (author_id = auth.user_id());

-- Users can soft delete their own posts
CREATE POLICY "Users can delete own posts"
  ON posts FOR UPDATE
  USING (author_id = auth.user_id() OR auth.is_admin());

-- ============================================================================
-- POST REACTIONS POLICIES
-- ============================================================================

CREATE POLICY "Users can read post reactions"
  ON post_reactions FOR SELECT
  USING (true);

CREATE POLICY "Verified users can create reactions"
  ON post_reactions FOR INSERT
  WITH CHECK (
    user_id = auth.user_id() AND
    auth.is_verified()
  );

CREATE POLICY "Users can delete own reactions"
  ON post_reactions FOR DELETE
  USING (user_id = auth.user_id());

-- ============================================================================
-- COMMENTS POLICIES
-- ============================================================================

CREATE POLICY "Users can read comments"
  ON comments FOR SELECT
  USING (deleted_at IS NULL);

CREATE POLICY "Verified users can create comments"
  ON comments FOR INSERT
  WITH CHECK (
    user_id = auth.user_id() AND
    auth.is_verified()
  );

CREATE POLICY "Users can update own comments"
  ON comments FOR UPDATE
  USING (user_id = auth.user_id() AND deleted_at IS NULL)
  WITH CHECK (user_id = auth.user_id());

CREATE POLICY "Users can delete own comments"
  ON comments FOR UPDATE
  USING (user_id = auth.user_id() OR auth.is_admin());

-- ============================================================================
-- COMMENT REACTIONS POLICIES
-- ============================================================================

CREATE POLICY "Users can read comment reactions"
  ON comment_reactions FOR SELECT
  USING (true);

CREATE POLICY "Verified users can create comment reactions"
  ON comment_reactions FOR INSERT
  WITH CHECK (
    user_id = auth.user_id() AND
    auth.is_verified()
  );

CREATE POLICY "Users can delete own comment reactions"
  ON comment_reactions FOR DELETE
  USING (user_id = auth.user_id());

-- ============================================================================
-- REPORTS POLICIES
-- ============================================================================

CREATE POLICY "Users can read own reports"
  ON reports FOR SELECT
  USING (
    reporter_id = auth.user_id() OR
    auth.is_admin()
  );

CREATE POLICY "Verified users can create reports"
  ON reports FOR INSERT
  WITH CHECK (
    reporter_id = auth.user_id() AND
    auth.is_verified()
  );

CREATE POLICY "Admins can update reports"
  ON reports FOR UPDATE
  USING (auth.is_admin())
  WITH CHECK (auth.is_admin());

-- ============================================================================
-- HELP REQUESTS POLICIES
-- ============================================================================

CREATE POLICY "Users can read help requests"
  ON help_requests FOR SELECT
  USING (
    visibility = 'public' OR
    (visibility = 'members_only' AND auth.is_verified()) OR
    (visibility = 'city_only' AND auth.same_city(city)) OR
    user_id = auth.user_id() OR
    auth.is_admin()
  );

CREATE POLICY "Verified users can create help requests"
  ON help_requests FOR INSERT
  WITH CHECK (
    user_id = auth.user_id() AND
    auth.is_verified()
  );

CREATE POLICY "Users can update own help requests"
  ON help_requests FOR UPDATE
  USING (user_id = auth.user_id())
  WITH CHECK (user_id = auth.user_id());

-- ============================================================================
-- PLEDGES POLICIES
-- ============================================================================

CREATE POLICY "Users can read pledges"
  ON pledges FOR SELECT
  USING (
    pledger_id = auth.user_id() OR
    EXISTS (SELECT 1 FROM help_requests WHERE id = pledges.help_request_id AND user_id = auth.user_id()) OR
    auth.is_admin()
  );

CREATE POLICY "Verified users can create pledges"
  ON pledges FOR INSERT
  WITH CHECK (
    pledger_id = auth.user_id() AND
    auth.is_verified()
  );

CREATE POLICY "Users can update own pledges"
  ON pledges FOR UPDATE
  USING (pledger_id = auth.user_id())
  WITH CHECK (pledger_id = auth.user_id());

-- ============================================================================
-- GROUPS POLICIES
-- ============================================================================

CREATE POLICY "Users can read public groups"
  ON groups FOR SELECT
  USING (
    is_private = false OR
    auth.is_group_member(id) OR
    owner_id = auth.user_id() OR
    auth.is_admin()
  );

CREATE POLICY "Verified users can create groups"
  ON groups FOR INSERT
  WITH CHECK (
    owner_id = auth.user_id() AND
    auth.is_verified()
  );

CREATE POLICY "Group owners can update groups"
  ON groups FOR UPDATE
  USING (
    owner_id = auth.user_id() OR
    auth.is_group_admin(id)
  )
  WITH CHECK (
    owner_id = auth.user_id() OR
    auth.is_group_admin(id)
  );

-- ============================================================================
-- GROUP MEMBERS POLICIES
-- ============================================================================

CREATE POLICY "Users can read group members"
  ON group_members FOR SELECT
  USING (
    user_id = auth.user_id() OR
    auth.is_group_member(group_id) OR
    auth.is_admin()
  );

CREATE POLICY "Users can join groups"
  ON group_members FOR INSERT
  WITH CHECK (
    user_id = auth.user_id() AND
    auth.is_verified()
  );

CREATE POLICY "Group admins can update members"
  ON group_members FOR UPDATE
  USING (
    auth.is_group_admin(group_id) OR
    user_id = auth.user_id()
  )
  WITH CHECK (
    auth.is_group_admin(group_id) OR
    user_id = auth.user_id()
  );

CREATE POLICY "Users can leave groups"
  ON group_members FOR DELETE
  USING (
    user_id = auth.user_id() OR
    auth.is_group_admin(group_id)
  );

-- ============================================================================
-- THREADS POLICIES
-- ============================================================================

CREATE POLICY "Users can read threads"
  ON threads FOR SELECT
  USING (
    auth.is_group_member(group_id) OR
    EXISTS (SELECT 1 FROM groups WHERE id = threads.group_id AND is_private = false)
  );

CREATE POLICY "Group members can create threads"
  ON threads FOR INSERT
  WITH CHECK (
    author_id = auth.user_id() AND
    auth.is_group_member(group_id)
  );

CREATE POLICY "Thread authors can update threads"
  ON threads FOR UPDATE
  USING (
    author_id = auth.user_id() OR
    auth.is_group_admin(group_id)
  )
  WITH CHECK (
    author_id = auth.user_id() OR
    auth.is_group_admin(group_id)
  );

-- ============================================================================
-- THREAD POSTS POLICIES
-- ============================================================================

CREATE POLICY "Users can read thread posts"
  ON thread_posts FOR SELECT
  USING (
    deleted_at IS NULL AND
    EXISTS (
      SELECT 1 FROM threads t
      WHERE t.id = thread_posts.thread_id
      AND (
        auth.is_group_member(t.group_id) OR
        EXISTS (SELECT 1 FROM groups WHERE id = t.group_id AND is_private = false)
      )
    )
  );

CREATE POLICY "Group members can create thread posts"
  ON thread_posts FOR INSERT
  WITH CHECK (
    author_id = auth.user_id() AND
    EXISTS (
      SELECT 1 FROM threads t
      WHERE t.id = thread_id
      AND auth.is_group_member(t.group_id)
    )
  );

CREATE POLICY "Users can update own thread posts"
  ON thread_posts FOR UPDATE
  USING (author_id = auth.user_id() AND deleted_at IS NULL)
  WITH CHECK (author_id = auth.user_id());

-- ============================================================================
-- EVENTS POLICIES
-- ============================================================================

CREATE POLICY "Users can read events"
  ON events FOR SELECT
  USING (
    visibility = 'public' OR
    (visibility = 'members_only' AND auth.is_verified()) OR
    (visibility = 'city_only' AND auth.same_city(city)) OR
    organiser_id = auth.user_id() OR
    auth.is_admin()
  );

CREATE POLICY "Verified users can create events"
  ON events FOR INSERT
  WITH CHECK (
    organiser_id = auth.user_id() AND
    auth.is_verified()
  );

CREATE POLICY "Organisers can update events"
  ON events FOR UPDATE
  USING (organiser_id = auth.user_id())
  WITH CHECK (organiser_id = auth.user_id());

-- ============================================================================
-- EVENT RSVPS POLICIES
-- ============================================================================

CREATE POLICY "Users can read event RSVPs"
  ON event_rsvps FOR SELECT
  USING (
    user_id = auth.user_id() OR
    EXISTS (SELECT 1 FROM events WHERE id = event_rsvps.event_id AND organiser_id = auth.user_id()) OR
    auth.is_admin()
  );

CREATE POLICY "Verified users can create RSVPs"
  ON event_rsvps FOR INSERT
  WITH CHECK (
    user_id = auth.user_id() AND
    auth.is_verified()
  );

CREATE POLICY "Users can update own RSVPs"
  ON event_rsvps FOR UPDATE
  USING (user_id = auth.user_id())
  WITH CHECK (user_id = auth.user_id());

CREATE POLICY "Users can delete own RSVPs"
  ON event_rsvps FOR DELETE
  USING (user_id = auth.user_id());

-- ============================================================================
-- NOTIFICATIONS POLICIES
-- ============================================================================

CREATE POLICY "Users can read own notifications"
  ON notifications FOR SELECT
  USING (user_id = auth.user_id());

CREATE POLICY "System can create notifications"
  ON notifications FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  USING (user_id = auth.user_id())
  WITH CHECK (user_id = auth.user_id());

CREATE POLICY "Users can delete own notifications"
  ON notifications FOR DELETE
  USING (user_id = auth.user_id());

-- ============================================================================
-- BADGES POLICIES
-- ============================================================================

CREATE POLICY "Everyone can read badges"
  ON badges FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage badges"
  ON badges FOR ALL
  USING (auth.is_admin())
  WITH CHECK (auth.is_admin());

-- ============================================================================
-- USER BADGES POLICIES
-- ============================================================================

CREATE POLICY "Users can read user badges"
  ON user_badges FOR SELECT
  USING (true);

CREATE POLICY "System can award badges"
  ON user_badges FOR INSERT
  WITH CHECK (true);

-- ============================================================================
-- PINCODES POLICIES
-- ============================================================================

CREATE POLICY "Everyone can read pincodes"
  ON pincodes FOR SELECT
  USING (true);

-- ============================================================================
-- MODERATION ACTIONS POLICIES
-- ============================================================================

CREATE POLICY "Admins can read moderation actions"
  ON moderation_actions FOR SELECT
  USING (auth.is_admin());

CREATE POLICY "Admins can create moderation actions"
  ON moderation_actions FOR INSERT
  WITH CHECK (
    moderator_id = auth.user_id() AND
    auth.is_admin()
  );

-- ============================================================================
-- USER SESSIONS POLICIES
-- ============================================================================

CREATE POLICY "Users can read own sessions"
  ON user_sessions FOR SELECT
  USING (user_id = auth.user_id());

CREATE POLICY "System can manage sessions"
  ON user_sessions FOR ALL
  USING (true)
  WITH CHECK (true);
