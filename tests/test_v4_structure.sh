#!/bin/bash
# CCTeam v4構造テストスクリプト

set -e

# カラー定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 CCTeam v4 構造テスト${NC}"
echo "=========================="
echo ""

# セッション存在確認
check_session() {
    local session=$1
    if tmux has-session -t "$session" 2>/dev/null; then
        echo -e "${GREEN}✅ $session セッション存在${NC}"
        return 0
    else
        echo -e "${RED}❌ $session セッション不在${NC}"
        return 1
    fi
}

# ペイン数確認
check_panes() {
    local session=$1
    local expected=$2
    local count=$(tmux list-panes -t "$session" 2>/dev/null | wc -l || echo 0)
    
    if [ "$count" -eq "$expected" ]; then
        echo -e "${GREEN}✅ $session: $count ペイン (期待値: $expected)${NC}"
        return 0
    else
        echo -e "${RED}❌ $session: $count ペイン (期待値: $expected)${NC}"
        return 1
    fi
}

# テスト実行
echo -e "${YELLOW}1. セッション確認${NC}"
check_session "ccteam-boss"
check_session "ccteam-1"
check_session "ccteam-2"
check_session "ccteam-3"

echo ""
echo -e "${YELLOW}2. ペイン構成確認${NC}"
check_panes "ccteam-boss:main" 1
check_panes "ccteam-1:main" 4
check_panes "ccteam-2:main" 4
check_panes "ccteam-3:main" 4

echo ""
echo -e "${YELLOW}3. コマンド確認${NC}"
if command -v ccteam-v4 &> /dev/null; then
    echo -e "${GREEN}✅ ccteam-v4 コマンド存在${NC}"
else
    echo -e "${RED}❌ ccteam-v4 コマンド不在${NC}"
fi

if [ -x "scripts/agent-send-v4.sh" ]; then
    echo -e "${GREEN}✅ agent-send-v4.sh 実行可能${NC}"
else
    echo -e "${RED}❌ agent-send-v4.sh 実行不可${NC}"
fi

echo ""
echo -e "${YELLOW}4. ディレクトリ構造確認${NC}"
for team in team1-frontend team2-backend team3-devops; do
    if [ -d "instructions/$team" ]; then
        echo -e "${GREEN}✅ instructions/$team 存在${NC}"
    else
        echo -e "${RED}❌ instructions/$team 不在${NC}"
    fi
done

echo ""
echo -e "${BLUE}テスト完了！${NC}"