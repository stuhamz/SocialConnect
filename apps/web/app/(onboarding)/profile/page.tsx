'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Button from '@/components/ui/Button';
import Input from '@/components/ui/Input';
import Textarea from '@/components/ui/Textarea';
import Select from '@/components/ui/Select';
import { UserIcon, MapPinIcon, BriefcaseIcon, DocumentTextIcon } from '@heroicons/react/24/outline';

export default function ProfileCompletionPage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [cities, setCities] = useState<Array<{ value: string; label: string }>>([]);
  const [pincodes, setPincodes] = useState<Array<{ value: string; label: string }>>([]);
  
  const [formData, setFormData] = useState({
    name: '',
    city: '',
    pincode: '',
    profession: '',
    lineageNote: '',
  });

  // Load popular cities
  useEffect(() => {
    loadCities();
  }, []);

  // Load pincodes when city changes
  useEffect(() => {
    if (formData.city) {
      loadPincodes(formData.city);
    }
  }, [formData.city]);

  const loadCities = async () => {
    try {
      const response = await fetch('/api/location/cities');
      const data = await response.json();
      setCities(data.map((city: any) => ({
        value: city.city,
        label: `${city.city}, ${city.state}`,
      })));
    } catch (err) {
      console.error('Failed to load cities:', err);
    }
  };

  const loadPincodes = async (city: string) => {
    try {
      const response = await fetch(`/api/location/pincodes?city=${encodeURIComponent(city)}`);
      const data = await response.json();
      setPincodes(data.map((pc: any) => ({
        value: pc.pincode,
        label: `${pc.pincode}${pc.district ? ` - ${pc.district}` : ''}`,
      })));
    } catch (err) {
      console.error('Failed to load pincodes:', err);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      const response = await fetch('/api/user/complete-profile', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.error || 'Failed to update profile');
      }

      // Redirect to vouch request page
      router.push('/onboarding/vouch');
    } catch (err: any) {
      setError(err.message || 'Failed to update profile. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 via-white to-secondary-50 flex items-center justify-center p-4">
      <div className="w-full max-w-2xl">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center h-16 w-16 rounded-2xl bg-gradient-to-br from-primary-600 to-secondary-600 text-white font-bold text-2xl mb-4">
            A
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Complete Your Profile
          </h1>
          <p className="text-gray-600">
            Help us verify your identity and connect you with the community
          </p>
        </div>

        {/* Progress */}
        <div className="mb-8">
          <div className="flex items-center justify-center gap-2">
            <div className="flex items-center">
              <div className="h-8 w-8 rounded-full bg-primary-600 text-white flex items-center justify-center text-sm font-semibold">
                1
              </div>
              <span className="ml-2 text-sm font-medium text-gray-900">Profile</span>
            </div>
            <div className="h-0.5 w-12 bg-gray-300"></div>
            <div className="flex items-center">
              <div className="h-8 w-8 rounded-full bg-gray-300 text-gray-600 flex items-center justify-center text-sm font-semibold">
                2
              </div>
              <span className="ml-2 text-sm font-medium text-gray-500">Verification</span>
            </div>
          </div>
        </div>

        {/* Form Card */}
        <div className="card card-body">
          <form onSubmit={handleSubmit} className="space-y-6">
            <Input
              type="text"
              label="Full Name"
              placeholder="Enter your full name"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              leftIcon={<UserIcon className="h-5 w-5" />}
              required
              disabled={isLoading}
              helperText="Your name as it appears on official documents"
            />

            <Select
              label="City"
              placeholder="Select your city"
              value={formData.city}
              onChange={(e) => setFormData({ ...formData, city: e.target.value, pincode: '' })}
              options={cities}
              required
              disabled={isLoading}
              helperText="Select the city where you currently reside"
            />

            <Select
              label="Pincode"
              placeholder="Select your pincode"
              value={formData.pincode}
              onChange={(e) => setFormData({ ...formData, pincode: e.target.value })}
              options={pincodes}
              required
              disabled={isLoading || !formData.city}
              helperText="Select your area pincode for local connections"
            />

            <Input
              type="text"
              label="Profession"
              placeholder="e.g., Software Engineer, Teacher, Business Owner"
              value={formData.profession}
              onChange={(e) => setFormData({ ...formData, profession: e.target.value })}
              leftIcon={<BriefcaseIcon className="h-5 w-5" />}
              disabled={isLoading}
              helperText="Optional: Your current profession or occupation"
            />

            <Textarea
              label="Lineage Note"
              placeholder="Brief note about your family lineage or connection to the Abbasi community"
              value={formData.lineageNote}
              onChange={(e) => setFormData({ ...formData, lineageNote: e.target.value })}
              maxLength={500}
              showCount
              disabled={isLoading}
              helperText="This helps community members verify your connection (max 500 characters)"
              rows={4}
            />

            {error && (
              <div className="p-3 bg-danger-50 border border-danger-200 rounded-lg text-danger-700 text-sm">
                {error}
              </div>
            )}

            <div className="flex gap-4">
              <Button
                type="button"
                variant="ghost"
                size="lg"
                className="flex-1"
                onClick={() => router.back()}
                disabled={isLoading}
              >
                Back
              </Button>
              <Button
                type="submit"
                variant="primary"
                size="lg"
                className="flex-1"
                isLoading={isLoading}
              >
                Continue
              </Button>
            </div>
          </form>
        </div>

        {/* Info */}
        <div className="mt-6 p-4 bg-primary-50 border border-primary-200 rounded-lg">
          <p className="text-sm text-primary-900">
            <strong>Next Step:</strong> After completing your profile, you'll need 3 community members to vouch for you to gain full access.
          </p>
        </div>
      </div>
    </div>
  );
}
