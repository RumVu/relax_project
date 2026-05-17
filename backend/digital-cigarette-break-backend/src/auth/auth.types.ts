import type { User } from '@prisma/client';

export type AuthUser = Omit<User, 'password'>;

export interface JwtPayload {
  sub: string;
  email: string;
}
