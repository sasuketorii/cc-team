# Changelog

All notable changes to CCTeam will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-01-13

### Added
- Complete hierarchical team structure with proper bypass mode
- Boss → PM → Worker communication hierarchy (Boss can only talk to PMs)
- Proper tmux pane titles and consistent layout
- Fixed tmux pane creation timing issues
- Comprehensive test system for all versions (v3 and v4)
- DevContainer updates for CCTeam
- Git worktree automatic setup
- Roll call automation with Enter key support

### Changed
- Boss instructions now enforce hierarchical communication
- PM instructions updated with worker initialization procedures
- All launch scripts use proper bypass mode (`--permission-mode bypassPermissions`)
- Model usage simplified to aliases: `opus` and `sonnet`
- README and CLAUDE.md updated to v0.2.0
- No automatic initial prompts - clean startup

### Fixed
- Claude startup issue where only diagonal panes were working
- Enter key issue completely resolved
- Model naming to use aliases instead of dated versions
- Removed automatic initial messages that created custom models
- tmux pane timing by creating all panes before sending commands

### Enhanced
- Complete v4 structure implementation
- All existing features integrated (memory, error loop detection, etc.)
- Cleaner session names: ccteam-boss, ccteam-1, ccteam-2, ccteam-3

## [0.1.17] - 2025-01-13

### Fixed
- モデル指定を`claude --model`コマンドに統一
  - Boss/PM: `claude --model opus`
  - Worker: `claude --model sonnet`
- 初期プロンプト送信を完全に削除
- tmuxペイン作成タイミングの問題を修正

### Added
- Bypassモードをデフォルトに設定
  - `ccteam` または `ccteam 1`: Bypassモード（デフォルト）
  - `ccteam 2`: 手動認証モード
- カスタムモデル削除ガイド追加

### Changed
- `/model`コマンドを使用しない方式に変更
- 認証プロセスをBypassモード対応に更新

## [0.1.16] - 2025-01-13

### Added
- CCTeam v4 - シンプルな階層構造版
- `launch-ccteam-v4.sh` - v4起動スクリプト
- `agent-send-v4.sh` - v4通信スクリプト  
- `auto-auth-claude-v4.sh` - v4自動認証
- `ccteam-v4` - グローバルコマンド
- 新ディレクトリ構造: team1-frontend, team2-backend, team3-devops
- PM指示書（PM-1.md, PM-2.md, PM-3.md）各チーム用
- `docs/ccteam-v4-structure.md` - v4構造ドキュメント
- `tests/test_v4_structure.sh` - v4構造テストスクリプト

### Changed
- 1 Boss + 3チーム（各4人）のシンプルな構造に変更
- tmuxセッション: ccteam-boss + ccteam-team[1-3]
- エージェント名を直感的に変更（boss, pm1-3, worker1-1〜3-3）
- ccsendコマンドがv4対応を優先するように更新

### Enhanced
- より洗練されたシンプルな階層構造
- 従来の4人チーム構造を3つ並列運用
- 既存の高度な機能（メモリ、エラーループ）を完全統合

## [0.1.15] - 2025-01-13

### Added
- 階層型チーム構造（Boss + 3 PM + 9 Workers）
- `launch-ccteam-hierarchy.sh` - 階層型構造起動スクリプト
- `agent-send-hierarchy.sh` - 階層型構造用通信スクリプト
- PM指示書（PM-1.md, PM-2.md, PM-3.md）
- Worker指示書テンプレート
- SOWディレクトリとテンプレート
- work-reportsディレクトリとテンプレート

### Changed
- Boss指示書を階層型構造に対応
- 全指示書にメモリシステム、エラーループ検出の活用を追加
- インストールスクリプトに階層型コマンドを追加
- requirementsディレクトリを実装計画中心に再編成

### Enhanced
- Boss指示書に高度な機能（メモリ、エラーループ、品質ゲート）を統合
- PM指示書にWorktree、構造化ログ、自動レポートを統合

## [0.1.14] - 2025-01-12

### Added
- Test infrastructure with Jest configuration
- Basic unit and integration tests
- `auto-auth-claude.sh` - Automatic authentication for Claude agents
- Comprehensive implementation plan in `plans/CCTeam-v0.1.14-Implementation-Plan.md`
- CHANGELOG.md for tracking version history

### Changed
- Improved `agent-send.sh` with authentication state checking
- Enhanced `quality-gate.sh` to handle missing test infrastructure gracefully
- Updated `launch-ccteam-v3.sh` with authentication guidance

### Fixed
- Enter key issue in tmux send-keys (C-m works correctly)
- `enhanced_agent_send.sh` duplication (now symlinked to `agent-send.sh`)
- Authentication workflow for Bypassing Permissions screen

### Removed
- Gemini references from `setup-v2.sh` and documentation
- Duplicate code in `enhanced_agent_send.sh`

## [0.1.13] - 2025-01-12

### Added
- `auto-rollcall.sh` - Automatic agent roll call system
- `install.sh` - Global command installer
- Relative path support for better portability

### Changed
- Improved agent communication system
- Updated documentation paths to use relative references

### Fixed
- Agent initialization issues
- Path dependency problems

## [0.1.12] - 2025-01-11

### Added
- Worktree auto-management system
- Enhanced logging with structured logger
- Memory system integration

### Changed
- Project structure optimization
- Improved error handling

## [0.1.11] - 2025-01-10

### Fixed
- GitHub Actions Exit Code 128 error

## [0.1.10] - 2025-01-09

### Added
- Basic CCTeam functionality
- Boss-Worker architecture
- TMux session management

---

For detailed commit history, see the [GitHub repository](https://github.com/sasuketorii/cc-team)