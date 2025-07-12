#!/bin/bash

# CCTeam エージェント通信テストスクリプト
# 実際のエージェント通信機能の動作検証

set -euo pipefail

# カラー定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📡 CCTeam エージェント通信テスト${NC}"
echo "================================="
echo ""

# テスト結果
TESTS_PASSED=0
TESTS_FAILED=0

# テスト関数
communication_test() {
    local name="$1"
    local agent="$2"
    local expected_pane="$3"
    
    printf "%-50s" "  $name"
    
    # tmuxセッションの存在確認
    if ! tmux has-session -t ccteam 2>/dev/null; then
        echo -e "${YELLOW}SKIP (セッションなし)${NC}"
        return 0
    fi
    
    # ペインの存在確認
    if ! tmux list-panes -t "$expected_pane" &>/dev/null; then
        echo -e "${RED}❌ FAIL (ペインなし)${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
    
    # 通信テストメッセージ送信
    if ./scripts/agent-send.sh "$agent" "# テスト: $(date '+%H:%M:%S')" &>/dev/null; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# セッション存在確認
echo -e "${YELLOW}[前提条件] tmuxセッション確認${NC}"
if tmux has-session -t ccteam 2>/dev/null; then
    echo -e "  ccteamセッション: ${GREEN}✅ 存在${NC}"
    
    # ペイン数確認
    pane_count=$(tmux list-panes -t ccteam:main 2>/dev/null | wc -l | tr -d ' ')
    echo -e "  ペイン数: ${GREEN}$pane_count${NC}"
    
    if [ "$pane_count" -eq 4 ]; then
        echo -e "  ペイン構成: ${GREEN}✅ 正常（4ペイン）${NC}"
    else
        echo -e "  ペイン構成: ${YELLOW}⚠️  期待値と異なる（4ペイン期待、${pane_count}ペイン検出）${NC}"
    fi
else
    echo -e "  ccteamセッション: ${YELLOW}⚠️  存在しません${NC}"
    echo ""
    echo -e "${YELLOW}💡 セッションを起動するには:${NC}"
    echo "   ./scripts/launch-ccteam.sh"
    echo ""
    echo "セッションが存在しないため、構造テストのみ実行します。"
fi

echo ""

# 1. エージェント通信テスト（セッションがある場合）
echo -e "${YELLOW}[1/3] エージェント通信テスト${NC}"

if tmux has-session -t ccteam 2>/dev/null; then
    communication_test "Boss通信" "boss" "ccteam:main.0"
    communication_test "Worker1通信" "worker1" "ccteam:main.1"
    communication_test "Worker2通信" "worker2" "ccteam:main.2"
    communication_test "Worker3通信" "worker3" "ccteam:main.3"
else
    echo -e "  ${YELLOW}セッションが存在しないためスキップ${NC}"
fi

echo ""

# 2. スクリプト構文テスト
echo -e "${YELLOW}[2/3] スクリプト構文テスト${NC}"

printf "%-50s" "  agent-send.sh構文チェック"
if bash -n scripts/agent-send.sh; then
    echo -e "${GREEN}✅ PASS${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL${NC}"
    ((TESTS_FAILED++))
fi

printf "%-50s" "  enhanced_agent_send.sh構文チェック"
if bash -n scripts/enhanced_agent_send.sh; then
    echo -e "${GREEN}✅ PASS${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL${NC}"
    ((TESTS_FAILED++))
fi

printf "%-50s" "  launch-ccteam.sh構文チェック"
if bash -n scripts/launch-ccteam.sh; then
    echo -e "${GREEN}✅ PASS${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL${NC}"
    ((TESTS_FAILED++))
fi

echo ""

# 3. ログ出力テスト
echo -e "${YELLOW}[3/3] ログ出力テスト${NC}"

printf "%-50s" "  通信ログディレクトリ"
if test -d logs; then
    echo -e "${GREEN}✅ PASS${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL${NC}"
    ((TESTS_FAILED++))
fi

printf "%-50s" "  structured_logger動作確認"
if python3 -c "import sys; sys.path.append('scripts'); from structured_logger import StructuredLogger; logger = StructuredLogger('test'); print('OK')" &>/dev/null; then
    echo -e "${GREEN}✅ PASS${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL${NC}"
    ((TESTS_FAILED++))
fi

echo ""

# 結果レポート
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 通信テスト結果${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "✅ ${GREEN}成功: $TESTS_PASSED${NC}"
echo -e "❌ ${RED}失敗: $TESTS_FAILED${NC}"
echo ""

TOTAL=$((TESTS_PASSED + TESTS_FAILED))
if [ $TOTAL -gt 0 ]; then
    SUCCESS_RATE=$((TESTS_PASSED * 100 / TOTAL))
    echo -e "📈 成功率: ${GREEN}$SUCCESS_RATE%${NC}"
fi

echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 エージェント通信システムは正常に動作しています！${NC}"
    
    if ! tmux has-session -t ccteam 2>/dev/null; then
        echo ""
        echo -e "${YELLOW}💡 実際の通信テストを行うには:${NC}"
        echo "   1. ./scripts/launch-ccteam.sh でセッションを起動"
        echo "   2. 再度このテストを実行"
    fi
    
    exit 0
else
    echo -e "${RED}⚠️  エージェント通信システムに問題があります。${NC}"
    exit 1
fi