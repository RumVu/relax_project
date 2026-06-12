import type { NavItem } from '@/types';

export const primaryNav: NavItem[] = [
  { label: 'Overview', href: '/dashboard' },
  { label: 'Mood', href: '/dashboard/mood' },
  { label: 'Breaks', href: '/dashboard/breaks' },
  { label: 'Journal', href: '/dashboard/journal' },
  { label: 'Analytics', href: '/dashboard/analytics' },
  { label: 'Weather', href: '/dashboard/weather' },
  { label: 'Settings', href: '/dashboard/settings' },
];

export const adminNav: NavItem[] = [
  { label: 'Admin Home', href: '/admin' },
  { label: 'Users', href: '/admin/users' },
  { label: 'Search', href: '/admin/search' },
  { label: 'Logs', href: '/admin/logs' },
  { label: 'Quotes', href: '/admin/quotes' },
  { label: 'Sounds', href: '/admin/sounds' },
  { label: 'Podcasts', href: '/admin/podcasts' },
  { label: 'Exercises', href: '/admin/exercises' },
  { label: 'Themes', href: '/admin/themes' },
  { label: 'Onboarding', href: '/admin/onboarding' },
  { label: 'Companion Assets', href: '/admin/companion-assets' },
  { label: 'Companion Messages', href: '/admin/companion-messages' },
  { label: 'Pricing & sale', href: '/admin/pricing' },
  { label: 'User Locations', href: '/admin/user-locations' },
];
