#!/bin/bash

# CCTeam Launch Script
# 全エージェントを起動し、初期指示を送信します

set -e

# カラー定義
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
YELLOW=$'\033[0;33m'
PURPLE=$'\033[0;35m'
NC=$'\033[0m'

echo "🚀 CCTeam 起動準備"
echo "=================="

# 安全確認プロンプト
echo ""
echo "⚠️  注意事項:"
echo "  - 全エージェントは待機モードで起動します"
echo "  - 自動的に作業を開始することはありません"
echo "  - 明示的な指示を送信するまで待機します"
echo ""

# 起動確認
read -p "CCTeamを起動しますか？ (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "キャンセルしました"
    exit 0
fi

echo ""
echo "🚀 CCTeam を起動します..."

# セットアップが完了しているか確認
if ! tmux has-session -t ccteam 2>/dev/null || ! tmux has-session -t ccteam-boss 2>/dev/null; then
    echo "⚠️  tmuxセッションが見つかりません"
    echo "まず ./scripts/setup.sh を実行してください"
    exit 1
fi

# 要件定義の存在確認
if [ ! -d "requirements" ] || [ -z "$(ls -A requirements 2>/dev/null)" ]; then
    echo "⚠️  requirements/ フォルダに要件定義ファイルが見つかりません"
    echo "プロジェクトの要件定義を配置してから再実行してください"
    
    # サンプルの作成を提案
    read -p "サンプル要件定義を作成しますか？ (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./scripts/create-sample-requirements.sh
        echo "✅ サンプル要件定義を作成しました"
    else
        exit 1
    fi
fi

# ログディレクトリの確認
mkdir -p logs

# タイムスタンプ
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "👋 CCTeamメンバーを起こしています..."
echo ""
echo "🎯 あなたがCCTeamのBOSSを起こしました..."

# BOSS (ペイン0) - 両方のセッションで起動
tmux send-keys -t ccteam:main.0 "claude --dangerously-skip-permissions" C-m
tmux send-keys -t ccteam-boss:main.0 "claude --dangerously-skip-permissions" C-m
sleep 2
echo "  💼 BOSSが目覚めました！"

echo ""
echo "👷 BOSSがWorkersを起こしています..."

# Worker1 (ペイン1)
tmux send-keys -t ccteam:main.1 "claude --dangerously-skip-permissions" C-m
sleep 2
echo "  🎨 Worker1が起きました！"

# Worker2 (ペイン2)
tmux send-keys -t ccteam:main.2 "claude --dangerously-skip-permissions" C-m
sleep 2
echo "  ⚙️  Worker2が起きました！"

# Worker3 (ペイン3)
tmux send-keys -t ccteam:main.3 "claude --dangerously-skip-permissions" C-m
sleep 2
echo "  🔧 Worker3が起きました！"

# GEMINI (ccteam-boss:main.1)
tmux send-keys -t ccteam-boss:main.1 "gemini" C-m
sleep 2
echo "  🤖 GEMINIが起きました！"

echo ""
echo "🎊 CCTeam全員が目覚めました！"
echo ""

# 待機モードの指示を送信
echo "⏸️  待機モードの指示を送信しています..."

# BOSSへの初期指示（最小限の待機モード指示）
BOSS_INSTRUCTION="⏸️ 待機モード: ユーザーからの明確な指示を待ってください。自動的に作業を開始しないでください。"

# Worker1への初期指示（最小限）
WORKER1_INSTRUCTION="⏸️ Worker1 (フロントエンド): 待機モード。BOSSからの指示を待ってください。"

# Worker2への初期指示（最小限）
WORKER2_INSTRUCTION="⏸️ Worker2 (バックエンド): 待機モード。BOSSからの指示を待ってください。"

# Worker3への初期指示（最小限）
WORKER3_INSTRUCTION="⏸️ Worker3 (インフラ/テスト): 待機モード。BOSSからの指示を待ってください。"

# 各エージェントに指示を送信
./scripts/agent-send.sh boss "$BOSS_INSTRUCTION"
sleep 3
./scripts/agent-send.sh worker1 "$WORKER1_INSTRUCTION"
sleep 2
./scripts/agent-send.sh worker2 "$WORKER2_INSTRUCTION"
sleep 2
./scripts/agent-send.sh worker3 "$WORKER3_INSTRUCTION"

# 起動ログ
echo "[$TIMESTAMP] CCTeam launched successfully" >> logs/system.log

echo ""
echo "✅ ユーザーからの指示があるまで待機命令を出しました！"
echo ""
echo "✅ CCTeamが待機モードで起動しました！"
echo ""
echo "⏸️  ${YELLOW}全エージェントは待機状態です${NC}"
echo ""
echo "📝 各エージェントの役割："
echo "  ${RED}BOSS${NC}    - 全体管理、タスク分配、進捗追跡"
echo "  ${PURPLE}GEMINI${NC}  - AI補佐、高速調査、ドキュメント検索"
echo "  ${BLUE}Worker1${NC} - フロントエンド開発（UI/UX）"
echo "  ${GREEN}Worker2${NC} - バックエンド開発（API/DB）"
echo "  ${YELLOW}Worker3${NC} - インフラ・テスト（Docker/CI/CD）"
echo ""
echo "📺 エージェントに接続するには:"
echo ""
echo "  【tmux直接接続（現在のタブで開く）】"
echo "   ${GREEN}tmux attach -t ccteam${NC}      # 全員表示（BOSS + Worker×3）"
echo "   ${GREEN}tmux attach -t ccteam-boss${NC}  # BOSS + GEMINI 2分割表示"
echo ""
echo "  【新規タブで個別に開く】"
echo "   ${GREEN}./scripts/open-boss.sh${NC}     # BOSS用の新規タブ"
echo "   ${GREEN}./scripts/open-worker1.sh${NC}  # Worker1用の新規タブ"
echo "   ${GREEN}./scripts/open-worker2.sh${NC}  # Worker2用の新規タブ"
echo "   ${GREEN}./scripts/open-worker3.sh${NC}  # Worker3用の新規タブ"
echo "   ${GREEN}./scripts/open-all.sh${NC}      # 全エージェントを別タブで開く"
echo ""
echo "🚀 作業を開始するには、BOSSに指示を送信してください:"
echo "   ${GREEN}./scripts/agent-send.sh boss \"requirementsを読み込んで作業を開始してください\"${NC}"
echo ""
echo "📊 ステータスを確認するには:"
echo "   ${GREEN}./scripts/project-status.sh${NC}"
echo ""
echo "💡 tmux操作方法:"
echo "  セッション一覧: ${GREEN}Ctrl+b → s${NC}"
echo "  ペイン切り替え: ${GREEN}Ctrl+b → 矢印キー${NC}"
echo "  デタッチ: ${GREEN}Ctrl+b → d${NC}"
echo "  スクロール: ${GREEN}Ctrl+b → [${NC} (qで終了)"
echo "  ペイン最大化: ${GREEN}Ctrl+b → z${NC} (もう一度で解除)"
echo ""
echo "⚡ エージェントはあなたの指示を待っています！"