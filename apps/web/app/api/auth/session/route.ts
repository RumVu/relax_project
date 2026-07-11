import { cookies } from 'next/headers';
import { NextResponse } from 'next/server';
import { signRole } from '@/lib/session-sign';

export async function POST(request: Request) {
  let body: { role?: string };
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: 'invalid body' }, { status: 400 });
  }

  const role = body.role;
  if (!role || typeof role !== 'string') {
    return NextResponse.json({ error: 'role required' }, { status: 400 });
  }

  const normalized = role === 'ADMIN' ? 'ADMIN' : 'USER';
  const value = await signRole(`role:${normalized}`);
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
