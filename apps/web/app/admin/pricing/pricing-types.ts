export type BillingCycle = 'MONTHLY' | 'QUARTERLY' | 'YEARLY' | 'LIFETIME';

export interface Tier {
  id: string;
  name: string;
  title: string | null;
  description: string | null;
  price: number;
  salePrice: number | null;
  saleLabel: string | null;
  saleStartsAt: string | null;
  saleEndsAt: string | null;
  currency: string;
  billingCycle: BillingCycle;
  displayOrder: number;
  isActive: boolean;
}

export interface EditDraft {
  id?: string;
  name: string;
  title: string;
  description: string;
  price: string;
  salePrice: string;
  saleLabel: string;
  saleStartsAt: string;
  saleEndsAt: string;
  currency: string;
  billingCycle: BillingCycle;
  displayOrder: string;
  isActive: boolean;
}
