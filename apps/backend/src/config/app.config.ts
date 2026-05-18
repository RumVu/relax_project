import { registerAs } from '@nestjs/config';

export default registerAs('app', () => ({
  port: Number(process.env.PORT ?? 6823),
  nodeEnv: process.env.NODE_ENV ?? 'development',
}));
