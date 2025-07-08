import { config } from 'dotenv';
import path from 'path';

// テスト用環境変数の読み込み
config({ path: path.resolve(__dirname, '../.env.test') });

// テスト用環境変数の設定
process.env.NODE_ENV = 'test';
process.env.DATABASE_URL = process.env.DATABASE_URL || 'postgresql://test:test@localhost:5432/test_db';
process.env.REDIS_URL = process.env.REDIS_URL || 'redis://localhost:6379/1';
process.env.JWT_SECRET = 'test-jwt-secret';
process.env.SESSION_SECRET = 'test-session-secret';
process.env.PORT = '0'; // ランダムポートを使用

// グローバルモックの設定
jest.mock('../src/backend/utils/logger', () => ({
  logger: {
    info: jest.fn(),
    error: jest.fn(),
    warn: jest.fn(),
    debug: jest.fn(),
  },
}));

// データベース接続のモック（必要に応じて）
let mockDb: any;

beforeAll(async () => {
  // テスト用データベースのセットアップ
  // mockDb = await setupTestDatabase();
});

afterAll(async () => {
  // データベース接続のクリーンアップ
  // await cleanupTestDatabase(mockDb);
  
  // すべてのタイマーをクリア
  jest.clearAllTimers();
});

// 各テスト前の初期化
beforeEach(() => {
  jest.clearAllMocks();
});

// タイムアウトの設定
jest.setTimeout(30000);

// Redisクライアントのモック
jest.mock('redis', () => ({
  createClient: () => ({
    connect: jest.fn(),
    disconnect: jest.fn(),
    get: jest.fn(),
    set: jest.fn(),
    del: jest.fn(),
    expire: jest.fn(),
    on: jest.fn(),
  }),
}));

// HTTPリクエストのモック
jest.mock('axios');

// ファイルシステムのモック（必要に応じて）
jest.mock('fs/promises', () => ({
  readFile: jest.fn(),
  writeFile: jest.fn(),
  unlink: jest.fn(),
  mkdir: jest.fn(),
  rmdir: jest.fn(),
}));