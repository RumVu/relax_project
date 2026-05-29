import {
  Body,
  Controller,
  Delete,
  Get,
  Headers,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { minutes, Throttle } from '@nestjs/throttler';
import type { Request } from 'express';
import { getClientIp } from '../common/client-ip';
import { CurrentUser } from './decorators/current-user.decorator';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { AuthService } from './auth.service';
import type { AuthUser } from './auth.types';
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
  constructor(private readonly authService: AuthService) {}

  @ApiOperation({ summary: 'Register a local user and create a session' })
  @ApiCreatedResponse({
    type: AuthResponseDto,
    description: 'User, access token, and refresh token.',
  })
  @Throttle({
    default: { ttl: minutes(1), limit: 5, blockDuration: minutes(5) },
  })
  @Post('register')
  register(
    @Body() dto: RegisterDto,
    @Headers('user-agent') userAgent: string | undefined,
    @Req() request: Request,
  ) {
    return this.authService.register(dto, userAgent, getClientIp(request));
  }

  @ApiOperation({ summary: 'Login with email and password' })
  @ApiCreatedResponse({
    type: AuthResponseDto,
    description: 'User, access token, and refresh token.',
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
  ) {
    return this.authService.login(dto, userAgent, getClientIp(request));
  }

  @ApiOperation({ summary: 'Exchange a Google ID token for an app session' })
  @ApiCreatedResponse({
    type: AuthResponseDto,
    description: 'User, access token and refresh token (Google account).',
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
  ) {
    return this.authService.googleLogin(dto, userAgent, getClientIp(request));
  }

  @ApiOperation({ summary: 'Rotate a refresh token' })
  @ApiCreatedResponse({
    type: AuthResponseDto,
    description: 'Fresh access token, refresh token, and user.',
  })
  @ApiUnauthorizedResponse({
    description: 'Refresh token is invalid or expired.',
  })
  @Post('refresh')
  refresh(
    @Body() dto: RefreshTokenDto,
    @Headers('user-agent') userAgent: string | undefined,
    @Req() request: Request,
  ) {
    return this.authService.refresh(dto, userAgent, getClientIp(request));
  }

  @ApiOperation({ summary: 'Logout by revoking one refresh token' })
  @ApiCreatedResponse({
    type: AuthActionResultDto,
    description: 'Logout success payload.',
  })
  @Post('logout')
  logout(@Body() dto: RefreshTokenDto) {
    return this.authService.logout(dto.refreshToken);
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
}
