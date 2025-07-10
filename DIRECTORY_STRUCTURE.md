# 📁 CCTeam ディレクトリ構造ガイド

最終更新: 2025年1月10日 (v0.1.1)

## 🏗️ ディレクトリ構成

```
CCTeam/
├── 📄 CLAUDE.md              # Claudeプロジェクト設定
├── 📄 README.md              # プロジェクト概要
├── 📄 package.json           # プロジェクト設定
│
├── 📂 .claude/               # Claude Code Actions設定
│   └── claude_desktop_config.json
│
├── 📂 docs/                  # ユーザードキュメント
│   └── 使い方.md
│
├── 📂 instructions/          # AIエージェント指示書
│   ├── agent_instructions.md # 共通指示
│   ├── boss.md              # BOSSエージェント指示
│   ├── worker1.md           # Worker1指示
│   ├── worker2.md           # Worker2指示
│   └── worker3.md           # Worker3指示
│
├── 📂 investigation_reports/ # 調査報告書（日時付き）
│   ├── README.md
│   └── YYYYMMDD_HHMMSS_タイトル調査報告.md
│
├── 📂 logs/                  # ログファイル
│   ├── *.log                # プレーンテキストログ
│   ├── *_structured.jsonl   # 構造化ログ
│   └── errors_all.jsonl    # エラー集約
│
├── 📂 memory/               # AIメモリシステム
│   └── ccteam_memory.db    # SQLiteデータベース
│
├── 📂 plans/                # 計画書
│   ├── README.md
│   ├── CCTeam包括的修正プランv0.0.8.md # 実装済み（v0.1.0）
│   └── archive/            # 実施済み計画
│
├── 📂 reports/              # 自動生成レポート
│   ├── health_check_*.md   # ヘルスチェックレポート
│   └── v*_improvements_report.md
│
├── 📂 requirements/         # 要件定義
│   ├── README.md
│   ├── API仕様.md
│   ├── 機能要件.md
│   └── 技術スタック.md
│
├── 📂 scripts/              # 実行スクリプト
│   ├── README.md           # スクリプト詳細ガイド
│   ├── setup.sh           # 環境構築
│   ├── launch-ccteam-v3.sh  # CCTeam起動（手動認証版）
│   └── ... (多数のユーティリティ)
│
├── 📂 shared-docs/          # 共有ドキュメント
│   ├── エラーループ対策.md
│   └── 開発ガイドライン.md
│
├── 📂 tests/                # テストスクリプト
│   ├── test_scripts.md     # テストドキュメント
│   ├── history/           # テスト実行履歴
│   └── *.sh              # 各種テストスクリプト
│
├── 📂 worktrees/           # Git並列開発用
│
├── 📂 archive/             # アーカイブ（未使用）
└── 📂 tmp/                 # 一時ファイル
```

## 📝 各ディレクトリの用途

### コア設定
- **CLAUDE.md**: Claudeが理解するプロジェクト全体の設定
- **.claude/**: Claude Code Actionsのカスタムアクション定義

### ドキュメント
- **docs/**: エンドユーザー向けドキュメント
- **shared-docs/**: 開発者向け共有ドキュメント
- **investigation_reports/**: 調査・分析レポート（日時付き）
- **plans/**: 実装計画・最適化計画

### 開発リソース
- **instructions/**: AIエージェントへの指示書
- **requirements/**: プロジェクト要件定義
- **scripts/**: 自動化スクリプト群

### 実行時生成
- **logs/**: 実行ログ（構造化/非構造化）
- **memory/**: AI記憶システムのデータ
- **reports/**: 自動生成される各種レポート
- **worktrees/**: Git worktreeによる並列開発環境

### テスト・品質管理
- **tests/**: テストスクリプトと実行履歴
- **tests/history/**: テスト結果のアーカイブ

## 🔄 ファイル管理ルール

### 命名規則
1. **調査報告書**: `YYYYMMDD_HHMMSS_タイトル調査報告.md`
2. **ヘルスチェック**: `health_check_YYYYMMDD_HHMMSS.md`
3. **バージョンレポート**: `vX.X.X_improvements_report.md`

### アーカイブポリシー
- 3ヶ月経過: `archive/`へ移動
- 実装完了: 計画書は`plans/archive/`へ
- テスト結果: `tests/history/`に自動保存

### クリーンアップ
```bash
# テストファイルのクリーンアップ
./tests/cleanup_test_files.sh

# ログローテーション（自動実行）
./scripts/log_rotation.sh
```

## 🚀 クイックアクセス

### 新規作成
```bash
# 調査報告書
./scripts/create_investigation_report.sh "タイトル"

# 要件定義（サンプル）
./scripts/create-sample-requirements.sh
```

### 状況確認
```bash
# プロジェクト状況
./scripts/project-status.sh

# ヘルスチェック
./tests/quick_health_check.sh
```

### テスト実行
```bash
# 統合テスト
./tests/integration_test.sh

# テスト結果アーカイブ
./tests/test_log_archiver.sh
```