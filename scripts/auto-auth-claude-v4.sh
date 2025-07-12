#!/bin/bash
# CCTeam v4用自動認証スクリプト
# よりシンプルで確実な認証

set -e

# カラー定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔐 CCTeam v4 自動認証開始${NC}"
echo "=================================="

# セッションリスト
SESSIONS=(
    "ccteam-boss:Boss"
    "ccteam-1:Team1 (Frontend)"
    "ccteam-2:Team2 (Backend)"
    "ccteam-3:Team3 (DevOps)"
)

# 各セッションの認証
for session_info in "${SESSIONS[@]}"; do
    IFS=':' read -r session_name display_name <<< "$session_info"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        continue
    fi
    
    # 各ペインを確認（1セッション最大4ペイン）
    for pane in 0 1 2 3; do
        pane_id="$session_name:main.$pane"
        
        # ペイン存在確認
        if ! tmux list-panes -t "$pane_id" &>/dev/null 2>&1; then
            continue
        fi
        
        # 画面内容取得
        screen_content=$(tmux capture-pane -t "$pane_id" -p 2>/dev/null || echo "")
        
        # 認証画面チェック
        if echo "$screen_content" | grep -q "Bypassing Permissions\|Do you want to proceed"; then
            # 認証処理
            tmux send-keys -t "$pane_id" "2"
            sleep 0.1
            tmux send-keys -t "$pane_id" Enter
            sleep 2
        fi
    done
    
    echo -e "${GREEN}✅ $display_name 認証完了${NC}"
done

echo ""
echo -e "${GREEN}✅ 認証処理完了！${NC}"
echo ""
echo "次のステップ:"
echo "1. Boss接続: tmux attach -t ccteam-boss"
echo "2. Team接続: tmux attach -t ccteam-1"