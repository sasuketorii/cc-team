# CCTeam コマンド一覧

> このファイルはCCTeamで使用可能なすべてのコマンドとスクリプトの一覧です。
> 新しいスクリプトを追加した場合は、必ずこのファイルを更新してください。

## 目次

1. [プロジェクト管理](#プロジェクト管理)
2. [エージェント管理](#エージェント管理)
3. [開発ツール](#開発ツール)
4. [テスト関連](#テスト関連)
5. [メモリ・ログ管理](#メモリログ管理)
6. [Git Worktree](#git-worktree)
7. [調査・レポート](#調査レポート)
8. [メンテナンス](#メンテナンス)

---

## プロジェクト管理

### セットアップ
```bash
./scripts/setup.sh
```
- **説明**: CCTeamの初期環境構築
- **用途**: 最初のセットアップ時に実行
- **ディレクトリ**: `scripts/`

### プロジェクト状況確認
```bash
./scripts/project-status.sh
```
- **説明**: 現在のプロジェクト状況をレポート
- **出力**: エージェント状態、Git状態、ログ確認
- **ディレクトリ**: `scripts/`


---

## エージェント管理

### CCTeam起動
```bash
ccteam  # エイリアス
./scripts/launch-ccteam-v3.sh  # 実体
```
- **説明**: CCTeam（Boss + Workers）を起動
- **バージョン**: v3（手動認証版）
- **ディレクトリ**: `scripts/`

### エージェントへの指示送信
```bash
./scripts/agent-send.sh [agent] "メッセージ"
```
- **説明**: 特定のエージェントに指示を送信
- **引数**: 
  - `agent`: boss, worker1, worker2, worker3, gemini
  - `メッセージ`: 送信する指示内容
- **ディレクトリ**: `scripts/`

### tmuxペイン管理
```bash
./scripts/tmux-pane-manager.sh [command] [session]
```
- **コマンド**:
  - `save`: ペインレイアウトを保存
  - `restore`: ペインレイアウトを復元
  - `add`: 新しいペインを追加
  - `info`: ペイン情報を表示
- **ディレクトリ**: `scripts/`

---

## 開発ツール

### 開発サーバー
```bash
npm run dev
```
- **説明**: 開発サーバーを起動
- **ポート**: 3000（デフォルト）

### ビルド
```bash
npm run build
```
- **説明**: プロダクションビルドを実行

### リント
```bash
npm run lint
```
- **説明**: コード品質チェック

### タイプチェック
```bash
npm run typecheck
```
- **説明**: TypeScriptの型チェック

---

## テスト関連

### クイックヘルスチェック
```bash
./tests/quick_health_check.sh
```
- **説明**: 基本的なシステム動作確認
- **実行時間**: 約30秒
- **ディレクトリ**: `tests/`

### システムヘルスチェック
```bash
./tests/system_health_check.sh
```
- **説明**: 詳細なシステム健全性確認
- **実行時間**: 約2-3分
- **ディレクトリ**: `tests/`

### 統合テスト
```bash
./tests/integration_test.sh
```
- **説明**: エージェント間連携の統合テスト
- **ディレクトリ**: `tests/`

### テストログアーカイブ
```bash
./tests/test_log_archiver.sh
```
- **説明**: テスト結果を履歴として保存
- **出力**: `tests/history/`
- **ディレクトリ**: `tests/`

### テストファイルクリーンアップ
```bash
./tests/cleanup_test_files.sh
```
- **説明**: テスト関連の一時ファイルを削除
- **ディレクトリ**: `tests/`

### NPMテスト
```bash
npm test
```
- **説明**: Jestによる単体テスト実行

---

## メモリ・ログ管理

### メモリマネージャー
```bash
python3 scripts/memory_manager.py [command]
```
- **コマンド**:
  - `save`: 会話を保存
  - `load`: 最近の記憶を表示
  - `search`: 記憶を検索
  - `export`: スナップショットをエクスポート
  - `stats`: 統計情報を表示
- **ディレクトリ**: `scripts/`

### データリフレッシュ
```bash
./scripts/refresh-ccteam-data.sh
```
- **説明**: SQLite、ログ、メモリをすべてリフレッシュ
- **機能**: バックアップ作成後にクリーンアップ
- **ディレクトリ**: `scripts/`

### 古いファイルクリーンアップ
```bash
./scripts/cleanup_obsolete_files.sh
```
- **説明**: 不要になった古いファイルを削除
- **ディレクトリ**: `scripts/`

### ログフォーマット変換
```bash
./scripts/log_format_converter.sh
```
- **説明**: ログファイルのフォーマットを変換
- **ディレクトリ**: `scripts/`

### ログクリーンアップ
```bash
./scripts/log-cleanup.sh
```
- **説明**: 古いログファイルを削除
- **ディレクトリ**: `scripts/`

---

## Git Worktree

### Worktree並列開発セットアップ
```bash
./scripts/worktree-parallel-manual.sh setup
```
- **説明**: Git Worktreeの初期設定
- **ディレクトリ**: `scripts/`

### Worktree自動割り当て
```bash
./scripts/worktree-parallel-manual.sh auto-assign
```
- **説明**: エージェントにWorktreeを自動割り当て
- **ディレクトリ**: `scripts/`

### Worktree作成
```bash
./scripts/worktree-parallel-manual.sh create [branch] [agent]
```
- **説明**: 新しいWorktreeを作成
- **引数**:
  - `branch`: ブランチ名
  - `agent`: 担当エージェント
- **ディレクトリ**: `scripts/`

### Worktree状態確認
```bash
./scripts/worktree-parallel-manual.sh status
```
- **説明**: 全Worktreeの状態を表示
- **ディレクトリ**: `scripts/`

---

## 調査・レポート

### 調査報告書作成
```bash
./scripts/create_investigation_report.sh "タイトル" "説明"
```
- **説明**: 新規調査報告書を作成
- **出力**: `investigation_reports/YYYYMMDD_HHMMSS_タイトル調査報告.md`
- **ディレクトリ**: `scripts/`

### サンプル要件作成
```bash
./scripts/create-sample-requirements.sh
```
- **説明**: サンプルの要件定義ファイルを作成
- **ディレクトリ**: `scripts/`

### 構造化ロガー
```bash
python3 scripts/structured_logger.py
```
- **説明**: 構造化されたログ出力
- **ディレクトリ**: `scripts/`

### モデル設定
```bash
./scripts/setup-models.sh         # 詳細設定
./scripts/setup-models-simple.sh  # シンプル設定
```
- **説明**: AIモデルの設定
- **ディレクトリ**: `scripts/`

### 自動レポート
```bash
./scripts/auto-report.sh [cron|summary]
```
- **説明**: 定期レポートの自動生成
- **出力**: `reports/daily-report-YYYYMMDD.md`
- **ディレクトリ**: `scripts/`

---

## メンテナンス

### エラー分析
```bash
./scripts/analyze-errors.sh [--last-hour|--today]
```
- **説明**: ログからエラーパターンを分析
- **ディレクトリ**: `scripts/`

### ストレージ管理
```bash
./scripts/manage-storage.sh
```
- **説明**: ストレージ使用状況の確認と管理
- **ディレクトリ**: `scripts/`

### セキュリティユーティリティ
```bash
./scripts/security-utils.sh
```
- **説明**: セキュリティ関連のユーティリティ
- **ディレクトリ**: `scripts/`

---

## カスタムコマンド（.claude/commands/）

### CCTeam起動（エイリアス）
```bash
ccteam
```
- **実体**: `/Users/sasuketorii/.claude/commands/ccteam`
- **説明**: CCTeamを起動するカスタムコマンド

---

## 新規スクリプト追加時の手順

1. スクリプトを適切なディレクトリに配置
   - 一般的なスクリプト: `scripts/`
   - テスト関連: `tests/`
   - カスタムコマンド: `.claude/commands/`

2. 実行権限を付与
   ```bash
   chmod +x scripts/your-script.sh
   ```

3. このファイル（COMMANDS.md）を更新
   - 適切なセクションに追加
   - 説明、引数、出力を明記

4. scripts/README.mdを更新（必要に応じて）

---

最終更新日: 2025-01-12