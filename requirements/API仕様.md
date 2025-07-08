# API仕様

## エンドポイント一覧

### 認証系
- `POST /api/auth/register` - ユーザー登録
- `POST /api/auth/login` - ログイン
- `POST /api/auth/logout` - ログアウト
- `POST /api/auth/refresh` - トークン更新

### ユーザー系
- `GET /api/users/me` - 現在のユーザー情報
- `PUT /api/users/me` - ユーザー情報更新
- `DELETE /api/users/me` - アカウント削除

### タスク系
- `GET /api/tasks` - タスク一覧取得
- `POST /api/tasks` - タスク作成
- `GET /api/tasks/:id` - タスク詳細取得
- `PUT /api/tasks/:id` - タスク更新
- `DELETE /api/tasks/:id` - タスク削除

### リスト系
- `GET /api/lists` - リスト一覧取得
- `POST /api/lists` - リスト作成
- `GET /api/lists/:id` - リスト詳細取得
- `PUT /api/lists/:id` - リスト更新
- `DELETE /api/lists/:id` - リスト削除
- `GET /api/lists/:id/tasks` - リスト内のタスク取得

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