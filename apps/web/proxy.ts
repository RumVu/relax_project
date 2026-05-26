import { NextRequest, NextResponse } from 'next/server';

const protectedPrefixes = ['/dashboard', '/admin'];

export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const sessionMarker = request.cookies.get('relax_session')?.value;
  const role = sessionMarker ? readSessionRole(sessionMarker) : null;
  const isDevPreview =
    process.env.NODE_ENV === 'development' &&
    request.nextUrl.searchParams.get('preview') === '1';

  if (
    isDevPreview &&
    protectedPrefixes.some((prefix) => pathname.startsWith(prefix))
  ) {
    const response = NextResponse.redirect(new URL(pathname, request.url));
    response.cookies.set('relax_session', 'dev-dashboard-preview', {
      sameSite: 'lax',
      path: '/',
      maxAge: 60 * 60,
    });

    return response;
  }

  if (
    protectedPrefixes.some((prefix) => pathname.startsWith(prefix)) &&
    !sessionMarker
  ) {
    return NextResponse.redirect(new URL('/auth/login', request.url));
  }

  if (pathname.startsWith('/admin') && role !== 'ADMIN') {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  if (
    (pathname.startsWith('/auth/login') ||
      pathname.startsWith('/auth/register')) &&
    sessionMarker
  ) {
    return NextResponse.redirect(
      new URL(role === 'ADMIN' ? '/admin' : '/dashboard', request.url),
    );
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    '/dashboard/:path*',
    '/admin/:path*',
    '/auth/login',
    '/auth/register',
  ],
};

function readSessionRole(sessionMarker: string) {
  if (sessionMarker === 'role:ADMIN' || sessionMarker === 'ADMIN') {
    return 'ADMIN';
  }

  if (sessionMarker === 'role:USER' || sessionMarker === 'USER') {
    return 'USER';
  }

  // Backward compatibility for stale cookies created before the marker format.
  return readJwtRole(sessionMarker);
}

function readJwtRole(token: string) {
  try {
    const [, payload] = token.split('.');
    if (!payload) {
      return null;
    }

    const normalized = payload.replace(/-/g, '+').replace(/_/g, '/');
    const padded = normalized.padEnd(Math.ceil(normalized.length / 4) * 4, '=');
    const decoded = JSON.parse(atob(padded)) as { role?: string };
    return decoded.role ?? null;
  } catch {
    return null;
  }
}
