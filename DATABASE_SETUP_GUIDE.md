# 🗄️ Database Setup Guide

## ⚠️ CRITICAL: You must complete this step for the app to work!

Your application is running but needs the database to be set up. Follow these exact steps:

---

## Step 1: Access Supabase Dashboard

1. Go to https://supabase.com
2. Sign in to your account  
3. Open your project: **qpeidpngxzariahjdmgl**
4. Click **"SQL Editor"** in the left sidebar

---

## Step 2: Run Database Files (In This Order!)

### 🔹 File 1: Schema (Creates Tables)

1. Click **"New query"** in SQL Editor
2. Copy the ENTIRE contents of `packages/db/schema.sql` 
3. Paste into the SQL Editor
4. Click **"Run"** (bottom right)
5. Wait for success message ✅

**What this does:** Creates 24 database tables including users, posts, vouches, etc.

### 🔹 File 2: Security Policies  

1. Click **"New query"** again
2. Copy the ENTIRE contents of `packages/db/rls-policies.sql`
3. Paste into the SQL Editor  
4. Click **"Run"**
5. Wait for success message ✅

**What this does:** Sets up Row Level Security to protect user data

### 🔹 File 3: Test Data

1. Click **"New query"** again
2. Copy the ENTIRE contents of `packages/db/seed.sql`
3. Paste into the SQL Editor
4. Click **"Run"**  
5. Wait for success message ✅

**What this does:** Adds test users and sample data for testing

---

## Step 3: Verify Setup

After running all 3 files:

1. Go to **"Table Editor"** in Supabase dashboard
2. You should see 24+ tables listed
3. Click on **"users"** table - should have some test data

---

## Step 4: Test Your App

1. Go back to: https://work-1-wgcytztucyrafgsi.prod-runtime.all-hands.dev
2. Click **"Get Started"** or **"Join the Community"**
3. You should now see the signup form (not 404)
4. Try signing up with your email
5. Check your email for the OTP code

---

## 🎯 What Each File Contains

### schema.sql (636 lines)
- 24 database tables
- User accounts, posts, comments, vouches
- Groups, events, help requests
- All the core functionality

### rls-policies.sql (644 lines)  
- Security rules for each table
- Ensures users can only see their own data
- Protects against unauthorized access

### seed.sql (267 lines)
- Test user accounts
- Sample posts and comments  
- City and pincode data
- Helps you test the app immediately

---

## 🚨 Troubleshooting

### "Syntax Error" in SQL
- Make sure you copied the ENTIRE file
- Don't skip any lines at the beginning or end
- Run files in the correct order (schema → policies → seed)

### "Permission Denied"
- Make sure you're signed in to the correct Supabase account
- Verify you're in the right project (qpeidpngxzariahjdmgl)

### Still Getting 404 on Signup
- Check that all 3 SQL files ran successfully
- Look for any error messages in the SQL Editor
- Refresh your browser after database setup

---

## 📧 Test Email Accounts (After Setup)

Once database is set up, you can test with these accounts:

- test1@example.com
- test2@example.com  
- test3@example.com

These are pre-created in the seed data for testing vouching system.

---

## ✅ Success Checklist

After completing database setup, you should be able to:

- [x] See signup form (not 404)
- [x] Enter email and receive OTP
- [x] Complete profile setup
- [x] See "waiting for vouches" status
- [x] Access the social feed (after manual verification)

---

## 🎉 You're All Set!

Once the database is set up, your SocialConnect app will be fully functional with:

- ✅ Email authentication with OTP
- ✅ Profile creation and verification
- ✅ Social feed with posts and likes
- ✅ Vouch system for community verification
- ✅ Help Hub for assistance requests
- ✅ Groups and events (coming soon)

**Your app URL:** https://work-1-wgcytztucyrafgsi.prod-runtime.all-hands.dev

---

*Need help? The database files are located in `/workspace/project/SocialConnect/packages/db/`*