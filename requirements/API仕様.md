# API仕様

## エンドポイント一覧

### 認証系
- `POST /api/auth/login` - ログイン
- `POST /api/auth/logout` - ログアウト

### ユーザー系
- `GET /api/users` - ユーザー一覧
- `GET /api/users/:id` - ユーザー詳細
- `POST /api/users` - ユーザー作成
- `PUT /api/users/:id` - ユーザー更新

## レスポンス形式
```json
{
  "success": true,
  "data": {},
  "error": null
}
```

## エラーコード
- 400: Bad Request
- 401: Unauthorized
- 404: Not Found
- 500: Internal Server Error