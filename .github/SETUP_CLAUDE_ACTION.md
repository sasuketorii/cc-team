# Claude Code GitHub Action セットアップガイド

## 🌟 Claude MAXプランユーザーの方へ

### 認証について
**Claude MAXプランでGitHub連携済みの場合、APIキーの設定は不要です！**

公式GitHub連携により、以下が自動的に利用可能になります：
- @claudeメンションへの応答
- Claude Code Actionの実行
- 認証情報の自動管理

### 必要な設定（MAXプランユーザー）

#### 1. GitHub連携の確認
1. ClaudeのWebインターフェースでGitHub連携が完了しているか確認
2. 連携されているリポジトリを確認

#### 2. リポジトリ権限の設定
Settings → Actions → General → Workflow permissions で以下を確認：
- ✅ Read and write permissions
- ✅ Allow GitHub Actions to create and approve pull requests

## 🚀 使い方

### 基本的な使用
```bash
# Issueやプルリクエストでコメント
@claude ユーザー認証機能を実装して
```

### CCTeam Boss機能
```bash
# Bossにタスクを依頼
@claude boss requirements/を分析してタスク分配計画を作成
```

### 自動リリース
```bash
# パッチリリース（0.0.x）
@claude release patch

# マイナーリリース（0.x.0）
@claude release minor

# メジャーリリース（x.0.0）
@claude release major
```

## ⚠️ 注意事項

1. **Claude MAXプランのGitHub連携が有効であることを確認**
2. **メインブランチの保護を推奨**
3. **PR経由での変更を推奨**
4. **リポジトリへのアクセス権限を適切に管理**

## 🔧 トラブルシューティング

### Actionが動作しない場合
1. Claude MAXプランのGitHub連携が有効か確認
2. ワークフロー権限を確認
3. @claudeメンションが含まれているか確認
4. リポジトリがClaudeに連携されているか確認

### エラーが発生する場合
- Actions タブでログを確認
- Claude Web UIでGitHub連携状態を確認
- レート制限に注意

## 🎆 MAXプランのメリット

- APIキー管理不要
- セキュリティリスクの低減
- シームレスなGitHub統合
- 公式サポート