# AbbasiConnect - Deployment Guide

Complete guide to deploying AbbasiConnect to production.

---

## 📋 Pre-Deployment Checklist

### 1. Code Preparation
- [ ] All dependencies installed
- [ ] TypeScript compiles without errors
- [ ] All tests passing (when implemented)
- [ ] Environment variables documented
- [ ] Secrets generated and secured
- [ ] Git repository clean

### 2. Database Setup
- [ ] Supabase project created
- [ ] Schema migrations applied
- [ ] RLS policies enabled
- [ ] Seed data loaded
- [ ] Indexes created
- [ ] Backup strategy configured

### 3. External Services
- [ ] Email provider configured (Brevo/Resend)
- [ ] Domain registered
- [ ] DNS configured
- [ ] SSL certificate ready
- [ ] CDN configured (Cloudflare)

### 4. Security
- [ ] Strong secrets generated
- [ ] Service role key secured
- [ ] Rate limiting configured
- [ ] CORS settings reviewed
- [ ] Security headers configured

---

## 🚀 Deployment Steps

### Step 1: Set Up Supabase (15 minutes)

1. **Create Project**
   ```
   1. Go to https://app.supabase.com
   2. Click "New Project"
   3. Choose organization
   4. Enter project name: "abbasiconnect-prod"
   5. Generate strong database password
   6. Select region closest to users (e.g., Mumbai for India)
   7. Wait for project to initialize (~2 minutes)
   ```

2. **Run Database Migrations**
   ```
   1. Go to SQL Editor in Supabase dashboard
   2. Create new query
   3. Copy contents of packages/db/schema.sql
   4. Run query
   5. Verify all tables created (should see 24 tables)
   
   6. Create new query
   7. Copy contents of packages/db/rls-policies.sql
   8. Run query
   9. Verify policies created
   
   10. Create new query
   11. Copy contents of packages/db/seed.sql
   12. Run query
   13. Verify seed data loaded
   ```

3. **Get API Keys**
   ```
   1. Go to Settings > API
   2. Copy Project URL
   3. Copy anon/public key
   4. Copy service_role key (keep secure!)
   ```

4. **Configure Storage**
   ```
   1. Go to Storage
   2. Create bucket: "avatars"
      - Public: Yes
      - File size limit: 5MB
      - Allowed MIME types: image/jpeg, image/png, image/webp
   
   3. Create bucket: "posts"
      - Public: Yes
      - File size limit: 5MB
      - Allowed MIME types: image/jpeg, image/png, image/webp
   
   4. Set up RLS policies for buckets (see storage-policies.sql)
   ```

### Step 2: Configure Email Provider (10 minutes)

#### Option A: Brevo (Recommended)

1. **Create Account**
   ```
   1. Go to https://app.brevo.com
   2. Sign up for free account
   3. Verify email
   ```

2. **Get API Key**
   ```
   1. Go to Settings > SMTP & API
   2. Click "Generate a new API key"
   3. Name it "AbbasiConnect Production"
   4. Copy the key
   ```

3. **Configure Domain**
   ```
   1. Go to Senders & IP
   2. Add domain: abbasiconnect.com
   3. Add DNS records:
      - SPF: v=spf1 include:spf.brevo.com ~all
      - DKIM: (provided by Brevo)
      - DMARC: v=DMARC1; p=none; rua=mailto:admin@abbasiconnect.com
   4. Verify domain
   ```

4. **Create Email Template**
   ```
   1. Go to Templates
   2. Create new template
   3. Name: "OTP Verification"
   4. Subject: "Your AbbasiConnect verification code"
   5. Body: See email-templates/otp.html
   ```

#### Option B: Resend (Alternative)

1. **Create Account**
   ```
   1. Go to https://resend.com
   2. Sign up for free account
   3. Verify email
   ```

2. **Get API Key**
   ```
   1. Go to API Keys
   2. Create new key
   3. Name it "AbbasiConnect Production"
   4. Copy the key
   ```

3. **Add Domain**
   ```
   1. Go to Domains
   2. Add domain: abbasiconnect.com
   3. Add DNS records provided
   4. Verify domain
   ```

### Step 3: Deploy to Vercel (15 minutes)

1. **Prepare Repository**
   ```bash
   # Initialize git if not already done
   cd C:/Users/hamza/Desktop/abbasiconnect
   git init
   git add .
   git commit -m "Initial commit - AbbasiConnect MVP"
   
   # Create GitHub repository
   # Go to https://github.com/new
   # Create repository: abbasiconnect
   
   # Push code
   git remote add origin https://github.com/yourusername/abbasiconnect.git
   git branch -M main
   git push -u origin main
   ```

2. **Connect to Vercel**
   ```
   1. Go to https://vercel.com
   2. Sign up/login with GitHub
   3. Click "Add New Project"
   4. Import your GitHub repository
   5. Configure project:
      - Framework Preset: Next.js
      - Root Directory: apps/web
      - Build Command: npm run build
      - Output Directory: .next
   ```

3. **Add Environment Variables**
   ```
   In Vercel project settings > Environment Variables, add:
   
   NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
   SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
   
   BREVO_API_KEY=your-brevo-api-key
   EMAIL_FROM=noreply@abbasiconnect.com
   EMAIL_FROM_NAME=AbbasiConnect
   
   NEXT_PUBLIC_APP_URL=https://abbasiconnect.com
   
   SESSION_SECRET=your-generated-secret
   JWT_SECRET=your-generated-secret
   
   NODE_ENV=production
   
   # Feature flags
   NEXT_PUBLIC_ENABLE_COMMENTS=true
   NEXT_PUBLIC_ENABLE_IMAGE_UPLOAD=true
   NEXT_PUBLIC_ENABLE_HELP_HUB=true
   NEXT_PUBLIC_ENABLE_GROUPS=true
   NEXT_PUBLIC_ENABLE_EVENTS=true
   ```

4. **Deploy**
   ```
   1. Click "Deploy"
   2. Wait for build to complete (~2-3 minutes)
   3. Get deployment URL: https://abbasiconnect.vercel.app
   ```

### Step 4: Configure Custom Domain (10 minutes)

1. **Add Domain to Vercel**
   ```
   1. Go to Project Settings > Domains
   2. Add domain: abbasiconnect.com
   3. Add domain: www.abbasiconnect.com
   ```

2. **Configure DNS (Cloudflare)**
   ```
   1. Go to Cloudflare dashboard
   2. Select your domain
   3. Go to DNS > Records
   4. Add records:
      
      Type: CNAME
      Name: @
      Target: cname.vercel-dns.com
      Proxy: Yes (orange cloud)
      
      Type: CNAME
      Name: www
      Target: cname.vercel-dns.com
      Proxy: Yes (orange cloud)
   ```

3. **Enable SSL**
   ```
   1. In Cloudflare: SSL/TLS > Overview
   2. Set to "Full (strict)"
   3. Wait for SSL certificate to provision (~5 minutes)
   ```

4. **Configure Cloudflare Settings**
   ```
   1. Speed > Optimization
      - Auto Minify: Enable all
      - Brotli: Enable
      - Early Hints: Enable
   
   2. Caching > Configuration
      - Caching Level: Standard
      - Browser Cache TTL: 4 hours
   
   3. Security > Settings
      - Security Level: Medium
      - Challenge Passage: 30 minutes
   ```

### Step 5: Configure PWA (5 minutes)

1. **Generate VAPID Keys**
   ```bash
   npx web-push generate-vapid-keys
   ```

2. **Add to Environment Variables**
   ```
   NEXT_PUBLIC_VAPID_PUBLIC_KEY=your-public-key
   VAPID_PRIVATE_KEY=your-private-key
   VAPID_SUBJECT=mailto:admin@abbasiconnect.com
   ```

3. **Redeploy**
   ```
   git add .
   git commit -m "Add VAPID keys"
   git push
   ```

### Step 6: Set Up Monitoring (10 minutes)

1. **Vercel Analytics**
   ```
   1. Go to Project > Analytics
   2. Enable Web Analytics
   3. Enable Speed Insights
   ```

2. **Supabase Monitoring**
   ```
   1. Go to Project > Reports
   2. Review database performance
   3. Set up alerts for:
      - Database size > 400MB
      - API requests > 45k/day
      - Storage > 900MB
   ```

3. **Uptime Monitoring** (Optional)
   ```
   Use UptimeRobot (free):
   1. Go to https://uptimerobot.com
   2. Add monitor:
      - Type: HTTPS
      - URL: https://abbasiconnect.com
      - Interval: 5 minutes
   3. Add alert contacts
   ```

---

## 🔒 Security Hardening

### 1. Supabase Security

```sql
-- Verify RLS is enabled on all tables
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND rowsecurity = false;

-- Should return no rows

-- Review policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE schemaname = 'public';
```

### 2. API Rate Limiting

Add to `middleware.ts`:
```typescript
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  // Add security headers
  const response = NextResponse.next();
  
  response.headers.set('X-Frame-Options', 'DENY');
  response.headers.set('X-Content-Type-Options', 'nosniff');
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  response.headers.set('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
  
  return response;
}
```

### 3. Environment Variables

```bash
# Rotate secrets every 90 days
openssl rand -base64 32  # New SESSION_SECRET
openssl rand -base64 32  # New JWT_SECRET

# Update in Vercel
# Redeploy
```

---

## 📊 Post-Deployment Verification

### 1. Smoke Tests

```bash
# Test homepage
curl -I https://abbasiconnect.com
# Should return 200

# Test API
curl https://abbasiconnect.com/api/health
# Should return {"status": "ok"}

# Test signup
# Go to https://abbasiconnect.com/signup
# Enter email
# Verify OTP received

# Test login
# Go to https://abbasiconnect.com/login
# Enter email
# Verify OTP received

# Test feed
# Complete onboarding
# Verify feed loads
# Create post
# Like post
```

### 2. Performance Tests

```bash
# Lighthouse audit
npx lighthouse https://abbasiconnect.com --view

# Target scores:
# Performance: > 90
# Accessibility: > 95
# Best Practices: > 95
# SEO: > 90
# PWA: > 90
```

### 3. Security Tests

```bash
# SSL test
https://www.ssllabs.com/ssltest/analyze.html?d=abbasiconnect.com
# Target: A+ rating

# Security headers
https://securityheaders.com/?q=abbasiconnect.com
# Target: A rating
```

---

## 🔄 Continuous Deployment

### GitHub Actions Workflow

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: |
          npm install
          cd apps/web && npm install
          
      - name: Run tests
        run: npm test
        
      - name: Build
        run: cd apps/web && npm run build
        
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

---

## 📈 Scaling Considerations

### When to Upgrade

| Metric | Free Tier Limit | Upgrade Trigger | Next Tier |
|--------|----------------|-----------------|-----------|
| Database Size | 500MB | > 400MB | Supabase Pro ($25/mo) |
| Storage | 1GB | > 800MB | Supabase Pro ($25/mo) |
| API Requests | 50k/day | > 40k/day | Supabase Pro ($25/mo) |
| Emails | 300/day | > 250/day | Brevo Lite ($25/mo) |
| Bandwidth | 100GB/mo | > 80GB/mo | Vercel Pro ($20/mo) |

### Optimization Tips

1. **Database**
   - Add indexes on frequently queried columns
   - Use database functions for complex queries
   - Enable connection pooling
   - Archive old data

2. **Images**
   - Compress before upload
   - Use WebP format
   - Implement lazy loading
   - Use CDN for delivery

3. **API**
   - Implement caching
   - Use pagination
   - Optimize queries
   - Add request batching

---

## 🐛 Troubleshooting

### Common Issues

1. **Build Fails**
   ```
   Error: Module not found
   Solution: Check package.json, run npm install
   ```

2. **Database Connection Fails**
   ```
   Error: Invalid API key
   Solution: Verify SUPABASE_URL and keys in env vars
   ```

3. **Email Not Sending**
   ```
   Error: 401 Unauthorized
   Solution: Verify BREVO_API_KEY, check domain verification
   ```

4. **RLS Blocking Queries**
   ```
   Error: Row level security policy violation
   Solution: Review RLS policies, check user authentication
   ```

5. **Slow Performance**
   ```
   Issue: Pages loading slowly
   Solution: Check database indexes, optimize queries, enable caching
   ```

---

## 📞 Support

### Resources
- Supabase Docs: https://supabase.com/docs
- Vercel Docs: https://vercel.com/docs
- Next.js Docs: https://nextjs.org/docs
- Brevo Docs: https://developers.brevo.com

### Community
- GitHub Issues: https://github.com/yourusername/abbasiconnect/issues
- Discord: (create community server)
- Email: support@abbasiconnect.com

---

## ✅ Deployment Complete!

Your AbbasiConnect app is now live at:
- **Production**: https://abbasiconnect.com
- **Admin**: https://abbasiconnect.com/admin
- **API**: https://abbasiconnect.com/api

Next steps:
1. Monitor error logs
2. Track user signups
3. Gather feedback
4. Plan next features
5. Celebrate! 🎉
