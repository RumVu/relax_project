import { NextRequest, NextResponse } from 'next/server';

const protectedPrefixes = ['/dashboard', '/admin'];

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const token = request.cookies.get('relax_session')?.value;

  if (
    protectedPrefixes.some((prefix) => pathname.startsWith(prefix)) &&
    !token
  ) {
    return NextResponse.redirect(new URL('/auth/login', request.url));
  }

  if (
    (pathname.startsWith('/auth/login') ||
      pathname.startsWith('/auth/register')) &&
    token
  ) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
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
