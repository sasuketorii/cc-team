#!/bin/bash
# 通知管理システム
# 複数のスクリプトから利用される通知機能

set -euo pipefail

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログディレクトリ
LOG_DIR="${LOG_DIR:-$(dirname "$0")/../logs}"
mkdir -p "$LOG_DIR"

# 通知送信
send_notification() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # レベルに応じた色分け
    case $level in
        "ERROR")
            echo -e "${RED}[ERROR] $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARNING] $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}[INFO] $message${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS] $message${NC}"
            ;;
        *)
            echo "[UNKNOWN] $message"
            ;;
    esac
    
    # ログファイルに記録
    echo "[$timestamp] [$level] $message" >> "$LOG_DIR/notifications.log"
}

# イベントログ記録
log_event() {
    local event_type=$1
    local event_data=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # イベントログファイルに記録
    echo "[$timestamp] [$event_type] $event_data" >> "$LOG_DIR/events.log"
    
    # 重要なイベントは通知も送信
    case $event_type in
        "SYSTEM_START"|"SYSTEM_STOP")
            send_notification "INFO" "$event_type: $event_data"
            ;;
        "ERROR"|"CRITICAL")
            send_notification "ERROR" "$event_type: $event_data"
            ;;
        "WARNING")
            send_notification "WARNING" "$event_type: $event_data"
            ;;
    esac
}

# エラー通知ヘルパー
notify_error() {
    send_notification "ERROR" "$1"
}

# 警告通知ヘルパー
notify_warning() {
    send_notification "WARNING" "$1"
}

# 情報通知ヘルパー
notify_info() {
    send_notification "INFO" "$1"
}

# 成功通知ヘルパー
notify_success() {
    send_notification "SUCCESS" "$1"
}

# システム通知（macOS対応）
system_notification() {
    local title=$1
    local message=$2
    
    # macOSの場合
    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "display notification \"$message\" with title \"$title\""
    fi
    
    # Linuxでnotify-sendが利用可能な場合
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$title" "$message"
    fi
}

# エクスポート
export -f send_notification
export -f log_event
export -f notify_error
export -f notify_warning
export -f notify_info
export -f notify_success
export -f system_notification