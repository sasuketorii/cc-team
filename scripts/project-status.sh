#!/bin/bash

# Project Status Script
# プロジェクトの現在の状態を表示します

# カラー定義を読み込み
source "$(dirname "${BASH_SOURCE[0]}")/common/colors.sh"

echo "================== CCTeam プロジェクトステータス =================="
echo ""

# tmuxセッションの状態確認
echo -e "${CYAN}【tmuxセッション】${NC}"
if tmux has-session -t ccteam 2>/dev/null; then
    echo -e "✅ ccteamセッション: ${GREEN}アクティブ${NC}"
    
    # 各ペインの状態を確認
    echo ""
    echo -e "${CYAN}【エージェント状態】${NC}"
    
    # BOSSの状態
    if tmux list-panes -t ccteam:main -F "#{pane_index} #{pane_current_command}" | grep -q "^0 "; then
        echo -e "${RED}[BOSS]${NC}     : アクティブ"
    fi
    
    # Worker1の状態
    if tmux list-panes -t ccteam:main -F "#{pane_index} #{pane_current_command}" | grep -q "^1 "; then
        echo -e "${BLUE}[Worker1]${NC}  : アクティブ (フロントエンド)"
    fi
    
    # Worker2の状態
    if tmux list-panes -t ccteam:main -F "#{pane_index} #{pane_current_command}" | grep -q "^2 "; then
        echo -e "${GREEN}[Worker2]${NC}  : アクティブ (バックエンド)"
    fi
    
    # Worker3の状態
    if tmux list-panes -t ccteam:main -F "#{pane_index} #{pane_current_command}" | grep -q "^3 "; then
        echo -e "${YELLOW}[Worker3]${NC}  : アクティブ (インフラ/テスト)"
    fi
else
    echo -e "❌ ccteamセッション: ${RED}非アクティブ${NC}"
    echo "   ./scripts/setup.sh を実行してください"
fi

# 要件定義の確認
echo ""
echo -e "${CYAN}【要件定義】${NC}"
if [ -d "requirements" ] && [ -n "$(ls -A requirements 2>/dev/null)" ]; then
    echo "📁 requirements/ フォルダ:"
    find requirements -type f -name "*.md" -o -name "*.txt" -o -name "*.yaml" | while read file; do
        echo "   - $(basename "$file")"
    done
else
    echo "❌ 要件定義が見つかりません"
    echo "   → requirements/フォルダに.md/.txt/.yamlファイルを配置してください"
    echo "   → 例: requirements/project-requirements.md"
fi

# 最近のログ活動
echo ""
echo -e "${CYAN}【最近の活動】${NC}"
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
echo -e "${CYAN}【エラー状態】${NC}"
ERROR_COUNT=0
for log in logs/*.log; do
    if [ -f "$log" ]; then
        errors=$(grep -i "error\|failed\|exception" "$log" 2>/dev/null | wc -l)
        if [ $errors -gt 0 ]; then
            ERROR_COUNT=$((ERROR_COUNT + errors))
            echo -e "⚠️  $(basename "$log"): ${RED}$errors エラー${NC}"
        fi
    fi
done

if [ $ERROR_COUNT -eq 0 ]; then
    echo "✅ エラーは検出されていません"
fi

# ディスク使用量
echo ""
echo -e "${CYAN}【リソース使用状況】${NC}"
if [ -d "logs" ]; then
    LOG_SIZE=$(du -sh logs 2>/dev/null | cut -f1)
    echo "📊 ログサイズ: $LOG_SIZE"
fi

# 推奨アクション
echo ""
echo -e "${CYAN}【推奨アクション】${NC}"
if ! tmux has-session -t ccteam 2>/dev/null; then
    echo -e "1. ${GREEN}./scripts/setup.sh${NC} - tmuxセッションを作成"
    echo -e "2. ${GREEN}./scripts/launch-ccteam.sh${NC} - CCTeamを起動"
elif [ ! -f "logs/communication.log" ] || [ $(wc -l < logs/communication.log) -lt 5 ]; then
    echo -e "1. ${GREEN}tmux attach -t ccteam${NC} - セッションに接続して進捗を確認"
else
    echo -e "1. ${GREEN}tail -f logs/boss.log${NC} - BOSSの活動をモニター"
    echo -e "2. ${GREEN}./scripts/agent-send.sh boss \"ステータス確認\"${NC} - 進捗確認"
fi

echo ""
echo "=================================================================="