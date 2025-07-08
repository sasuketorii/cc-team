import { test, expect } from '@playwright/test';

test.describe('CCTeam アプリケーション', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('ホームページが正しく表示される', async ({ page }) => {
    await expect(page).toHaveTitle(/CCTeam/);
    await expect(page.locator('h1')).toContainText('CCTeam');
  });

  test('ナビゲーションが機能する', async ({ page }) => {
    // ナビゲーションリンクをクリック
    await page.click('nav a[href="/about"]');
    await expect(page).toHaveURL('/about');
    
    await page.click('nav a[href="/"]');
    await expect(page).toHaveURL('/');
  });

  test('フォーム送信が正しく動作する', async ({ page }) => {
    // フォームに入力
    await page.fill('input[name="name"]', 'テストユーザー');
    await page.fill('input[name="email"]', 'test@example.com');
    
    // 送信ボタンをクリック
    await page.click('button[type="submit"]');
    
    // 成功メッセージを確認
    await expect(page.locator('.success-message')).toBeVisible();
  });

  test('レスポンシブデザインが機能する', async ({ page }) => {
    // モバイルビューポートサイズに変更
    await page.setViewportSize({ width: 375, height: 667 });
    
    // モバイルメニューが表示されることを確認
    await expect(page.locator('.mobile-menu-button')).toBeVisible();
    
    // デスクトップビューポートサイズに戻す
    await page.setViewportSize({ width: 1280, height: 720 });
    
    // デスクトップメニューが表示されることを確認
    await expect(page.locator('.desktop-menu')).toBeVisible();
  });

  test('エラーハンドリングが正しく動作する', async ({ page }) => {
    // 存在しないページにアクセス
    await page.goto('/not-found-page');
    
    // 404エラーページが表示されることを確認
    await expect(page.locator('h1')).toContainText('404');
  });
});