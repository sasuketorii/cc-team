#!/bin/bash
# CCTeam起動スクリプト v0.1.5
# DevContainer & Worktree自動化対応版

VERSION="0.1.5"
SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 共通カラー定義を読み込み
source "$SCRIPT_DIR/common/colors.sh"

# ログファイル
LOG_FILE="$PROJECT_ROOT/logs/ccteam-launch.log"
mkdir -p "$PROJECT_ROOT/logs"

# エラーハンドリング
set -euo pipefail
trap 'error_handler $? $LINENO' ERR

error_handler() {
    local exit_code=$1
    local line_no=$2
    echo -e "${RED}❌ エラーが発生しました${NC}" | tee -a "$LOG_FILE"
    echo -e "${YELLOW}   詳細: 処理中にエラーが発生しました${NC}" | tee -a "$LOG_FILE"
    echo -e "${YELLOW}   対処: ログファイルを確認してください: $LOG_FILE${NC}" | tee -a "$LOG_FILE"
    cleanup
    exit $exit_code
}

# ログ関数
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case $level in
        "INFO")  echo -e "${BLUE}[INFO]${NC} $message" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
    esac
}

# DevContainer環境チェック
check_devcontainer_env() {
    if [ "${CCTEAM_DEV_CONTAINER:-false}" = "true" ]; then
        log "INFO" "🐳 DevContainer環境を検出しました"
        
        # Worktree自動セットアップ
        if [ "${CCTEAM_AUTO_WORKTREE:-false}" = "true" ] && [ ! -f "$PROJECT_ROOT/worktrees/.auto-setup-done" ]; then
            log "INFO" "🌳 Worktree自動セットアップを開始します..."
            
            # requirements確認
            if [ -d "$PROJECT_ROOT/requirements" ] && [ "$(ls -A $PROJECT_ROOT/requirements/*.md 2>/dev/null)" ]; then
                echo -e "${YELLOW}📋 要件定義を検出しました。Worktreeを自動作成しますか？ (Y/n)${NC}"
                read -r response
                
                if [[ ! "$response" =~ ^[Nn]$ ]]; then
                    if [ -f "$SCRIPT_DIR/worktree-auto-manager.sh" ]; then
                        "$SCRIPT_DIR/worktree-auto-manager.sh" create-project-worktrees
                        touch "$PROJECT_ROOT/worktrees/.auto-setup-done"
                    else
                        log "WARN" "worktree-auto-manager.shが見つかりません"
                    fi
                fi
            fi
        fi
        
        # Boss v2モード有効化
        export BOSS_VERSION="2.0"
        export BOSS_AUTO_WORKTREE="true"
        export BOSS_NOTIFICATION="true"
        log "INFO" "Boss v2モードを有効化しました"
    fi
}

# 通知マネージャーのロード
load_notification_manager() {
    if [ -f "$SCRIPT_DIR/notification-manager.sh" ]; then
        source "$SCRIPT_DIR/notification-manager.sh"
        log "INFO" "通知マネージャーをロードしました"
        return 0
    else
        log "WARN" "通知マネージャーが見つかりません"
        return 1
    fi
}

# tmuxセッション確認
check_existing_session() {
    if tmux has-session -t ccteam 2>/dev/null; then
        echo -e "${YELLOW}⚠️  既存のCCTeamセッションが見つかりました${NC}"
        echo ""
        echo "オプションを選択してください："
        echo "  1) 既存のセッションに接続"
        echo "  2) 既存のセッションを終了して新規起動"
        echo "  3) キャンセル"
        echo ""
        echo -n "選択 (1-3): "
        read -r choice
        
        case $choice in
            1)
                log "INFO" "既存のセッションに接続します"
                tmux attach -t ccteam
                exit 0
                ;;
            2)
                log "INFO" "既存のセッションを終了します"
                tmux kill-session -t ccteam 2>/dev/null || true
                sleep 1
                ;;
            3)
                log "INFO" "キャンセルしました"
                exit 0
                ;;
            *)
                log "ERROR" "無効な選択です"
                exit 1
                ;;
        esac
    fi
}

# スタートアップバナー表示
show_startup_banner() {
    clear
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║      ██████╗ ██████╗████████╗███████╗ █████╗ ███╗   ███╗     ║
    ║     ██╔════╝██╔════╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║     ║
    ║     ██║     ██║        ██║   █████╗  ███████║██╔████╔██║     ║
    ║     ██║     ██║        ██║   ██╔══╝  ██╔══██║██║╚██╔╝██║     ║
    ║     ╚██████╗╚██████╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║     ║
    ║      ╚═════╝ ╚═════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝     ║
    ║                                                               ║
    ║              Virtual System Development Company               ║
    ║                     by SasukeTorii                           ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
    
    echo ""
    echo -e "${CYAN}Version: $VERSION${NC}"
    echo -e "${GREEN}DevContainer対応 & Worktree自動管理${NC}"
    echo ""
}

# メイン起動処理
launch_ccteam() {
    log "INFO" "=== CCTeam v$VERSION 起動開始 ==="
    
    # tmuxセッション作成
    log "INFO" "tmuxセッションを作成中..."
    tmux new-session -d -s ccteam -n main 2>&1 | tee -a "$LOG_FILE" || {
        log "ERROR" "tmuxセッションの作成に失敗しました"
        return 1
    }
    
    # ペイン分割（2x2グリッド）
    tmux split-window -t ccteam:main -h
    tmux split-window -t ccteam:main.0 -v
    tmux split-window -t ccteam:main.2 -v
    
    # ペインタイトル設定
    tmux select-pane -t ccteam:main.0 -T "Boss"
    tmux select-pane -t ccteam:main.1 -T "Worker1 (Frontend)"
    tmux select-pane -t ccteam:main.2 -T "Worker2 (Backend)"
    tmux select-pane -t ccteam:main.3 -T "Worker3 (QA/DevOps)"
    
    # 各ペインでClaude起動
    log "INFO" "各エージェントを起動中..."
    
    # Boss起動（v2モード）
    tmux send-keys -t ccteam:main.0 "cd $PROJECT_ROOT" C-m
    tmux send-keys -t ccteam:main.0 "export BOSS_VERSION=$BOSS_VERSION" C-m
    tmux send-keys -t ccteam:main.0 "export BOSS_AUTO_WORKTREE=$BOSS_AUTO_WORKTREE" C-m
    tmux send-keys -t ccteam:main.0 "claude --dangerously-skip-permissions" C-m
    
    # Workers起動
    for i in 1 2 3; do
        tmux send-keys -t ccteam:main.$i "cd $PROJECT_ROOT" C-m
        tmux send-keys -t ccteam:main.$i "claude --dangerously-skip-permissions" C-m
    done
    
    # tmuxオプション設定
    tmux set-option -t ccteam -g mouse on
    tmux set-option -t ccteam -g pane-border-status top
    tmux set-option -t ccteam -g pane-border-format "#{pane_title}"
    
    log "SUCCESS" "CCTeamセッションを作成しました"
    
    # 起動完了通知
    if load_notification_manager; then
        notify_info "CCTeam v$VERSION が起動しました"
    fi
}

# 認証ガイド表示
show_auth_guide() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}📋 認証手順（各エージェントで実行）${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "各ペインで以下の選択を行ってください："
    echo ""
    echo -e "${GREEN}1. Bypass Permissions承認${NC}"
    echo "   選択肢が表示されたら: ${CYAN}2${NC} (Yes, enable all)"
    echo ""
    echo -e "${GREEN}2. Boss（左上ペイン）での初期設定${NC}"
    
    if [ "${BOSS_VERSION:-1.0}" = "2.0" ]; then
        echo "   ${CYAN}Boss v2.0モードで起動しています${NC}"
        echo "   - Worktree自動管理機能: ${GREEN}有効${NC}"
        echo "   - 通知機能: ${GREEN}有効${NC}"
        echo ""
        echo "   初期コマンド例:"
        echo "   ${CYAN}requirementsフォルダの要件を読み込んで、プロジェクトを開始してください${NC}"
    else
        echo "   初期コマンド例:"
        echo "   ${CYAN}instructions/boss.mdの指示に従って動作してください${NC}"
    fi
    echo ""
    echo -e "${GREEN}3. Workers（その他のペイン）${NC}"
    echo "   各Workerの指示書に従って待機"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 接続情報表示
show_connection_info() {
    echo ""
    echo -e "${GREEN}✅ CCTeam起動完了！${NC}"
    echo ""
    echo "セッションに接続するには:"
    echo -e "  ${CYAN}tmux attach -t ccteam${NC}"
    echo ""
    echo "便利なコマンド:"
    echo "  ${CYAN}ccsend <agent> \"message\"${NC} - エージェントにメッセージ送信"
    echo "  ${CYAN}ccstatus${NC}                  - ステータス確認"
    echo "  ${CYAN}ccmon${NC}                     - セッション監視"
    echo "  ${CYAN}cckill${NC}                    - セッション終了"
    
    if [ "${BOSS_VERSION:-1.0}" = "2.0" ]; then
        echo ""
        echo "Boss v2.0 新機能:"
        echo "  ${CYAN}wts${NC}                       - Worktree状態確認"
        echo "  ${CYAN}./scripts/worktree-auto-manager.sh${NC} - Worktree管理"
    fi
}

# クリーンアップ処理
cleanup() {
    log "INFO" "クリーンアップ処理を実行中..."
}

# ヘルプ表示
show_help() {
    cat << EOF
${BLUE}CCTeam起動スクリプト v$VERSION${NC}

${GREEN}使用方法:${NC}
  $SCRIPT_NAME [options]

${GREEN}オプション:${NC}
  -h, --help        このヘルプを表示
  -v, --version     バージョン情報を表示
  -r, --restart     既存セッションを終了して再起動
  -a, --attach      起動後自動的にセッションに接続
  -q, --quiet       静かに起動（バナー非表示）
  --v3              v3互換モードで起動（Boss v1.0）
  --batch           バッチモード（対話的プロンプトなし）

${GREEN}環境変数:${NC}
  BOSS_VERSION      Bossのバージョン（1.0 or 2.0）
  CCTEAM_DEV_CONTAINER  DevContainer環境フラグ
  CCTEAM_AUTO_WORKTREE  Worktree自動セットアップ

${GREEN}例:${NC}
  # 通常起動
  $SCRIPT_NAME

  # 再起動して自動接続
  $SCRIPT_NAME -r -a

  # v3互換モード
  $SCRIPT_NAME --v3

EOF
}

# メイン処理
main() {
    local attach_after=false
    local quiet_mode=false
    local restart_mode=false
    local batch_mode=false
    local v3_mode=false
    
    # オプション解析
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                echo "CCTeam Launch Script v$VERSION"
                exit 0
                ;;
            -r|--restart)
                restart_mode=true
                shift
                ;;
            -a|--attach)
                attach_after=true
                shift
                ;;
            -q|--quiet)
                quiet_mode=true
                shift
                ;;
            --v3)
                v3_mode=true
                export BOSS_VERSION="1.0"
                shift
                ;;
            --batch)
                batch_mode=true
                shift
                ;;
            *)
                log "ERROR" "不明なオプション: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # v3モードチェック
    if [ "$v3_mode" = true ]; then
        log "INFO" "v3互換モードで起動します"
        # v3スクリプトにフォールバック
        if [ -f "$SCRIPT_DIR/launch-ccteam-v3.sh" ]; then
            exec "$SCRIPT_DIR/launch-ccteam-v3.sh" "$@"
        else
            log "ERROR" "v3スクリプトが見つかりません"
            exit 1
        fi
    fi
    
    # DevContainer環境チェック
    check_devcontainer_env
    
    # 通知マネージャーロード
    load_notification_manager
    
    # バナー表示
    if [ "$quiet_mode" = false ]; then
        show_startup_banner
    fi
    
    # 再起動モード
    if [ "$restart_mode" = true ]; then
        log "INFO" "既存のセッションを終了します"
        tmux kill-session -t ccteam 2>/dev/null || true
        sleep 1
    else
        # 既存セッション確認（バッチモードでない場合）
        if [ "$batch_mode" = false ]; then
            check_existing_session
        fi
    fi
    
    # CCTeam起動
    if launch_ccteam; then
        # 認証ガイド表示
        if [ "$quiet_mode" = false ]; then
            show_auth_guide
            show_connection_info
        fi
        
        # 自動接続
        if [ "$attach_after" = true ]; then
            log "INFO" "セッションに接続します"
            sleep 2
            tmux attach -t ccteam
        fi
    else
        log "ERROR" "CCTeamの起動に失敗しました"
        exit 1
    fi
}

# スクリプト実行
main "$@"