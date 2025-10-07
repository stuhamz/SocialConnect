# SocialConnect

A secure, exclusive community platform for verified people built as a Progressive Web App.

## 🎯 Features

- **Secure Authentication**: Email OTP with optional phone verification
- **Community Vouching**: 3-approval verification system
- **Social Feed**: Posts, comments, likes, and reactions
- **Help Hub**: Community assistance requests and pledge tracking
- **Groups & Forums**: Public and private community groups
- **Events**: RSVP system with photo galleries
- **Search**: Find members by name, city, profession
- **Gamification**: Badges, streaks, and trust scores
- **Admin Dashboard**: Moderation and user management

## 🛠️ Tech Stack

- **Frontend**: Next.js 14, React Server Components, Tailwind CSS
- **Backend**: Supabase (Postgres, Auth, Storage, Realtime)
- **Auth**: Email OTP (Brevo/Resend), Passkeys/WebAuthn
- **Hosting**: Vercel (free tier)
- **CDN**: Cloudflare
- **Analytics**: Self-hosted Umami

## 📁 Project Structure

```
socialconnect/
├── apps/
│   └── web/              # Next.js 14 PWA
├── packages/
│   ├── db/               # Database schema and migrations
│   └── api/              # Shared API utilities
├── infra/                # Deployment scripts
└── docs/                 # Documentation
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ and npm
- Supabase account (free tier)
- Brevo or Resend account for email OTP

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd socialconnect
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp apps/web/.env.example apps/web/.env.local
```

4. Configure your `.env.local` with:
   - Supabase URL and anon key
   - Email provider credentials (Brevo/Resend)
   - VAPID keys for web push

5. Set up the database:
```bash
npm run db:setup
npm run db:migrate
npm run db:seed
```

6. Run the development server:
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## 📚 Documentation

- [Setup Guide](docs/SETUP.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [API Documentation](docs/API.md)
- [Operations Runbook](docs/RUNBOOK.md)

## 🔒 Security

- Row Level Security (RLS) on all database tables
- Email OTP with rate limiting
- Content moderation and reporting
- GDPR/DPDP compliant data handling
- Encrypted PII at rest

## 💰 Cost Structure

Target: **$0-25/month**

- Vercel Hobby: $0 (free tier)
- Supabase Free: $0 (500MB DB, 1GB storage)
- Brevo Email: $0 (300 emails/day)
- Cloudflare: $0 (free tier)

## 🤝 Contributing

This is a private community project. For contribution guidelines, please contact the maintainers.

## 📄 License

MIT License - see LICENSE file for details


---

Built with ❤️ for the community
