#!/bin/bash
# エンター問題修正のテストスクリプト

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== CCTeam エンター問題修正テスト ===${NC}"
echo ""

# 現在のセッション確認
echo "1. 現在のtmuxセッション確認:"
tmux ls 2>&1 || echo "セッションなし"
echo ""

# エンター送信方法のテスト
echo "2. エンター送信方法のテスト:"

# テスト用セッション作成
echo "テスト用セッション作成中..."
tmux new-session -d -s test-enter -n main
sleep 1

echo ""
echo -e "${YELLOW}各種エンター送信方法をテスト:${NC}"

# 方法1: C-m
echo -n "  方法1 (C-m): "
tmux send-keys -t test-enter:main.0 "echo 'Test C-m'" C-m
sleep 0.5
if tmux capture-pane -t test-enter:main.0 -p | grep -q "Test C-m"; then
    echo -e "${GREEN}✓ 成功${NC}"
else
    echo -e "${RED}✗ 失敗${NC}"
fi

# 方法2: Enter
echo -n "  方法2 (Enter): "
tmux send-keys -t test-enter:main.0 "echo 'Test Enter'" Enter
sleep 0.5
if tmux capture-pane -t test-enter:main.0 -p | grep -q "Test Enter"; then
    echo -e "${GREEN}✓ 成功${NC}"
else
    echo -e "${RED}✗ 失敗${NC}"
fi

# 方法3: -lオプション
echo -n "  方法3 (-lオプション): "
tmux send-keys -l -t test-enter:main.0 "echo 'Test -l option'"
tmux send-keys -t test-enter:main.0 Enter
sleep 0.5
if tmux capture-pane -t test-enter:main.0 -p | grep -q "Test -l option"; then
    echo -e "${GREEN}✓ 成功${NC}"
else
    echo -e "${RED}✗ 失敗${NC}"
fi

# クリーンアップ
tmux kill-session -t test-enter 2>/dev/null || true

echo ""
echo "3. agent-send.sh動作テスト:"

# 実際のセッションでテスト
if tmux has-session -t ccteam-boss 2>/dev/null; then
    echo -e "${BLUE}Bossにテストメッセージ送信...${NC}"
    ./scripts/agent-send.sh boss "テストメッセージ: エンター問題が修正されているか確認"
    echo -e "${GREEN}✓ 送信完了${NC}"
elif tmux has-session -t ccteam 2>/dev/null; then
    echo -e "${BLUE}Bossにテストメッセージ送信...${NC}"
    ./scripts/agent-send.sh boss "テストメッセージ: エンター問題が修正されているか確認"
    echo -e "${GREEN}✓ 送信完了${NC}"
else
    echo -e "${YELLOW}CCTeamセッションが起動していません${NC}"
    echo "先に ./scripts/launch-ccteam.sh でセッションを起動してください"
fi

echo ""
echo -e "${GREEN}=== テスト完了 ===${NC}"
echo ""
echo "推奨事項:"
echo "  - agent-send.shではEnterを使用しています"
echo "  - これはMCP環境での互換性を確保します"
echo "  - 通常のtmux環境でも動作します"