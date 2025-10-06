import { NextResponse } from 'next/server';
import { getPopularCities } from '@/../../packages/api/location';

export async function GET() {
  try {
    const cities = await getPopularCities(50);
    return NextResponse.json(cities, { status: 200 });
  } catch (error) {
    console.error('Get cities error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch cities' },
      { status: 500 }
    );
  }
}
