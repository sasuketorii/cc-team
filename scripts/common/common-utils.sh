#!/bin/bash
# CCTeam共通ユーティリティ v0.1.5
# 全スクリプトで使用する共通関数とユーティリティ

# 一度だけ定義（多重読み込み防止）
if [ -n "${CCTEAM_COMMON_UTILS_LOADED}" ]; then
    return 0
fi
export CCTEAM_COMMON_UTILS_LOADED=1

# カラー定義を読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/colors.sh"

# プロジェクトルート自動検出
detect_project_root() {
    local current="$PWD"
    while [ "$current" != "/" ]; do
        if [ -f "$current/package.json" ] && [ -d "$current/scripts" ]; then
            echo "$current"
            return 0
        fi
        current=$(dirname "$current")
    done
    return 1
}

# プロジェクトルートを設定
if [ -z "$PROJECT_ROOT" ]; then
    export PROJECT_ROOT=$(detect_project_root)
    if [ -z "$PROJECT_ROOT" ]; then
        echo -e "${RED}❌ エラー: CCTeamプロジェクトルートが見つかりません${NC}" >&2
        exit 1
    fi
fi

# ログディレクトリを作成
mkdir -p "$PROJECT_ROOT/logs"

# 統一ログ関数
cclog() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="${CCTEAM_LOG_FILE:-$PROJECT_ROOT/logs/ccteam.log}"
    
    # ログファイルに記録
    echo "[$timestamp] [$level] $message" >> "$log_file"
    
    # 構造化ログ（JSON形式）も保存
    if command -v jq &>/dev/null; then
        echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"message\":\"$message\"}" >> "$log_file.json"
    fi
    
    # Python構造化ロガーとの統合
    if [ -f "$PROJECT_ROOT/scripts/structured_logger.py" ] && command -v python3 &>/dev/null; then
        python3 "$PROJECT_ROOT/scripts/structured_logger.py" \
            --log \
            --level="$level" \
            --message="$message" \
            --component="${CCTEAM_COMPONENT:-general}" \
            2>/dev/null || true
    fi
    
    # コンソール出力
    case $level in
        "INFO")    echo -e "${BLUE}ℹ️${NC}  $message" ;;
        "SUCCESS") echo -e "${GREEN}✅${NC} $message" ;;
        "WARN")    echo -e "${YELLOW}⚠️${NC}  $message" ;;
        "ERROR")   echo -e "${RED}❌${NC} $message" ;;
        "DEBUG")   
            if [ "${CCTEAM_DEBUG}" = "true" ]; then
                echo -e "${PURPLE}🔍${NC} $message"
            fi
            ;;
    esac
}

# 依存関係チェック
check_dependencies() {
    local deps=("tmux" "git" "jq")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        cclog "ERROR" "必要なコマンドがありません: ${missing[*]}"
        cclog "INFO" "インストール: brew install ${missing[*]} (macOS)"
        return 1
    fi
    return 0
}

# エラーハンドリング
set_error_trap() {
    trap 'handle_error $? $LINENO' ERR
}

handle_error() {
    local exit_code=$1
    local line_no=$2
    cclog "ERROR" "エラーが発生しました (終了コード: $exit_code, 行: $line_no)"
    
    # スタックトレースを表示
    local frame=0
    while caller $frame; do
        ((frame++))
    done
    
    return $exit_code
}

# 条件付き待機（ポーリング）
wait_for_condition() {
    local condition_cmd="$1"
    local timeout=${2:-10}
    local interval=${3:-0.1}
    local elapsed=0
    
    while ! eval "$condition_cmd"; do
        if (( $(echo "$elapsed >= $timeout" | bc -l) )); then
            return 1
        fi
        sleep $interval
        elapsed=$(echo "$elapsed + $interval" | bc -l)
    done
    
    return 0
}

# tmuxペイン準備待機
wait_for_tmux_pane() {
    local session="$1"
    local pane="$2"
    local pattern="${3:-claude>}"
    
    wait_for_condition \
        "tmux capture-pane -t '$session:$pane' -p 2>/dev/null | grep -q '$pattern'" \
        5 0.1
}

# プロセス起動待機
wait_for_process() {
    local process_name="$1"
    local timeout=${2:-10}
    
    wait_for_condition "pgrep -f '$process_name' >/dev/null" "$timeout"
}

# 安全なファイル作成
secure_file_create() {
    local file="$1"
    local content="$2"
    local perms="${3:-600}"
    
    # 安全な一時ファイル作成
    local temp_file=$(mktemp)
    echo "$content" > "$temp_file"
    
    # アトミックな移動
    mv "$temp_file" "$file"
    chmod "$perms" "$file"
}

# プログレスバー表示
show_progress() {
    local current=$1
    local total=$2
    local width=50
    
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    
    printf "\r["
    printf "%${filled}s" | tr ' ' '='
    printf "%$((width - filled))s" | tr ' ' '-'
    printf "] %3d%%" $percent
    
    [ $current -eq $total ] && echo ""
}

# 確認プロンプト
confirm() {
    local prompt="${1:-続行しますか？}"
    local default="${2:-n}"
    
    local yn
    if [ "$default" = "y" ]; then
        read -p "$prompt [Y/n] " yn
        yn=${yn:-y}
    else
        read -p "$prompt [y/N] " yn
        yn=${yn:-n}
    fi
    
    [[ "$yn" =~ ^[Yy]$ ]]
}

# ユーティリティ関数のエクスポート
export -f cclog
export -f check_dependencies
export -f wait_for_condition
export -f wait_for_tmux_pane
export -f wait_for_process
export -f secure_file_create
export -f show_progress
export -f confirm