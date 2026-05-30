/**
 * BigDataCloud reverse-geocode HTTP client. Pure — caller handles
 * caching. Returns null on any failure so callers can treat "no
 * locality" as a stable empty state.
 */
const BIGDATACLOUD_URL =
  'https://api.bigdatacloud.net/data/reverse-geocode-client';
const REQUEST_TIMEOUT_MS = 5000;

interface ReverseGeocodePayload {
  city?: string;
  locality?: string;
  principalSubdivision?: string;
  countryName?: string;
  countryCode?: string;
  latitude?: number;
  longitude?: number;
  lookupSource?: string;
}

export interface ReverseGeocodeResult {
  provider: 'bigdatacloud';
  latitude: number;
  longitude: number;
  locationName: string | null;
  city: string | null;
  locality: string | null;
  principalSubdivision: string | null;
  countryName: string | null;
  countryCode: string | null;
  lookupSource: string | null;
}

/** Pick the most specific human label available, in city > … > country order. */
function buildLocationName(payload: ReverseGeocodePayload): string | null {
  return (
    payload.city ||
    payload.locality ||
    payload.principalSubdivision ||
    payload.countryName ||
    null
  );
}

export async function fetchReverseGeocode(
  latitude: number,
  longitude: number,
  localityLanguage = 'vi',
): Promise<ReverseGeocodeResult | null> {
  const url = new URL(BIGDATACLOUD_URL);
  url.searchParams.set('latitude', String(latitude));
  url.searchParams.set('longitude', String(longitude));
  url.searchParams.set('localityLanguage', localityLanguage);

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  try {
    const response = await fetch(url, { signal: controller.signal });
    if (!response.ok) return null;

    const payload = (await response.json()) as ReverseGeocodePayload;

    return {
      provider: 'bigdatacloud',
      latitude,
      longitude,
      locationName: buildLocationName(payload),
      city: payload.city ?? null,
      locality: payload.locality ?? null,
      principalSubdivision: payload.principalSubdivision ?? null,
      countryName: payload.countryName ?? null,
      countryCode: payload.countryCode ?? null,
      lookupSource: payload.lookupSource ?? null,
    };
  } catch {
    return null;
  } finally {
    clearTimeout(timeout);
  }
}
