#!/bin/bash
# CCTeam v4 - シンプルな階層構造版
# Boss + 3チーム（PM+Worker×3）

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

echo -e "${BLUE}🏢 CCTeam v0.1.16 起動 (階層構造版)${NC}"
echo "================================"
echo ""

# 既存セッションクリーンアップ
cleanup_sessions() {
    tmux kill-session -t ccteam-boss 2>/dev/null || true
    tmux kill-session -t ccteam-1 2>/dev/null || true
    tmux kill-session -t ccteam-2 2>/dev/null || true
    tmux kill-session -t ccteam-3 2>/dev/null || true
}

# Boss専用セッション
create_boss_session() {
    echo -e "${GREEN}👑 Boss セッション作成中...${NC}"
    tmux new-session -d -s ccteam-boss -n main
    tmux send-keys -t ccteam-boss:main "cd $PROJECT_ROOT && claude --model opus --permission-mode bypassPermissions" Enter
    sleep 1
}

# チームセッション（従来のccteam構造）
create_team_session() {
    local team_num=$1
    local team_name=$2
    local session_name="ccteam-$team_num"
    
    echo -e "${GREEN}🏢 Team$team_num ($team_name) セッション作成中...${NC}"
    
    # 全てのペインを先に作成
    tmux new-session -d -s "$session_name" -n main
    
    # 垂直に分割（左右）
    tmux split-window -h -t "$session_name:main"
    
    # 左側を水平に分割
    tmux split-window -v -t "$session_name:main.0"
    
    # 右側を水平に分割
    tmux split-window -v -t "$session_name:main.1"
    
    # レイアウトを均等に調整
    tmux select-layout -t "$session_name:main" tiled
    
    # ペインタイトルを設定（tmux 2.3以降）
    if tmux -V | grep -qE "(^tmux [2-9]\.[3-9]|^tmux [3-9]\.)"; then
        tmux select-pane -t "$session_name:main.0" -T "PM-$team_num"
        tmux select-pane -t "$session_name:main.1" -T "Worker1"
        tmux select-pane -t "$session_name:main.2" -T "Worker2"
        tmux select-pane -t "$session_name:main.3" -T "Worker3"
        
        # ペインボーダーにタイトルを表示
        tmux set-option -t "$session_name" pane-border-status top
        tmux set-option -t "$session_name" pane-border-format "#{pane_index}: #{pane_title}"
    fi
    
    # ペイン構成の安定化を待つ
    sleep 0.5
    
    # PM（ペイン0:左上）にはopus、Worker（ペイン1:右上,2:左下,3:右下）にはsonnetを設定
    tmux send-keys -t "$session_name:main.0" "cd $PROJECT_ROOT && claude --model opus --permission-mode bypassPermissions" Enter
    sleep 0.5
    
    # Worker1（右上）、Worker2（左下）、Worker3（右下）
    for pane in 1 2 3; do
        tmux send-keys -t "$session_name:main.$pane" "cd $PROJECT_ROOT && claude --model sonnet --permission-mode bypassPermissions" Enter
        sleep 0.5
    done
}

# メイン処理
main() {
    echo -e "${YELLOW}構成:${NC}"
    echo "  👑 Boss (全体統括) - Opus 4"
    echo "  ├── Team1 [Frontend]"
    echo "  │   ├── PM-1 (Opus 4)"
    echo "  │   └── Worker×3 (Sonnet)"
    echo "  ├── Team2 [Backend]"
    echo "  │   ├── PM-2 (Opus 4)"
    echo "  │   └── Worker×3 (Sonnet)"
    echo "  └── Team3 [DevOps]"
    echo "      ├── PM-3 (Opus 4)"
    echo "      └── Worker×3 (Sonnet)"
    echo ""
    
    # クリーンアップ
    cleanup_sessions
    
    # セッション作成
    create_boss_session
    create_team_session 1 "Frontend"
    create_team_session 2 "Backend"
    create_team_session 3 "DevOps"
    
    # 自動的にBypassモードで起動
    echo -e "${GREEN}✅ 全エージェントがBypassモードで自動起動します${NC}"
    sleep 2
    
    # 起動完了（モデル設定は各claudeコマンドで指定）
    
    # 既存機能の初期化
    echo -e "${YELLOW}🔧 システム初期化中...${NC}"
    
    # メモリシステム
    if [ -f "$PROJECT_ROOT/scripts/memory_manager.py" ]; then
        python3 "$PROJECT_ROOT/scripts/memory_manager.py" save --agent SYSTEM --message "CCTeam v0.1.16起動 (階層構造版)" 2>/dev/null || true
    fi
    
    # エラーループ検出
    if [ -f "$PROJECT_ROOT/scripts/error_loop_detector.py" ]; then
        python3 "$PROJECT_ROOT/scripts/error_loop_detector.py" start --all-teams >/dev/null 2>&1 &
    fi
    
    echo ""
    echo -e "${GREEN}✅ CCTeam起動完了！${NC}"
    echo ""
    echo -e "${BLUE}接続方法:${NC}"
    echo -e "  Boss:  ${YELLOW}tmux attach -t ccteam-boss${NC}"
    echo -e "  Team1: ${YELLOW}tmux attach -t ccteam-1${NC} (Frontend)"
    echo -e "  Team2: ${YELLOW}tmux attach -t ccteam-2${NC} (Backend)"
    echo -e "  Team3: ${YELLOW}tmux attach -t ccteam-3${NC} (DevOps)"
    echo ""
    echo -e "${BLUE}通信方法:${NC}"
    echo -e "  Boss宛:    ${YELLOW}ccsend boss \"メッセージ\"${NC}"
    echo -e "  PM宛:      ${YELLOW}ccsend pm1 \"メッセージ\"${NC}"
    echo -e "  Worker宛:  ${YELLOW}ccsend worker1-1 \"メッセージ\"${NC}"
    echo ""
    echo -e "${YELLOW}📖 使い方:${NC}"
    echo -e "  1. Bossに要件を伝える: ${CYAN}ccsend boss \"@requirements を読んで作業開始\"${NC}"
    echo -e "  2. または手動初期化: ${CYAN}./scripts/smart-init.sh${NC}"
    echo ""
    echo -e "${GREEN}準備完了！${NC}"
}

# 実行
main "$@"