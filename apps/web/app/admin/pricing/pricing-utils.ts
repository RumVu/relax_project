import type { EditDraft, Tier } from './pricing-types';

export const EMPTY_DRAFT: EditDraft = {
  name: '',
  title: '',
  description: '',
  price: '0',
  salePrice: '',
  saleLabel: '',
  saleStartsAt: '',
  saleEndsAt: '',
  currency: 'VND',
  billingCycle: 'MONTHLY',
  displayOrder: '0',
  isActive: true,
};

export function toDraft(tier: Tier): EditDraft {
  return {
    id: tier.id,
    name: tier.name,
    title: tier.title ?? '',
    description: tier.description ?? '',
    price: String(tier.price ?? 0),
    salePrice: tier.salePrice == null ? '' : String(tier.salePrice),
    saleLabel: tier.saleLabel ?? '',
    saleStartsAt: tier.saleStartsAt ? tier.saleStartsAt.slice(0, 16) : '',
    saleEndsAt: tier.saleEndsAt ? tier.saleEndsAt.slice(0, 16) : '',
    currency: tier.currency,
    billingCycle: tier.billingCycle,
    displayOrder: String(tier.displayOrder ?? 0),
    isActive: tier.isActive,
  };
}
