// Jest テスト環境のセットアップ
import '@testing-library/jest-dom';

// グローバルモックの設定
global.console = {
  ...console,
  error: jest.fn(),
  warn: jest.fn(),
};

// テストタイムアウトの設定
jest.setTimeout(30000);

// 環境変数の設定
process.env.NODE_ENV = 'test';
process.env.DATABASE_URL = 'postgresql://test:test@localhost:5432/test_db';
process.env.REDIS_URL = 'redis://localhost:6379';

// モック関数のリセット
afterEach(() => {
  jest.clearAllMocks();
});

// データベース接続のクリーンアップ
afterAll(async () => {
  // ここでデータベース接続をクローズする処理を追加
});