# CCTeam プロジェクト v0.1.4

## 概要
CCTeamはClaude Code AIエージェントによる統合Boss + 3 Workers構成の開発チームです。tmuxを使用して単一セッションで全エージェントを管理し、効率的な並列開発を実現します。

## エージェント構成（統合アーキテクチャ）
- **BOSS** (統合版): 全体管理・Worker直接制御
- **Worker1**: フロントエンド開発
- **Worker2**: バックエンド開発
- **Worker3**: テスト・品質保証
- **Gemini** (サポート): 調査・ドキュメント支援

## セットアップ

### 初期設定
```bash
# 環境構築
./scripts/setup.sh

# CCTeam起動（v3: 手動認証版）
ccteam  # または ./scripts/launch-ccteam-v3.sh

# プロジェクト状況確認
./scripts/project-status.sh

# tmux接続
tmux attach -t ccteam
```

### エージェント間通信
```bash
# BOSSへの指示:
./scripts/agent-send.sh boss "requirementsを読み込んで作業を開始してください"

# Workerへの直接指示（通常はBoss経由）:
./scripts/agent-send.sh worker1 "UIコンポーネントを実装してください"
```

### tmuxペイン管理
```bash
# ペインレイアウトを保存
./scripts/tmux-pane-manager.sh save ccteam

# ペインを復元
./scripts/tmux-pane-manager.sh restore ccteam

# 新しいエージェントを追加
./scripts/tmux-pane-manager.sh add ccteam worker4

# ペイン情報を表示
./scripts/tmux-pane-manager.sh info ccteam
```

### Git Worktree並列開発
```bash
# 初期設定
./scripts/worktree-parallel-manual.sh setup

# 自動割り当て
./scripts/worktree-parallel-manual.sh auto-assign

# 新しいworktreeを作成
./scripts/worktree-parallel-manual.sh create feature/new-feature worker1

# 状態確認
./scripts/worktree-parallel-manual.sh status
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
  tests/           # テストスクリプト・履歴
    history/       # テスト実行履歴のアーカイブ
  memory/          # AIメモリシステム（SQLite）
  reports/         # 各種レポート出力
  investigation_reports/  # 調査報告書（日時付き）
  .claude/         # Claude Code Actions設定
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

#### テストスクリプト
```bash
# クイックヘルスチェック
./tests/quick_health_check.sh

# 詳細システムチェック
./tests/system_health_check.sh

# 統合テスト
./tests/integration_test.sh

# テスト後のクリーンアップ
./tests/cleanup_test_files.sh

# テスト結果のアーカイブ
./tests/test_log_archiver.sh
```

#### テスト履歴
- `tests/history/`: テスト実行結果のアーカイブ
- 各実行ごとにタイムスタンプ付きディレクトリを作成
- レポート、ログ、サマリー情報を保存

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

## ドキュメント管理

### 調査報告書の作成
```bash
# 新規調査報告書の作成（日本時間でファイル名生成）
./scripts/create_investigation_report.sh "タイトル" "説明"

# 例：
./scripts/create_investigation_report.sh "エラーループ改善" "エラーループ検出システムの改善調査"
# → investigation_reports/20250109_193000_エラーループ改善調査報告.md
```

### ドキュメント構成
- `investigation_reports/`: 調査報告書（YYYYMMDD_HHMMSS_タイトル調査報告.md）
- `reports/`: 自動生成レポート
- `tests/test_scripts.md`: テストスクリプトのドキュメント

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