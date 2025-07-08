#!/bin/bash
# CCTeam Launch v2 - Claude Code起動スクリプト
# 2つのtmuxセッション（Boss+Gemini、Workers）でClaude Codeを起動

set -e

# カラー定義
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
YELLOW=$'\033[0;33m'
PURPLE=$'\033[0;35m'
NC=$'\033[0m'

echo "🚀 CCTeam Claude Code起動を開始します..."

# tmuxセッションの存在確認
if ! tmux has-session -t ccteam-boss 2>/dev/null || ! tmux has-session -t ccteam-workers 2>/dev/null; then
    echo "❌ tmuxセッションが見つかりません。先にセットアップを実行してください："
    echo "  ${GREEN}./scripts/setup-v2.sh${NC}"
    exit 1
fi

# Claude Codeコマンドの確認
if ! command -v claude &> /dev/null; then
    echo "❌ Claude Codeがインストールされていません"
    echo "  インストール: ${GREEN}https://claude.ai/code${NC}"
    exit 1
fi

# プロジェクトディレクトリ
PROJECT_DIR=$(pwd)

echo "👋 CCTeamメンバーを起こしています..."
echo ""
echo "🎯 あなたがCCTeamのBOSSを起こしました..."

# BOSS (ccteam-boss:main.0)
tmux send-keys -t ccteam-boss:main.0 C-c  # 既存のプロセスを停止
sleep 0.5
tmux send-keys -t ccteam-boss:main.0 "cd $PROJECT_DIR" C-m
tmux send-keys -t ccteam-boss:main.0 "claude --model opus --dangerously-skip-permissions" C-m
sleep 2
echo "  💼 BOSSが目覚めました！"

# GEMINI (ccteam-boss:main.1)
tmux send-keys -t ccteam-boss:main.1 C-c
sleep 0.5
tmux send-keys -t ccteam-boss:main.1 "cd $PROJECT_DIR" C-m
tmux send-keys -t ccteam-boss:main.1 "gemini --model gemini-2.5-pro" C-m
sleep 2
echo "  🤖 BOSSがGEMINIを起こしました！"

echo ""
echo "👷 BOSSがWorkersを起こしています..."

# Worker1 (ccteam-workers:main.0)
tmux send-keys -t ccteam-workers:main.0 C-c
sleep 0.5
tmux send-keys -t ccteam-workers:main.0 "cd $PROJECT_DIR" C-m
tmux send-keys -t ccteam-workers:main.0 "claude --model opus --dangerously-skip-permissions" C-m
sleep 2
echo "  🎨 Worker1が起きました！"

# Worker2 (ccteam-workers:main.1)
tmux send-keys -t ccteam-workers:main.1 C-c
sleep 0.5
tmux send-keys -t ccteam-workers:main.1 "cd $PROJECT_DIR" C-m
tmux send-keys -t ccteam-workers:main.1 "claude --model opus --dangerously-skip-permissions" C-m
sleep 2
echo "  ⚙️ Worker2が起きました！"

# Worker3 (ccteam-workers:main.2)
tmux send-keys -t ccteam-workers:main.2 C-c
sleep 0.5
tmux send-keys -t ccteam-workers:main.2 "cd $PROJECT_DIR" C-m
tmux send-keys -t ccteam-workers:main.2 "claude --model opus --dangerously-skip-permissions" C-m
sleep 2
echo "  🔧 Worker3が起きました！"

# Worker4 (ccteam-workers:main.3)
tmux send-keys -t ccteam-workers:main.3 C-c
sleep 0.5
tmux send-keys -t ccteam-workers:main.3 "cd $PROJECT_DIR" C-m
tmux send-keys -t ccteam-workers:main.3 "claude --model opus --dangerously-skip-permissions" C-m
sleep 2
echo "  🧪 Worker4が起きました！"

# 起動ログ記録
echo "[$(date '+%Y-%m-%d %H:%M:%S')] All Claude Code instances launched" >> logs/system.log

echo ""
echo "🎊 CCTeam全員が目覚めました！"
echo ""
echo "📺 tmuxセッションに接続："
echo "  Boss+Gemini: ${GREEN}tmux attach -t ccteam-boss${NC}"
echo "  Workers:     ${GREEN}tmux attach -t ccteam-workers${NC}"
echo ""
echo "💡 操作方法："
echo "  ペイン切り替え: Ctrl+b → 矢印キー"
echo "  セッション切り替え: Ctrl+b → s"
echo "  デタッチ: Ctrl+b → d"
echo ""
echo "📝 各エージェントの役割："
echo "  ${PURPLE}BOSS${NC}    - 全体管理、タスク分配"
echo "  ${GREEN}GEMINI${NC}  - AI補佐、調査支援"
echo "  ${BLUE}Worker1${NC} - フロントエンド開発"
echo "  ${GREEN}Worker2${NC} - バックエンド開発"
echo "  ${RED}Worker3${NC} - インフラ/DevOps"
echo "  ${YELLOW}Worker4${NC} - テスト/品質保証"
