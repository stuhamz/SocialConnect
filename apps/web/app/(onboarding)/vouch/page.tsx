'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Button from '@/components/ui/Button';
import Avatar from '@/components/ui/Avatar';
import { CheckCircleIcon, ClockIcon, UserGroupIcon } from '@heroicons/react/24/outline';

interface VouchStatus {
  totalVouches: number;
  requiredVouches: number;
  status: 'awaiting_vouches' | 'verified';
  vouchers: Array<{
    id: string;
    name: string;
    photo_url: string | null;
    decision: string;
    created_at: string;
  }>;
}

export default function VouchRequestPage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(true);
  const [vouchStatus, setVouchStatus] = useState<VouchStatus | null>(null);

  useEffect(() => {
    loadVouchStatus();
    // Poll for updates every 10 seconds
    const interval = setInterval(loadVouchStatus, 10000);
    return () => clearInterval(interval);
  }, []);

  const loadVouchStatus = async () => {
    try {
      const response = await fetch('/api/vouch/status');
      const data = await response.json();
      setVouchStatus(data);
      
      // If verified, redirect to feed
      if (data.status === 'verified') {
        setTimeout(() => {
          router.push('/feed');
        }, 2000);
      }
    } catch (err) {
      console.error('Failed to load vouch status:', err);
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-primary-50 via-white to-secondary-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  const progress = vouchStatus ? (vouchStatus.totalVouches / vouchStatus.requiredVouches) * 100 : 0;
  const isVerified = vouchStatus?.status === 'verified';

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 via-white to-secondary-50 flex items-center justify-center p-4">
      <div className="w-full max-w-2xl">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center h-16 w-16 rounded-2xl bg-gradient-to-br from-primary-600 to-secondary-600 text-white font-bold text-2xl mb-4">
            A
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            {isVerified ? 'Welcome to AbbasiConnect!' : 'Community Verification'}
          </h1>
          <p className="text-gray-600">
            {isVerified 
              ? 'Your account has been verified by the community'
              : 'Waiting for community members to vouch for you'
            }
          </p>
        </div>

        {/* Progress */}
        <div className="mb-8">
          <div className="flex items-center justify-center gap-2">
            <div className="flex items-center">
              <div className="h-8 w-8 rounded-full bg-success-600 text-white flex items-center justify-center text-sm font-semibold">
                ✓
              </div>
              <span className="ml-2 text-sm font-medium text-gray-900">Profile</span>
            </div>
            <div className="h-0.5 w-12 bg-primary-600"></div>
            <div className="flex items-center">
              <div className={`h-8 w-8 rounded-full flex items-center justify-center text-sm font-semibold ${
                isVerified ? 'bg-success-600 text-white' : 'bg-primary-600 text-white'
              }`}>
                {isVerified ? '✓' : '2'}
              </div>
              <span className={`ml-2 text-sm font-medium ${
                isVerified ? 'text-gray-900' : 'text-primary-600'
              }`}>
                Verification
              </span>
            </div>
          </div>
        </div>

        {/* Status Card */}
        <div className="card card-body mb-6">
          {isVerified ? (
            <div className="text-center py-8">
              <div className="inline-flex items-center justify-center h-20 w-20 rounded-full bg-success-100 text-success-600 mb-4">
                <CheckCircleIcon className="h-12 w-12" />
              </div>
              <h2 className="text-2xl font-bold text-gray-900 mb-2">
                Account Verified!
              </h2>
              <p className="text-gray-600 mb-6">
                You now have full access to AbbasiConnect
              </p>
              <Button
                variant="primary"
                size="lg"
                onClick={() => router.push('/feed')}
              >
                Go to Feed
              </Button>
            </div>
          ) : (
            <>
              {/* Progress Bar */}
              <div className="mb-6">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium text-gray-700">
                    Verification Progress
                  </span>
                  <span className="text-sm font-semibold text-primary-600">
                    {vouchStatus?.totalVouches || 0} / {vouchStatus?.requiredVouches || 3}
                  </span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-3">
                  <div
                    className="bg-gradient-to-r from-primary-600 to-secondary-600 h-3 rounded-full transition-all duration-500"
                    style={{ width: `${Math.min(progress, 100)}%` }}
                  ></div>
                </div>
              </div>

              {/* Vouchers */}
              {vouchStatus && vouchStatus.vouchers.length > 0 ? (
                <div className="space-y-4">
                  <h3 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
                    <UserGroupIcon className="h-5 w-5" />
                    Community Members Who Vouched
                  </h3>
                  <div className="space-y-3">
                    {vouchStatus.vouchers.map((voucher) => (
                      <div
                        key={voucher.id}
                        className="flex items-center gap-3 p-3 bg-success-50 border border-success-200 rounded-lg"
                      >
                        <Avatar
                          src={voucher.photo_url}
                          name={voucher.name}
                          size="md"
                        />
                        <div className="flex-1">
                          <p className="font-medium text-gray-900">{voucher.name}</p>
                          <p className="text-sm text-gray-600 capitalize">
                            {voucher.decision.replace('_', ' ')}
                          </p>
                        </div>
                        <CheckCircleIcon className="h-6 w-6 text-success-600" />
                      </div>
                    ))}
                  </div>
                </div>
              ) : (
                <div className="text-center py-8">
                  <div className="inline-flex items-center justify-center h-20 w-20 rounded-full bg-primary-100 text-primary-600 mb-4">
                    <ClockIcon className="h-12 w-12" />
                  </div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">
                    Waiting for Vouches
                  </h3>
                  <p className="text-gray-600">
                    Community members in your area will be notified to vouch for you
                  </p>
                </div>
              )}
            </>
          )}
        </div>

        {/* Info */}
        {!isVerified && (
          <div className="p-4 bg-primary-50 border border-primary-200 rounded-lg">
            <h4 className="font-semibold text-primary-900 mb-2">How it works:</h4>
            <ul className="text-sm text-primary-800 space-y-1">
              <li>• Verified members in your city can see your vouch request</li>
              <li>• They can vouch if they know you personally or through family</li>
              <li>• You need 3 vouches to get verified</li>
              <li>• This usually takes 1-3 days</li>
            </ul>
          </div>
        )}

        {/* Logout */}
        {!isVerified && (
          <div className="text-center mt-6">
            <button
              onClick={() => router.push('/auth/logout')}
              className="text-sm text-gray-600 hover:text-gray-900"
            >
              Logout
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
