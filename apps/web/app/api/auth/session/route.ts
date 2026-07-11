import { cookies } from 'next/headers';
import { NextResponse } from 'next/server';
import { signRole } from '@/lib/session-sign';

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:6823';

export async function POST(request: Request) {
  const authHeader = request.headers.get('authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return NextResponse.json({ error: 'unauthorized' }, { status: 401 });
  }

  const token = authHeader.slice(7);

  let user: { role?: string };
  try {
    const res = await fetch(`${API_URL}/v1/auth/me`, {
      headers: { Authorization: `Bearer ${token}` },
      cache: 'no-store',
    });
    if (!res.ok) {
      return NextResponse.json({ error: 'unauthorized' }, { status: 401 });
    }
    user = (await res.json()) as { role?: string };
  } catch {
    return NextResponse.json(
      { error: 'backend unreachable' },
      { status: 502 },
    );
  }

  const role = user.role === 'ADMIN' ? 'ADMIN' : 'USER';
  const value = await signRole(`role:${role}`);
  const cookieStore = await cookies();
  cookieStore.set('relax_session', value, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    path: '/',
    maxAge: 60 * 60 * 24 * 30,
  });

  return NextResponse.json({ ok: true });
}

export async function DELETE() {
  const cookieStore = await cookies();
  cookieStore.delete('relax_session');
  return NextResponse.json({ ok: true });
}
