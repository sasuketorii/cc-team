CCTeam（Claude Code Team）組織的開発指示書 v2.0
Claude Code公式推奨構成準拠版
📋 目次

組織概要
環境構成（公式推奨構造）
役割定義と責任範囲
開発ワークフロー
コミュニケーションプロトコル
品質管理基準
トラブルシューティング
ベストプラクティス


1. 組織概要
1.1 CCTeamミッション
yaml目的: AIエージェントによる高効率・高品質な組織的ソフトウェア開発
価値観:
  - 明確な役割分担による効率化
  - 継続的な品質向上
  - 知識の共有と蓄積
1.2 チーム構成
CCTeam
├── Boss (戦略的意思決定層)
├── PM層 (プロジェクト管理層)
│   ├── Frontend PM
│   ├── Backend PM
│   └── DB/Security PM
└── Worker層 (実装層)
    └── Worker 1-6

2. 環境構成（公式推奨構造）
2.1 ハードウェア・プラン
yamlMachine: MacBook M2 RAM 96GB
Claude Plan: MAX $200/month
Models:
  - Decision Layer: claude-opus-4-20250514
  - Implementation Layer: claude-sonnet-4-20250514
2.2 Claude Code公式ディレクトリ構造
Claude Codeは特定のディレクトリ構造を推奨しており、CLAUDE.mdファイルを階層的に読み込みます GitHubClaudeLog：
bash# プロジェクト構造
project/
├── CLAUDE.md              # プロジェクト全体の指示（Git管理対象）
├── CLAUDE.local.md        # ローカル作業用メモ（.gitignore対象）
├── .claude/               # Claude Code専用ディレクトリ
│   ├── commands/          # カスタムスラッシュコマンド
│   │   ├── fix-issue.md
│   │   ├── run-tests.md
│   │   └── deploy.md
│   ├── shared/            # CCTeam共有ナレッジ（拡張）
│   │   ├── decisions/     # アーキテクチャ決定
│   │   ├── implementations/ # 実装成果物
│   │   ├── reviews/       # レビュー記録
│   │   └── patterns/      # 成功パターン
│   └── logs/              # 実行ログ
├── .claude.json           # MCP設定（プロジェクト）
├── .mcp.json              # MCP設定（Git管理対象）
├── src/                   # ソースコード
│   ├── CLAUDE.md          # src固有の指示
│   ├── components/
│   │   └── CLAUDE.md      # コンポーネント固有の指示
│   └── lib/
├── worktrees/             # Git worktree
│   ├── frontend/
│   ├── backend/
│   └── database/
└── .devcontainer/         # 開発環境設定
2.3 CLAUDE.mdファイルの標準構造
公式推奨のCLAUDE.md構造には、Tech Stack、Project Structure、Commands、Code Style、Repository Etiquetteが含まれます Directory Structure Not Updated After Folder Renaming · Issue #65 · anthropics/claude-code：
markdown# Project: [プロジェクト名]

## Tech Stack
- Framework: Next.js 14
- Language: TypeScript 5.2
- Styling: Tailwind CSS 3.4
- Testing: Jest, React Testing Library

## Project Structure
- `src/app`: Next.js App Router pages
- `src/components`: Reusable React components
- `src/lib`: Core utilities and API clients
- `worktrees/`: Git worktree branches

## Commands
- `npm run dev`: Start development server
- `npm run build`: Build for production
- `npm run test`: Run all unit tests
- `npm run lint`: Run ESLint

## Code Style
- Use ES modules (import/export)
- Prefer arrow functions for components
- Destructure imports when possible
- Follow Airbnb JavaScript Style Guide

## Repository Etiquette
- Branch naming: feature/TICKET-123-description
- Commit format: type(scope): description
- Always create PR for code review
- Merge strategy: squash and merge

## CCTeam Specific Rules
- Boss reviews all architectural decisions
- PM approves implementation before merge
- Workers must include tests with implementation
- Use .claude/shared/ for knowledge sharing

## Do Not
- Do not edit files in production branch directly
- Do not skip code review process
- Do not commit without running tests
2.4 初期セットアップスクリプト（改訂版）
bash#!/bin/bash
# ccteam-setup.sh - Claude Code公式構造準拠

# 1. 基本ディレクトリ作成
mkdir -p .claude/{commands,shared/{decisions,implementations,reviews,patterns},logs}

# 2. CLAUDE.mdファイル生成
claude /init  # 公式コマンドでボイラープレート生成

# 3. カスタムコマンド作成
cat > .claude/commands/ccteam-status.md << 'EOF'
Show CCTeam development status:
1. List active worktrees and their branches
2. Show pending tasks in each team
3. Display recent decisions and reviews
4. Report any blocking issues
EOF

cat > .claude/commands/ccteam-sync.md << 'EOF'
Synchronize CCTeam knowledge:
1. Update shared patterns from successful implementations
2. Consolidate review feedback
3. Document new decisions
4. Clean up completed task files
EOF

# 4. MCP設定ファイル作成
cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "github": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "linear": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-linear"],
      "env": {
        "LINEAR_API_KEY": "${LINEAR_API_KEY}"
      }
    }
  }
}
EOF

# 5. Git Worktree設定
git worktree add -b feature/frontend worktrees/frontend
git worktree add -b feature/backend worktrees/backend
git worktree add -b feature/database worktrees/database

# 6. 各worktreeにCLAUDE.md配置
for dir in frontend backend database; do
  cat > worktrees/$dir/CLAUDE.md << EOF
# $dir Development Branch

Follow the main project CLAUDE.md and these specific rules:
- This is the $dir feature branch
- Coordinate with $dir PM for all changes
- Run tests before committing
EOF
done

# 7. tmuxセッション初期化（改善版）
cat > start-ccteam.sh << 'EOF'
#!/bin/bash
# CCTeam tmuxセッション起動スクリプト

# Boss session
tmux new-session -d -s boss -c $(pwd) 'claude'

# Frontend team
tmux new-session -d -s frontend-pm -c $(pwd)/worktrees/frontend 'claude'
tmux new-window -t frontend-pm:1 -n worker1 -c $(pwd)/worktrees/frontend 'claude'
tmux new-window -t frontend-pm:2 -n worker2 -c $(pwd)/worktrees/frontend 'claude'

# Backend team
tmux new-session -d -s backend-pm -c $(pwd)/worktrees/backend 'claude'
tmux new-window -t backend-pm:1 -n worker3 -c $(pwd)/worktrees/backend 'claude'
tmux new-window -t backend-pm:2 -n worker4 -c $(pwd)/worktrees/backend 'claude'

# Database team
tmux new-session -d -s database-pm -c $(pwd)/worktrees/database 'claude'
tmux new-window -t database-pm:1 -n worker5 -c $(pwd)/worktrees/database 'claude'
tmux new-window -t database-pm:2 -n worker6 -c $(pwd)/worktrees/database 'claude'

echo "CCTeam sessions started. Use 'tmux attach -t [session-name]' to connect."
EOF

chmod +x start-ccteam.sh
2.5 ホームディレクトリ設定
個人用コマンドは~/.claude/commands/に配置し、すべてのセッションで利用可能になります What is Working Directory in Claude Code | ClaudeLog：
bash# ~/.claude/commands/daily-standup.md
cat > ~/.claude/commands/daily-standup.md << 'EOF'
Generate daily standup report:
1. What I completed yesterday
2. What I'm working on today
3. Any blockers or concerns
4. Time estimate for current tasks
EOF

# ~/.claude/CLAUDE.md - 個人用グローバル設定
cat > ~/.claude/CLAUDE.md << 'EOF'
# Global Claude Code Settings

## Personal Preferences
- Always use verbose commit messages
- Include ticket numbers in branch names
- Prefer functional programming patterns
- Write tests before implementation

## Common Tools
- Editor: VS Code
- Terminal: iTerm2
- Shell: zsh with oh-my-zsh
EOF

3. 役割定義と責任範囲
3.1 Boss（最高意思決定者）
yamlモデル: claude-opus-4-20250514
作業ディレクトリ: プロジェクトルート

責任範囲:
  - プロジェクト全体の方向性決定
  - アーキテクチャの最終承認
  - リソース配分の決定
  - 品質基準の設定
  
専用コマンド:
  - /ccteam-status: 全体進捗確認
  - /architecture-review: アーキテクチャレビュー
  - /resource-allocation: リソース配分調整
3.2 PM層（プロジェクトマネージャー）
yamlモデル: claude-opus-4-20250514
作業ディレクトリ: 各worktreeルート

共通責任:
  - 詳細設計の策定
  - タスク分解と割り当て
  - 品質レビュー
  - 進捗管理

Frontend PM:
  作業場所: worktrees/frontend
  専用コマンド:
    - /component-review: コンポーネント設計レビュー
    - /ui-test: UI自動テスト実行

Backend PM:
  作業場所: worktrees/backend
  専用コマンド:
    - /api-spec: API仕様生成
    - /integration-test: 統合テスト実行

DB/Security PM:
  作業場所: worktrees/database
  専用コマンド:
    - /schema-review: スキーマレビュー
    - /security-audit: セキュリティ監査
3.3 Worker層（実装担当）
yamlモデル: claude-sonnet-4-20250514
作業ディレクトリ: 各worktree内の担当領域

共通責任:
  - 割り当てられたタスクの実装
  - ユニットテストの作成
  - コードドキュメントの作成
  - 実装上の課題のPMへの報告

作業ルール:
  - 必ず担当worktree内で作業
  - コミット前にテスト実行
  - CLAUDE.local.mdに作業メモを記録

4. 開発ワークフロー
4.1 Plan/Act パターン（公式推奨）
Claude Codeは"think"キーワードを使用した計画/実行パターンで最良の結果を出します What is Working Directory in Claude Code | ClaudeLog：
bash# 1. 計画フェーズ（Boss/PM）
claude "Think through the architecture for user authentication system. 
Create a detailed plan considering security, scalability, and maintainability."

# 2. 計画をファイルに保存
claude "Write the authentication architecture plan to 
.claude/shared/decisions/DECISION-004-auth-architecture.md"

# 3. 実装フェーズ（Worker）
claude "Based on .claude/shared/decisions/DECISION-004-auth-architecture.md, 
implement the JWT authentication module with tests"

# 4. レビューフェーズ（PM）
claude "Review the implementation in src/auth/, 
check against the architecture decision, 
and write feedback to .claude/shared/reviews/REVIEW-004-auth.md"
4.2 TDDワークフロー（公式推奨）
bash# Worker側での実装
# 1. テスト作成
claude "Write failing tests for user authentication with these scenarios:
- Valid credentials return JWT token
- Invalid credentials return 401
- Token expiry is handled correctly"

# 2. テスト実行（失敗確認）
claude "Run the authentication tests and confirm they fail"

# 3. 実装
claude "Implement the authentication module to make all tests pass"

# 4. リファクタリング
claude "Refactor the authentication code for clarity and efficiency 
while keeping all tests passing"
4.3 マルチエージェント協調
複数のClaude インスタンスが共有スクラッチパッドを通じて通信できます：
bash# 共有スクラッチパッド設定
mkdir -p .claude/shared/scratchpad

# Worker1が問題を記録
echo "Need help with React Hook optimization" > .claude/shared/scratchpad/worker1-help.md

# Worker2が支援
claude "Read .claude/shared/scratchpad/worker1-help.md and provide optimization suggestions"

5. コミュニケーションプロトコル
5.1 非同期コミュニケーション戦略
bash# タスクキューシステム
mkdir -p .claude/shared/queue/{pending,in-progress,completed,blocked}

# PMがタスクを作成
cat > .claude/shared/queue/pending/TASK-005.md << 'EOF'
Task: Implement user profile API
Priority: High
Assigned: Worker3
Dependencies: TASK-004 (auth)
Deadline: 2 days
EOF

# Workerがタスク開始
mv .claude/shared/queue/pending/TASK-005.md \
   .claude/shared/queue/in-progress/TASK-005.md

# 完了時
mv .claude/shared/queue/in-progress/TASK-005.md \
   .claude/shared/queue/completed/TASK-005.md
5.2 Git Worktree を活用した並列開発
Git worktreeを使用することで、同じリポジトリの複数ブランチを別々のディレクトリで同時に作業できます：
bash# 新機能の並列開発
git worktree add worktrees/feature-payment feature/payment-system
git worktree add worktrees/feature-notification feature/notification-system

# 各チームが独立して作業
cd worktrees/feature-payment
claude "Implement payment processing module"

cd worktrees/feature-notification
claude "Implement real-time notification system"

6. 品質管理基準
6.1 コードレビュー自動化
bash# レビュー用カスタムコマンド
cat > .claude/commands/code-review.md << 'EOF'
Perform comprehensive code review:
1. Check SOLID principles compliance
2. Verify test coverage (minimum 80%)
3. Analyze security vulnerabilities
4. Check performance implications
5. Validate documentation completeness
6. Write findings to .claude/shared/reviews/

Focus on: $ARGUMENTS
EOF
6.2 継続的品質監視
bash# 品質メトリクス追跡
cat > .claude/commands/quality-metrics.md << 'EOF'
Generate quality metrics report:
1. Calculate test coverage across all modules
2. Count TODO/FIXME comments
3. Measure code complexity (cyclomatic)
4. Check dependency vulnerabilities
5. Generate report in .claude/shared/metrics/
EOF

7. トラブルシューティング
7.1 コンテキスト管理
長いセッション中は/clearコマンドを頻繁に使用してコンテキストをリセットします：
bash# コンテキストが満杯になる前の対処
# 1. 現在の作業を要約
claude "Summarize current work progress to .claude/local/session-summary.md"

# 2. コンテキストクリア
claude /clear

# 3. 要約を読み込んで継続
claude "Read .claude/local/session-summary.md and continue the implementation"
7.2 ヘッドレスモードでの自動化
CI/CDやスクリプトでの使用にはヘッドレスモード（-pフラグ）を使用します Claude integrations | Workflow automation with n8n：
bash# 自動レビュースクリプト
#!/bin/bash
for file in $(git diff --name-only main); do
  claude -p "Review the changes in $file for security issues" \
    --output-format stream-json | \
    jq -r '.content' >> security-review.md
done

8. ベストプラクティス
8.1 効率的なMCP活用
json// プロジェクト用 .mcp.json
{
  "mcpServers": {
    "postgres": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      }
    },
    "github": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "sentry": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sentry"],
      "env": {
        "SENTRY_AUTH_TOKEN": "${SENTRY_AUTH_TOKEN}"
      }
    }
  }
}
8.2 知識の蓄積と再利用
bash# 成功パターンの自動収集
cat > .claude/commands/capture-pattern.md << 'EOF'
Capture successful implementation pattern:
1. Analyze the recent implementation
2. Extract reusable patterns
3. Document in .claude/shared/patterns/
4. Create template for future use

Implementation to analyze: $ARGUMENTS
EOF

# 使用例
claude /capture-pattern "authentication module"
8.3 チームパフォーマンス追跡
bash# メトリクス収集スクリプト
cat > collect-metrics.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y-%m-%d)
METRICS_FILE=".claude/shared/metrics/daily-$DATE.json"

echo "{" > $METRICS_FILE
echo "  \"date\": \"$DATE\"," >> $METRICS_FILE
echo "  \"tasks_completed\": $(ls .claude/shared/queue/completed/*.md 2>/dev/null | wc -l)," >> $METRICS_FILE
echo "  \"opus_calls\": $(grep -c opus .claude/logs/*.log 2>/dev/null || echo 0)," >> $METRICS_FILE
echo "  \"sonnet_calls\": $(grep -c sonnet .claude/logs/*.log 2>/dev/null || echo 0)," >> $METRICS_FILE
echo "  \"active_worktrees\": $(git worktree list | wc -l)" >> $METRICS_FILE
echo "}" >> $METRICS_FILE

echo "Metrics collected in $METRICS_FILE"
EOF

chmod +x collect-metrics.sh

付録：クイックリファレンス
必須コマンド一覧
bash# 初期設定
claude /init          # CLAUDE.md生成
claude /memory        # 読み込まれた設定確認

# セッション管理
claude /clear         # コンテキストクリア
claude /compact       # コンテキスト圧縮

# MCP管理
claude /mcp           # MCP接続状態確認
claude mcp add        # 新規MCP追加

# カスタムコマンド
claude /[command]     # .claude/commands/内のコマンド実行
tmuxセッション管理
bash# セッション一覧
tmux ls | grep -E "(boss|pm|worker)"

# セッションアタッチ
tmux attach -t frontend-pm

# 全セッション終了
tmux kill-server
この指示書はClaude Code公式のベストプラクティスとディレクトリ構造 GitHubClaudeLogに準拠しています。定期的に公式ドキュメントを確認し、新機能や推奨事項の更新を反映してください。