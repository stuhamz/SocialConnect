import { NextRequest, NextResponse } from 'next/server';
import { getPincodesForCity } from '@/../../packages/api/location';

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const city = searchParams.get('city');

    if (!city) {
      return NextResponse.json(
        { error: 'City parameter is required' },
        { status: 400 }
      );
    }

    const pincodes = await getPincodesForCity(city);
    return NextResponse.json(pincodes, { status: 200 });
  } catch (error) {
    console.error('Get pincodes error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch pincodes' },
      { status: 500 }
    );
  }
}
