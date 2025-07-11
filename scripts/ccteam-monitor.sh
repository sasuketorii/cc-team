#!/bin/bash

# CCTeam Status Monitor
# リアルタイムでエージェントの状態を監視

# 共通カラー定義を読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/colors.sh"

# 状態を取得する関数
get_agent_status() {
    local session=$1
    local pane=$2
    
    if tmux list-panes -t "$session" 2>/dev/null | grep -q "^$pane:"; then
        # ペインが存在する場合
        local pane_pid=$(tmux list-panes -t "$session" -F "#{pane_index} #{pane_pid}" | grep "^$pane " | awk '{print $2}')
        if ps -p $pane_pid > /dev/null 2>&1; then
            # プロセスが生きている
            if tmux capture-pane -t "$session:$pane" -p | grep -q "Human:"; then
                echo "🟢 アクティブ"
            else
                echo "🟡 待機中"
            fi
        else
            echo "⚫ 未起動"
        fi
    else
        echo "❌ エラー"
    fi
}

# ログから最新の通信を取得
get_latest_communications() {
    local count=5
    if [ -f logs/communication.log ]; then
        tail -n $count logs/communication.log 2>/dev/null | while read line; do
            echo "  $line"
        done
    else
        echo "  （通信履歴なし）"
    fi
}

# メイン監視ループ
monitor_loop() {
    while true; do
        clear
        
        echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│${NC} CCTeam Status Monitor - $(date '+%H:%M:%S')        ${CYAN}│${NC}"
        echo -e "${CYAN}├─────────────────────────────────────────────────┤${NC}"
        
        # Boss状態
        boss_status=$(get_agent_status "ccteam-boss" "0")
        echo -e "${CYAN}│${NC} ${RED}Boss:${NC}    $boss_status                      ${CYAN}│${NC}"
        
        # Worker状態
        worker1_status=$(get_agent_status "ccteam-workers" "0")
        worker2_status=$(get_agent_status "ccteam-workers" "1")
        worker3_status=$(get_agent_status "ccteam-workers" "2")
        
        echo -e "${CYAN}│${NC} ${BLUE}Worker1:${NC} $worker1_status                     ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC} ${GREEN}Worker2:${NC} $worker2_status                     ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC} ${YELLOW}Worker3:${NC} $worker3_status                     ${CYAN}│${NC}"
        
        echo -e "${CYAN}├─────────────────────────────────────────────────┤${NC}"
        echo -e "${CYAN}│${NC} 最新の通信:                                    ${CYAN}│${NC}"
        
        # 最新のログ表示
        if [ -f logs/boss.log ]; then
            latest_log=$(tail -n 1 logs/boss.log 2>/dev/null | head -c 45)
            if [ -n "$latest_log" ]; then
                printf "${CYAN}│${NC} %-47s ${CYAN}│${NC}\n" "$latest_log..."
            fi
        fi
        
        echo -e "${CYAN}├─────────────────────────────────────────────────┤${NC}"
        echo -e "${CYAN}│${NC} 操作:                                          ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  [a] Boss接続  [w] Worker接続  [r] 更新        ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  [l] ログ表示  [q] 終了                        ${CYAN}│${NC}"
        echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
        
        # キー入力待機（1秒タイムアウト）
        read -t 1 -n 1 key
        
        case $key in
            a)
                tmux attach -t ccteam-boss
                ;;
            w)
                tmux attach -t ccteam-workers
                ;;
            l)
                echo ""
                echo "最新のログ:"
                tail -n 20 logs/*.log
                read -p "Enterキーで続行..."
                ;;
            q)
                echo ""
                echo "監視を終了します"
                exit 0
                ;;
        esac
    done
}

# tmuxセッション確認
if ! tmux has-session -t ccteam-boss 2>/dev/null && ! tmux has-session -t ccteam-workers 2>/dev/null; then
    echo "❌ CCTeamセッションが見つかりません"
    echo "まず ccteam または ccteam-guided を実行してください"
    exit 1
fi

# 監視開始
echo "CCTeam監視を開始します..."
echo "終了するには 'q' を押してください"
sleep 2

monitor_loop