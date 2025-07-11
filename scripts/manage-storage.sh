#!/bin/bash
# CCTeam ストレージ管理スクリプト

# カラー定義を読み込み
source "$(dirname "${BASH_SOURCE[0]}")/common/colors.sh"

# プロジェクトルート
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 使用状況を表示
show_usage() {
    echo -e "${CYAN}=== CCTeam Storage Usage ===${NC}"
    echo ""
    
    # ログサイズ
    if [ -d "$PROJECT_ROOT/.claude/logs" ]; then
        LOG_SIZE=$(du -sh "$PROJECT_ROOT/.claude/logs" 2>/dev/null | cut -f1)
        LOG_COUNT=$(find "$PROJECT_ROOT/.claude/logs" -name "*.log" | wc -l)
        echo -e "${BLUE}Logs:${NC} $LOG_SIZE ($LOG_COUNT files)"
    fi
    
    # メモリDBサイズ
    if [ -f "$PROJECT_ROOT/memory/ccteam_memory.db" ]; then
        DB_SIZE=$(du -sh "$PROJECT_ROOT/memory/ccteam_memory.db" | cut -f1)
        RECORD_COUNT=$(sqlite3 "$PROJECT_ROOT/memory/ccteam_memory.db" "SELECT COUNT(*) FROM conversations;" 2>/dev/null || echo "0")
        echo -e "${BLUE}Memory DB:${NC} $DB_SIZE ($RECORD_COUNT conversations)"
    fi
    
    # 決定文書
    if [ -d "$PROJECT_ROOT/.claude/shared/decisions" ]; then
        DEC_SIZE=$(du -sh "$PROJECT_ROOT/.claude/shared/decisions" | cut -f1)
        DEC_COUNT=$(find "$PROJECT_ROOT/.claude/shared/decisions" -name "*.md" | wc -l)
        echo -e "${BLUE}Decisions:${NC} $DEC_SIZE ($DEC_COUNT documents)"
    fi
    
    echo ""
}

# ログクリーンアップ
clean_logs() {
    local days=${1:-7}
    echo -e "${YELLOW}Cleaning logs older than $days days...${NC}"
    
    # バックアップ作成
    local backup_dir="$PROJECT_ROOT/.claude/logs/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # 古いログを移動
    find "$PROJECT_ROOT/.claude/logs" -name "*.log" -mtime +$days -exec mv {} "$backup_dir/" \; 2>/dev/null
    
    # 空のバックアップディレクトリは削除
    rmdir "$backup_dir" 2>/dev/null || true
    
    echo -e "${GREEN}✅ Log cleanup completed${NC}"
}

# メモリDBの最適化
optimize_memory() {
    echo -e "${YELLOW}Optimizing memory database...${NC}"
    
    if [ -f "$PROJECT_ROOT/memory/ccteam_memory.db" ]; then
        # バックアップ
        cp "$PROJECT_ROOT/memory/ccteam_memory.db" "$PROJECT_ROOT/memory/ccteam_memory.db.backup"
        
        # VACUUM実行
        sqlite3 "$PROJECT_ROOT/memory/ccteam_memory.db" "VACUUM;"
        
        # 古い会話を削除（30日以上前）
        sqlite3 "$PROJECT_ROOT/memory/ccteam_memory.db" "DELETE FROM conversations WHERE datetime(timestamp) < datetime('now', '-30 days');"
        
        echo -e "${GREEN}✅ Memory optimization completed${NC}"
    else
        echo -e "${RED}❌ Memory database not found${NC}"
    fi
}

# メモリDBリセット
reset_memory() {
    echo -e "${RED}⚠️  WARNING: This will reset all memory data!${NC}"
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        # バックアップ
        if [ -f "$PROJECT_ROOT/memory/ccteam_memory.db" ]; then
            mv "$PROJECT_ROOT/memory/ccteam_memory.db" "$PROJECT_ROOT/memory/ccteam_memory.db.backup-$(date +%Y%m%d-%H%M%S)"
        fi
        
        # 新規作成
        sqlite3 "$PROJECT_ROOT/memory/ccteam_memory.db" << EOF
CREATE TABLE conversations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    agent TEXT,
    content TEXT,
    context TEXT
);

CREATE TABLE learned_patterns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pattern TEXT,
    context TEXT,
    usage_count INTEGER DEFAULT 1
);

CREATE TABLE project_contexts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key TEXT UNIQUE,
    value TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
EOF
        
        echo -e "${GREEN}✅ Memory database reset completed${NC}"
    else
        echo -e "${YELLOW}Cancelled${NC}"
    fi
}

# 自動クリーンアップ設定
setup_auto_cleanup() {
    echo -e "${CYAN}Setting up automatic cleanup...${NC}"
    
    # crontab設定を生成
    local cron_cmd="0 2 * * 0 $PROJECT_ROOT/scripts/manage-storage.sh auto"
    
    echo "Add this to your crontab (crontab -e):"
    echo "$cron_cmd"
    echo ""
    echo "This will run cleanup every Sunday at 2 AM"
}

# 自動実行モード
auto_cleanup() {
    echo "[$(date)] Starting automatic cleanup..." >> "$PROJECT_ROOT/.claude/logs/cleanup.log"
    clean_logs 7
    optimize_memory
    show_usage >> "$PROJECT_ROOT/.claude/logs/cleanup.log"
}

# メイン処理
case "${1:-usage}" in
    usage)
        show_usage
        ;;
    clean-logs)
        clean_logs "${2:-7}"
        ;;
    optimize)
        optimize_memory
        ;;
    reset)
        reset_memory
        ;;
    auto-setup)
        setup_auto_cleanup
        ;;
    auto)
        auto_cleanup
        ;;
    *)
        echo "Usage: $0 {usage|clean-logs [days]|optimize|reset|auto-setup|auto}"
        exit 1
        ;;
esac