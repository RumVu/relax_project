import { expect, test } from '@playwright/test';

test.describe('Public surface smoke', () => {
  test('login page renders the email/password form', async ({ page }) => {
    await page.goto('/auth/login');
    await expect(
      page.getByRole('heading', { name: /sign in to the recovery dashboard/i }),
    ).toBeVisible();
    await expect(page.getByPlaceholder('Email')).toBeVisible();
    await expect(page.getByPlaceholder('Password')).toBeVisible();
    await expect(page.getByRole('link', { name: /create one/i })).toBeVisible();
  });

  test('register page renders the sign-up form', async ({ page }) => {
    await page.goto('/auth/register');
    await expect(page.getByPlaceholder('Full name')).toBeVisible();
    await expect(page.getByPlaceholder('Email')).toBeVisible();
    await expect(page.getByPlaceholder('Password')).toBeVisible();
  });

  test('login page links over to the register flow', async ({ page }) => {
    await page.goto('/auth/login');
    await page.getByRole('link', { name: /create one/i }).click();
    await expect(page).toHaveURL(/\/auth\/register/);
    await expect(page.getByPlaceholder('Full name')).toBeVisible();
  });
});
