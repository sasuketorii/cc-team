#!/bin/bash
# CCTeam エージェント自動初期化スクリプト v1.0.0
# Claudeの認証後に各エージェントを初期化

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 共通カラー定義を読み込み
source "$SCRIPT_DIR/common/colors.sh"

echo -e "${BLUE}🤖 CCTeam エージェント初期化開始${NC}"
echo "=================================="

# タイムスタンプ
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 認証確認
echo -e "${YELLOW}⚠️  重要: 全エージェントで認証（'2'を入力）が完了していることを確認してください${NC}"
echo -e "未完了の場合は、Ctrl+Cで中断して認証を完了させてください"
echo ""
read -p "認証は完了していますか？ (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "初期化を中断しました"
    exit 0
fi

echo ""
echo -e "${GREEN}📋 エージェントを初期化中...${NC}"

# Boss初期化
echo -e "${BLUE}1. Boss初期化中...${NC}"
tmux send-keys -t ccteam-boss:main.0 C-c
sleep 0.5
tmux send-keys -t ccteam-boss:main.0 "/file instructions/boss.md を読み込んで、CCTeam Bossとして動作を開始してください。待機モードで起動し、ユーザーからの指示を待ってください。" Enter
echo "  ✅ Boss初期化コマンド送信"
sleep 2

# Worker1初期化
echo -e "${BLUE}2. Worker1（フロントエンド）初期化中...${NC}"
tmux send-keys -t ccteam-workers:main.0 C-c
sleep 0.5
tmux send-keys -t ccteam-workers:main.0 "/file instructions/worker1.md を読み込んで、フロントエンド開発担当のWorker1として動作を開始してください。Bossからの指示を待ってください。" Enter
echo "  ✅ Worker1初期化コマンド送信"
sleep 2

# Worker2初期化
echo -e "${BLUE}3. Worker2（バックエンド）初期化中...${NC}"
tmux send-keys -t ccteam-workers:main.1 C-c
sleep 0.5
tmux send-keys -t ccteam-workers:main.1 "/file instructions/worker2.md を読み込んで、バックエンド開発担当のWorker2として動作を開始してください。Bossからの指示を待ってください。" Enter
echo "  ✅ Worker2初期化コマンド送信"
sleep 2

# Worker3初期化
echo -e "${BLUE}4. Worker3（テスト/品質保証）初期化中...${NC}"
tmux send-keys -t ccteam-workers:main.2 C-c
sleep 0.5
tmux send-keys -t ccteam-workers:main.2 "/file instructions/worker3.md を読み込んで、テスト・品質保証担当のWorker3として動作を開始してください。Bossからの指示を待ってください。" Enter
echo "  ✅ Worker3初期化コマンド送信"

# ログ記録
echo "[$TIMESTAMP] Agents initialized" >> "$PROJECT_ROOT/logs/system.log"

echo ""
echo -e "${GREEN}✅ 全エージェントの初期化コマンドを送信しました！${NC}"
echo ""
echo "次のステップ："
echo "1. 各エージェントが指示書を読み込むまで待ってください（10-15秒）"
echo "2. 動作確認："
echo -e "   ${CYAN}./scripts/auto-rollcall.sh${NC}  # 点呼で応答を確認"
echo ""
echo "3. 開発開始："
echo -e "   ${CYAN}./scripts/agent-send.sh boss \"requirementsを読み込んでプロジェクトを開始してください\"${NC}"
echo ""
echo -e "${YELLOW}💡 ヒント: tmux attach -t ccteam-boss で進行状況を確認できます${NC}"