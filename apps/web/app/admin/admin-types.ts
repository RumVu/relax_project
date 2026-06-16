export type InfraHealth = {
  service: string;
  status: 'up' | 'down' | 'unknown';
  latencyMs: number | null;
  detail?: string;
  endpoint: string;
};
