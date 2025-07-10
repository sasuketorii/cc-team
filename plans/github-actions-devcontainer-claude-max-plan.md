# CCTeam GitHub Actions & Dev Container 実装計画（Claude MAX対応版）

## 🎯 目的
CCTeamの開発環境を標準化し、安全かつ効率的な開発・CI/CDパイプラインを構築する。
Claude MAXサブスクリプション認証に対応した自動化を実現。

## 🔐 Claude MAX認証対応

### 認証方式の変更点
- ❌ APIキーベースの認証は使用不可
- ✅ OAuthトークンベースの認証を使用
- ✅ `~/.claude/.credentials.json`からトークン抽出
- ✅ GitHub Secretsでトークンを安全に管理

### 実装アプローチ
1. **ローカル開発**: Dev Containerで`~/.claude`をマウント
2. **CI/CD**: GitHub ActionsでOAuthトークンを環境変数として注入
3. **トークン更新**: 定期的な自動更新メカニズム

---

## 📦 Dev Container実装

### 1. 基本構成（`.devcontainer/devcontainer.json`）
```json
{
  "name": "CCTeam Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {},
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/devcontainers/features/node:1": {
      "version": "lts"
    },
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.11"
    }
  },
  
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-azuretools.vscode-docker",
        "github.vscode-github-actions",
        "ms-python.python",
        "esbenp.prettier-vscode",
        "dbaeumer.vscode-eslint"
      ],
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash",
        "python.defaultInterpreterPath": "/usr/local/bin/python"
      }
    }
  },
  
  "mounts": [
    // Claude認証情報をマウント（読み取り専用）
    "source=${localEnv:HOME}/.claude,target=/home/vscode/.claude,type=bind,consistency=cached,readonly"
  ],
  
  "postCreateCommand": "bash .devcontainer/post-create.sh",
  "postStartCommand": "bash .devcontainer/post-start.sh",
  
  "remoteUser": "vscode",
  
  "features": {
    // tmux環境
    "ghcr.io/devcontainers/features/sshd:1": {}
  }
}
```

### 2. セットアップスクリプト（`.devcontainer/post-create.sh`）
```bash
#!/bin/bash
set -e

echo "🚀 CCTeam Dev Container セットアップ開始..."

# 1. tmuxインストール
sudo apt-get update
sudo apt-get install -y tmux expect jq sqlite3

# 2. Claude CLIインストール（非公式フォーク使用）
echo "📦 Claude CLI (OAuth対応版) インストール中..."
git clone https://github.com/unofficial/claude-cli-oauth.git /tmp/claude-cli
cd /tmp/claude-cli
npm install -g .

# 3. CCTeam依存関係インストール
cd /workspaces/CCTeam
npm install

# 4. Python環境セットアップ
pip install -r requirements.txt

# 5. グローバルコマンド設定
./install.sh --dev-container

# 6. Claude認証確認
if [ -f ~/.claude/.credentials.json ]; then
    echo "✅ Claude認証情報を検出しました"
else
    echo "⚠️  Claude認証情報が見つかりません。ホストで認証を完了してください"
fi

echo "✅ Dev Container セットアップ完了！"
```

### 3. 起動時スクリプト（`.devcontainer/post-start.sh`）
```bash
#!/bin/bash

# Claude認証トークン確認
if [ -f ~/.claude/.credentials.json ]; then
    TOKEN_EXPIRY=$(jq -r '.expires_at' ~/.claude/.credentials.json)
    CURRENT_TIME=$(date +%s)
    
    if [ "$TOKEN_EXPIRY" -lt "$CURRENT_TIME" ]; then
        echo "⚠️  Claude認証トークンが期限切れです。再認証が必要です。"
    else
        echo "✅ Claude認証トークンは有効です"
    fi
fi

# CCTeamステータス表示
echo "📊 CCTeamステータス:"
ccstatus || true
```

---

## 🔧 GitHub Actions実装

### 1. CI/CDワークフロー（`.github/workflows/ci.yml`）
```yaml
name: CCTeam CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 9 * * 1' # 毎週月曜日9時（JST）

env:
  NODE_VERSION: '20'
  PYTHON_VERSION: '3.11'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      
      - name: Install dependencies
        run: |
          npm ci
          pip install -r requirements.txt
          sudo apt-get update && sudo apt-get install -y tmux expect
      
      - name: Run tests
        run: |
          npm test
          ./tests/integration_test.sh
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: tests/history/

  quality-check:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup environment
        uses: ./.github/actions/setup-env
      
      - name: Run quality checks
        run: |
          npm run lint
          ./scripts/quality-gate.sh check
      
      - name: Generate report
        run: ./scripts/quality-gate.sh report > quality-report.md
      
      - name: Comment PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('quality-report.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: report
            });

  claude-analysis:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Claude OAuth
        run: |
          # OAuthトークンをセットアップ
          mkdir -p ~/.claude
          echo '{
            "access_token": "${{ secrets.CLAUDE_OAUTH_TOKEN }}",
            "refresh_token": "${{ secrets.CLAUDE_REFRESH_TOKEN }}",
            "expires_at": ${{ secrets.CLAUDE_TOKEN_EXPIRY }}
          }' > ~/.claude/.credentials.json
      
      - name: Install Claude CLI (OAuth版)
        run: |
          git clone https://github.com/unofficial/claude-cli-oauth.git
          cd claude-cli-oauth
          npm install -g .
      
      - name: Analyze PR changes
        run: |
          # 変更ファイルを取得
          CHANGED_FILES=$(gh pr diff ${{ github.event.pull_request.number }} --name-only)
          
          # Claudeで分析
          echo "以下の変更をレビューしてください：" > review-prompt.txt
          gh pr diff ${{ github.event.pull_request.number }} >> review-prompt.txt
          
          claude --no-interactive < review-prompt.txt > claude-review.md
      
      - name: Post review
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const review = fs.readFileSync('claude-review.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## 🤖 Claude Code Review\n\n${review}`
            });
```

### 2. 自動修正ワークフロー（`.github/workflows/auto-fix.yml`）
```yaml
name: Auto Fix

on:
  issue_comment:
    types: [created]

jobs:
  auto-fix:
    if: contains(github.event.comment.body, '/fix')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Claude
        uses: ./.github/actions/setup-claude
        with:
          oauth-token: ${{ secrets.CLAUDE_OAUTH_TOKEN }}
          refresh-token: ${{ secrets.CLAUDE_REFRESH_TOKEN }}
      
      - name: Parse fix request
        id: parse
        run: |
          COMMENT="${{ github.event.comment.body }}"
          # /fix の後のテキストを抽出
          FIX_REQUEST=${COMMENT#*/fix }
          echo "request=$FIX_REQUEST" >> $GITHUB_OUTPUT
      
      - name: Run CCTeam fix
        run: |
          # CCTeam起動
          ./scripts/launch-ccteam-v3.sh --batch
          
          # Boss に修正指示
          ./scripts/agent-send.sh boss "GitHub Issue #${{ github.event.issue.number }} の以下の修正を実行: ${{ steps.parse.outputs.request }}"
          
          # 完了待機（最大30分）
          ./scripts/wait-for-completion.sh 1800
      
      - name: Create PR
        run: |
          git config user.name "CCTeam Bot"
          git config user.email "ccteam@bot.local"
          
          BRANCH="fix/issue-${{ github.event.issue.number }}"
          git checkout -b $BRANCH
          git add -A
          git commit -m "fix: Issue #${{ github.event.issue.number }} - ${{ steps.parse.outputs.request }}"
          git push origin $BRANCH
          
          gh pr create \
            --title "Fix: Issue #${{ github.event.issue.number }}" \
            --body "Automated fix for issue #${{ github.event.issue.number }}\n\nRequested by: @${{ github.event.comment.user.login }}\n\nFix request: ${{ steps.parse.outputs.request }}" \
            --base main
```

### 3. 定期メンテナンスワークフロー（`.github/workflows/maintenance.yml`）
```yaml
name: Maintenance

on:
  schedule:
    - cron: '0 2 * * *' # 毎日午前2時（UTC）
  workflow_dispatch:

jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Cleanup old logs
        run: |
          ./scripts/log_rotation.sh
          ./scripts/cleanup_obsolete_files.sh
      
      - name: Update dependencies
        run: |
          npm update
          pip install -U -r requirements.txt
      
      - name: Create PR if changes
        run: |
          if [[ -n $(git status --porcelain) ]]; then
            git config user.name "CCTeam Bot"
            git config user.email "ccteam@bot.local"
            
            BRANCH="maintenance/$(date +%Y%m%d)"
            git checkout -b $BRANCH
            git add -A
            git commit -m "chore: 定期メンテナンス - $(date +%Y/%m/%d)"
            git push origin $BRANCH
            
            gh pr create \
              --title "定期メンテナンス - $(date +%Y/%m/%d)" \
              --body "自動メンテナンスによる更新です。" \
              --base main
          fi

  token-refresh:
    runs-on: ubuntu-latest
    steps:
      - name: Refresh Claude OAuth Token
        run: |
          # トークンリフレッシュロジック
          RESPONSE=$(curl -X POST https://api.claude.ai/oauth/token \
            -H "Content-Type: application/json" \
            -d '{
              "grant_type": "refresh_token",
              "refresh_token": "${{ secrets.CLAUDE_REFRESH_TOKEN }}"
            }')
          
          NEW_TOKEN=$(echo $RESPONSE | jq -r '.access_token')
          NEW_EXPIRY=$(echo $RESPONSE | jq -r '.expires_at')
          
          # GitHub Secretsを更新
          gh secret set CLAUDE_OAUTH_TOKEN --body "$NEW_TOKEN"
          gh secret set CLAUDE_TOKEN_EXPIRY --body "$NEW_EXPIRY"
```

### 4. カスタムアクション（`.github/actions/setup-claude/action.yml`）
```yaml
name: Setup Claude OAuth
description: Claude CLI with OAuth authentication setup

inputs:
  oauth-token:
    description: 'Claude OAuth access token'
    required: true
  refresh-token:
    description: 'Claude OAuth refresh token'
    required: true

runs:
  using: composite
  steps:
    - name: Install Claude CLI
      shell: bash
      run: |
        git clone https://github.com/unofficial/claude-cli-oauth.git /tmp/claude-cli
        cd /tmp/claude-cli
        npm install -g .
    
    - name: Setup credentials
      shell: bash
      run: |
        mkdir -p ~/.claude
        echo '{
          "access_token": "${{ inputs.oauth-token }}",
          "refresh_token": "${{ inputs.refresh-token }}",
          "expires_at": '$(date -d "+1 hour" +%s)'
        }' > ~/.claude/.credentials.json
```

---

## 🚀 実装手順

### Phase 1: Dev Container（今すぐ実装）
1. `.devcontainer/`ディレクトリ作成
2. 設定ファイル配置
3. ローカルでテスト
4. ドキュメント更新

### Phase 2: 基本的なGitHub Actions（1週間以内）
1. `.github/workflows/`ディレクトリ作成
2. テスト・品質チェックワークフロー実装
3. GitHub Secretsセットアップ

### Phase 3: Claude統合（2週間以内）
1. OAuth認証の調査・テスト
2. 自動レビューワークフロー実装
3. 自動修正機能の実装

### Phase 4: 高度な自動化（1ヶ月以内）
1. 定期メンテナンス自動化
2. トークン自動更新
3. 監視・アラート機能

---

## 📝 必要なGitHub Secrets

```yaml
CLAUDE_OAUTH_TOKEN: # Claude OAuthアクセストークン
CLAUDE_REFRESH_TOKEN: # リフレッシュトークン
CLAUDE_TOKEN_EXPIRY: # トークン有効期限（UNIXタイムスタンプ）
GITHUB_TOKEN: # 自動で提供される
```

---

## ⚠️ 注意事項

1. **認証情報の取り扱い**
   - OAuthトークンは絶対にコードにハードコードしない
   - Dev Containerでは読み取り専用マウントを使用
   - CI/CDではGitHub Secretsを使用

2. **非公式ツールの使用**
   - Claude CLI OAuth版は非公式フォーク
   - 定期的に更新状況を確認
   - 公式サポートが出たら移行検討

3. **レート制限**
   - Claude APIのレート制限に注意
   - 必要に応じてリトライロジック実装
   - 並列実行数を制限

---

## 📚 参考リンク

- [VSCode Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Claude CLI OAuth Fork](https://github.com/unofficial/claude-cli-oauth) ※架空のURL
- [CCTeam Documentation](./README.md)

---

**Created by SasukeTorii / REV-C Inc.**