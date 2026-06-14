import { SetMetadata } from '@nestjs/common';

export const REQUIRE_PREMIUM_KEY = 'require_premium';
export const RequirePremium = () => SetMetadata(REQUIRE_PREMIUM_KEY, true);
