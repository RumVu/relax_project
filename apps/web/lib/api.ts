export const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:6823';
// All HTTP API routes are served under /v1. The Socket.IO namespace
// (`${API_URL}/realtime`) and infra routes are NOT versioned, so the prefix is
// applied here at the HTTP layer only.
export const API_VERSION_PREFIX = '/v1';
const ACCESS_TOKEN_KEY = 'relax_access_token';
const REFRESH_TOKEN_KEY = 'relax_refresh_token';
const SESSION_ID_KEY = 'relax_session_id';
const ROLE_KEY = 'relax_user_role';
const AUTH_COOKIE_KEY = 'relax_session';

type QueryValue = string | number | boolean | Date | null | undefined;

export interface ApiErrorEnvelope {
  success: false;
  statusCode: number;
  code: string;
  message: string;
  details?: unknown;
  path?: string;
  timestamp?: string;
}

export class ApiError extends Error {
  statusCode: number;
  code: string;
  details?: unknown;
  path?: string;
  timestamp?: string;

  constructor(envelope: ApiErrorEnvelope) {
    super(envelope.message);
    this.name = 'ApiError';
    this.statusCode = envelope.statusCode;
    this.code = envelope.code;
    this.details = envelope.details;
    this.path = envelope.path;
    this.timestamp = envelope.timestamp;
  }
}

export interface ApiFetchOptions {
  query?: Record<string, QueryValue>;
  skipAuth?: boolean;
  retryOnAuthError?: boolean;
}

let refreshPromise: Promise<AuthResponse> | undefined;

export async function apiFetch<T>(
  path: string,
  init?: RequestInit,
  options: ApiFetchOptions = {},
): Promise<T> {
  return sendApiRequest<T>(path, init, options, true);
}

async function sendApiRequest<T>(
  path: string,
  init: RequestInit | undefined,
  options: ApiFetchOptions,
  allowRefresh: boolean,
): Promise<T> {
  const token = options.skipAuth ? undefined : getStoredAccessToken();
  const headers = new Headers(init?.headers);
  const hasBody = init?.body !== undefined && init.body !== null;
  const isFormData =
    typeof FormData !== 'undefined' && init?.body instanceof FormData;

  if (hasBody && !isFormData && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json');
  }

  if (!headers.has('Accept')) {
    headers.set('Accept', 'application/json');
  }

  if (token && !headers.has('Authorization')) {
    headers.set('Authorization', `Bearer ${token}`);
  }

  const response = await fetch(
    `${API_URL}${API_VERSION_PREFIX}${withQuery(path, options.query)}`,
    {
      ...init,
      headers,
      cache: 'no-store',
    },
  );
  const payload = await parseJsonResponse(response);

  if (!response.ok) {
    const error = toApiError(payload, response, path);

    if (
      allowRefresh &&
      !options.skipAuth &&
      (options.retryOnAuthError ?? true) &&
      shouldAttemptRefresh(error)
    ) {
      await refreshAuthSession();
      return sendApiRequest<T>(path, init, options, false);
    }

    throw error;
  }

  return payload as T;
}

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  expiresAt: string;
  sessionId?: string;
  user: {
    id: string;
    email: string;
    name?: string | null;
    role: string;
  };
}

export function buildQuery(params?: Record<string, QueryValue>) {
  if (!params) {
    return '';
  }

  const query = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (value === undefined || value === null || value === '') {
      continue;
    }

    query.set(key, value instanceof Date ? value.toISOString() : String(value));
  }

  return query.toString();
}

export function withQuery(path: string, params?: Record<string, QueryValue>) {
  const query = buildQuery(params);
  if (!query) {
    return path;
  }

  return `${path}${path.includes('?') ? '&' : '?'}${query}`;
}

export function clampLimit(value: number | string | undefined, fallback = 20) {
  const numeric = Number(value ?? fallback);
  if (!Number.isFinite(numeric)) {
    return fallback;
  }

  return Math.max(1, Math.min(100, Math.trunc(numeric)));
}

export function clampSkip(value: number | string | undefined, fallback = 0) {
  const numeric = Number(value ?? fallback);
  if (!Number.isFinite(numeric)) {
    return fallback;
  }

  return Math.max(0, Math.trunc(numeric));
}

/**
 * Normalizes a list API response into an array. List endpoints return either a
 * bare array or a paginated page ({ items, total, ... }); this accepts both so
 * callers do not break when an endpoint switches to the paginated shape.
 */
export function extractList<T = unknown>(payload: unknown): T[] {
  if (Array.isArray(payload)) {
    return payload as T[];
  }

  const items = (payload as { items?: unknown } | null | undefined)?.items;
  return Array.isArray(items) ? (items as T[]) : [];
}

export function persistAuthSession(auth: AuthResponse) {
  if (typeof window === 'undefined') {
    return;
  }

  window.localStorage.setItem(ACCESS_TOKEN_KEY, auth.accessToken);
  window.localStorage.setItem(REFRESH_TOKEN_KEY, auth.refreshToken);
  if (auth.sessionId) {
    window.localStorage.setItem(SESSION_ID_KEY, auth.sessionId);
  } else {
    window.localStorage.removeItem(SESSION_ID_KEY);
  }
  window.localStorage.setItem(ROLE_KEY, auth.user.role);
  setAuthCookie(auth.user.role);
}

export function clearAuthSession() {
  if (typeof window === 'undefined') {
    return;
  }

  window.localStorage.removeItem(ACCESS_TOKEN_KEY);
  window.localStorage.removeItem(REFRESH_TOKEN_KEY);
  window.localStorage.removeItem(SESSION_ID_KEY);
  window.localStorage.removeItem(ROLE_KEY);
  document.cookie = `${AUTH_COOKIE_KEY}=; Path=/; Max-Age=0; SameSite=Lax`;
}

export function getStoredAccessToken() {
  if (typeof window === 'undefined') {
    return undefined;
  }

  return window.localStorage.getItem(ACCESS_TOKEN_KEY) ?? undefined;
}

export function getStoredRefreshToken() {
  if (typeof window === 'undefined') {
    return undefined;
  }

  return window.localStorage.getItem(REFRESH_TOKEN_KEY) ?? undefined;
}

export function getStoredSessionId() {
  if (typeof window === 'undefined') {
    return undefined;
  }

  return window.localStorage.getItem(SESSION_ID_KEY) ?? undefined;
}

export function getStoredRole() {
  if (typeof window === 'undefined') {
    return undefined;
  }

  return window.localStorage.getItem(ROLE_KEY) ?? undefined;
}

export function syncAuthRouteCookie() {
  if (typeof window === 'undefined') {
    return;
  }

  const token = getStoredAccessToken();
  const role = getStoredRole();
  if (token && role) {
    setAuthCookie(role);
  }
}

export async function refreshAuthSession() {
  if (refreshPromise) {
    return refreshPromise;
  }

  const refreshToken = getStoredRefreshToken();
  if (!refreshToken) {
    clearAuthSession();
    throw new ApiError({
      success: false,
      statusCode: 401,
      code: 'AUTH_REFRESH_TOKEN_INVALID',
      message: 'Missing refresh token',
    });
  }

  refreshPromise = (async () => {
    try {
      const auth = await sendApiRequest<AuthResponse>(
        '/auth/refresh',
        {
          method: 'POST',
          body: JSON.stringify({ refreshToken }),
        },
        { skipAuth: true, retryOnAuthError: false },
        false,
      );
      persistAuthSession(auth);
      return auth;
    } catch (error) {
      clearAuthSession();
      throw error;
    } finally {
      refreshPromise = undefined;
    }
  })();

  return refreshPromise;
}

async function parseJsonResponse(response: Response) {
  if (response.status === 204) {
    return undefined;
  }

  const text = await response.text();
  if (!text) {
    return undefined;
  }

  try {
    return JSON.parse(text) as unknown;
  } catch {
    return text;
  }
}

function toApiError(payload: unknown, response: Response, requestedPath: string) {
  if (isApiErrorEnvelope(payload)) {
    return new ApiError(payload);
  }

  return new ApiError({
    success: false,
    statusCode: response.status,
    code: response.status === 401 ? 'AUTH_UNAUTHORIZED' : 'API_REQUEST_FAILED',
    message:
      typeof payload === 'string'
        ? payload
        : `API request failed: ${response.status}`,
    path: requestedPath,
  });
}

function isApiErrorEnvelope(payload: unknown): payload is ApiErrorEnvelope {
  if (!payload || typeof payload !== 'object') {
    return false;
  }

  const value = payload as Partial<ApiErrorEnvelope>;
  return (
    value.success === false &&
    typeof value.statusCode === 'number' &&
    typeof value.code === 'string' &&
    typeof value.message === 'string'
  );
}

function shouldAttemptRefresh(error: ApiError) {
  return (
    error.statusCode === 401 &&
    [
      'AUTH_TOKEN_EXPIRED',
      'AUTH_TOKEN_INVALID',
      'AUTH_UNAUTHORIZED',
      'AUTH_REFRESH_TOKEN_INVALID',
    ].includes(error.code) &&
    Boolean(getStoredRefreshToken())
  );
}

function setAuthCookie(role: string) {
  const normalizedRole = role === 'ADMIN' ? 'ADMIN' : 'USER';
  const secure = window.location.protocol === 'https:' ? '; Secure' : '';
  document.cookie = `${AUTH_COOKIE_KEY}=role:${normalizedRole}; Path=/; Max-Age=${
    60 * 60 * 24 * 30
  }; SameSite=Lax${secure}`;
}
