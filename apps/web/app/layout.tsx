import type { Metadata, Viewport } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';

const inter = Inter({ 
  subsets: ['latin'],
  variable: '--font-inter',
  display: 'swap',
});

export const metadata: Metadata = {
  title: 'AbbasiConnect - Community Platform for Verified Abbasi Muslims',
  description: 'A secure, exclusive community platform for verified Abbasi Muslims to connect, support, and grow together.',
  keywords: ['community', 'abbasi', 'muslim', 'social', 'networking'],
  authors: [{ name: 'AbbasiConnect Team' }],
  creator: 'AbbasiConnect',
  publisher: 'AbbasiConnect',
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  manifest: '/manifest.json',
  appleWebApp: {
    capable: true,
    statusBarStyle: 'default',
    title: 'AbbasiConnect',
  },
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://abbasiconnect.com',
    siteName: 'AbbasiConnect',
    title: 'AbbasiConnect - Community Platform',
    description: 'A secure, exclusive community platform for verified Abbasi Muslims',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'AbbasiConnect',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'AbbasiConnect - Community Platform',
    description: 'A secure, exclusive community platform for verified Abbasi Muslims',
    images: ['/og-image.png'],
  },
  robots: {
    index: false, // Private community - no public indexing
    follow: false,
    googleBot: {
      index: false,
      follow: false,
    },
  },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 5,
  userScalable: true,
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#ffffff' },
    { media: '(prefers-color-scheme: dark)', color: '#0f172a' },
  ],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={inter.variable}>
      <head>
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="icon" href="/icon.svg" type="image/svg+xml" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
      </head>
      <body className="min-h-screen bg-gray-50">
        {children}
      </body>
    </html>
  );
}
