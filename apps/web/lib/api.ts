const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:6823';
const ACCESS_TOKEN_KEY = 'relax_access_token';
const REFRESH_TOKEN_KEY = 'relax_refresh_token';

export async function apiFetch<T>(path: string, init?: RequestInit): Promise<T> {
  const token = getStoredAccessToken();
  const headers = new Headers(init?.headers);
  if (!headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json');
  }
  if (token && !headers.has('Authorization')) {
    headers.set('Authorization', `Bearer ${token}`);
  }

  const response = await fetch(`${API_URL}${path}`, {
    ...init,
    headers,
    cache: 'no-store',
  });

  if (!response.ok) {
    throw new Error(`API request failed: ${response.status}`);
  }

  return response.json() as Promise<T>;
}

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  expiresAt: string;
  user: {
    id: string;
    email: string;
    name?: string | null;
    role: string;
  };
}

export function persistAuthSession(auth: AuthResponse) {
  if (typeof window === 'undefined') {
    return;
  }

  window.localStorage.setItem(ACCESS_TOKEN_KEY, auth.accessToken);
  window.localStorage.setItem(REFRESH_TOKEN_KEY, auth.refreshToken);
  document.cookie = `relax_session=${auth.accessToken}; Path=/; Max-Age=${60 * 60 * 24 * 7}; SameSite=Lax`;
}

export function clearAuthSession() {
  if (typeof window === 'undefined') {
    return;
  }

  window.localStorage.removeItem(ACCESS_TOKEN_KEY);
  window.localStorage.removeItem(REFRESH_TOKEN_KEY);
  document.cookie = 'relax_session=; Path=/; Max-Age=0; SameSite=Lax';
}

function getStoredAccessToken() {
  if (typeof window === 'undefined') {
    return undefined;
  }

  return window.localStorage.getItem(ACCESS_TOKEN_KEY) ?? undefined;
}
