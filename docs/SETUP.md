# AbbasiConnect - Setup Guide

This guide will help you set up the AbbasiConnect development environment on your local machine.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** 18.x or higher ([Download](https://nodejs.org/))
- **npm** 9.x or higher (comes with Node.js)
- **Git** ([Download](https://git-scm.com/))
- A **Supabase** account ([Sign up](https://supabase.com/))
- A **Brevo** or **Resend** account for email ([Brevo](https://www.brevo.com/) | [Resend](https://resend.com/))

## Step 1: Clone the Repository

```bash
git clone <repository-url>
cd abbasiconnect
```

## Step 2: Install Dependencies

Install all project dependencies:

```bash
npm install
```

This will install dependencies for all workspaces (root, web app, and packages).

## Step 3: Set Up Supabase

### 3.1 Create a Supabase Project

1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Click "New Project"
3. Fill in the details:
   - **Name**: AbbasiConnect
   - **Database Password**: Choose a strong password (save it securely)
   - **Region**: Choose closest to your target users
4. Click "Create new project"

### 3.2 Get Your Supabase Credentials

Once your project is created:

1. Go to **Settings** → **API**
2. Copy the following:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (starts with `eyJ...`)
   - **service_role key** (starts with `eyJ...`) - Keep this secret!

### 3.3 Run Database Migrations

1. Open the Supabase SQL Editor
2. Run the schema file:
   ```sql
   -- Copy and paste contents of packages/db/schema.sql
   ```
3. Run the RLS policies:
   ```sql
   -- Copy and paste contents of packages/db/rls-policies.sql
   ```
4. Run the seed data:
   ```sql
   -- Copy and paste contents of packages/db/seed.sql
   ```

Alternatively, you can use the Supabase CLI:

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link your project
supabase link --project-ref <your-project-ref>

# Run migrations
supabase db push
```

### 3.4 Set Up Storage Buckets

In Supabase Dashboard:

1. Go to **Storage**
2. Create the following buckets:
   - `avatars` (public)
   - `posts` (public)
   - `events` (public)
   - `help-requests` (public)
   - `groups` (public)

For each bucket:
- Click "New bucket"
- Enter the name
- Set as **Public bucket**
- Click "Create bucket"

## Step 4: Set Up Email Provider

### Option A: Brevo (Recommended for MVP)

1. Sign up at [Brevo](https://www.brevo.com/)
2. Verify your email
3. Go to **SMTP & API** → **API Keys**
4. Create a new API key
5. Copy the API key

### Option B: Resend (Alternative)

1. Sign up at [Resend](https://resend.com/)
2. Verify your email
3. Go to **API Keys**
4. Create a new API key
5. Copy the API key

### Configure Sender Domain (Important!)

For better deliverability:

1. Add your domain in the email provider
2. Add DNS records (SPF, DKIM, DMARC)
3. Verify the domain

For development, you can use the default sender, but for production, use a custom domain.

## Step 5: Configure Environment Variables

1. Copy the example environment file:
   ```bash
   cp apps/web/.env.example apps/web/.env.local
   ```

2. Edit `apps/web/.env.local` and fill in your credentials:

```env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...

# App Configuration
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME=AbbasiConnect

# Email Provider (Brevo)
BREVO_API_KEY=xkeysib-...
BREVO_SENDER_EMAIL=noreply@yourdomain.com
BREVO_SENDER_NAME=AbbasiConnect

# Email Provider (Resend - Optional Fallback)
RESEND_API_KEY=re_...

# Web Push Notifications (Generate these - see below)
NEXT_PUBLIC_VAPID_PUBLIC_KEY=
VAPID_PRIVATE_KEY=
VAPID_SUBJECT=mailto:admin@yourdomain.com

# Security (Generate random strings)
JWT_SECRET=your-jwt-secret-min-32-chars
ENCRYPTION_KEY=your-encryption-key-32-chars

# Feature Flags
ENABLE_PHONE_VERIFICATION=false
ENABLE_WEBAUTHN=true
ENABLE_MATRIMONY=false
ENABLE_DONATIONS=false

# Environment
NODE_ENV=development
```

## Step 6: Generate VAPID Keys for Web Push

Web push notifications require VAPID keys:

```bash
# Install web-push globally
npm install -g web-push

# Generate VAPID keys
web-push generate-vapid-keys

# Copy the output to your .env.local
# Public Key → NEXT_PUBLIC_VAPID_PUBLIC_KEY
# Private Key → VAPID_PRIVATE_KEY
```

## Step 7: Generate Security Keys

Generate random strings for JWT and encryption:

```bash
# On Linux/Mac
openssl rand -base64 32

# On Windows (PowerShell)
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))

# Or use Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

Run this twice to generate both `JWT_SECRET` and `ENCRYPTION_KEY`.

## Step 8: Load Pincode Data

The seed file includes sample pincode data. For production, you'll need the complete Indian pincode dataset.

### Option 1: Use Sample Data (Development)

The seed file already includes ~40 sample pincodes for major cities. This is sufficient for development.

### Option 2: Load Full Dataset (Production)

1. Download the complete Indian pincode dataset (CSV format)
2. Create a script to import it:

```javascript
// scripts/import-pincodes.js
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const csv = require('csv-parser');

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const pincodes = [];

fs.createReadStream('pincodes.csv')
  .pipe(csv())
  .on('data', (row) => {
    pincodes.push({
      pincode: row.pincode,
      city: row.city,
      district: row.district,
      state: row.state,
      latitude: parseFloat(row.latitude),
      longitude: parseFloat(row.longitude),
    });
  })
  .on('end', async () => {
    console.log(`Importing ${pincodes.length} pincodes...`);
    
    // Insert in batches of 1000
    for (let i = 0; i < pincodes.length; i += 1000) {
      const batch = pincodes.slice(i, i + 1000);
      const { error } = await supabase.from('pincodes').insert(batch);
      
      if (error) {
        console.error('Error:', error);
      } else {
        console.log(`Imported ${i + batch.length} pincodes`);
      }
    }
    
    console.log('Import complete!');
  });
```

## Step 9: Run the Development Server

Start the development server:

```bash
npm run dev
```

The app will be available at [http://localhost:3000](http://localhost:3000)

## Step 10: Verify Setup

1. Open [http://localhost:3000](http://localhost:3000)
2. You should see the AbbasiConnect landing page
3. Try signing up with an email
4. Check that you receive the OTP email
5. Complete the verification

## Troubleshooting

### Issue: "Cannot find module '@supabase/supabase-js'"

**Solution**: Run `npm install` in the root directory

### Issue: "Invalid Supabase URL"

**Solution**: Check that your `.env.local` has the correct Supabase URL without trailing slash

### Issue: "Email not sending"

**Solution**: 
- Verify your email provider API key
- Check that sender email is verified
- Look at the server logs for detailed error messages

### Issue: "Database connection error"

**Solution**:
- Verify Supabase project is active
- Check that RLS policies are applied
- Ensure service role key is correct

### Issue: "Module not found" errors

**Solution**: 
- Delete `node_modules` and `.next` folders
- Run `npm install` again
- Restart the dev server

## Next Steps

- Read the [API Documentation](./API.md)
- Review the [Deployment Guide](./DEPLOYMENT.md)
- Check the [Operations Runbook](./RUNBOOK.md)
- Start building features!

## Getting Help

If you encounter issues:

1. Check the [TODO.md](../TODO.md) for known issues
2. Review the error logs in the terminal
3. Check Supabase logs in the dashboard
4. Contact the development team

## Development Tips

- Use the Supabase Dashboard to inspect database tables
- Enable verbose logging in development
- Use the Network tab to debug API calls
- Test with multiple user accounts
- Keep your `.env.local` file secure and never commit it

---

**Ready to build!** 🚀
