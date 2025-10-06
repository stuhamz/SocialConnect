import Link from 'next/link';
import { ArrowRightIcon, ShieldCheckIcon, UsersIcon, HeartIcon, CalendarIcon } from '@heroicons/react/24/outline';

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 via-white to-secondary-50">
      {/* Header */}
      <header className="container-custom py-6">
        <nav className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <div className="h-10 w-10 rounded-lg bg-gradient-to-br from-primary-600 to-secondary-600 flex items-center justify-center text-white font-bold text-xl">
              A
            </div>
            <span className="text-2xl font-bold gradient-text">AbbasiConnect</span>
          </div>
          <div className="flex items-center space-x-4">
            <Link href="/auth/login" className="text-gray-600 hover:text-gray-900 font-medium">
              Login
            </Link>
            <Link href="/auth/signup" className="btn btn-primary btn-md">
              Get Started
            </Link>
          </div>
        </nav>
      </header>

      {/* Hero Section */}
      <section className="container-custom py-20 text-center">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-5xl md:text-6xl font-bold text-gray-900 mb-6">
            Connect with Your
            <span className="gradient-text"> Community</span>
          </h1>
          <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
            A secure, exclusive platform for verified Abbasi Muslims to connect, support each other, and grow together.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Link href="/auth/signup" className="btn btn-primary btn-lg w-full sm:w-auto">
              Join the Community
              <ArrowRightIcon className="ml-2 h-5 w-5" />
            </Link>
            <Link href="#features" className="btn btn-secondary btn-lg w-full sm:w-auto">
              Learn More
            </Link>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="container-custom py-20">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            Built for Our Community
          </h2>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            Everything you need to connect, support, and grow with fellow community members
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
          {/* Feature 1 */}
          <div className="card card-body text-center">
            <div className="inline-flex items-center justify-center h-16 w-16 rounded-full bg-primary-100 text-primary-600 mx-auto mb-4">
              <ShieldCheckIcon className="h-8 w-8" />
            </div>
            <h3 className="text-xl font-semibold text-gray-900 mb-2">
              Verified Members
            </h3>
            <p className="text-gray-600">
              Community-driven verification with 3-vouch system ensures authenticity
            </p>
          </div>

          {/* Feature 2 */}
          <div className="card card-body text-center">
            <div className="inline-flex items-center justify-center h-16 w-16 rounded-full bg-secondary-100 text-secondary-600 mx-auto mb-4">
              <UsersIcon className="h-8 w-8" />
            </div>
            <h3 className="text-xl font-semibold text-gray-900 mb-2">
              Groups & Forums
            </h3>
            <p className="text-gray-600">
              Join city chapters, professional networks, and interest-based groups
            </p>
          </div>

          {/* Feature 3 */}
          <div className="card card-body text-center">
            <div className="inline-flex items-center justify-center h-16 w-16 rounded-full bg-success-100 text-success-600 mx-auto mb-4">
              <HeartIcon className="h-8 w-8" />
            </div>
            <h3 className="text-xl font-semibold text-gray-900 mb-2">
              Help Hub
            </h3>
            <p className="text-gray-600">
              Request and provide assistance for financial, medical, and educational needs
            </p>
          </div>

          {/* Feature 4 */}
          <div className="card card-body text-center">
            <div className="inline-flex items-center justify-center h-16 w-16 rounded-full bg-warning-100 text-warning-600 mx-auto mb-4">
              <CalendarIcon className="h-8 w-8" />
            </div>
            <h3 className="text-xl font-semibold text-gray-900 mb-2">
              Events
            </h3>
            <p className="text-gray-600">
              Organize and attend community events in your city
            </p>
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section className="bg-white py-20">
        <div className="container-custom">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-4">
              How It Works
            </h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Simple steps to join our verified community
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
            {/* Step 1 */}
            <div className="text-center">
              <div className="inline-flex items-center justify-center h-16 w-16 rounded-full bg-primary-600 text-white font-bold text-2xl mb-4">
                1
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                Sign Up
              </h3>
              <p className="text-gray-600">
                Create your account with email verification and complete your profile
              </p>
            </div>

            {/* Step 2 */}
            <div className="text-center">
              <div className="inline-flex items-center justify-center h-16 w-16 rounded-full bg-primary-600 text-white font-bold text-2xl mb-4">
                2
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                Get Vouched
              </h3>
              <p className="text-gray-600">
                Receive 3 vouches from verified members who know you
              </p>
            </div>

            {/* Step 3 */}
            <div className="text-center">
              <div className="inline-flex items-center justify-center h-16 w-16 rounded-full bg-primary-600 text-white font-bold text-2xl mb-4">
                3
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                Connect & Grow
              </h3>
              <p className="text-gray-600">
                Access all features and start connecting with the community
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="container-custom py-20">
        <div className="card card-body text-center bg-gradient-to-r from-primary-600 to-secondary-600 text-white">
          <h2 className="text-4xl font-bold mb-4">
            Ready to Join?
          </h2>
          <p className="text-xl mb-8 opacity-90 max-w-2xl mx-auto">
            Be part of a growing community of verified Abbasi Muslims supporting each other
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Link href="/auth/signup" className="btn bg-white text-primary-600 hover:bg-gray-100 btn-lg w-full sm:w-auto">
              Create Account
              <ArrowRightIcon className="ml-2 h-5 w-5" />
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-gray-400 py-12">
        <div className="container-custom">
          <div className="grid md:grid-cols-4 gap-8 mb-8">
            <div>
              <div className="flex items-center space-x-2 mb-4">
                <div className="h-8 w-8 rounded-lg bg-gradient-to-br from-primary-600 to-secondary-600 flex items-center justify-center text-white font-bold">
                  A
                </div>
                <span className="text-xl font-bold text-white">AbbasiConnect</span>
              </div>
              <p className="text-sm">
                A secure community platform for verified Abbasi Muslims
              </p>
            </div>

            <div>
              <h3 className="text-white font-semibold mb-4">Community</h3>
              <ul className="space-y-2 text-sm">
                <li><Link href="/about" className="hover:text-white">About Us</Link></li>
                <li><Link href="/guidelines" className="hover:text-white">Guidelines</Link></li>
                <li><Link href="/help" className="hover:text-white">Help Center</Link></li>
              </ul>
            </div>

            <div>
              <h3 className="text-white font-semibold mb-4">Legal</h3>
              <ul className="space-y-2 text-sm">
                <li><Link href="/terms" className="hover:text-white">Terms of Service</Link></li>
                <li><Link href="/privacy" className="hover:text-white">Privacy Policy</Link></li>
                <li><Link href="/acceptable-use" className="hover:text-white">Acceptable Use</Link></li>
              </ul>
            </div>

            <div>
              <h3 className="text-white font-semibold mb-4">Contact</h3>
              <ul className="space-y-2 text-sm">
                <li>support@abbasiconnect.com</li>
                <li>grievance@abbasiconnect.com</li>
              </ul>
            </div>
          </div>

          <div className="border-t border-gray-800 pt-8 text-center text-sm">
            <p>&copy; {new Date().getFullYear()} AbbasiConnect. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
