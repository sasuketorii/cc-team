# CCTeam Worker2 - Backend API

タスク管理システムのバックエンドAPIサービス

## 技術スタック

- Node.js + Express
- TypeScript
- PostgreSQL (Prisma ORM)
- JWT認証

## セットアップ

1. 環境変数の設定
```bash
cp .env.example .env
# .envファイルを編集して実際の値を設定
```

2. 依存関係のインストール
```bash
npm install
```

3. データベースのセットアップ
```bash
npx prisma migrate dev
npx prisma generate
```

4. 開発サーバーの起動
```bash
npm run dev
```

## スクリプト

- `npm run dev` - 開発サーバー起動（ホットリロード）
- `npm run build` - TypeScriptのビルド
- `npm start` - プロダクションサーバー起動
- `npm test` - テスト実行
- `npm run lint` - ESLintチェック
- `npm run format` - Prettierフォーマット

## プロジェクト構造

```
src/
├── controllers/   # リクエストハンドラー
├── models/       # データモデル定義
├── routes/       # APIルート定義
├── services/     # ビジネスロジック
├── middleware/   # カスタムミドルウェア
├── utils/        # ユーティリティ関数
├── types/        # TypeScript型定義
└── server.ts     # エントリーポイント
```

## API エンドポイント

- `GET /health` - ヘルスチェック
- `GET /api/v1` - API情報

### 今後実装予定
- `/api/v1/auth` - 認証関連
- `/api/v1/users` - ユーザー管理
- `/api/v1/tasks` - タスク管理