#!/bin/bash

# CCTeam統合修正テストスクリプト
# 修正された統合問題の検証を実行

set -euo pipefail

# カラー定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 CCTeam統合修正テスト${NC}"
echo "=========================="
echo ""

# テスト結果
TESTS_PASSED=0
TESTS_FAILED=0

# テスト関数
test_check() {
    local name="$1"
    local cmd="$2"
    
    printf "%-50s" "  $name"
    if eval "$cmd" &> /dev/null; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# 1. Critical修正の検証
echo -e "${YELLOW}[1/4] Critical修正検証${NC}"

# agent-send.shの正しいマッピング確認
test_check "agent-send.sh - Boss mapping" "grep -q 'boss)' scripts/agent-send.sh && grep -A 1 'boss)' scripts/agent-send.sh | grep -q 'ccteam:main.0'"
test_check "agent-send.sh - Worker1 mapping" "grep -A 1 'worker1)' scripts/agent-send.sh | grep -q 'ccteam:main.1'"
test_check "agent-send.sh - Worker2 mapping" "grep -A 1 'worker2)' scripts/agent-send.sh | grep -q 'ccteam:main.2'"
test_check "agent-send.sh - Worker3 mapping" "grep -A 1 'worker3)' scripts/agent-send.sh | grep -q 'ccteam:main.3'"

# enhanced_agent_send.shの同期確認
test_check "enhanced_agent_send.sh sync" "grep -A 1 'worker1)' scripts/enhanced_agent_send.sh | grep -q 'ccteam:main.1'"

# launch-ccteam.shの存在確認
test_check "launch-ccteam.sh exists" "test -f scripts/launch-ccteam.sh"
test_check "launch-ccteam.sh delegates to v4" "grep -q 'launch-ccteam-v4.sh' scripts/launch-ccteam.sh"

echo ""

# 2. スクリプト整合性検証
echo -e "${YELLOW}[2/4] スクリプト整合性検証${NC}"

test_check "open-boss.sh correct target" "grep -q 'ccteam:main.0' scripts/open-boss.sh"
test_check "open-worker1.sh correct target" "grep -q 'ccteam:main.1' scripts/open-worker1.sh"
test_check "open-worker2.sh correct target" "grep -q 'ccteam:main.2' scripts/open-worker2.sh"
test_check "open-worker3.sh correct target" "grep -q 'ccteam:main.3' scripts/open-worker3.sh"

test_check "worktree-parallel-manual.sh mapping" "grep -A 1 'worker1)' scripts/worktree-parallel-manual.sh | grep -q 'ccteam:main.1'"

echo ""

# 3. 依存関係検証
echo -e "${YELLOW}[3/4] 依存関係検証${NC}"

test_check "structured_logger.py exists" "test -f scripts/structured_logger.py"
test_check "security-utils.sh exists" "test -f scripts/security-utils.sh"
test_check "notification-manager.sh exists" "test -f scripts/notification-manager.sh"

# Python依存関係
test_check "structured_logger import" "python3 -c 'import sys; sys.path.append(\"scripts\"); from structured_logger import StructuredLogger'"

echo ""

# 4. アーキテクチャ一貫性検証
echo -e "${YELLOW}[4/4] アーキテクチャ一貫性検証${NC}"

# v4スクリプトのセッション構造確認
test_check "v4 creates single session" "grep -q 'tmux new-session -d -s ccteam' scripts/launch-ccteam-v4.sh"
test_check "v4 has 4 panes" "grep -c 'split-window.*ccteam:main' scripts/launch-ccteam-v4.sh | grep -q '3'"
test_check "v4 Boss pane title" "grep -q 'ccteam:main.0.*Boss' scripts/launch-ccteam-v4.sh"
test_check "v4 Worker3 pane" "grep -q 'ccteam:main.3' scripts/launch-ccteam-v4.sh"

echo ""

# 結果レポート
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 テスト結果${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "✅ ${GREEN}成功: $TESTS_PASSED${NC}"
echo -e "❌ ${RED}失敗: $TESTS_FAILED${NC}"
echo ""

TOTAL=$((TESTS_PASSED + TESTS_FAILED))
if [ $TOTAL -gt 0 ]; then
    SUCCESS_RATE=$((TESTS_PASSED * 100 / TOTAL))
    echo -e "📈 成功率: ${GREEN}$SUCCESS_RATE%${NC}"
else
    echo -e "⚠️  テストが実行されませんでした"
fi

echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 全ての統合修正が正常に完了しています！${NC}"
    exit 0
else
    echo -e "${RED}⚠️  一部の修正に問題があります。詳細を確認してください。${NC}"
    exit 1
fi