#!/bin/bash

# CCTeam tmuxペイン管理システム v0.0.8
# ペインの動的復元、追加、管理機能を提供

set -euo pipefail

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 設定ディレクトリ
CONFIG_DIR="$HOME/.ccteam"
mkdir -p "$CONFIG_DIR"

# ペイン状態を保存
save_pane_layout() {
    local session=$1
    local layout_file="$CONFIG_DIR/pane_layout_${session}.txt"
    
    echo -e "${BLUE}📁 $session のペインレイアウトを保存中...${NC}"
    
    # ペイン情報を保存
    tmux list-panes -t "$session" -F "#{pane_index}:#{pane_title}:#{pane_width}x#{pane_height}:#{pane_current_command}" > "$layout_file"
    
    # 現在のレイアウト文字列も保存
    tmux list-windows -t "$session" -F "#{window_layout}" > "$CONFIG_DIR/window_layout_${session}.txt"
    
    echo -e "${GREEN}✅ レイアウトを保存しました: $layout_file${NC}"
}

# ペインを復元
restore_pane_layout() {
    local session=$1
    local layout_file="$CONFIG_DIR/pane_layout_${session}.txt"
    
    if [[ ! -f $layout_file ]]; then
        echo -e "${RED}❌ レイアウトファイルが見つかりません: $layout_file${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🔄 $session のペインレイアウトを復元中...${NC}"
    
    # 現在のペイン数を確認
    local current_panes=$(tmux list-panes -t "$session" 2>/dev/null | wc -l || echo 0)
    local expected_panes=$(wc -l < "$layout_file")
    
    if [[ $current_panes -lt $expected_panes ]]; then
        echo "ペインが不足しています（現在: $current_panes、期待: $expected_panes）"
        
        # CCTeamの標準レイアウト（2x2）を復元
        if [[ $session == "ccteam" ]] && [[ $expected_panes -eq 4 ]]; then
            echo "CCTeam標準レイアウトを復元します..."
            
            # 既存のペインを全て削除して再作成
            tmux kill-pane -a -t "$session:main.0" 2>/dev/null || true
            
            # 2x2レイアウトを再作成
            tmux split-window -h -t "$session:main"
            tmux split-window -v -t "$session:main.0"
            tmux split-window -v -t "$session:main.1"
            
            # ペインタイトルを復元
            while IFS=':' read -r index title width_height command; do
                if [[ -n "$title" ]]; then
                    tmux select-pane -t "$session:main.$index" -T "$title" 2>/dev/null || true
                fi
            done < "$layout_file"
            
            # レイアウトを均等に調整
            tmux select-layout -t "$session:main" tiled
            
            echo -e "${GREEN}✅ レイアウトを復元しました${NC}"
        else
            # その他のセッション用の汎用復元
            while [[ $current_panes -lt $expected_panes ]]; do
                tmux split-window -t "$session"
                ((current_panes++))
            done
            tmux select-layout -t "$session" tiled
        fi
    fi
}

# 単一エージェントを追加
add_single_agent() {
    local session=$1
    local agent_type=$2  # worker4, specialist1, etc.
    
    echo -e "${BLUE}➕ $agent_type を $session に追加中...${NC}"
    
    # 現在のペイン数を確認
    local current_panes=$(tmux list-panes -t "$session" | wc -l)
    
    # 新しいペインを作成
    if [[ $current_panes -eq 4 ]]; then
        # 2x2レイアウトの場合、3x2に拡張
        echo "2x2レイアウトを3x2に拡張します..."
        tmux split-window -h -t "$session.3"
    else
        # それ以外は最後に追加
        tmux split-window -t "$session"
    fi
    
    # レイアウトを再調整
    tmux select-layout -t "$session" tiled
    
    # 新しいペインにタイトルを設定
    local new_pane_index=$current_panes
    tmux select-pane -t "$session.$new_pane_index" -T "$agent_type"
    
    # 新しいエージェントを起動
    tmux send-keys -t "$session.$new_pane_index" "claude" C-m
    sleep 2
    
    # 初期メッセージを送信
    tmux send-keys -t "$session.$new_pane_index" "👋 $agent_type として起動しました。指示を待機しています。" C-m
    
    echo -e "${GREEN}✅ $agent_type を追加しました（ペイン: $new_pane_index）${NC}"
    
    # レイアウトを保存
    save_pane_layout "$session"
}

# ペインの状態を監視
monitor_panes() {
    local session=$1
    
    echo -e "${BLUE}👁️  $session のペイン状態を監視中...${NC}"
    
    while true; do
        # 現在のペイン数を確認
        local current_panes=$(tmux list-panes -t "$session" 2>/dev/null | wc -l || echo 0)
        
        # 期待されるペイン数（保存されたレイアウトから）
        local layout_file="$CONFIG_DIR/pane_layout_${session}.txt"
        if [[ -f $layout_file ]]; then
            local expected_panes=$(wc -l < "$layout_file")
            
            if [[ $current_panes -lt $expected_panes ]]; then
                echo -e "${YELLOW}⚠️  ペインが失われました！復元を試みます...${NC}"
                restore_pane_layout "$session"
            fi
        fi
        
        sleep 5
    done
}

# exitフックの設定
setup_exit_hook() {
    echo -e "${BLUE}🔧 tmux exitフックを設定中...${NC}"
    
    # フックスクリプトを作成
    cat > "$CONFIG_DIR/pane_exit_hook.sh" << 'EOF'
#!/bin/bash
# tmuxペインが終了した時に自動実行されるフック

SESSION=$(tmux display-message -p '#S')
PANE_INDEX=$(tmux display-message -p '#{pane_index}')
PANE_TITLE=$(tmux display-message -p '#{pane_title}')

# CCTeamセッションの場合のみ処理
if [[ $SESSION == "ccteam"* ]]; then
    echo "[$(date)] Pane died: $SESSION.$PANE_INDEX ($PANE_TITLE)" >> ~/.ccteam/pane_events.log
    
    # 自動復元を試みる
    $(dirname $0)/../scripts/tmux-pane-manager.sh restore "$SESSION" &
fi
EOF
    
    chmod +x "$CONFIG_DIR/pane_exit_hook.sh"
    
    # tmux設定に追加
    if ! grep -q "pane-died" ~/.tmux.conf 2>/dev/null; then
        echo "" >> ~/.tmux.conf
        echo "# CCTeam pane management hooks" >> ~/.tmux.conf
        echo "set-hook -g pane-died 'run-shell \"$CONFIG_DIR/pane_exit_hook.sh\"'" >> ~/.tmux.conf
        echo -e "${GREEN}✅ tmux設定にフックを追加しました${NC}"
        echo -e "${YELLOW}⚠️  tmuxを再起動するか、設定をリロードしてください: tmux source-file ~/.tmux.conf${NC}"
    else
        echo -e "${GREEN}✅ フックは既に設定されています${NC}"
    fi
}

# ペイン情報を表示
show_pane_info() {
    local session=$1
    
    echo -e "${BLUE}📊 $session のペイン情報:${NC}"
    echo ""
    
    tmux list-panes -t "$session" -F "Pane #{pane_index}: #{pane_title} (#{pane_width}x#{pane_height}) - #{pane_current_command}" 2>/dev/null || {
        echo -e "${RED}セッションが見つかりません${NC}"
        return 1
    }
    
    echo ""
    local total_panes=$(tmux list-panes -t "$session" | wc -l)
    echo "合計ペイン数: $total_panes"
}

# ヘルプメッセージ
show_help() {
    echo "CCTeam tmuxペイン管理システム v0.0.8"
    echo ""
    echo "使用方法: $0 <command> [options]"
    echo ""
    echo "コマンド:"
    echo "  save <session>          - ペインレイアウトを保存"
    echo "  restore <session>       - ペインレイアウトを復元"
    echo "  add <session> <type>    - 新しいエージェントを追加"
    echo "  monitor <session>       - ペイン状態を継続的に監視"
    echo "  info <session>          - ペイン情報を表示"
    echo "  setup-hooks             - exitフックを設定"
    echo "  help                    - このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 save ccteam"
    echo "  $0 restore ccteam"
    echo "  $0 add ccteam worker4"
    echo "  $0 add ccteam specialist1"
}

# メイン処理
case "${1:-help}" in
    "save")
        save_pane_layout "${2:-ccteam}"
        ;;
    "restore")
        restore_pane_layout "${2:-ccteam}"
        ;;
    "add")
        if [[ -z "${3:-}" ]]; then
            echo -e "${RED}エラー: エージェントタイプを指定してください${NC}"
            echo "例: $0 add ccteam worker4"
            exit 1
        fi
        add_single_agent "${2:-ccteam}" "$3"
        ;;
    "monitor")
        monitor_panes "${2:-ccteam}"
        ;;
    "info")
        show_pane_info "${2:-ccteam}"
        ;;
    "setup-hooks")
        setup_exit_hook
        ;;
    "help"|*)
        show_help
        ;;
esac