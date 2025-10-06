# AbbasiConnect Installation Script for Windows
# This script installs all dependencies and sets up the development environment

Write-Host "🚀 Installing AbbasiConnect..." -ForegroundColor Cyan
Write-Host ""

# Check Node.js version
Write-Host "📦 Checking Node.js version..." -ForegroundColor Yellow
try {
    $nodeVersion = node -v
    $versionNumber = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
    
    if ($versionNumber -lt 18) {
        Write-Host "❌ Error: Node.js 18 or higher is required" -ForegroundColor Red
        Write-Host "   Current version: $nodeVersion" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Node.js version: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Node.js is not installed" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Install root dependencies
Write-Host "📦 Installing root dependencies..." -ForegroundColor Yellow
npm install
Write-Host ""

# Install web app dependencies
Write-Host "📦 Installing web app dependencies..." -ForegroundColor Yellow
Set-Location apps/web
npm install
Set-Location ../..
Write-Host ""

# Generate VAPID keys for web push
Write-Host "🔑 Generating VAPID keys for web push notifications..." -ForegroundColor Yellow
$webPushInstalled = Get-Command web-push -ErrorAction SilentlyContinue

if ($webPushInstalled) {
    Write-Host "Generating keys..." -ForegroundColor Yellow
    web-push generate-vapid-keys
    Write-Host ""
    Write-Host "⚠️  Please copy these keys to your .env.local file:" -ForegroundColor Yellow
    Write-Host "   NEXT_PUBLIC_VAPID_PUBLIC_KEY=<public key>" -ForegroundColor Yellow
    Write-Host "   VAPID_PRIVATE_KEY=<private key>" -ForegroundColor Yellow
} else {
    Write-Host "⚠️  web-push CLI not found. Install it globally:" -ForegroundColor Yellow
    Write-Host "   npm install -g web-push" -ForegroundColor Yellow
    Write-Host "   Then run: web-push generate-vapid-keys" -ForegroundColor Yellow
}
Write-Host ""

# Generate security keys
Write-Host "🔐 Generating security keys..." -ForegroundColor Yellow
$jwtSecret = [Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))
$encryptionKey = [Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))

Write-Host "JWT_SECRET=$jwtSecret" -ForegroundColor Cyan
Write-Host "ENCRYPTION_KEY=$encryptionKey" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Please copy these keys to your .env.local file" -ForegroundColor Yellow
Write-Host ""

# Create .env.local if it doesn't exist
if (-not (Test-Path "apps/web/.env.local")) {
    Write-Host "📝 Creating .env.local from example..." -ForegroundColor Yellow
    Copy-Item "apps/web/.env.example" "apps/web/.env.local"
    Write-Host "✅ Created apps/web/.env.local" -ForegroundColor Green
    Write-Host "⚠️  Please update it with your credentials" -ForegroundColor Yellow
} else {
    Write-Host "ℹ️  .env.local already exists" -ForegroundColor Blue
}
Write-Host ""

Write-Host "✅ Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Update apps/web/.env.local with your credentials:" -ForegroundColor White
Write-Host "      - Supabase URL and keys" -ForegroundColor Gray
Write-Host "      - Email provider API key (Brevo/Resend)" -ForegroundColor Gray
Write-Host "      - VAPID keys (generated above)" -ForegroundColor Gray
Write-Host "      - Security keys (generated above)" -ForegroundColor Gray
Write-Host ""
Write-Host "   2. Set up your Supabase project:" -ForegroundColor White
Write-Host "      - Run packages/db/schema.sql" -ForegroundColor Gray
Write-Host "      - Run packages/db/rls-policies.sql" -ForegroundColor Gray
Write-Host "      - Run packages/db/seed.sql" -ForegroundColor Gray
Write-Host ""
Write-Host "   3. Start the development server:" -ForegroundColor White
Write-Host "      npm run dev" -ForegroundColor Gray
Write-Host ""
Write-Host "📚 For detailed setup instructions, see docs/SETUP.md" -ForegroundColor Cyan
