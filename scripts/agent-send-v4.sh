#!/bin/bash
# CCTeam v4用エージェント送信スクリプト
# シンプルで直感的な構造

set -e

# カラー定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 使用方法
usage() {
    echo "使用方法: $0 <agent> <message>"
    echo ""
    echo "エージェント:"
    echo "  boss     - 全体統括Boss"
    echo "  pm1      - Team1 PM (Frontend)"
    echo "  pm2      - Team2 PM (Backend)"  
    echo "  pm3      - Team3 PM (DevOps)"
    echo "  worker1-1 to worker1-3 - Team1 Workers"
    echo "  worker2-1 to worker2-3 - Team2 Workers"
    echo "  worker3-1 to worker3-3 - Team3 Workers"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
fi

AGENT=$1
MESSAGE="${@:2}"

# エージェントマッピング
case $AGENT in
    "boss")
        SESSION="ccteam-boss"
        PANE="main.0"
        ;;
    "pm1")
        SESSION="ccteam-1"
        PANE="main.0"
        ;;
    "pm2")
        SESSION="ccteam-2"
        PANE="main.0"
        ;;
    "pm3")
        SESSION="ccteam-3"
        PANE="main.0"
        ;;
    "worker1-1")
        SESSION="ccteam-1"
        PANE="main.1"
        ;;
    "worker1-2")
        SESSION="ccteam-1"
        PANE="main.2"
        ;;
    "worker1-3")
        SESSION="ccteam-1"
        PANE="main.3"
        ;;
    "worker2-1")
        SESSION="ccteam-2"
        PANE="main.1"
        ;;
    "worker2-2")
        SESSION="ccteam-2"
        PANE="main.2"
        ;;
    "worker2-3")
        SESSION="ccteam-2"
        PANE="main.3"
        ;;
    "worker3-1")
        SESSION="ccteam-3"
        PANE="main.1"
        ;;
    "worker3-2")
        SESSION="ccteam-3"
        PANE="main.2"
        ;;
    "worker3-3")
        SESSION="ccteam-3"
        PANE="main.3"
        ;;
    *)
        echo -e "${RED}エラー: 無効なエージェント名 '$AGENT'${NC}"
        usage
        ;;
esac

# セッション存在確認
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    echo -e "${RED}エラー: セッション '$SESSION' が存在しません${NC}"
    echo -e "${YELLOW}ヒント: './scripts/launch-ccteam-v4.sh' でCCTeamを起動してください${NC}"
    exit 1
fi

# メッセージ送信
echo -e "${GREEN}📤 $AGENT にメッセージを送信中...${NC}"
tmux send-keys -t "$SESSION:$PANE" C-c
sleep 0.5
tmux send-keys -t "$SESSION:$PANE" "$MESSAGE"
sleep 0.1
tmux send-keys -t "$SESSION:$PANE" Enter

echo -e "${GREEN}✅ 送信完了${NC}"

# メモリシステムに記録
if [ -f "scripts/memory_manager.py" ]; then
    python3 scripts/memory_manager.py save --agent "$AGENT" --message "Received: $MESSAGE" 2>/dev/null || true
fi