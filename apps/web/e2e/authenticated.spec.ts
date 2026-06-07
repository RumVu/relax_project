import { expect, test, type BrowserContext, type Page } from '@playwright/test';

test.describe('Authenticated dashboard surfaces', () => {
  test('dashboard renders for a signed-in user', async ({ context, page }) => {
    await signInAs(context, page, 'USER');
    await mockApi(page);

    await page.goto('/dashboard');

    await expect(
      page.getByRole('heading', { name: /relax dashboard|bảng điều khiển/i }),
    ).toBeVisible();
    await expect(page.getByText(/current streak|chuỗi hiện tại/i)).toBeVisible();
    await expect(page.getByRole('link', { name: /settings|cài đặt/i })).toBeVisible();
  });

  test('admin dashboard renders for an admin session', async ({ context, page }) => {
    await signInAs(context, page, 'ADMIN');
    await mockApi(page);

    await page.goto('/admin');

    await expect(
      page.getByRole('heading', { name: /admin dashboard|bảng điều khiển quản trị/i }),
    ).toBeVisible();
    await expect(page.getByRole('link', { name: /users|người dùng/i })).toBeVisible();
    await expect(page.getByRole('link', { name: /sounds|âm thanh/i })).toBeVisible();
  });
});

async function signInAs(
  context: BrowserContext,
  page: Page,
  role: 'ADMIN' | 'USER',
) {
  await context.addCookies([
    {
      name: 'relax_session',
      value: `role:${role}`,
      domain: 'localhost',
      path: '/',
    },
  ]);

  await page.addInitScript((userRole) => {
    window.localStorage.setItem('relax_access_token', 'playwright-access-token');
    window.localStorage.setItem('relax_session_id', 'playwright-session');
    window.localStorage.setItem('relax_user_role', userRole);
  }, role);
}

async function mockApi(page: Page) {
  await page.route('**/v1/**', async (route) => {
    const url = new URL(route.request().url());
    const path = url.pathname.replace(/^\/v1/, '');

    await route.fulfill({
      contentType: 'application/json',
      json: payloadFor(path),
      status: 200,
    });
  });
}

function payloadFor(path: string) {
  if (path === '/auth/me') {
    return {
      id: 'playwright-user',
      email: 'playwright@example.com',
      name: 'Playwright User',
      role: 'ADMIN',
    };
  }

  if (path === '/admin/analytics/overview') {
    return {
      metrics: [
        { label: 'DAU', value: 12, delta: '+2 today' },
        { label: 'Users', value: 48, delta: '+4 this week' },
      ],
      userGrowth: [{ label: 'Mon', value: 4 }],
      contentEngagement: [{ label: 'Sounds', value: 8 }],
      users: [
        {
          name: 'Playwright User',
          email: 'playwright@example.com',
          status: 'Active',
          plan: 'FREE',
          streak: 3,
          lastLogin: 'Today',
        },
      ],
      content: [{ area: 'Sounds', endpoint: '/ambient-sounds', live: 8, drafts: 0 }],
    };
  }

  if (path === '/analytics/me/overview') {
    return {
      summaryCards: {
        currentStreak: 3,
        totalRelaxTime: '45m',
        totalJournals: 2,
        companionAffection: 88,
        stressReduction: 24,
      },
      mood: {
        currentMood: 'CALM',
        prompt: 'Take a softer break.',
        summary: {
          total: 4,
          topMood: 'CALM',
          currentStreak: 3,
          longestStreak: 5,
          averageIntensity: 60,
        },
        recommendations: [],
      },
      relax: {
        totalSessions: 3,
        totalDurationSeconds: 2700,
        relief: 24,
        favoriteActivities: [],
        recentMoments: [],
      },
      companion: {
        level: 1,
        affection: 88,
        energy: 75,
        mood: 'CHILL',
        action: 'IDLE',
        totalInteractions: 2,
        recentInteractions: [],
      },
      weather: {
        greeting: { title: 'Good afternoon', subtitle: 'Light clouds', iconKey: 'sun' },
        current: { temperature: 25, weatherCode: 1, isDay: true },
        forecast: [],
      },
      notifications: { unreadCount: 1, list: [] },
    };
  }

  if (path.includes('/unread-count')) return { count: 0 };
  if (path.includes('/stats')) return {};
  if (path.includes('/profile')) return { displayName: 'Playwright User' };
  if (path.includes('/preferences')) return { locale: 'en' };
  if (path.includes('/billing/me')) return { plan: 'FREE' };
  if (path.includes('/weather/me/current')) return {};
  if (path.includes('/weather/me/forecast')) return { items: [] };

  return { items: [], total: 0 };
}
