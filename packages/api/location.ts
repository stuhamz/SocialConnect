import { createServiceRoleClient } from './supabase';

// Haversine formula to calculate distance between two coordinates
export const calculateDistance = (
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number => {
  const R = 6371; // Earth's radius in kilometers
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);
  
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) *
    Math.cos(toRadians(lat2)) *
    Math.sin(dLon / 2) *
    Math.sin(dLon / 2);
  
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance = R * c;
  
  return distance;
};

const toRadians = (degrees: number): number => {
  return degrees * (Math.PI / 180);
};

// Get coordinates for a pincode
export const getPincodeCoordinates = async (
  pincode: string
): Promise<{ latitude: number; longitude: number; city: string; state: string } | null> => {
  const supabase = createServiceRoleClient();
  
  const { data, error } = await supabase
    .from('pincodes')
    .select('latitude, longitude, city, state')
    .eq('pincode', pincode)
    .single();

  if (error || !data) {
    return null;
  }

  return {
    latitude: Number(data.latitude),
    longitude: Number(data.longitude),
    city: data.city,
    state: data.state,
  };
};

// Find nearby pincodes within a radius
export const findNearbyPincodes = async (
  pincode: string,
  radiusKm: number = 50
): Promise<Array<{
  pincode: string;
  city: string;
  state: string;
  distance: number;
}>> => {
  const coords = await getPincodeCoordinates(pincode);
  
  if (!coords) {
    return [];
  }

  const supabase = createServiceRoleClient();
  
  // Calculate bounding box for efficient querying
  const latDelta = radiusKm / 111; // 1 degree latitude ≈ 111 km
  const lonDelta = radiusKm / (111 * Math.cos(toRadians(coords.latitude)));

  const { data, error } = await supabase
    .from('pincodes')
    .select('pincode, city, state, latitude, longitude')
    .gte('latitude', coords.latitude - latDelta)
    .lte('latitude', coords.latitude + latDelta)
    .gte('longitude', coords.longitude - lonDelta)
    .lte('longitude', coords.longitude + lonDelta);

  if (error || !data) {
    return [];
  }

  // Calculate actual distances and filter by radius
  const nearby = data
    .map((location) => {
      const distance = calculateDistance(
        coords.latitude,
        coords.longitude,
        Number(location.latitude),
        Number(location.longitude)
      );

      return {
        pincode: location.pincode,
        city: location.city,
        state: location.state,
        distance: Math.round(distance * 10) / 10, // Round to 1 decimal
      };
    })
    .filter((location) => location.distance <= radiusKm)
    .sort((a, b) => a.distance - b.distance);

  return nearby;
};

// Find users near a pincode
export const findNearbyUsers = async (
  pincode: string,
  radiusKm: number = 50,
  limit: number = 50
): Promise<Array<{
  id: string;
  name: string;
  city: string;
  pincode: string;
  photo_url: string | null;
  profession: string | null;
  distance: number;
}>> => {
  const nearbyPincodes = await findNearbyPincodes(pincode, radiusKm);
  
  if (nearbyPincodes.length === 0) {
    return [];
  }

  const supabase = createServiceRoleClient();
  
  const pincodeList = nearbyPincodes.map((p) => p.pincode);
  
  const { data, error } = await supabase
    .from('users')
    .select('id, name, city, pincode, photo_url, profession')
    .in('pincode', pincodeList)
    .eq('status', 'verified')
    .is('deleted_at', null)
    .limit(limit);

  if (error || !data) {
    return [];
  }

  // Add distance information
  const usersWithDistance = data.map((user) => {
    const pincodeInfo = nearbyPincodes.find((p) => p.pincode === user.pincode);
    return {
      ...user,
      distance: pincodeInfo?.distance || 0,
    };
  });

  // Sort by distance
  usersWithDistance.sort((a, b) => a.distance - b.distance);

  return usersWithDistance;
};

// Find events near a pincode
export const findNearbyEvents = async (
  pincode: string,
  radiusKm: number = 50,
  limit: number = 20
): Promise<Array<{
  id: string;
  title: string;
  city: string;
  event_date: string;
  event_time: string | null;
  distance: number;
}>> => {
  const nearbyPincodes = await findNearbyPincodes(pincode, radiusKm);
  
  if (nearbyPincodes.length === 0) {
    return [];
  }

  const supabase = createServiceRoleClient();
  
  // Get cities from nearby pincodes
  const cities = [...new Set(nearbyPincodes.map((p) => p.city))];
  
  const { data, error } = await supabase
    .from('events')
    .select('id, title, city, event_date, event_time')
    .in('city', cities)
    .gte('event_date', new Date().toISOString().split('T')[0])
    .order('event_date', { ascending: true })
    .limit(limit);

  if (error || !data) {
    return [];
  }

  // Add distance information based on city
  const eventsWithDistance = data.map((event) => {
    const cityPincode = nearbyPincodes.find((p) => p.city === event.city);
    return {
      ...event,
      distance: cityPincode?.distance || 0,
    };
  });

  return eventsWithDistance;
};

// Get city suggestions for autocomplete
export const getCitySuggestions = async (
  query: string,
  limit: number = 10
): Promise<Array<{ city: string; state: string; count: number }>> => {
  const supabase = createServiceRoleClient();
  
  const { data, error } = await supabase
    .from('pincodes')
    .select('city, state')
    .ilike('city', `${query}%`)
    .limit(limit * 5); // Get more to deduplicate

  if (error || !data) {
    return [];
  }

  // Deduplicate and count
  const cityMap = new Map<string, { state: string; count: number }>();
  
  data.forEach((row) => {
    const key = `${row.city}, ${row.state}`;
    if (cityMap.has(key)) {
      cityMap.get(key)!.count++;
    } else {
      cityMap.set(key, { state: row.state, count: 1 });
    }
  });

  // Convert to array and sort by count
  const suggestions = Array.from(cityMap.entries())
    .map(([cityState, info]) => {
      const [city] = cityState.split(', ');
      return {
        city,
        state: info.state,
        count: info.count,
      };
    })
    .sort((a, b) => b.count - a.count)
    .slice(0, limit);

  return suggestions;
};

// Get pincodes for a city
export const getPincodesForCity = async (
  city: string
): Promise<Array<{ pincode: string; district: string | null }>> => {
  const supabase = createServiceRoleClient();
  
  const { data, error } = await supabase
    .from('pincodes')
    .select('pincode, district')
    .eq('city', city)
    .order('pincode');

  if (error || !data) {
    return [];
  }

  return data;
};

// Validate pincode
export const validatePincode = async (pincode: string): Promise<boolean> => {
  if (!/^\d{6}$/.test(pincode)) {
    return false;
  }

  const coords = await getPincodeCoordinates(pincode);
  return coords !== null;
};

// Get distance between two pincodes
export const getDistanceBetweenPincodes = async (
  pincode1: string,
  pincode2: string
): Promise<number | null> => {
  const [coords1, coords2] = await Promise.all([
    getPincodeCoordinates(pincode1),
    getPincodeCoordinates(pincode2),
  ]);

  if (!coords1 || !coords2) {
    return null;
  }

  return calculateDistance(
    coords1.latitude,
    coords1.longitude,
    coords2.latitude,
    coords2.longitude
  );
};

// Format distance for display
export const formatDistance = (distanceKm: number): string => {
  if (distanceKm < 1) {
    return `${Math.round(distanceKm * 1000)}m`;
  }
  
  if (distanceKm < 10) {
    return `${distanceKm.toFixed(1)}km`;
  }
  
  return `${Math.round(distanceKm)}km`;
};

// Get popular cities
export const getPopularCities = async (
  limit: number = 20
): Promise<Array<{ city: string; state: string; userCount: number }>> => {
  const supabase = createServiceRoleClient();
  
  const { data, error } = await supabase
    .from('users')
    .select('city')
    .eq('status', 'verified')
    .is('deleted_at', null);

  if (error || !data) {
    return [];
  }

  // Count users per city
  const cityCount = new Map<string, number>();
  data.forEach((user) => {
    cityCount.set(user.city, (cityCount.get(user.city) || 0) + 1);
  });

  // Get state information for top cities
  const topCities = Array.from(cityCount.entries())
    .sort((a, b) => b[1] - a[1])
    .slice(0, limit);

  const citiesWithState = await Promise.all(
    topCities.map(async ([city, count]) => {
      const { data } = await supabase
        .from('pincodes')
        .select('state')
        .eq('city', city)
        .limit(1)
        .single();

      return {
        city,
        state: data?.state || 'Unknown',
        userCount: count,
      };
    })
  );

  return citiesWithState;
};
