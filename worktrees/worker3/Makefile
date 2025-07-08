.PHONY: help install test build deploy clean

help: ## ヘルプを表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## 依存関係をインストール
	npm ci
	npx playwright install --with-deps

test: ## テストを実行
	npm run test:coverage

test-e2e: ## E2Eテストを実行
	npm run test:e2e

test-all: test test-e2e ## すべてのテストを実行

docker-up: ## Docker環境を起動
	docker-compose up -d

docker-down: ## Docker環境を停止
	docker-compose down

docker-build: ## Dockerイメージをビルド
	docker-compose build

docker-logs: ## Dockerログを表示
	docker-compose logs -f

docker-clean: ## Docker環境をクリーンアップ
	docker-compose down -v
	docker system prune -f

build: ## アプリケーションをビルド
	npm run build

deploy-staging: ## ステージング環境にデプロイ
	@echo "Deploying to staging..."
	# ステージング環境へのデプロイコマンド

deploy-production: ## 本番環境にデプロイ
	@echo "Deploying to production..."
	# 本番環境へのデプロイコマンド

clean: ## ビルド成果物をクリーンアップ
	rm -rf dist coverage playwright-report node_modules

setup: install docker-build docker-up ## 開発環境をセットアップ
	@echo "Development environment is ready!"

monitor: ## アプリケーションの監視
	docker-compose logs -f app