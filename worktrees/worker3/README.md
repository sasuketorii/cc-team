# CCTeam インフラストラクチャ & テスト環境

Worker3が管理するインフラストラクチャとテスト環境のセットアップです。

## 構成

- **Docker Compose**: 開発環境の構築
- **Jest**: 単体テスト
- **Playwright**: E2Eテスト
- **GitHub Actions**: CI/CDパイプライン

## クイックスタート

```bash
# 環境セットアップ
make setup

# テスト実行
make test-all

# Docker環境確認
docker-compose ps
```

## 主要コマンド

### Docker操作
- `make docker-up`: 環境起動
- `make docker-down`: 環境停止
- `make docker-logs`: ログ確認
- `make docker-clean`: クリーンアップ

### テスト実行
- `make test`: 単体テスト
- `make test-e2e`: E2Eテスト
- `make test-all`: 全テスト実行

### デプロイ
- `make deploy-staging`: ステージング環境
- `make deploy-production`: 本番環境

## 環境構成

### サービス一覧
- **app**: Node.jsアプリケーション (Port: 3000)
- **postgres**: PostgreSQL DB (Port: 5432)
- **redis**: Redisキャッシュ (Port: 6379)
- **nginx**: リバースプロキシ (Port: 80/443)
- **adminer**: DB管理ツール (Port: 8080)

### テストカバレッジ目標
- ブランチ: 80%
- 関数: 80%
- 行: 80%
- ステートメント: 80%

## CI/CDパイプライン

1. **Test**: 単体テスト・E2Eテスト実行
2. **Build**: Dockerイメージビルド
3. **Deploy**: 本番環境へのデプロイ（mainブランチのみ）

---
Worker3 - Infrastructure & Testing