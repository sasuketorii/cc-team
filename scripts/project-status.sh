#!/bin/bash

# Project Status Script
# プロジェクトの現在の状態を表示します

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "================== CCTeam プロジェクトステータス =================="
echo ""

# tmuxセッションの状態確認
echo "${CYAN}【tmuxセッション】${NC}"
if tmux has-session -t ccteam 2>/dev/null; then
    echo "✅ ccteamセッション: ${GREEN}アクティブ${NC}"
    
    # 各ペインの状態を確認
    echo ""
    echo "${CYAN}【エージェント状態】${NC}"
    
    # BOSSの状態
    if tmux list-panes -t ccteam:main -F "#{pane_index} #{pane_current_command}" | grep -q "^0 "; then
        echo "${RED}[BOSS]${NC}     : アクティブ"
    fi
    
    # Worker1の状態
    if tmux list-panes -t ccteam:main -F "#{pane_index} #{pane_current_command}" | grep -q "^1 "; then
        echo "${BLUE}[Worker1]${NC}  : アクティブ (フロントエンド)"
    fi
    
    # Worker2の状態
    if tmux list-panes -t ccteam:main -F "#{pane_index} #{pane_current_command}" | grep -q "^2 "; then
        echo "${GREEN}[Worker2]${NC}  : アクティブ (バックエンド)"
    fi
    
    # Worker3の状態
    if tmux list-panes -t ccteam:main -F "#{pane_index} #{pane_current_command}" | grep -q "^3 "; then
        echo "${YELLOW}[Worker3]${NC}  : アクティブ (インフラ/テスト)"
    fi
else
    echo "❌ ccteamセッション: ${RED}非アクティブ${NC}"
    echo "   ./scripts/setup.sh を実行してください"
fi

# 要件定義の確認
echo ""
echo "${CYAN}【要件定義】${NC}"
if [ -d "requirements" ] && [ -n "$(ls -A requirements 2>/dev/null)" ]; then
    echo "📁 requirements/ フォルダ:"
    find requirements -type f -name "*.md" -o -name "*.txt" -o -name "*.yaml" | while read file; do
        echo "   - $(basename "$file")"
    done
else
    echo "❌ 要件定義が見つかりません"
fi

# 最近のログ活動
echo ""
echo "${CYAN}【最近の活動】${NC}"
if [ -f "logs/system.log" ]; then
    echo "📝 システムログ (最新5件):"
    tail -n 5 logs/system.log | sed 's/^/   /'
fi

# 通信ログ
if [ -f "logs/communication.log" ]; then
    echo ""
    echo "💬 通信ログ (最新5件):"
    tail -n 5 logs/communication.log | sed 's/^/   /'
fi

# エラーチェック
echo ""
echo "${CYAN}【エラー状態】${NC}"
ERROR_COUNT=0
for log in logs/*.log; do
    if [ -f "$log" ]; then
        errors=$(grep -i "error\|failed\|exception" "$log" 2>/dev/null | wc -l)
        if [ $errors -gt 0 ]; then
            ERROR_COUNT=$((ERROR_COUNT + errors))
            echo "⚠️  $(basename "$log"): ${RED}$errors エラー${NC}"
        fi
    fi
done

if [ $ERROR_COUNT -eq 0 ]; then
    echo "✅ エラーは検出されていません"
fi

# ディスク使用量
echo ""
echo "${CYAN}【リソース使用状況】${NC}"
if [ -d "logs" ]; then
    LOG_SIZE=$(du -sh logs 2>/dev/null | cut -f1)
    echo "📊 ログサイズ: $LOG_SIZE"
fi

# 推奨アクション
echo ""
echo "${CYAN}【推奨アクション】${NC}"
if ! tmux has-session -t ccteam 2>/dev/null; then
    echo "1. ${GREEN}./scripts/setup.sh${NC} - tmuxセッションを作成"
    echo "2. ${GREEN}./scripts/launch-ccteam.sh${NC} - CCTeamを起動"
elif [ ! -f "logs/communication.log" ] || [ $(wc -l < logs/communication.log) -lt 5 ]; then
    echo "1. ${GREEN}tmux attach -t ccteam${NC} - セッションに接続して進捗を確認"
else
    echo "1. ${GREEN}tail -f logs/boss.log${NC} - BOSSの活動をモニター"
    echo "2. ${GREEN}./scripts/agent-send.sh boss \"ステータス確認\"${NC} - 進捗確認"
fi

echo ""
echo "=================================================================="