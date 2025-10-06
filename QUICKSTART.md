# AbbasiConnect - Quick Start Guide

**Get up and running in 15 minutes!** ⚡

---

## 🎯 What You'll Get

After following this guide, you'll have:
- ✅ A working Next.js PWA
- ✅ Database with 24 tables
- ✅ Authentication system
- ✅ Social feed
- ✅ Vouch system
- ✅ All running locally

---

## 📋 Prerequisites (2 minutes)

Check you have these installed:

```bash
# Node.js 18 or higher
node --version
# Should show v18.x.x or higher

# npm
npm --version
# Should show 9.x.x or higher
```

Don't have Node.js? Download from [nodejs.org](https://nodejs.org/)

---

## 🚀 Step 1: Install Dependencies (3 minutes)

```bash
# Navigate to project
cd C:/Users/hamza/Desktop/abbasiconnect

# Install root dependencies
npm install

# Install web app dependencies
cd apps/web
npm install

# Go back to root
cd ../..
```

**Wait for installation to complete** (this may take 2-3 minutes)

---

## 🗄️ Step 2: Set Up Supabase (5 minutes)

### 2.1 Create Account
1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign up with GitHub (recommended) or email

### 2.2 Create Project
1. Click "New Project"
2. Choose your organization (or create one)
3. Enter project details:
   - **Name**: `abbasiconnect-dev`
   - **Database Password**: Generate a strong password (save it!)
   - **Region**: Choose closest to you (e.g., Mumbai for India)
4. Click "Create new project"
5. **Wait 2 minutes** for project to initialize

### 2.3 Run Database Migrations
1. In Supabase dashboard, click "SQL Editor" in left sidebar
2. Click "New query"
3. Open `C:/Users/hamza/Desktop/abbasiconnect/packages/db/schema.sql`
4. Copy ALL contents
5. Paste into Supabase SQL Editor
6. Click "Run" (bottom right)
7. Wait for success message

8. Click "New query" again
9. Open `packages/db/rls-policies.sql`
10. Copy ALL contents
11. Paste and click "Run"

12. Click "New query" again
13. Open `packages/db/seed.sql`
14. Copy ALL contents
15. Paste and click "Run"

### 2.4 Get API Keys
1. Click "Settings" (gear icon) in left sidebar
2. Click "API" under Project Settings
3. Copy these values (you'll need them next):
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon public** key (long string starting with `eyJ...`)
   - **service_role** key (long string starting with `eyJ...`)

---

## 📧 Step 3: Set Up Email (3 minutes)

### Option A: Brevo (Recommended)

1. Go to [brevo.com](https://www.brevo.com)
2. Click "Sign up free"
3. Complete registration
4. Go to Settings > SMTP & API
5. Click "Generate a new API key"
6. Name it "AbbasiConnect Dev"
7. Copy the API key

### Option B: Resend (Alternative)

1. Go to [resend.com](https://resend.com)
2. Sign up
3. Go to API Keys
4. Create new key
5. Copy the key

---

## ⚙️ Step 4: Configure Environment (2 minutes)

```bash
# Navigate to web app
cd C:/Users/hamza/Desktop/abbasiconnect/apps/web

# Copy example file
copy .env.example .env.local
# On Mac/Linux: cp .env.example .env.local

# Open .env.local in notepad
notepad .env.local
# On Mac: nano .env.local
```

**Fill in these values:**

```env
# Supabase (from Step 2.4)
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# Email (from Step 3)
BREVO_API_KEY=your-brevo-api-key-here
EMAIL_FROM=noreply@yourdomain.com
EMAIL_FROM_NAME=AbbasiConnect

# App URL
NEXT_PUBLIC_APP_URL=http://localhost:3000

# Secrets (generate random strings)
SESSION_SECRET=any-random-string-at-least-32-characters-long
JWT_SECRET=another-random-string-at-least-32-characters

# Environment
NODE_ENV=development
```

**To generate secure secrets:**
```bash
# Windows PowerShell
-join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | % {[char]$_})

# Mac/Linux
openssl rand -base64 32
```

**Save and close the file**

---

## 🎬 Step 5: Start Development Server (1 minute)

```bash
# Make sure you're in apps/web directory
cd C:/Users/hamza/Desktop/abbasiconnect/apps/web

# Start the server
npm run dev
```

You should see:
```
▲ Next.js 14.x.x
- Local:        http://localhost:3000
- Ready in 2.5s
```

---

## 🎉 Step 6: Test It Out!

### Open Your Browser
Go to: **http://localhost:3000**

### Test the Flow

1. **Landing Page**
   - You should see the AbbasiConnect landing page
   - Click "Get Started" or "Sign Up"

2. **Sign Up**
   - Enter your email address
   - Click "Send Code"
   - Check your email for OTP

3. **Verify OTP**
   - Enter the 6-digit code
   - It should auto-submit
   - You'll be redirected to profile completion

4. **Complete Profile**
   - Enter your name
   - Select city (e.g., Delhi)
   - Select pincode
   - Enter profession
   - Add lineage note
   - Click "Continue"

5. **Vouch Request**
   - You'll see "Waiting for Vouches"
   - Shows 0/3 vouches
   - This is normal for new accounts

6. **Access Feed (Using Seed Data)**
   - Open Supabase dashboard
   - Go to Table Editor > users
   - Find your user
   - Change `status` from `awaiting_vouches` to `verified`
   - Refresh the page
   - You should now see the feed!

7. **Create a Post**
   - Click "Post" button
   - Write something
   - Click "Post"
   - Your post appears in the feed!

8. **Like a Post**
   - Click the heart icon
   - Count increases
   - Click again to unlike

---

## ✅ Success Checklist

You should now have:
- [x] Project running on http://localhost:3000
- [x] Database with 24 tables
- [x] Can sign up with email
- [x] Receive OTP emails
- [x] Complete profile
- [x] See vouch status
- [x] Access feed (after manual verification)
- [x] Create posts
- [x] Like posts

---

## 🐛 Troubleshooting

### "Module not found" errors
```bash
# Delete node_modules and reinstall
cd C:/Users/hamza/Desktop/abbasiconnect
rm -rf node_modules apps/web/node_modules
npm install
cd apps/web
npm install
```

### "Cannot connect to Supabase"
- Check your `.env.local` file
- Verify SUPABASE_URL and keys are correct
- Make sure there are no extra spaces
- Restart the dev server

### "Email not sending"
- Check BREVO_API_KEY is correct
- Verify your Brevo account is active
- Check spam folder
- Try with a different email address

### "Database error"
- Make sure you ran all 3 SQL files in order:
  1. schema.sql
  2. rls-policies.sql
  3. seed.sql
- Check for any error messages in Supabase SQL Editor

### Port 3000 already in use
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Mac/Linux
lsof -ti:3000 | xargs kill -9
```

### TypeScript errors in VS Code
- These are expected until dependencies are installed
- Run `npm install` in both root and apps/web
- Restart VS Code

---

## 📚 Next Steps

Now that you're up and running:

1. **Read the Documentation**
   - `FINAL_STATUS.md` - Complete project status
   - `docs/SETUP.md` - Detailed setup guide
   - `PROJECT_SUMMARY.md` - Architecture overview

2. **Explore the Code**
   - `apps/web/app/` - All pages
   - `apps/web/components/` - UI components
   - `apps/web/app/api/` - API routes
   - `packages/db/` - Database schema

3. **Start Developing**
   - Check `TODO.md` for next tasks
   - Comments system is next priority
   - Image upload after that

4. **Join Development**
   - Read `CONTRIBUTING.md` (coming soon)
   - Check GitHub issues
   - Submit pull requests

---

## 🎯 What's Working

✅ **Authentication**
- Email OTP signup
- Email OTP login
- Session management
- Rate limiting

✅ **Onboarding**
- Profile completion
- City/pincode selection
- Vouch request
- Status tracking

✅ **Social Feed**
- View posts
- Create posts
- Like/unlike
- Rate limiting (3 posts/day)

✅ **Security**
- Row Level Security
- Input validation
- Rate limiting
- Session tokens

---

## 🚧 What's Coming

⏳ **Next Features**
- Comments system
- Image upload
- User profiles
- Search functionality
- Help Hub
- Groups & Forums
- Events
- Notifications

---

## 💡 Pro Tips

1. **Use Seed Data**
   - The seed.sql file creates test users
   - Use these to test vouching
   - Email: test1@example.com, test2@example.com, etc.

2. **Check Supabase Logs**
   - Go to Logs in Supabase dashboard
   - See all database queries
   - Debug issues easily

3. **Use Browser DevTools**
   - Open Console (F12)
   - Check Network tab for API calls
   - See any errors

4. **Hot Reload**
   - Changes auto-reload
   - No need to restart server
   - Just save and refresh

5. **Database GUI**
   - Use Supabase Table Editor
   - View and edit data easily
   - Test RLS policies

---

## 📞 Need Help?

- 📖 **Documentation**: Check `docs/` folder
- 🐛 **Issues**: Create GitHub issue
- 💬 **Questions**: Check `FINAL_STATUS.md`
- 📧 **Email**: support@abbasiconnect.com

---

## 🎊 You're All Set!

**Congratulations!** You now have a fully functional community platform running locally.

**Time to build something amazing!** 🚀

---

**Project Location**: `C:/Users/hamza/Desktop/abbasiconnect/`  
**Dev Server**: http://localhost:3000  
**Status**: Ready for development  
**Next**: Start building features!

---

*Happy coding! 🌙*
