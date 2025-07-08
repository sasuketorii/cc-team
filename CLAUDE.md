# CCTeam プロジェクト

## 概要
CCTeamはClaude Code AIエージェントによるBOSS + 3 Workers構成の開発チームです。tmuxを使用して2x2の分割画面で並列開発を行います。

## エージェント構成
- **BOSS** (左上): プロジェクト管理・統括
- **Worker1** (右上): フロントエンド開発
- **Worker2** (左下): バックエンド開発
- **Worker3** (右下): テスト・品質保証

## セットアップ

### 初期設定
```bash
# 環境構築
./scripts/setup.sh

# CCTeam起動
./scripts/launch-ccteam.sh

# プロジェクト状況確認
./scripts/project-status.sh

# tmux接続
tmux attach -t ccteam
```

### エージェント間通信
```bash
# BOSSへの指示:
./scripts/agent-send.sh worker1 "タスク実行"

# Workerからの報告
./scripts/agent-send.sh boss "作業完了"
```

## 開発フロー

1. **要件定義**: `requirements/` フォルダに.mdファイルで定義
2. **CCTeam起動**: `./scripts/launch-ccteam.sh` で実行
3. **タスク分配**: BOSSが要件を分析してタスク分配
4. **並列開発**: Workerが並列で開発作業
5. **統合確認**: BOSSが10分ごとに統合確認

## ディレクトリ構造
```
CCTeam/
  scripts/          # 実行スクリプト
  instructions/     # エージェント指示書
  requirements/     # プロジェクト要件
  logs/            # ログファイル
  worktrees/       # Git worktree並列開発
```

## 運用管理

### ログファイル
- `logs/system.log`: システム全体ログ
- `logs/boss.log`: BOSSの活動ログ
- `logs/worker[1-3].log`: Workerの活動ログ
- `logs/communication.log`: エージェント間通信ログ

### 監視方法
1. tmuxセッション確認: `tmux ls`
2. ログ監視: `tail -f logs/*.log`
3. システム再起動: `./scripts/launch-ccteam.sh --restart`

## 開発ガイドライン

### コード品質
- 1日2-4時間の開発時間
- コードレビュー必須

### コミット
- 機能単位でコミット（30分以内）
- コミットメッセージは日本語
- ブランチ名は機能名:feature/xxx

### テスト
- カバレッジ目標: 80%以上
- 単体テスト: 必須
- 統合テスト: 自動化

## プロジェクト設定

### 依存関係
@import ./requirements/README.md

### 開発環境
- コード品質: .eslintrc/.prettierrc設定
- コミット規約: Conventional Commits準拠
- ブランチ戦略: Git Flow

### ビルド・テスト
```bash
# ビルド
npm run build

# テスト
npm test

# リント
npm run lint

# 開発サーバー
npm run dev
```

## トラブルシューティング

### よくある問題
- エージェント応答なし → 再起動
- コミットエラー → ブランチ確認
- ビルドエラー → 依存関係確認

### 対処法
- Workerの応答確認
- ログファイルの確認
- システム再起動

---
このプロジェクトはClaude Code AIエージェントを使用した効率的な開発を目指します。