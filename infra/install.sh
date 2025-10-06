#!/bin/bash

# AbbasiConnect Installation Script
# This script installs all dependencies and sets up the development environment

set -e

echo "🚀 Installing AbbasiConnect..."
echo ""

# Check Node.js version
echo "📦 Checking Node.js version..."
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Error: Node.js 18 or higher is required"
    echo "   Current version: $(node -v)"
    exit 1
fi
echo "✅ Node.js version: $(node -v)"
echo ""

# Install root dependencies
echo "📦 Installing root dependencies..."
npm install
echo ""

# Install web app dependencies
echo "📦 Installing web app dependencies..."
cd apps/web
npm install
cd ../..
echo ""

# Generate VAPID keys for web push
echo "🔑 Generating VAPID keys for web push notifications..."
if command -v web-push &> /dev/null; then
    echo "Generating keys..."
    web-push generate-vapid-keys
    echo ""
    echo "⚠️  Please copy these keys to your .env.local file:"
    echo "   NEXT_PUBLIC_VAPID_PUBLIC_KEY=<public key>"
    echo "   VAPID_PRIVATE_KEY=<private key>"
else
    echo "⚠️  web-push CLI not found. Install it globally:"
    echo "   npm install -g web-push"
    echo "   Then run: web-push generate-vapid-keys"
fi
echo ""

# Generate security keys
echo "🔐 Generating security keys..."
echo "JWT_SECRET=$(openssl rand -base64 32)"
echo "ENCRYPTION_KEY=$(openssl rand -base64 32)"
echo ""
echo "⚠️  Please copy these keys to your .env.local file"
echo ""

# Create .env.local if it doesn't exist
if [ ! -f "apps/web/.env.local" ]; then
    echo "📝 Creating .env.local from example..."
    cp apps/web/.env.example apps/web/.env.local
    echo "✅ Created apps/web/.env.local"
    echo "⚠️  Please update it with your credentials"
else
    echo "ℹ️  .env.local already exists"
fi
echo ""

echo "✅ Installation complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Update apps/web/.env.local with your credentials:"
echo "      - Supabase URL and keys"
echo "      - Email provider API key (Brevo/Resend)"
echo "      - VAPID keys (generated above)"
echo "      - Security keys (generated above)"
echo ""
echo "   2. Set up your Supabase project:"
echo "      - Run packages/db/schema.sql"
echo "      - Run packages/db/rls-policies.sql"
echo "      - Run packages/db/seed.sql"
echo ""
echo "   3. Start the development server:"
echo "      npm run dev"
echo ""
echo "📚 For detailed setup instructions, see docs/SETUP.md"
