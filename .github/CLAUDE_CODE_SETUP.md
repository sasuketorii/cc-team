# Claude Code GitHub Actions セットアップガイド

## 🚀 クイックスタート（MAXプランユーザー）

### 1. Claude Codeで /install-github-app を実行
```bash
# ターミナルでClaude Codeを開く
claude

# GitHub App をインストール
/install-github-app
```

これにより：
- GitHub Appがインストールされます
- 必要な権限が設定されます
- リポジトリとの連携が完了します

### 2. OAuth トークンを生成（オプション）
```bash
# MAX/Proユーザーの場合
claude setup-token

# 生成されたトークンをGitHub Secretsに追加
# Settings → Secrets → New repository secret
# Name: CLAUDE_CODE_OAUTH_TOKEN
# Value: 生成されたトークン
```

### 3. ワークフローファイルの確認
`.github/workflows/claude-code-action.yml` が存在することを確認

## 📝 使い方

### 基本的な使用
```bash
# Issue や PR でコメント
@claude このバグを修正してください

# Claudeが自動的に：
# 1. コードを分析
# 2. 修正を実装
# 3. PRを作成
```

### CCTeam Boss機能
```bash
# BossとしてタスクをCFaudeに依頼
@claude boss: requirements/を分析してタスク分配計画を作成してください

# Claudeが自動的に：
# 1. 要件を分析
# 2. タスク分配計画を作成
# 3. ドキュメントを生成
```

### リリース自動化
```bash
# バージョンアップとリリース
@claude release patch  # 0.0.x
@claude release minor  # 0.x.0
@claude release major  # x.0.0

# Claudeが自動的に：
# 1. CHANGELOGを更新
# 2. バージョンをアップ
# 3. タグとリリースを作成
```

## 🔧 トラブルシューティング

### Actionが動作しない場合
1. Claude Codeで `/install-github-app` を実行したか確認
2. リポジトリの権限設定を確認
3. @claudeメンションが正しく含まれているか確認

### 認証エラーの場合
- MAXプランユーザー: OAuth トークンを再生成
- 通常ユーザー: Anthropic APIキーを設定

## 🌟 MAXプラン特典

- APIキー管理不要
- 優先実行
- 高度なコード分析
- 無制限のリクエスト（レート制限内）

## 📚 参考リンク

- [公式ドキュメント（日本語）](https://docs.anthropic.com/ja/docs/claude-code/github-actions)
- [公式ドキュメント（英語）](https://docs.anthropic.com/en/docs/claude-code/github-actions)
- [GitHub リポジトリ](https://github.com/anthropics/claude-code-action)