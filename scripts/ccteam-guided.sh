#!/bin/bash

# CCTeam Guided Setup - 初心者向けガイド付き起動
# v1.0.0

set -e

# カラー定義
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
YELLOW=$'\033[0;33m'
PURPLE=$'\033[0;35m'
CYAN=$'\033[0;36m'
NC=$'\033[0m'

clear

echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "${CYAN}🎯 CCTeam ガイド付き起動${NC}"
echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "このガイドに従って、CCTeamを起動します。"
echo "各ステップで詳しい説明を表示します。"
echo ""

# Step 1: 環境確認
echo "${BLUE}━━━ Step 1/5: 環境確認 ━━━${NC}"
echo ""
echo "必要なツールがインストールされているか確認します..."
echo ""

# tmux確認
if command -v tmux &> /dev/null; then
    echo "✅ tmux: $(tmux -V)"
else
    echo "❌ tmuxがインストールされていません"
    echo "   macOS: brew install tmux"
    echo "   Ubuntu: sudo apt-get install tmux"
    exit 1
fi

# claude確認
if command -v claude &> /dev/null; then
    echo "✅ claude: インストール済み"
else
    echo "❌ Claude CLIがインストールされていません"
    echo "   インストール方法: https://docs.anthropic.com/claude/docs/claude-cli"
    exit 1
fi

echo ""
read -p "続行するには${GREEN}Enter${NC}キーを押してください..."

# Step 2: tmuxセッション作成
clear
echo "${BLUE}━━━ Step 2/5: tmuxセッション作成 ━━━${NC}"
echo ""
echo "CCTeam用のtmuxセッションを作成します。"
echo "これにより、複数のAIエージェントを同時に管理できます。"
echo ""

if tmux has-session -t ccteam-boss 2>/dev/null || tmux has-session -t ccteam-workers 2>/dev/null; then
    echo "⚠️  既存のセッションが見つかりました"
    read -p "既存のセッションを削除して新規作成しますか？ (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        tmux kill-session -t ccteam-boss 2>/dev/null || true
        tmux kill-session -t ccteam-workers 2>/dev/null || true
    else
        echo "既存のセッションを使用します"
    fi
fi

echo ""
echo "セッションを作成中..."
./scripts/setup-v2.sh > /dev/null 2>&1
echo "✅ tmuxセッション作成完了"

echo ""
read -p "続行するには${GREEN}Enter${NC}キーを押してください..."

# Step 3: Claude起動
clear
echo "${BLUE}━━━ Step 3/5: Claude起動 ━━━${NC}"
echo ""
echo "各エージェントでClaude CLIを起動します。"
echo "起動後、認証画面が表示されます。"
echo ""

echo "⏳ Claudeを起動しています..."
tmux send-keys -t ccteam-boss:main.0 "claude" C-m
sleep 1
tmux send-keys -t ccteam-workers:main.0 "claude" C-m
sleep 1
tmux send-keys -t ccteam-workers:main.1 "claude" C-m
sleep 1
tmux send-keys -t ccteam-workers:main.2 "claude" C-m

echo ""
echo "✅ Claude起動完了"
echo ""
echo "${YELLOW}重要: 次のステップで認証を行います${NC}"
echo ""
read -p "続行するには${GREEN}Enter${NC}キーを押してください..."

# Step 4: 認証ガイド
clear
echo "${BLUE}━━━ Step 4/5: 認証作業 ━━━${NC}"
echo ""
echo "各エージェントで認証を行います。"
echo "${YELLOW}新しいターミナルウィンドウ${NC}で以下を実行してください："
echo ""
echo "${GREEN}─────────────────────────────────────────${NC}"
echo ""
echo "1️⃣ Bossの認証:"
echo "   ${CYAN}tmux attach -t ccteam-boss${NC}"
echo ""
echo "   → Bypass Permissions画面で '${YELLOW}2${NC}' を入力してEnter"
echo "   → 認証後、${YELLOW}Ctrl+b → d${NC} でデタッチ"
echo ""
echo "${GREEN}─────────────────────────────────────────${NC}"
echo ""
echo "2️⃣ Workersの認証:"
echo "   ${CYAN}tmux attach -t ccteam-workers${NC}"
echo ""
echo "   → 各ペインで '${YELLOW}2${NC}' を入力してEnter"
echo "   → ペイン切り替え: ${YELLOW}Ctrl+b → 矢印キー${NC}"
echo "   → 全Worker認証後、${YELLOW}Ctrl+b → d${NC} でデタッチ"
echo ""
echo "${GREEN}─────────────────────────────────────────${NC}"
echo ""
read -p "認証が${YELLOW}完了したら${NC}、${GREEN}Enter${NC}キーを押してください..."

# Step 5: 初期プロンプト
clear
echo "${BLUE}━━━ Step 5/5: 初期プロンプト入力 ━━━${NC}"
echo ""
echo "認証が完了しました！"
echo "次は、Bossに初期指示を与えます。"
echo ""
echo "${GREEN}─────────────────────────────────────────${NC}"
echo ""
echo "Bossセッションに再接続:"
echo "   ${CYAN}tmux attach -t ccteam-boss${NC}"
echo ""
echo "推奨プロンプト例:"
echo ""
echo "1. ${YELLOW}\"requirementsフォルダの要件を読み込み、役割分担して開発を開始してください\"${NC}"
echo ""
echo "2. ${YELLOW}\"全Worker点呼: 各自の役割と準備状況を報告してください\"${NC}"
echo ""
echo "3. ${YELLOW}\"requirements/README.mdを分析して、各Workerにタスクを割り当ててください\"${NC}"
echo ""
echo "${GREEN}─────────────────────────────────────────${NC}"
echo ""
echo "✅ ${GREEN}セットアップ完了！${NC}"
echo ""
echo "📝 便利なコマンド:"
echo "   ${CYAN}tmux ls${NC}              - セッション一覧"
echo "   ${CYAN}tmux attach -t [名前]${NC} - セッションに接続"
echo "   ${CYAN}Ctrl+b → s${NC}           - セッション切り替え"
echo "   ${CYAN}Ctrl+b → d${NC}           - デタッチ"
echo ""
echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"