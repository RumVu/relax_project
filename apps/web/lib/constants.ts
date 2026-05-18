import type { NavItem, MoodPoint } from '@/types';

export const primaryNav: NavItem[] = [
  { label: 'Overview', href: '/dashboard' },
  { label: 'Mood', href: '/dashboard/mood' },
  { label: 'Breaks', href: '/dashboard/breaks' },
  { label: 'Journal', href: '/dashboard/journal' },
  { label: 'Analytics', href: '/dashboard/analytics' },
  { label: 'Settings', href: '/dashboard/settings' },
];

export const adminNav: NavItem[] = [
  { label: 'Admin Home', href: '/admin' },
  { label: 'Users', href: '/admin/users' },
  { label: 'Quotes', href: '/admin/quotes' },
  { label: 'Sounds', href: '/admin/sounds' },
  { label: 'Exercises', href: '/admin/exercises' },
];

export const moodTrend: MoodPoint[] = [
  { day: 'Mon', mood: 5, stress: 7 },
  { day: 'Tue', mood: 6, stress: 6 },
  { day: 'Wed', mood: 7, stress: 5 },
  { day: 'Thu', mood: 7, stress: 4 },
  { day: 'Fri', mood: 8, stress: 4 },
  { day: 'Sat', mood: 9, stress: 3 },
  { day: 'Sun', mood: 8, stress: 3 },
];

export const dashboardStats = [
  { label: 'Recovery score', value: '86%', note: 'Up 12% this week' },
  { label: 'Break streak', value: '14 days', note: '3 mindful pauses today' },
  { label: 'Journal cadence', value: '4 entries', note: 'Strong reflection rhythm' },
];
