#!/bin/bash
# CCTeam ログクリーンアップスクリプト
# 古いログファイルを定期的に削除

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 設定
LOG_DIR="$PROJECT_ROOT/logs"
ARCHIVE_DIR="$PROJECT_ROOT/archive"
MAX_AGE_LOGS=7        # 通常ログの保持期間（日）
MAX_AGE_ARCHIVE=30    # アーカイブの保持期間（日）

echo -e "${BLUE}🧹 CCTeam ログクリーンアップ${NC}"
echo "================================"

# クリーンアップ対象
declare -A CLEANUP_TARGETS=(
    ["logs/*.jsonl"]=7
    ["logs/*.json"]=7
    ["logs/*_test.log"]=3
    ["logs/test_*.log"]=3
    ["archive/reports/health_check_*.md"]=14
    ["worktrees/*/logs/*.log"]=7
)

TOTAL_DELETED=0
TOTAL_SIZE_FREED=0

# ファイルサイズを人間が読める形式に変換
human_readable_size() {
    local size=$1
    if (( size > 1073741824 )); then
        echo "$(( size / 1073741824 ))GB"
    elif (( size > 1048576 )); then
        echo "$(( size / 1048576 ))MB"
    elif (( size > 1024 )); then
        echo "$(( size / 1024 ))KB"
    else
        echo "${size}B"
    fi
}

# クリーンアップ実行
for pattern in "${!CLEANUP_TARGETS[@]}"; do
    local max_age="${CLEANUP_TARGETS[$pattern]}"
    echo -e "\n${YELLOW}検索中: $pattern (${max_age}日以上前)${NC}"
    
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            local file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
            local file_age=$(find "$file" -mtime +${max_age} | wc -l)
            
            if [ $file_age -gt 0 ]; then
                echo -e "  削除: $(basename "$file") ($(human_readable_size $file_size))"
                rm -f "$file"
                ((TOTAL_DELETED++))
                ((TOTAL_SIZE_FREED+=file_size))
            fi
        fi
    done < <(find "$PROJECT_ROOT" -path "$PROJECT_ROOT/$pattern" -print0 2>/dev/null)
done

# 空のログディレクトリを削除
echo -e "\n${YELLOW}空のディレクトリを削除中...${NC}"
find "$PROJECT_ROOT/logs" -type d -empty -delete 2>/dev/null || true
find "$PROJECT_ROOT/archive" -type d -empty -delete 2>/dev/null || true

# 結果表示
echo -e "\n${GREEN}=== クリーンアップ完了 ===${NC}"
echo "削除されたファイル: $TOTAL_DELETED 個"
echo "解放されたディスク容量: $(human_readable_size $TOTAL_SIZE_FREED)"

# 現在の状態
echo -e "\n${BLUE}📊 現在のディスク使用状況:${NC}"
if [ -d "$LOG_DIR" ]; then
    echo "logs/: $(du -sh "$LOG_DIR" 2>/dev/null | cut -f1)"
fi
if [ -d "$ARCHIVE_DIR" ]; then
    echo "archive/: $(du -sh "$ARCHIVE_DIR" 2>/dev/null | cut -f1)"
fi

# cron設定の提案
if [ "$TOTAL_DELETED" -gt 0 ]; then
    echo -e "\n${GREEN}💡 定期実行を推奨:${NC}"
    echo "crontabに以下を追加:"
    echo "0 3 * * * cd $PROJECT_ROOT && ./scripts/log-cleanup.sh"
fi