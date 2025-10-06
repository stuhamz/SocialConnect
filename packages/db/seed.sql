-- AbbasiConnect Seed Data
-- Initial data for development and testing

-- ============================================================================
-- BADGES
-- ============================================================================

INSERT INTO badges (code, name, description, icon_url, criteria_json) VALUES
('EARLY_ADOPTER', 'Early Adopter', 'Joined AbbasiConnect in the first month', '/badges/early-adopter.svg', '{"type": "early_user", "threshold": 1000}'),
('VERIFIED_MEMBER', 'Verified Member', 'Successfully completed community verification', '/badges/verified.svg', '{"type": "status", "status": "verified"}'),
('TOP_CONTRIBUTOR', 'Top Contributor', 'Made 50+ helpful posts and comments', '/badges/top-contributor.svg', '{"type": "engagement", "posts": 50}'),
('HELPER_OF_MONTH', 'Helper of the Month', 'Most helpful member this month', '/badges/helper-month.svg', '{"type": "monthly", "category": "help"}'),
('COMMUNITY_BUILDER', 'Community Builder', 'Created 3+ active groups', '/badges/community-builder.svg', '{"type": "groups", "created": 3}'),
('EVENT_ORGANIZER', 'Event Organizer', 'Organized 5+ successful events', '/badges/event-organizer.svg', '{"type": "events", "organized": 5}'),
('TRUSTED_VOUCHER', 'Trusted Voucher', 'Successfully vouched for 10+ members', '/badges/trusted-voucher.svg', '{"type": "vouches", "count": 10}'),
('GENEROUS_GIVER', 'Generous Giver', 'Fulfilled 5+ help requests', '/badges/generous-giver.svg', '{"type": "help", "fulfilled": 5}'),
('STREAK_MASTER', 'Streak Master', 'Maintained 30-day login streak', '/badges/streak-master.svg', '{"type": "streak", "days": 30}'),
('WELCOME_AMBASSADOR', 'Welcome Ambassador', 'Helped onboard 20+ new members', '/badges/ambassador.svg', '{"type": "referrals", "count": 20}');

-- ============================================================================
-- INDIAN PINCODES (Sample data - in production, load full dataset)
-- ============================================================================

-- Major cities sample data
INSERT INTO pincodes (pincode, city, district, state, latitude, longitude) VALUES
-- Delhi
('110001', 'New Delhi', 'Central Delhi', 'Delhi', 28.6139, 77.2090),
('110025', 'Okhla', 'South Delhi', 'Delhi', 28.5355, 77.2750),
('110019', 'Zakir Nagar', 'South Delhi', 'Delhi', 28.5667, 77.2833),
('110065', 'Jamia Nagar', 'South Delhi', 'Delhi', 28.5667, 77.2833),

-- Mumbai
('400001', 'Mumbai', 'Mumbai City', 'Maharashtra', 18.9388, 72.8354),
('400051', 'Bandra', 'Mumbai Suburban', 'Maharashtra', 19.0596, 72.8295),
('400070', 'Kurla', 'Mumbai Suburban', 'Maharashtra', 19.0728, 72.8826),

-- Bangalore
('560001', 'Bangalore', 'Bangalore Urban', 'Karnataka', 12.9716, 77.5946),
('560027', 'Shivajinagar', 'Bangalore Urban', 'Karnataka', 12.9833, 77.6000),

-- Hyderabad
('500001', 'Hyderabad', 'Hyderabad', 'Telangana', 17.3850, 78.4867),
('500002', 'Charminar', 'Hyderabad', 'Telangana', 17.3616, 78.4747),
('500024', 'Santosh Nagar', 'Hyderabad', 'Telangana', 17.3500, 78.4833),

-- Lucknow
('226001', 'Lucknow', 'Lucknow', 'Uttar Pradesh', 26.8467, 80.9462),
('226003', 'Chowk', 'Lucknow', 'Uttar Pradesh', 26.8500, 80.9167),

-- Kolkata
('700001', 'Kolkata', 'Kolkata', 'West Bengal', 22.5726, 88.3639),
('700016', 'Park Circus', 'Kolkata', 'West Bengal', 22.5333, 88.3667),

-- Chennai
('600001', 'Chennai', 'Chennai', 'Tamil Nadu', 13.0827, 80.2707),
('600079', 'Triplicane', 'Chennai', 'Tamil Nadu', 13.0500, 80.2833),

-- Ahmedabad
('380001', 'Ahmedabad', 'Ahmedabad', 'Gujarat', 23.0225, 72.5714),
('380004', 'Jamalpur', 'Ahmedabad', 'Gujarat', 23.0333, 72.6000),

-- Pune
('411001', 'Pune', 'Pune', 'Maharashtra', 18.5204, 73.8567),
('411006', 'Camp', 'Pune', 'Maharashtra', 18.5167, 73.8833),

-- Jaipur
('302001', 'Jaipur', 'Jaipur', 'Rajasthan', 26.9124, 75.7873),
('302003', 'Ramganj', 'Jaipur', 'Rajasthan', 26.9167, 75.8000);

-- ============================================================================
-- SAMPLE ADMIN USER (for development only)
-- ============================================================================

-- Note: In production, create admin users through secure process
-- Password: Admin@123 (hashed)
INSERT INTO users (
  id,
  email,
  name,
  city,
  pincode,
  profession,
  lineage_note,
  status,
  is_admin,
  email_verified,
  trust_score
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  'admin@abbasiconnect.com',
  'System Administrator',
  'New Delhi',
  '110001',
  'Platform Administrator',
  'System Account',
  'verified',
  true,
  true,
  1000
);

-- ============================================================================
-- SAMPLE COMMUNITY GUIDELINES POST
-- ============================================================================

INSERT INTO posts (
  id,
  author_id,
  type,
  text,
  visibility,
  is_pinned
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001',
  'text',
  E'# Welcome to AbbasiConnect! 🌟\n\n## Community Guidelines\n\n### Our Values\n- **Respect**: Treat all members with dignity and kindness\n- **Authenticity**: Be genuine in your interactions\n- **Privacy**: Respect others\' personal information\n- **Support**: Help fellow community members\n\n### What We Encourage\n✅ Meaningful conversations and connections\n✅ Helping others through the Help Hub\n✅ Organizing and attending community events\n✅ Sharing knowledge and experiences\n✅ Building lasting relationships\n\n### What We Don\'t Allow\n❌ Harassment or bullying\n❌ Hate speech or discrimination\n❌ Spam or commercial solicitation\n❌ Misinformation or fake news\n❌ Impersonation or fake accounts\n\n### Verification Process\nNew members need 3 vouches from verified members to gain full access. This ensures our community remains safe and authentic.\n\n### Help & Support\nIf you need assistance or want to report an issue, please use the report button or contact our moderators.\n\n**Together, we build a stronger community!**',
  'public',
  true
);

-- ============================================================================
-- SAMPLE HELP CATEGORIES DATA
-- ============================================================================

-- This helps users understand what kind of help requests are appropriate
INSERT INTO posts (
  author_id,
  type,
  text,
  visibility,
  is_pinned
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  'text',
  E'# Help Hub Categories 🤝\n\n## Financial Assistance\n- Emergency medical expenses\n- Education fees\n- Business startup support\n- Debt relief\n\n## Medical Support\n- Treatment costs\n- Medicine expenses\n- Medical equipment\n- Hospital bills\n\n## Education\n- School/college fees\n- Books and supplies\n- Coaching classes\n- Skill development courses\n\n## Housing\n- Rent assistance\n- Home repairs\n- Relocation support\n\n## Employment\n- Job referrals\n- Career guidance\n- Interview preparation\n- Skill training\n\n**Remember**: All help requests are reviewed to ensure authenticity. Please provide relevant documentation when possible.',
  'public',
  true
);

-- ============================================================================
-- SAMPLE GROUPS
-- ============================================================================

INSERT INTO groups (
  id,
  name,
  slug,
  description,
  is_private,
  city,
  owner_id
) VALUES
(
  '00000000-0000-0000-0000-000000000001',
  'General Discussion',
  'general-discussion',
  'Open forum for all community members to discuss various topics',
  false,
  NULL,
  '00000000-0000-0000-0000-000000000001'
),
(
  '00000000-0000-0000-0000-000000000002',
  'Delhi Chapter',
  'delhi-chapter',
  'Community group for members in Delhi and NCR',
  false,
  'New Delhi',
  '00000000-0000-0000-0000-000000000001'
),
(
  '00000000-0000-0000-0000-000000000003',
  'Mumbai Chapter',
  'mumbai-chapter',
  'Community group for members in Mumbai',
  false,
  'Mumbai',
  '00000000-0000-0000-0000-000000000001'
),
(
  '00000000-0000-0000-0000-000000000004',
  'Professionals Network',
  'professionals-network',
  'Connect with professionals across various fields',
  false,
  NULL,
  '00000000-0000-0000-0000-000000000001'
),
(
  '00000000-0000-0000-0000-000000000005',
  'Youth Forum',
  'youth-forum',
  'Platform for young members to connect and collaborate',
  false,
  NULL,
  '00000000-0000-0000-0000-000000000001'
);

-- Add admin as member of all groups
INSERT INTO group_members (group_id, user_id, role, status) VALUES
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'owner', 'approved'),
('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'owner', 'approved'),
('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'owner', 'approved'),
('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'owner', 'approved'),
('00000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000001', 'owner', 'approved');

-- ============================================================================
-- SAMPLE WELCOME THREAD
-- ============================================================================

INSERT INTO threads (
  id,
  group_id,
  author_id,
  title,
  is_pinned
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001',
  'Welcome to AbbasiConnect - Introduce Yourself!',
  true
);

INSERT INTO thread_posts (
  thread_id,
  author_id,
  text
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001',
  E'Welcome to AbbasiConnect! 👋\n\nWe\'re excited to have you here. This is a safe space for our community to connect, support each other, and grow together.\n\nPlease introduce yourself:\n- Your name and city\n- Your profession or interests\n- What you hope to gain from this community\n- How you can contribute\n\nLooking forward to getting to know everyone!'
);

-- ============================================================================
-- INDEXES FOR SEED DATA
-- ============================================================================

-- Refresh materialized views if any
-- REFRESH MATERIALIZED VIEW IF EXISTS user_stats;

-- ============================================================================
-- NOTES
-- ============================================================================

-- 1. In production, load complete Indian pincode dataset (~150,000 records)
-- 2. Remove or secure the sample admin account
-- 3. Add more sample data as needed for testing
-- 4. Consider adding sample users for testing vouch flow (with proper consent)
-- 5. Add sample events for different cities
-- 6. Add sample help requests (anonymized)

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify seed data
DO $$
BEGIN
  RAISE NOTICE 'Seed data loaded successfully!';
  RAISE NOTICE 'Badges: %', (SELECT COUNT(*) FROM badges);
  RAISE NOTICE 'Pincodes: %', (SELECT COUNT(*) FROM pincodes);
  RAISE NOTICE 'Users: %', (SELECT COUNT(*) FROM users);
  RAISE NOTICE 'Groups: %', (SELECT COUNT(*) FROM groups);
  RAISE NOTICE 'Posts: %', (SELECT COUNT(*) FROM posts);
END $$;
