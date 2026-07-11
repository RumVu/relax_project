const SECRET = process.env.SESSION_SECRET || 'relax-session-secret-dev';

function toHex(bytes: Uint8Array): string {
  return Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

async function getKey(): Promise<CryptoKey> {
  return crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(SECRET),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
}

export async function signRole(role: string): Promise<string> {
  const key = await getKey();
  const sig = await crypto.subtle.sign(
    'HMAC',
    key,
    new TextEncoder().encode(role),
  );
  return `${role}.${toHex(new Uint8Array(sig))}`;
}

export async function verifySession(
  cookieValue: string,
): Promise<string | null> {
  const dot = cookieValue.lastIndexOf('.');
  if (dot < 1) return null;

  const role = cookieValue.slice(0, dot);
  const providedSig = cookieValue.slice(dot + 1);
  const expected = await signRole(role);
  const expectedSig = expected.slice(expected.lastIndexOf('.') + 1);

  if (providedSig.length !== expectedSig.length) return null;
  let diff = 0;
  for (let i = 0; i < providedSig.length; i++) {
    diff |= providedSig.charCodeAt(i) ^ expectedSig.charCodeAt(i);
  }
  return diff === 0 ? role : null;
}
