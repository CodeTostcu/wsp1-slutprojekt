import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('localhost:9292');
  await page.getByLabel('Användarnamn').fill("Korven");
  await page.getByLabel('Lösenord').fill("123");

  await page.getByText('Login').click();
  
  await expect(page.getByText('Mmm Mumsigt')).toBeVisible();
});


