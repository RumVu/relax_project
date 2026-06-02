import {
  Body,
  Controller,
  Delete,
  Get,
  Headers,
  Patch,
  Post,
  Req,
  Res,
  UseGuards,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { minutes, Throttle } from '@nestjs/throttler';
import type { Request, Response } from 'express';
import { getClientIp } from '../common/client-ip';
import { ErrorCode } from '../common/errors/error-code';
import { CurrentUser } from './decorators/current-user.decorator';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { AuthService } from './auth.service';
import type { AuthUser } from './auth.types';
import { ChangePasswordDto } from './dto/change-password.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { RegisterDto } from './dto/register.dto';
import { DeleteAccountDto } from './dto/delete-account.dto';
import { GoogleLoginDto } from './dto/google-login.dto';
import { RequestPasswordResetDto } from './dto/request-password-reset.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { VerifyEmailDto } from './dto/verify-email.dto';
import { AuthActionResultDto, AuthResponseDto } from './dto/auth-response.dto';
import { UserResponseDto } from '../users/dto/user-response.dto';

@ApiTags('Auth')
@Throttle({
  default: { ttl: minutes(1), limit: 20, blockDuration: minutes(2) },
})
@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly configService: ConfigService,
  ) {}

  @ApiOperation({ summary: 'Register a local user and create a session' })
  @ApiCreatedResponse({
    type: AuthResponseDto,
    description: 'User, access token, and HttpOnly refresh cookie.',
  })
  @Throttle({
    default: { ttl: minutes(1), limit: 5, blockDuration: minutes(5) },
  })
  @Post('register')
  register(
    @Body() dto: RegisterDto,
    @Headers('user-agent') userAgent: string | undefined,
    @Req() request: Request,
    @Res({ passthrough: true }) response: Response,
  ) {
    return this.withRefreshCookie(
      response,
      this.authService.register(dto, userAgent, getClientIp(request)),
    );
  }

  @ApiOperation({ summary: 'Login with email and password' })
  @ApiCreatedResponse({
    type: AuthResponseDto,
    description: 'User, access token, and HttpOnly refresh cookie.',
  })
  @ApiUnauthorizedResponse({
    description: 'Invalid credentials or inactive user.',
  })
  @Throttle({
    default: { ttl: minutes(1), limit: 5, blockDuration: minutes(5) },
  })
  @Post('login')
  login(
    @Body() dto: LoginDto,
    @Headers('user-agent') userAgent: string | undefined,
    @Req() request: Request,
    @Res({ passthrough: true }) response: Response,
  ) {
    return this.withRefreshCookie(
      response,
      this.authService.login(dto, userAgent, getClientIp(request)),
    );
  }

  @ApiOperation({ summary: 'Exchange a Google ID token for an app session' })
  @ApiCreatedResponse({
    type: AuthResponseDto,
    description: 'User, access token and HttpOnly refresh cookie.',
  })
  @ApiUnauthorizedResponse({
    description:
      'Google ID token missing/invalid, or GOOGLE_CLIENT_ID not configured on backend.',
  })
  @Throttle({
    default: { ttl: minutes(1), limit: 10, blockDuration: minutes(5) },
  })
  @Post('google')
  google(
    @Body() dto: GoogleLoginDto,
    @Headers('user-agent') userAgent: string | undefined,
    @Req() request: Request,
    @Res({ passthrough: true }) response: Response,
  ) {
    return this.withRefreshCookie(
      response,
      this.authService.googleLogin(dto, userAgent, getClientIp(request)),
    );
  }

  @ApiOperation({ summary: 'Rotate a refresh token' })
  @ApiCreatedResponse({
    type: AuthResponseDto,
    description:
      'Fresh access token, rotated HttpOnly refresh cookie, and user.',
  })
  @ApiUnauthorizedResponse({
    description: 'Refresh token is invalid or expired.',
  })
  @Post('refresh')
  refresh(
    @Body() dto: RefreshTokenDto,
    @Headers('user-agent') userAgent: string | undefined,
    @Req() request: Request,
    @Res({ passthrough: true }) response: Response,
  ) {
    const refreshToken =
      dto.refreshToken ?? this.getRefreshTokenCookie(request);
    if (!refreshToken) {
      throw new UnauthorizedException({
        code: ErrorCode.AUTH_REFRESH_TOKEN_INVALID,
        message: 'Refresh token is invalid or expired',
      });
    }

    return this.withRefreshCookie(
      response,
      this.authService.refresh(refreshToken, userAgent, getClientIp(request)),
    );
  }

  @ApiOperation({ summary: 'Logout by revoking one refresh token' })
  @ApiCreatedResponse({
    type: AuthActionResultDto,
    description: 'Logout success payload.',
  })
  @Post('logout')
  logout(
    @Body() dto: RefreshTokenDto,
    @Req() request: Request,
    @Res({ passthrough: true }) response: Response,
  ) {
    this.clearRefreshCookie(response);
    return this.authService.logout(
      dto.refreshToken ?? this.getRefreshTokenCookie(request),
    );
  }

  @ApiOperation({ summary: 'Request a password reset email' })
  @ApiCreatedResponse({
    type: AuthActionResultDto,
    description:
      'Password reset request accepted. In development, devToken is returned if no email provider is configured.',
  })
  @Throttle({
    default: { ttl: minutes(1), limit: 5, blockDuration: minutes(5) },
  })
  @Post('password-reset/request')
  requestPasswordReset(@Body() dto: RequestPasswordResetDto) {
    return this.authService.requestPasswordReset(dto);
  }

  @ApiOperation({ summary: 'Reset password with an account token' })
  @ApiCreatedResponse({
    type: AuthActionResultDto,
    description: 'Password has been reset and active sessions were revoked.',
  })
  @Post('password-reset/confirm')
  resetPassword(@Body() dto: ResetPasswordDto) {
    return this.authService.resetPassword(dto);
  }

  @ApiOperation({ summary: 'Verify email with an account token' })
  @ApiCreatedResponse({
    type: AuthActionResultDto,
    description: 'Email verification result.',
  })
  @Post('email/verify')
  verifyEmail(@Body() dto: VerifyEmailDto) {
    return this.authService.verifyEmail(dto);
  }

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Get the current authenticated user' })
  @ApiOkResponse({
    type: UserResponseDto,
    description: 'Current safe user payload.',
  })
  @ApiUnauthorizedResponse({
    description: 'Bearer token is missing or invalid.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me')
  me(@CurrentUser() user: AuthUser) {
    return this.authService.me(user.id);
  }

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Change the current local user password' })
  @ApiOkResponse({
    type: AuthActionResultDto,
    description: 'Password has been changed.',
  })
  @ApiUnauthorizedResponse({
    description: 'Current password is missing or incorrect.',
  })
  @UseGuards(JwtAuthGuard)
  @Patch('me/password')
  changeMyPassword(
    @CurrentUser() user: AuthUser,
    @Body() dto: ChangePasswordDto,
  ) {
    return this.authService.changeMinePassword(user.id, dto);
  }

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Export current user personal data' })
  @ApiOkResponse({
    description:
      'GDPR-style JSON export for the authenticated user. Secret hashes and provider tokens are excluded.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me/export')
  exportMine(@CurrentUser() user: AuthUser) {
    return this.authService.exportMine(user.id);
  }

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Request current user email verification token' })
  @ApiCreatedResponse({
    type: AuthActionResultDto,
    description:
      'Email verification request accepted. In development, devToken is returned if no email provider is configured.',
  })
  @UseGuards(JwtAuthGuard)
  @Post('me/email-verification')
  requestEmailVerification(@CurrentUser() user: AuthUser) {
    return this.authService.requestEmailVerification(user.id);
  }

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Delete or deactivate the current account' })
  @ApiOkResponse({
    type: AuthActionResultDto,
    description:
      'Account deletion result. SOFT anonymizes and deactivates; HARD removes related data via cascade.',
  })
  @UseGuards(JwtAuthGuard)
  @Delete('me')
  deleteMine(@CurrentUser() user: AuthUser, @Body() dto: DeleteAccountDto) {
    return this.authService.deleteMine(user.id, dto);
  }

  private async withRefreshCookie(
    response: Response,
    authPromise: Promise<AuthResponseDto>,
  ) {
    const auth = await authPromise;
    if (auth.refreshToken) {
      this.setRefreshCookie(response, auth.refreshToken);
    }
    return auth;
  }

  private setRefreshCookie(response: Response, refreshToken: string) {
    response.cookie(this.refreshCookieName, refreshToken, {
      httpOnly: true,
      maxAge: 1000 * 60 * 60 * 24 * 30,
      path: '/v1/auth',
      sameSite: this.refreshCookieSameSite,
      secure: this.refreshCookieSecure,
    });
  }

  private clearRefreshCookie(response: Response) {
    response.clearCookie(this.refreshCookieName, {
      path: '/v1/auth',
      sameSite: this.refreshCookieSameSite,
      secure: this.refreshCookieSecure,
    });
  }

  private getRefreshTokenCookie(request: Request) {
    const cookieHeader = request.headers.cookie;
    if (!cookieHeader) {
      return undefined;
    }

    return cookieHeader
      .split(';')
      .map((part) => part.trim())
      .map((part) => {
        const separator = part.indexOf('=');
        if (separator === -1) {
          return undefined;
        }
        return [
          decodeURIComponent(part.slice(0, separator)),
          decodeURIComponent(part.slice(separator + 1)),
        ] as const;
      })
      .find((entry) => entry?.[0] === this.refreshCookieName)?.[1];
  }

  private get refreshCookieName() {
    return (
      this.configService.get<string>('app.authRefreshCookieName') ??
      'relax_refresh_token'
    );
  }

  private get refreshCookieSecure() {
    const configured = this.configService.get<string>(
      'app.authRefreshCookieSecure',
    );
    if (configured) {
      return configured === 'true';
    }
    return this.configService.get<string>('app.nodeEnv') === 'production';
  }

  private get refreshCookieSameSite(): 'lax' | 'strict' | 'none' {
    const configured = this.configService
      .get<string>('app.authRefreshCookieSameSite')
      ?.toLowerCase();
    if (
      configured === 'lax' ||
      configured === 'strict' ||
      configured === 'none'
    ) {
      return configured;
    }
    return this.refreshCookieSecure ? 'none' : 'lax';
  }
}
