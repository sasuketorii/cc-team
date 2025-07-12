#!/bin/bash
# 修正版launch-ccteam-v4の動作テスト

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

echo -e "${BLUE}🧪 修正版CCTeam起動スクリプトのテスト${NC}"
echo "========================================"

# テスト用セッション
TEST_SESSION="test-ccteam-fixed"

# クリーンアップ
cleanup() {
    tmux kill-session -t "$TEST_SESSION" 2>/dev/null || true
}
trap cleanup EXIT

echo -e "${YELLOW}1. 標準方式のテスト（待機時間追加版）${NC}"
cleanup

# テスト用にechoコマンドを使用
tmux new-session -d -s "$TEST_SESSION" -n main
tmux send-keys -t "$TEST_SESSION:main" "echo 'Pane 0 OK'" Enter
sleep 0.2

tmux split-window -h -t "$TEST_SESSION:main"
sleep 0.2
tmux send-keys -t "$TEST_SESSION:main.1" "echo 'Pane 1 OK'" Enter
sleep 0.2

tmux split-window -v -t "$TEST_SESSION:main.0"
sleep 0.2
tmux send-keys -t "$TEST_SESSION:main.2" "echo 'Pane 2 OK'" Enter
sleep 0.2

tmux split-window -v -t "$TEST_SESSION:main.1"
sleep 0.2
tmux send-keys -t "$TEST_SESSION:main.3" "echo 'Pane 3 OK'" Enter
sleep 0.2

tmux select-layout -t "$TEST_SESSION:main" tiled
sleep 0.5

echo "結果確認："
for i in 0 1 2 3; do
    content=$(tmux capture-pane -t "$TEST_SESSION:main.$i" -p | grep -E "OK|Pane" | tail -n 1 || echo "失敗")
    echo "ペイン$i: $content"
done

cleanup
echo ""

echo -e "${YELLOW}2. 代替方式のテスト（全ペイン作成後に一括送信）${NC}"

# 代替方式のテスト
tmux new-session -d -s "$TEST_SESSION" -n main
tmux split-window -h -t "$TEST_SESSION:main"
tmux split-window -v -t "$TEST_SESSION:main.0"
tmux split-window -v -t "$TEST_SESSION:main.1"
tmux select-layout -t "$TEST_SESSION:main" tiled

sleep 0.5

for pane in 0 1 2 3; do
    tmux send-keys -t "$TEST_SESSION:main.$pane" "echo 'Pane $pane OK (Alt)'" Enter
    sleep 0.1
done

sleep 0.5

echo "結果確認："
for i in 0 1 2 3; do
    content=$(tmux capture-pane -t "$TEST_SESSION:main.$i" -p | grep -E "OK|Alt" | tail -n 1 || echo "失敗")
    echo "ペイン$i: $content"
done

cleanup
echo ""

echo -e "${YELLOW}3. 推奨事項${NC}"
echo "修正内容："
echo "- 各split-window後に0.2秒の待機時間を追加"
echo "- 代替方式：全ペイン作成後に一括でコマンド送信"
echo "- 環境変数 CCTEAM_USE_ALT_METHOD=true で代替方式を使用可能"
echo ""
echo "使用例："
echo "  通常版: ./scripts/launch-ccteam-v4-fixed.sh"
echo "  代替版: CCTEAM_USE_ALT_METHOD=true ./scripts/launch-ccteam-v4-fixed.sh"

echo ""
echo -e "${GREEN}✅ テスト完了${NC}"