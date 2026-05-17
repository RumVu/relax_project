import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { UsersService } from '../users/users.service';
import type { AuthUser, JwtPayload } from './auth.types';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  async register(
    dto: RegisterDto,
  ): Promise<{ user: AuthUser; accessToken: string }> {
    const user = await this.usersService.create(dto);
    return { user, accessToken: this.signToken(user) };
  }

  async login(dto: LoginDto): Promise<{ user: AuthUser; accessToken: string }> {
    const account = await this.usersService.findByEmailForAuth(dto.email);
    if (!account || !account.isActive || account.isBanned) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const valid = await bcrypt.compare(dto.password, account.password);
    if (!valid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const user = await this.usersService.findById(account.id);
    return { user, accessToken: this.signToken(user) };
  }

  private signToken(user: AuthUser): string {
    const payload: JwtPayload = { sub: user.id, email: user.email };
    return this.jwtService.sign(payload);
  }
}
