#!/bin/bash

# CCTeam 統合テストスクリプト
# システム全体の動作確認を実行

set -euo pipefail

# カラー定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 CCTeam 統合テスト開始${NC}"
echo "=========================="
echo ""

# テスト結果
TESTS_PASSED=0
TESTS_FAILED=0

# テスト関数
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    
    echo -n "▶ $test_name... "
    
    if eval "$test_cmd" &> /tmp/test_output.log; then
        echo -e "${GREEN}✅ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        echo "  詳細:"
        cat /tmp/test_output.log | sed 's/^/    /'
        ((TESTS_FAILED++))
        return 1
    fi
}

# 1. 基本ファイル構造テスト
echo -e "${YELLOW}[1/7] 基本ファイル構造${NC}"
run_test "プロジェクトルート" "test -f package.json && test -f CLAUDE.md"
run_test "スクリプトディレクトリ" "test -d scripts && ls scripts/*.sh | wc -l | grep -v '^0$'"
run_test "ログディレクトリ" "test -d logs"
echo ""

# 2. Python環境テスト
echo -e "${YELLOW}[2/7] Python環境${NC}"
run_test "Python3インストール" "python3 --version"
run_test "構造化ログモジュール" "python3 -c 'import scripts.structured_logger'"
run_test "エラーループ検出モジュール" "python3 -c 'import scripts.error_loop_detector'"
run_test "メモリマネージャモジュール" "python3 -c 'import scripts.memory_manager'"
echo ""

# 3. エラーループ検出システムテスト
echo -e "${YELLOW}[3/7] エラーループ検出システム${NC}"
run_test "エラーループ検出status" "python3 scripts/error_loop_detector.py status"
run_test "エラーループヘルパー" "python3 scripts/error_loop_helper.py 'test error' | grep -q '📚'"
echo ""

# 4. メモリシステムテスト
echo -e "${YELLOW}[4/7] メモリシステム${NC}"
run_test "メモリディレクトリ作成" "mkdir -p memory"
run_test "メモリマネージャ初期化" "python3 -c 'from scripts.memory_manager import CCTeamMemoryManager; m = CCTeamMemoryManager()'"
echo ""

# 5. ログシステムテスト
echo -e "${YELLOW}[5/7] ログシステム${NC}"
run_test "構造化ログテスト" "python3 scripts/structured_logger.py test"
run_test "ログローテーションスクリプト" "test -x scripts/log_rotation.sh"
echo ""

# 6. 通信システムテスト
echo -e "${YELLOW}[6/7] 通信システム${NC}"
run_test "agent-send.shスクリプト" "test -x scripts/agent-send.sh"
run_test "enhanced_agent_send.sh" "test -x scripts/enhanced_agent_send.sh"
echo ""

# 7. Claude Code Actions検証
echo -e "${YELLOW}[7/7] Claude Code Actions${NC}"
run_test "Claude設定ディレクトリ" "test -d .claude"
run_test "Claude設定ファイル" "test -f .claude/claude_desktop_config.json"
run_test "アクション数確認" "cat .claude/claude_desktop_config.json | grep -c '\"id\"' | grep -E '^[0-9]+$'"
echo ""

# レポート生成
echo -e "${BLUE}📊 テスト結果サマリー${NC}"
echo "=========================="
echo -e "✅ 成功: ${GREEN}$TESTS_PASSED${NC}"
echo -e "❌ 失敗: ${RED}$TESTS_FAILED${NC}"
echo ""

# 総合判定
if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}🎉 すべてのテストが成功しました！${NC}"
    echo ""
    echo "システムは正常に動作しています。"
    exit 0
else
    echo -e "${RED}⚠️  一部のテストが失敗しました${NC}"
    echo ""
    echo "失敗したテストを確認して修正してください。"
    exit 1
fi