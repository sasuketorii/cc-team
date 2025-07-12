#!/bin/bash
# tmuxペイン作成と番号割り当てのデバッグスクリプト

set -e

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔍 tmuxペイン番号割り当てデバッグ${NC}"
echo "================================"

# テストセッション名
TEST_SESSION="debug-tmux-test"

# 既存セッションをクリーンアップ
tmux kill-session -t "$TEST_SESSION" 2>/dev/null || true

echo -e "${YELLOW}1. 新規セッション作成${NC}"
tmux new-session -d -s "$TEST_SESSION" -n main
echo "初期状態："
tmux list-panes -t "$TEST_SESSION:main" -F "Pane #{pane_index}: #{pane_id} (#{pane_width}x#{pane_height})"
echo ""

echo -e "${YELLOW}2. 垂直分割（左右）${NC}"
tmux split-window -h -t "$TEST_SESSION:main"
echo "垂直分割後："
tmux list-panes -t "$TEST_SESSION:main" -F "Pane #{pane_index}: #{pane_id} (#{pane_width}x#{pane_height})"
echo ""

echo -e "${YELLOW}3. 左側（ペイン0）を水平分割${NC}"
tmux split-window -v -t "$TEST_SESSION:main.0"
echo "左側分割後："
tmux list-panes -t "$TEST_SESSION:main" -F "Pane #{pane_index}: #{pane_id} (#{pane_width}x#{pane_height})"
echo ""

echo -e "${YELLOW}4. 右側（ペイン1）を水平分割${NC}"
tmux split-window -v -t "$TEST_SESSION:main.1"
echo "右側分割後："
tmux list-panes -t "$TEST_SESSION:main" -F "Pane #{pane_index}: #{pane_id} (#{pane_width}x#{pane_height})"
echo ""

echo -e "${YELLOW}5. tiledレイアウト適用${NC}"
tmux select-layout -t "$TEST_SESSION:main" tiled
echo "tiled適用後："
tmux list-panes -t "$TEST_SESSION:main" -F "Pane #{pane_index}: #{pane_id} (#{pane_width}x#{pane_height})"
echo ""

echo -e "${YELLOW}6. 各ペインにテストメッセージを送信${NC}"
for i in 0 1 2 3; do
    echo "ペイン$iに送信: 'echo Pane $i'"
    tmux send-keys -t "$TEST_SESSION:main.$i" "echo 'Pane $i'" Enter
done
echo ""

echo -e "${YELLOW}7. 各ペインの内容を確認${NC}"
for i in 0 1 2 3; do
    echo -e "${GREEN}ペイン$i:${NC}"
    tmux capture-pane -t "$TEST_SESSION:main.$i" -p | tail -n 3
    echo "---"
done

echo -e "${YELLOW}8. セッションクリーンアップ${NC}"
tmux kill-session -t "$TEST_SESSION"

echo -e "${GREEN}✅ デバッグ完了${NC}"