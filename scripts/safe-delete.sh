#!/bin/bash
# 安全な削除システム - 削除ファイルをゴミ箱に移動して復旧可能にする

set -e

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ゴミ箱ディレクトリ
TRASH_DIR="$HOME/.ccteam-trash"
TRASH_INFO="$TRASH_DIR/.trashinfo"

# ゴミ箱の初期化
init_trash() {
    mkdir -p "$TRASH_DIR"
    touch "$TRASH_INFO"
}

# 関数: 安全な削除
safe_delete() {
    local file="$1"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local basename=$(basename "$file")
    local trash_name="${timestamp}_${basename}"
    
    if [ ! -e "$file" ]; then
        echo -e "${RED}Error: File not found: $file${NC}"
        return 1
    fi
    
    # ゴミ箱に移動
    mv "$file" "$TRASH_DIR/$trash_name"
    
    # メタデータ記録
    echo "$trash_name|$file|$(date)" >> "$TRASH_INFO"
    
    echo -e "${GREEN}✓ Moved to trash: $file${NC}"
    echo -e "${YELLOW}  → Restore with: ccteam-restore '$basename'${NC}"
}

# 関数: ファイル復元
restore_file() {
    local search_term="$1"
    
    # 検索
    local matches=$(grep "$search_term" "$TRASH_INFO" | tail -1)
    
    if [ -z "$matches" ]; then
        echo -e "${RED}No files found matching: $search_term${NC}"
        echo -e "Use 'ccteam-trash list' to see all deleted files"
        return 1
    fi
    
    local trash_name=$(echo "$matches" | cut -d'|' -f1)
    local original_path=$(echo "$matches" | cut -d'|' -f2)
    
    if [ -f "$TRASH_DIR/$trash_name" ]; then
        # 復元先の確認
        if [ -e "$original_path" ]; then
            echo -e "${YELLOW}File already exists at original location${NC}"
            read -p "Overwrite? (y/N): " confirm
            if [ "$confirm" != "y" ]; then
                return 1
            fi
        fi
        
        # 復元
        mv "$TRASH_DIR/$trash_name" "$original_path"
        
        # メタデータから削除
        grep -v "$trash_name" "$TRASH_INFO" > "$TRASH_INFO.tmp"
        mv "$TRASH_INFO.tmp" "$TRASH_INFO"
        
        echo -e "${GREEN}✓ Restored: $original_path${NC}"
    else
        echo -e "${RED}Trash file not found${NC}"
        return 1
    fi
}

# 関数: ゴミ箱リスト表示
list_trash() {
    echo -e "${YELLOW}🗑️  CCTeam Trash Contents:${NC}"
    echo "================================"
    
    if [ ! -s "$TRASH_INFO" ]; then
        echo "Trash is empty"
        return
    fi
    
    while IFS='|' read -r trash_name original_path delete_date; do
        local size=$(du -h "$TRASH_DIR/$trash_name" 2>/dev/null | cut -f1)
        echo -e "📄 ${original_path##*/}"
        echo -e "   Original: $original_path"
        echo -e "   Deleted: $delete_date"
        echo -e "   Size: $size"
        echo ""
    done < "$TRASH_INFO"
    
    # ゴミ箱のサイズ
    local total_size=$(du -sh "$TRASH_DIR" 2>/dev/null | cut -f1)
    echo -e "Total trash size: ${total_size}"
}

# 関数: ゴミ箱を空にする
empty_trash() {
    echo -e "${YELLOW}⚠️  This will permanently delete all files in trash${NC}"
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        rm -rf "$TRASH_DIR"/*
        > "$TRASH_INFO"
        echo -e "${GREEN}✓ Trash emptied${NC}"
    else
        echo "Cancelled"
    fi
}

# 関数: 古いファイルを自動削除
auto_clean() {
    local days=${1:-30}  # デフォルト30日
    
    echo -e "${YELLOW}Cleaning files older than $days days...${NC}"
    
    local count=0
    while IFS='|' read -r trash_name original_path delete_date; do
        local file_date=$(date -d "$delete_date" +%s 2>/dev/null || date -j -f "%a %b %d %T %Z %Y" "$delete_date" +%s)
        local current_date=$(date +%s)
        local age_days=$(( (current_date - file_date) / 86400 ))
        
        if [ $age_days -gt $days ]; then
            rm -f "$TRASH_DIR/$trash_name"
            ((count++))
        fi
    done < "$TRASH_INFO"
    
    # メタデータクリーンアップ
    local temp_file=$(mktemp)
    while IFS='|' read -r trash_name original_path delete_date; do
        if [ -f "$TRASH_DIR/$trash_name" ]; then
            echo "$trash_name|$original_path|$delete_date" >> "$temp_file"
        fi
    done < "$TRASH_INFO"
    mv "$temp_file" "$TRASH_INFO"
    
    echo -e "${GREEN}✓ Cleaned $count old files${NC}"
}

# エイリアス設定スクリプト生成
create_aliases() {
    cat > "$HOME/.ccteam-aliases" << 'EOF'
# CCTeam Safe Delete Aliases
alias rm='ccteam-delete'
alias ccteam-delete='bash ~/CC-Team/CCTeam/scripts/safe-delete.sh delete'
alias ccteam-restore='bash ~/CC-Team/CCTeam/scripts/safe-delete.sh restore'
alias ccteam-trash='bash ~/CC-Team/CCTeam/scripts/safe-delete.sh'

# 元のrmコマンドを使いたい場合
alias real-rm='/bin/rm'
EOF
    
    echo -e "${GREEN}✓ Aliases created${NC}"
    echo -e "${YELLOW}Add this to your shell config:${NC}"
    echo "source ~/.ccteam-aliases"
}

# 初期化
init_trash

# コマンド処理
case "$1" in
    "delete")
        shift
        for file in "$@"; do
            safe_delete "$file"
        done
        ;;
    "restore")
        restore_file "$2"
        ;;
    "list")
        list_trash
        ;;
    "empty")
        empty_trash
        ;;
    "clean")
        auto_clean "${2:-30}"
        ;;
    "setup")
        create_aliases
        ;;
    *)
        echo "CCTeam Safe Delete System"
        echo "========================="
        echo ""
        echo "Usage: $0 {delete|restore|list|empty|clean|setup} [args]"
        echo ""
        echo "Commands:"
        echo "  delete <files>    - Safely delete files to trash"
        echo "  restore <name>    - Restore file from trash"
        echo "  list             - List trash contents"
        echo "  empty            - Empty trash (permanent delete)"
        echo "  clean [days]     - Auto-clean files older than N days"
        echo "  setup            - Create shell aliases"
        echo ""
        echo "Examples:"
        echo "  $0 delete file.txt"
        echo "  $0 restore file.txt"
        echo "  $0 clean 7        # Clean files older than 7 days"
        ;;
esac