import { NextRequest, NextResponse } from 'next/server';
import { verifySession } from '@/lib/session-sign';

const LOGIN_PATH = '/auth/login';

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  if (pathname.startsWith('/dashboard') || pathname.startsWith('/admin')) {
    const session = request.cookies.get('relax_session');
    if (!session?.value) {
      const loginUrl = request.nextUrl.clone();
      loginUrl.pathname = LOGIN_PATH;
      loginUrl.searchParams.set('redirect', pathname);
      return NextResponse.redirect(loginUrl);
    }

    const role = await verifySession(session.value);
    if (!role) {
      const loginUrl = request.nextUrl.clone();
      loginUrl.pathname = LOGIN_PATH;
      const response = NextResponse.redirect(loginUrl);
      response.cookies.delete('relax_session');
      return response;
    }

    if (pathname.startsWith('/admin')) {
      if (role !== 'role:ADMIN') {
        const dashboardUrl = request.nextUrl.clone();
        dashboardUrl.pathname = '/dashboard';
        return NextResponse.redirect(dashboardUrl);
      }
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/dashboard/:path*', '/admin/:path*'],
};
