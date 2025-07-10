#!/bin/bash

# CCTeam Launch Script v3.0.0
# 完全手動認証・ユーザー主導型

set -e

# カラー定義
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
YELLOW=$'\033[0;33m'
PURPLE=$'\033[0;35m'
NC=$'\033[0m'

echo "🚀 CCTeam 起動準備 (v3.0.0)"
echo "=================="

# セットアップが完了しているか確認
if ! tmux has-session -t ccteam-workers 2>/dev/null || ! tmux has-session -t ccteam-boss 2>/dev/null; then
    echo "📺 tmuxセッションを作成しています..."
    ./scripts/setup-v2.sh
    echo ""
fi

# 要件定義の存在確認
if [ ! -d "requirements" ] || [ -z "$(ls -A requirements 2>/dev/null)" ]; then
    echo "⚠️  requirements/ フォルダに要件定義ファイルが見つかりません"
    echo "プロジェクトの要件定義を配置してから再実行してください"
    echo ""
    echo "💡 サンプル要件定義を作成するには:"
    echo "   ./scripts/create-sample-requirements.sh"
    exit 1
fi

# ログディレクトリの確認
mkdir -p logs

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 認証手順"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣ Bossセッションに接続:"
echo "   ${GREEN}tmux attach -t ccteam-boss${NC}"
echo ""
echo "2️⃣ Bypass Permissions画面が表示されたら:"
echo "   - '2' (Yes, I accept) を入力してEnter"
echo "   - Ctrl+b → d でデタッチ"
echo ""
echo "3️⃣ Workerセッションに接続:"
echo "   ${GREEN}tmux attach -t ccteam-workers${NC}"
echo "   - 各Workerペインで '2' を入力してEnter"
echo "   - Ctrl+b → 矢印キー でペイン切り替え"
echo "   - Ctrl+b → d でデタッチ"
echo ""
echo "4️⃣ 認証完了後、Bossペインで初期指示を入力:"
echo "   例: ${YELLOW}'requirementsを読み込んで開発を開始してください'${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 確認プロンプト
echo ""
read -p "準備はよろしいですか？ (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "キャンセルしました"
    exit 0
fi

# タイムスタンプ
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo ""
echo "⏳ Claudeを起動しています..."
echo ""

# Boss起動（プロンプト送信なし）
echo "  💼 Boss起動中..."
tmux send-keys -t ccteam-boss:main.0 "claude --dangerously-skip-permissions" C-m
sleep 2

# Workers起動（プロンプト送信なし）
echo "  🎨 Worker1起動中..."
tmux send-keys -t ccteam-workers:main.0 "claude --dangerously-skip-permissions" C-m
sleep 2

echo "  ⚙️  Worker2起動中..."
tmux send-keys -t ccteam-workers:main.1 "claude --dangerously-skip-permissions" C-m
sleep 2

echo "  🔧 Worker3起動中..."
tmux send-keys -t ccteam-workers:main.2 "claude --dangerously-skip-permissions" C-m
sleep 2

# Geminiは一時的に無効化
echo "  🤖 GEMINI（相談役）は一時的に無効化中..."

echo ""
echo "✅ 起動完了！"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "👉 ${YELLOW}今すぐ実行:${NC}"
echo ""
echo "   ${GREEN}tmux attach -t ccteam-boss${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 推奨する初期プロンプト:"
echo ""
echo "1. 開発開始:"
echo "   ${YELLOW}\"requirementsフォルダの要件を読み込み、役割分担して開発を開始してください\"${NC}"
echo ""
echo "2. 点呼確認:"
echo "   ${YELLOW}\"全Worker点呼: 各自の役割と準備状況を報告してください\"${NC}"
echo ""
echo "3. タスク分配:"
echo "   ${YELLOW}\"requirements/README.mdを分析して、各Workerにタスクを割り当ててください\"${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 起動ログ
echo "[$TIMESTAMP] CCTeam launched successfully (v3.0.0 - Manual Auth)" >> logs/system.log