#!/bin/bash
# Claude起動タイミングのデバッグスクリプト

set -e

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# プロジェクトルート
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}🔍 Claude起動タイミングデバッグ${NC}"
echo "================================"

# テストセッション名
TEST_SESSION="debug-claude-test"

# 既存セッションをクリーンアップ
tmux kill-session -t "$TEST_SESSION" 2>/dev/null || true

echo -e "${YELLOW}1. セッション作成と分割${NC}"
# 新規セッション作成
tmux new-session -d -s "$TEST_SESSION" -n main

# 各ペインでechoコマンドを実行（claudeの代わり）
echo "ペイン0にコマンド送信..."
tmux send-keys -t "$TEST_SESSION:main" "echo 'Claude 0 started'" Enter

# 垂直分割
tmux split-window -h -t "$TEST_SESSION:main"
echo "ペイン1にコマンド送信..."
tmux send-keys -t "$TEST_SESSION:main.1" "echo 'Claude 1 started'" Enter

# 左側を水平分割
tmux split-window -v -t "$TEST_SESSION:main.0"
echo "ペイン2にコマンド送信..."
tmux send-keys -t "$TEST_SESSION:main.2" "echo 'Claude 2 started'" Enter

# 右側を水平分割
tmux split-window -v -t "$TEST_SESSION:main.1"
echo "ペイン3にコマンド送信..."
tmux send-keys -t "$TEST_SESSION:main.3" "echo 'Claude 3 started'" Enter

# レイアウト調整
tmux select-layout -t "$TEST_SESSION:main" tiled

# 少し待つ
sleep 1

echo ""
echo -e "${YELLOW}2. 各ペインの状態確認${NC}"
echo "現在のペイン構成："
tmux list-panes -t "$TEST_SESSION:main" -F "Pane #{pane_index}: #{pane_id} at (#{pane_left},#{pane_top}) size #{pane_width}x#{pane_height}"

echo ""
echo -e "${YELLOW}3. 各ペインの内容確認${NC}"
for i in 0 1 2 3; do
    echo -e "${GREEN}ペイン$i の内容:${NC}"
    content=$(tmux capture-pane -t "$TEST_SESSION:main.$i" -p | grep -E "Claude|started" | tail -n 1 || echo "内容なし")
    echo "$content"
done

echo ""
echo -e "${YELLOW}4. v4スクリプトの動作をシミュレート${NC}"
echo "v4では以下の順序でコマンドを送信："
echo "1. ペイン0（初期）にclaude送信"
echo "2. 垂直分割後、ペイン1にclaude送信"
echo "3. 左側分割後、ペイン2にclaude送信"
echo "4. 右側分割後、ペイン3にclaude送信"

echo ""
echo -e "${YELLOW}5. 問題の分析${NC}"
echo "分割によるペイン番号の再割り当て："
echo "- 初期: ペイン0のみ"
echo "- 垂直分割後: ペイン0（左）、ペイン1（右）"
echo "- 左側分割後: ペイン番号が再割り当てされる可能性"
echo "- 右側分割後: さらに番号が変わる可能性"

# クリーンアップ
tmux kill-session -t "$TEST_SESSION"

echo ""
echo -e "${GREEN}✅ デバッグ完了${NC}"