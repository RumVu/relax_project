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
import { CurrentUser } from './decorators/current-user.decorator';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { AuthService } from './auth.service';
import type { AuthUser } from './auth.types';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { RegisterDto } from './dto/register.dto';
import { DeleteAccountDto } from './dto/delete-account.dto';
import { RequestPasswordResetDto } from './dto/request-password-reset.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { VerifyEmailDto } from './dto/verify-email.dto';

@ApiTags('Auth')
@Throttle({
  default: { ttl: minutes(1), limit: 20, blockDuration: minutes(2) },
})
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @ApiOperation({ summary: 'Register a local user and create a session' })
  @ApiCreatedResponse({ description: 'User, access token, and refresh token.' })
  @Throttle({
    default: { ttl: minutes(1), limit: 5, blockDuration: minutes(5) },
  })
  @Post('register')
  register(
    @Body() dto: RegisterDto,
    @Headers('user-agent') userAgent: string | undefined,
    @Req() request: Request,
  ) {
    return this.authService.register(dto, userAgent, request.ip);
  }

  @ApiOperation({ summary: 'Login with email and password' })
  @ApiCreatedResponse({ description: 'User, access token, and refresh token.' })
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
    return this.authService.login(dto, userAgent, request.ip);
  }

  @ApiOperation({ summary: 'Rotate a refresh token' })
  @ApiCreatedResponse({
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
    return this.authService.refresh(dto, userAgent, request.ip);
  }

  @ApiOperation({ summary: 'Logout by revoking one refresh token' })
  @ApiCreatedResponse({ description: 'Logout success payload.' })
  @Post('logout')
  logout(@Body() dto: RefreshTokenDto) {
    return this.authService.logout(dto.refreshToken);
  }

  @ApiOperation({ summary: 'Request a password reset email' })
  @ApiCreatedResponse({
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
    description: 'Password has been reset and active sessions were revoked.',
  })
  @Post('password-reset/confirm')
  resetPassword(@Body() dto: ResetPasswordDto) {
    return this.authService.resetPassword(dto);
  }

  @ApiOperation({ summary: 'Verify email with an account token' })
  @ApiCreatedResponse({ description: 'Email verification result.' })
  @Post('email/verify')
  verifyEmail(@Body() dto: VerifyEmailDto) {
    return this.authService.verifyEmail(dto);
  }

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Get the current authenticated user' })
  @ApiOkResponse({ description: 'Current safe user payload.' })
  @ApiUnauthorizedResponse({
    description: 'Bearer token is missing or invalid.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me')
  me(@CurrentUser() user: AuthUser) {
    return this.authService.me(user.id);
  }

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Request current user email verification token' })
  @ApiCreatedResponse({
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
    description:
      'Account deletion result. SOFT anonymizes and deactivates; HARD removes related data via cascade.',
  })
  @UseGuards(JwtAuthGuard)
  @Delete('me')
  deleteMine(@CurrentUser() user: AuthUser, @Body() dto: DeleteAccountDto) {
    return this.authService.deleteMine(user.id, dto);
  }
}
