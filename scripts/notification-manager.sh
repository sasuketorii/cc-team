#!/bin/bash
# CCTeam通知マネージャー v1.0.0
# Claude Code hooks連携・マルチプラットフォーム対応

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# セキュリティユーティリティを読み込み
if [ -f "$SCRIPT_DIR/security-utils.sh" ]; then
    source "$SCRIPT_DIR/security-utils.sh"
fi

# 共通カラー定義を読み込み
source "$SCRIPT_DIR/common/colors.sh"

# 通知タイプ定義
NOTIFY_SUCCESS="task_complete"
NOTIFY_ERROR="error"
NOTIFY_APPROVAL="approval_needed"
NOTIFY_INFO="info"
NOTIFY_WARNING="warning"

# ログ設定
LOG_DIR="$PROJECT_ROOT/logs"
NOTIFICATION_LOG="$LOG_DIR/notifications.log"
mkdir -p "$LOG_DIR"

# 通知設定の読み込み
NOTIFICATION_CONFIG="$HOME/.ccteam/notification-config.json"
NOTIFICATION_HANDLER="$HOME/.ccteam/notification-handler.sh"

# ログ関数
log_notification() {
    local type=$1
    local title=$2
    local message=$3
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$type] $title: $message" >> "$NOTIFICATION_LOG"
}

# OS検出関数
detect_os() {
    case "$OSTYPE" in
        darwin*)  echo "macos" ;;
        linux*)   echo "linux" ;;
        msys*|cygwin*|mingw*) echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

# macOS通知
notify_macos() {
    local title=$1
    local message=$2
    local type=$3
    
    # サウンドの選択
    local sound="Glass"
    case $type in
        "$NOTIFY_ERROR") sound="Basso" ;;
        "$NOTIFY_APPROVAL") sound="Hero" ;;
        "$NOTIFY_WARNING") sound="Funk" ;;
    esac
    
    # AppleScriptで通知
    osascript -e "display notification \"$message\" with title \"CCTeam: $title\" sound name \"$sound\"" 2>/dev/null || true
    
    # terminal-notifierがインストールされている場合
    if command -v terminal-notifier &> /dev/null; then
        terminal-notifier -title "CCTeam: $title" -message "$message" -sound "$sound" -group "ccteam" 2>/dev/null || true
    fi
}

# Linux/WSL通知
notify_linux() {
    local title=$1
    local message=$2
    local type=$3
    
    # アイコンと緊急度の設定
    local icon="terminal"
    local urgency="normal"
    
    case $type in
        "$NOTIFY_ERROR")
            icon="error"
            urgency="critical"
            ;;
        "$NOTIFY_APPROVAL")
            icon="info"
            urgency="critical"
            ;;
        "$NOTIFY_WARNING")
            icon="warning"
            urgency="high"
            ;;
        "$NOTIFY_SUCCESS")
            icon="checkbox-checked"
            urgency="low"
            ;;
    esac
    
    # notify-sendで通知
    if command -v notify-send &> /dev/null; then
        notify-send "CCTeam: $title" "$message" -i "$icon" -u "$urgency" -t 10000 2>/dev/null || true
    fi
    
    # WSLの場合、Windows側にも通知を試みる
    if grep -qi microsoft /proc/version 2>/dev/null; then
        # PowerShellで通知（WSL2）
        if command -v powershell.exe &> /dev/null; then
            local ps_script="[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null; \
            \$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02); \
            \$template.SelectSingleNode('//text[@id=\"1\"]').InnerText = 'CCTeam: $title'; \
            \$template.SelectSingleNode('//text[@id=\"2\"]').InnerText = '$message'; \
            \$toast = [Windows.UI.Notifications.ToastNotification]::new(\$template); \
            [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('CCTeam').Show(\$toast)"
            
            powershell.exe -Command "$ps_script" 2>/dev/null || true
        fi
    fi
}

# Windows通知（Git Bash/MSYS2）
notify_windows() {
    local title=$1
    local message=$2
    local type=$3
    
    # msg.exeを使用（簡易通知）
    if command -v msg.exe &> /dev/null; then
        msg.exe "*" "/TIME:10" "CCTeam: $title - $message" 2>/dev/null || true
    fi
}

# Claude Code hooks連携
trigger_claude_hook() {
    local type=$1
    local title=$2
    local message=$3
    
    # Claude Code環境変数を設定
    export CLAUDE_CODE_SESSION_ID="${CLAUDE_CODE_SESSION_ID:-ccteam-$(date +%s)}"
    export CLAUDE_CODE_MESSAGE="$message"
    export CLAUDE_CODE_TITLE="$title"
    export CLAUDE_CODE_TYPE="$type"
    
    # カスタムハンドラーが存在する場合は実行
    if [ -x "$NOTIFICATION_HANDLER" ]; then
        "$NOTIFICATION_HANDLER" 2>&1 | tee -a "$NOTIFICATION_LOG" || true
    fi
}

# Webhook通知（Slack/Discord等）
send_webhook_notification() {
    local title=$1
    local message=$2
    local type=$3
    
    # 環境変数からWebhook URLを取得
    local webhook_url="${CCTEAM_WEBHOOK_URL:-}"
    
    if [ -z "$webhook_url" ]; then
        return 0
    fi
    
    # 色の設定（Slack用）
    local color="#36a64f"  # 緑（成功）
    case $type in
        "$NOTIFY_ERROR") color="#ff0000" ;;      # 赤
        "$NOTIFY_WARNING") color="#ff9900" ;;    # オレンジ
        "$NOTIFY_APPROVAL") color="#0099ff" ;;   # 青
    esac
    
    # JSONペイロード作成
    local payload
    
    # Slack形式
    if [[ "$webhook_url" == *"slack.com"* ]]; then
        payload=$(cat <<EOF
{
  "attachments": [{
    "color": "$color",
    "title": "CCTeam: $title",
    "text": "$message",
    "footer": "CCTeam Notification",
    "ts": $(date +%s)
  }]
}
EOF
)
    # Discord形式
    elif [[ "$webhook_url" == *"discord.com"* ]]; then
        payload=$(cat <<EOF
{
  "embeds": [{
    "title": "CCTeam: $title",
    "description": "$message",
    "color": $(printf "%d" 0x${color:1}),
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  }]
}
EOF
)
    # 汎用形式
    else
        payload=$(cat <<EOF
{
  "text": "CCTeam: $title\n$message",
  "type": "$type"
}
EOF
)
    fi
    
    # Webhook送信
    curl -X POST "$webhook_url" \
        -H "Content-Type: application/json" \
        -d "$payload" \
        -s -o /dev/null || true
}

# メイン通知送信関数
send_notification() {
    local type=$1
    local title=$2
    local message=$3
    local priority=${4:-normal}
    
    # ログ記録
    log_notification "$type" "$title" "$message"
    
    # コンソール出力
    case $type in
        "$NOTIFY_SUCCESS")
            echo -e "${GREEN}✅ [SUCCESS]${NC} $title: $message"
            ;;
        "$NOTIFY_ERROR")
            echo -e "${RED}❌ [ERROR]${NC} $title: $message"
            ;;
        "$NOTIFY_WARNING")
            echo -e "${YELLOW}⚠️  [WARNING]${NC} $title: $message"
            ;;
        "$NOTIFY_APPROVAL")
            echo -e "${BLUE}🔔 [APPROVAL]${NC} $title: $message"
            ;;
        *)
            echo -e "${BLUE}ℹ️  [INFO]${NC} $title: $message"
            ;;
    esac
    
    # OS別通知
    local os=$(detect_os)
    case $os in
        "macos")
            notify_macos "$title" "$message" "$type"
            ;;
        "linux")
            notify_linux "$title" "$message" "$type"
            ;;
        "windows")
            notify_windows "$title" "$message" "$type"
            ;;
    esac
    
    # Claude Code hooks
    trigger_claude_hook "$type" "$title" "$message"
    
    # Webhook通知
    send_webhook_notification "$title" "$message" "$type"
}

# 便利な通知関数

# タスク完了通知
notify_task_complete() {
    local task=$1
    send_notification "$NOTIFY_SUCCESS" "タスク完了" "$task"
}

# エラー通知
notify_error() {
    local error=$1
    send_notification "$NOTIFY_ERROR" "エラー発生" "$error" "critical"
}

# 警告通知
notify_warning() {
    local warning=$1
    send_notification "$NOTIFY_WARNING" "警告" "$warning" "high"
}

# 承認要求通知
notify_approval_needed() {
    local request=$1
    send_notification "$NOTIFY_APPROVAL" "承認が必要です" "$request" "critical"
}

# 情報通知
notify_info() {
    local info=$1
    send_notification "$NOTIFY_INFO" "情報" "$info"
}

# プログレス通知（連続的な進捗用）
notify_progress() {
    local current=$1
    local total=$2
    local task=$3
    
    local percentage=$((current * 100 / total))
    local message="$task: $current/$total ($percentage%)"
    
    # 25%ごとに通知
    if [ $((current % (total / 4))) -eq 0 ] || [ "$current" -eq "$total" ]; then
        send_notification "$NOTIFY_INFO" "進捗更新" "$message"
    fi
}

# バッチ通知（複数の通知をまとめる）
batch_notifications() {
    local title=$1
    shift
    local messages=("$@")
    
    local combined_message=""
    for msg in "${messages[@]}"; do
        combined_message+="• $msg\n"
    done
    
    send_notification "$NOTIFY_INFO" "$title" "${combined_message%\\n}"
}

# セットアップ関数
setup_notification_handler() {
    echo -e "${BLUE}🔔 通知ハンドラーをセットアップします${NC}"
    
    # ディレクトリ作成
    mkdir -p "$HOME/.ccteam"
    
    # 通知ハンドラー作成
    cat > "$NOTIFICATION_HANDLER" << 'EOF'
#!/bin/bash
# CCTeam Claude Code hooks通知ハンドラー

# 環境変数から情報取得
SESSION_ID=$CLAUDE_CODE_SESSION_ID
MESSAGE=$CLAUDE_CODE_MESSAGE
TITLE=$CLAUDE_CODE_TITLE
TYPE=$CLAUDE_CODE_TYPE

# ここにカスタム処理を追加
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Hook triggered: $TYPE - $TITLE" >> ~/.ccteam/hook-activity.log

# 追加の通知処理をここに実装
# 例: 特定のイベントでスクリプト実行、ログ収集等
EOF
    
    chmod +x "$NOTIFICATION_HANDLER"
    
    # 設定ファイル作成
    cat > "$NOTIFICATION_CONFIG" << EOF
{
  "version": "1.0.0",
  "enabled": true,
  "handlers": {
    "macos": {
      "terminal-notifier": true,
      "osascript": true
    },
    "linux": {
      "notify-send": true,
      "wsl-powershell": true
    },
    "webhook": {
      "enabled": false,
      "url": ""
    }
  },
  "filters": {
    "min_priority": "normal",
    "rate_limit": {
      "enabled": true,
      "max_per_minute": 10
    }
  }
}
EOF
    
    echo -e "${GREEN}✅ セットアップ完了${NC}"
    echo "設定ファイル: $NOTIFICATION_CONFIG"
    echo "ハンドラー: $NOTIFICATION_HANDLER"
}

# ヘルプ表示
show_help() {
    cat << EOF
${BLUE}CCTeam通知マネージャー v1.0.0${NC}

${GREEN}使用方法:${NC}
  source $(basename "$0")  # 関数をインポート
  
  # または直接実行
  $(basename "$0") <command> [args]

${GREEN}コマンド:${NC}
  test              - テスト通知を送信
  setup             - 通知ハンドラーをセットアップ
  help              - このヘルプを表示

${GREEN}関数（sourceした場合）:${NC}
  notify_task_complete "タスク名"
  notify_error "エラーメッセージ"
  notify_warning "警告メッセージ"
  notify_approval_needed "承認リクエスト"
  notify_info "情報メッセージ"
  notify_progress 50 100 "処理中"
  batch_notifications "タイトル" "メッセージ1" "メッセージ2"

${GREEN}環境変数:${NC}
  CCTEAM_WEBHOOK_URL  - Slack/Discord Webhook URL

${GREEN}例:${NC}
  # テスト通知
  $(basename "$0") test

  # スクリプト内で使用
  source $(basename "$0")
  notify_task_complete "ビルドが完了しました"

EOF
}

# テスト通知
test_notifications() {
    echo -e "${BLUE}🧪 通知テストを実行します${NC}"
    echo ""
    
    notify_info "通知システムのテストを開始します"
    
    notify_task_complete "テストタスクが正常に完了しました"
    
    notify_warning "これは警告通知のテストです"
    
    notify_error "エラー通知のテスト（実際のエラーではありません）"
    
    notify_approval_needed "承認通知のテスト - アクションは不要です"
    
    batch_notifications "バッチ通知テスト" \
        "複数のメッセージを" \
        "まとめて通知できます" \
        "便利な機能です"
    
    echo ""
    echo -e "${GREEN}✅ テスト完了${NC}"
    echo "ログ: $NOTIFICATION_LOG"
}

# スクリプトとして実行された場合の処理
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    case "${1:-help}" in
        "test")
            test_notifications
            ;;
        "setup")
            setup_notification_handler
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo -e "${RED}❌ エラー: 不明なコマンドです: '$1'${NC}"
            echo -e "${YELLOW}   利用可能なコマンド: test, setup, help${NC}"
            echo -e "${YELLOW}   詳細なヘルプを表示: $0 help${NC}"
            exit 1
            ;;
    esac
fi

# 関数をエクスポート（sourceされた場合用）
export -f send_notification
export -f notify_task_complete
export -f notify_error
export -f notify_warning
export -f notify_approval_needed
export -f notify_info
export -f notify_progress
export -f batch_notifications