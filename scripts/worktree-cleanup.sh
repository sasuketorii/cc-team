#!/bin/bash
# CCTeam Worktree自動クリーンアップ v0.1.5
# 完了したWorktreeの自動削除とディスク容量管理

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# セキュリティユーティリティを読み込み
source "$SCRIPT_DIR/security-utils.sh"

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 設定
WORKTREE_BASE="$PROJECT_ROOT/worktrees"
CLEANUP_LOG="$PROJECT_ROOT/logs/worktree-cleanup.log"
RETENTION_DAYS=7  # デフォルト保持期間（日）

# ログ関数
log() {
    local level=$1
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" >> "$CLEANUP_LOG"
}

# 使用方法表示
show_usage() {
    cat << EOF
${BLUE}CCTeam Worktree クリーンアップ v0.1.5${NC}

使用方法: worktree-cleanup.sh [command] [options]

コマンド:
  auto              マージ済みWorktreeを自動削除
  clean-old         指定日数以上古いWorktreeを削除
  clean-merged      マージ済みのWorktreeを削除
  clean-branch      特定のブランチのWorktreeを削除
  list-candidates   削除候補を表示（削除しない）
  status            クリーンアップ状況を表示

オプション:
  --days <N>        保持期間（デフォルト: 7日）
  --force           確認なしで削除
  --dry-run         削除せずに対象を表示
  --archive         削除前にアーカイブ作成

例:
  # マージ済みWorktreeを自動削除
  worktree-cleanup.sh auto
  
  # 14日以上古いWorktreeを削除
  worktree-cleanup.sh clean-old --days 14
  
  # 削除候補を確認
  worktree-cleanup.sh list-candidates
EOF
}

# Worktreeがマージ済みか確認
is_merged() {
    local branch=$1
    local base_branch=${2:-main}
    
    # リモートの最新状態を取得
    git fetch origin "$base_branch" --quiet 2>/dev/null || true
    
    # マージ済みブランチのリストに含まれるか確認
    if git branch -r --merged "origin/$base_branch" | grep -q "origin/$branch"; then
        return 0
    fi
    
    # ローカルでマージ済みか確認
    if git branch --merged "$base_branch" | grep -q "$branch"; then
        return 0
    fi
    
    return 1
}

# Worktreeの最終更新日を取得
get_worktree_age() {
    local worktree_path=$1
    
    if [ -d "$worktree_path/.git" ]; then
        # 最後のコミット日時を取得
        cd "$worktree_path"
        local last_commit=$(git log -1 --format=%ct 2>/dev/null || echo "0")
        local now=$(date +%s)
        local age_days=$(( (now - last_commit) / 86400 ))
        echo "$age_days"
    else
        echo "999"  # .gitがない場合は古いとみなす
    fi
}

# Worktreeをアーカイブ
archive_worktree() {
    local worktree_path=$1
    local branch_name=$2
    local archive_dir="$PROJECT_ROOT/archive/worktrees"
    
    mkdir -p "$archive_dir"
    local archive_name="$archive_dir/${branch_name//\//_}-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    echo -e "${BLUE}📦 Worktreeをアーカイブ中: $branch_name${NC}"
    tar -czf "$archive_name" -C "$(dirname "$worktree_path")" "$(basename "$worktree_path")" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ アーカイブ作成: $archive_name${NC}"
        log "INFO" "Archived worktree: $branch_name to $archive_name"
        return 0
    else
        echo -e "${RED}❌ アーカイブ作成失敗${NC}"
        return 1
    fi
}

# Worktreeを削除
remove_worktree() {
    local worktree_path=$1
    local branch_name=$2
    local archive=${3:-false}
    
    # セキュリティチェック
    if ! validate_path "$worktree_path" "$PROJECT_ROOT"; then
        log "ERROR" "Invalid worktree path: $worktree_path"
        return 1
    fi
    
    # アーカイブオプション
    if [ "$archive" = true ]; then
        archive_worktree "$worktree_path" "$branch_name"
    fi
    
    echo -e "${YELLOW}🗑️  Worktreeを削除: $branch_name${NC}"
    
    # Git worktree削除
    cd "$PROJECT_ROOT"
    git worktree remove "$worktree_path" --force 2>/dev/null || true
    
    # ブランチ削除（ローカル）
    git branch -D "$branch_name" 2>/dev/null || true
    
    log "INFO" "Removed worktree: $branch_name at $worktree_path"
    echo -e "${GREEN}✅ 削除完了${NC}"
}

# マージ済みWorktreeを自動削除
auto_cleanup() {
    local dry_run=${1:-false}
    local archive=${2:-false}
    
    echo -e "${BLUE}🔍 マージ済みWorktreeを検索中...${NC}"
    log "INFO" "=== Auto cleanup started ==="
    
    local deleted_count=0
    local skipped_count=0
    
    git worktree list | while read -r line; do
        local path=$(echo "$line" | awk '{print $1}')
        local branch=$(echo "$line" | awk '{print $3}' | tr -d '[]')
        
        # メインブランチはスキップ
        if [[ "$path" == "$PROJECT_ROOT" ]]; then
            continue
        fi
        
        # worktreesディレクトリ内のみ処理
        if [[ "$path" == *"/worktrees/"* ]]; then
            if is_merged "$branch"; then
                echo ""
                echo "📌 マージ済み: $branch"
                
                if [ "$dry_run" = true ]; then
                    echo "  → [DRY RUN] 削除対象"
                else
                    if remove_worktree "$path" "$branch" "$archive"; then
                        ((deleted_count++))
                    fi
                fi
            else
                ((skipped_count++))
            fi
        fi
    done
    
    echo ""
    echo -e "${GREEN}=== クリーンアップ完了 ===${NC}"
    echo "削除: $deleted_count 個"
    echo "スキップ: $skipped_count 個"
    
    log "INFO" "Auto cleanup completed: deleted=$deleted_count, skipped=$skipped_count"
}

# 古いWorktreeを削除
clean_old_worktrees() {
    local days=${1:-$RETENTION_DAYS}
    local dry_run=${2:-false}
    local archive=${3:-false}
    
    echo -e "${BLUE}🔍 ${days}日以上古いWorktreeを検索中...${NC}"
    log "INFO" "=== Clean old worktrees started (days=$days) ==="
    
    local deleted_count=0
    
    git worktree list | while read -r line; do
        local path=$(echo "$line" | awk '{print $1}')
        local branch=$(echo "$line" | awk '{print $3}' | tr -d '[]')
        
        # メインブランチはスキップ
        if [[ "$path" == "$PROJECT_ROOT" ]]; then
            continue
        fi
        
        # worktreesディレクトリ内のみ処理
        if [[ "$path" == *"/worktrees/"* ]] && [ -d "$path" ]; then
            local age=$(get_worktree_age "$path")
            
            if [ "$age" -ge "$days" ]; then
                echo ""
                echo "📌 古いWorktree: $branch (${age}日前)"
                
                if [ "$dry_run" = true ]; then
                    echo "  → [DRY RUN] 削除対象"
                else
                    if remove_worktree "$path" "$branch" "$archive"; then
                        ((deleted_count++))
                    fi
                fi
            fi
        fi
    done
    
    echo ""
    echo -e "${GREEN}=== クリーンアップ完了 ===${NC}"
    echo "削除: $deleted_count 個"
}

# 削除候補を表示
list_candidates() {
    echo -e "${BLUE}📋 Worktree削除候補:${NC}"
    echo ""
    
    local merged_count=0
    local old_count=0
    
    echo "## マージ済みWorktree"
    echo "-------------------"
    git worktree list | while read -r line; do
        local path=$(echo "$line" | awk '{print $1}')
        local branch=$(echo "$line" | awk '{print $3}' | tr -d '[]')
        
        if [[ "$path" != "$PROJECT_ROOT" ]] && [[ "$path" == *"/worktrees/"* ]]; then
            if is_merged "$branch"; then
                echo "✓ $branch"
                ((merged_count++))
            fi
        fi
    done
    
    echo ""
    echo "## 古いWorktree (${RETENTION_DAYS}日以上)"
    echo "-------------------------"
    git worktree list | while read -r line; do
        local path=$(echo "$line" | awk '{print $1}')
        local branch=$(echo "$line" | awk '{print $3}' | tr -d '[]')
        
        if [[ "$path" != "$PROJECT_ROOT" ]] && [[ "$path" == *"/worktrees/"* ]] && [ -d "$path" ]; then
            local age=$(get_worktree_age "$path")
            if [ "$age" -ge "$RETENTION_DAYS" ]; then
                echo "• $branch (${age}日前)"
                ((old_count++))
            fi
        fi
    done
    
    echo ""
    echo -e "${YELLOW}合計: マージ済み ${merged_count}個、古い ${old_count}個${NC}"
}

# クリーンアップ状況表示
show_status() {
    echo -e "${BLUE}📊 Worktreeクリーンアップ状況${NC}"
    echo "================================"
    
    # アクティブなWorktree
    local active_count=$(git worktree list | grep -c "/worktrees/" || echo "0")
    echo "アクティブなWorktree: $active_count 個"
    
    # ディスク使用量
    if [ -d "$WORKTREE_BASE" ]; then
        local disk_usage=$(du -sh "$WORKTREE_BASE" 2>/dev/null | cut -f1)
        echo "ディスク使用量: $disk_usage"
    fi
    
    # 最後のクリーンアップ
    if [ -f "$CLEANUP_LOG" ]; then
        local last_cleanup=$(grep "Auto cleanup completed" "$CLEANUP_LOG" | tail -1 | cut -d' ' -f1,2 | tr -d '[]')
        if [ -n "$last_cleanup" ]; then
            echo "最終クリーンアップ: $last_cleanup"
        fi
    fi
    
    echo ""
    
    # 削除候補サマリー
    list_candidates
}

# メイン処理
mkdir -p "$(dirname "$CLEANUP_LOG")"

# オプション解析
DRY_RUN=false
FORCE=false
ARCHIVE=false
DAYS=$RETENTION_DAYS

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --archive)
            ARCHIVE=true
            shift
            ;;
        --days)
            DAYS="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

# コマンド実行
case "${1:-help}" in
    auto)
        auto_cleanup "$DRY_RUN" "$ARCHIVE"
        ;;
    clean-old)
        clean_old_worktrees "$DAYS" "$DRY_RUN" "$ARCHIVE"
        ;;
    clean-merged)
        auto_cleanup "$DRY_RUN" "$ARCHIVE"
        ;;
    clean-branch)
        if [ -z "${2:-}" ]; then
            echo -e "${RED}エラー: ブランチ名を指定してください${NC}"
            exit 1
        fi
        # 特定ブランチの削除（実装省略）
        ;;
    list-candidates|list)
        list_candidates
        ;;
    status)
        show_status
        ;;
    help|*)
        show_usage
        ;;
esac