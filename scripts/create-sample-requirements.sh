#!/bin/bash

# Create Sample Requirements Script
# サンプル要件定義を作成します

echo "📝 サンプル要件定義を作成しています..."

mkdir -p requirements/sample

# サンプルプロジェクト要件定義
cat > requirements/sample/README.md << 'EOF'
# タスク管理システム開発プロジェクト

## プロジェクト概要
シンプルで使いやすいタスク管理Webアプリケーションを開発する。

## 主要機能
1. ユーザー認証（ログイン/ログアウト）
2. タスクのCRUD操作
3. タスクの優先度設定
4. タスクのカテゴリ分類
5. 期限管理とリマインダー

## 技術要件
- フロントエンド: React + TypeScript
- バックエンド: Node.js + Express
- データベース: PostgreSQL
- 認証: JWT
- スタイリング: Tailwind CSS

## 非機能要件
- レスポンシブデザイン対応
- ページ読み込み時間3秒以内
- 同時接続100ユーザー対応

## 納期
- MVP: 2週間
- 完成版: 1ヶ月
EOF

# 機能詳細
cat > requirements/sample/features.md << 'EOF'
# 機能詳細仕様

## 1. ユーザー認証
- メールアドレスとパスワードでのログイン
- 新規ユーザー登録
- パスワードリセット機能
- セッション管理（24時間有効）

## 2. タスク管理
### タスク作成
- タイトル（必須、100文字以内）
- 説明（任意、1000文字以内）
- 優先度（高・中・低）
- カテゴリ選択
- 期限設定

### タスク一覧
- ソート機能（期限、優先度、作成日）
- フィルター機能（ステータス、カテゴリ）
- 検索機能（タイトル、説明）
- ページネーション（20件/ページ）

### タスク更新
- 全項目の編集可能
- ステータス変更（未着手→進行中→完了）
- 更新履歴の保存

## 3. 通知機能
- 期限24時間前の通知
- 期限超過時の警告
- メール通知オプション
EOF

# 技術仕様
cat > requirements/sample/technical.md << 'EOF'
# 技術仕様書

## アーキテクチャ
- フロントエンドとバックエンドの分離
- RESTful API設計
- JWT認証

## API設計
### 認証関連
- POST /api/auth/login
- POST /api/auth/register
- POST /api/auth/logout
- POST /api/auth/refresh

### タスク関連
- GET /api/tasks（一覧取得）
- POST /api/tasks（作成）
- GET /api/tasks/:id（詳細取得）
- PUT /api/tasks/:id（更新）
- DELETE /api/tasks/:id（削除）

## データベース設計
### usersテーブル
- id (UUID, PK)
- email (VARCHAR(255), UNIQUE)
- password_hash (VARCHAR(255))
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

### tasksテーブル
- id (UUID, PK)
- user_id (UUID, FK)
- title (VARCHAR(100))
- description (TEXT)
- priority (ENUM)
- category (VARCHAR(50))
- status (ENUM)
- due_date (TIMESTAMP)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

## セキュリティ要件
- パスワードのハッシュ化（bcrypt）
- SQLインジェクション対策
- XSS対策
- CSRF対策
- HTTPSの使用
EOF

echo "✅ サンプル要件定義を作成しました！"
echo ""
echo "作成されたファイル:"
echo "- requirements/sample/README.md (プロジェクト概要)"
echo "- requirements/sample/features.md (機能詳細)"
echo "- requirements/sample/technical.md (技術仕様)"