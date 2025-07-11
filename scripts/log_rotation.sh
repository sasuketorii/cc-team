#!/bin/bash
# CCTeam ログローテーションスクリプト
# 大きなログファイルを圧縮し、古いログを削除します

set -e

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# 設定
LOG_DIR="logs"
MAX_SIZE="10M"  # 10MB以上のログを圧縮
MAX_AGE=30      # 30日以上前の圧縮ログを削除
DISK_WARNING=80 # ディスク使用率警告閾値

echo -e "${BLUE}📋 CCTeam ログローテーション${NC}"
echo "=========================="

# ログディレクトリの確認
if [ ! -d "$LOG_DIR" ]; then
    echo -e "${RED}エラー: ログディレクトリ '$LOG_DIR' が存在しません${NC}"
    exit 1
fi

# 大きなログファイルを検索して圧縮
echo -e "${YELLOW}大きなログファイルを検索中...${NC}"
COMPRESSED_COUNT=0

while IFS= read -r -d '' logfile; do
    SIZE=$(ls -lh "$logfile" | awk '{print $5}')
    BASENAME=$(basename "$logfile")
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    GZFILE="${logfile}.${TIMESTAMP}.gz"
    
    echo -e "  圧縮中: $BASENAME ($SIZE) ..."
    gzip -c "$logfile" > "$GZFILE"
    
    # 元のログファイルをクリア（削除ではなく空にする）
    echo "$(date): Log rotated" > "$logfile"
    
    echo -e "  ${GREEN}✓${NC} 圧縮完了: $(basename "$GZFILE")"
    ((COMPRESSED_COUNT++))
done < <(find "$LOG_DIR" -name "*.log" -size +${MAX_SIZE} -print0)

if [ $COMPRESSED_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓ 圧縮が必要なログファイルはありません${NC}"
else
    echo -e "${GREEN}✓ $COMPRESSED_COUNT 個のログファイルを圧縮しました${NC}"
fi

echo ""

# 古い圧縮ログファイルを削除
echo -e "${YELLOW}古い圧縮ログファイルを検索中...${NC}"
DELETED_COUNT=0

# .gzファイルの削除
while IFS= read -r -d '' oldgz; do
    BASENAME=$(basename "$oldgz")
    rm -f "$oldgz"
    echo -e "  ${GREEN}✓${NC} 削除: $BASENAME"
    ((DELETED_COUNT++))
done < <(find "$LOG_DIR" -name "*.gz" -mtime +${MAX_AGE} -print0)

# 古い通常のログファイルも削除（error_loops.json, *.jsonlなど）
while IFS= read -r -d '' oldlog; do
    BASENAME=$(basename "$oldlog")
    # 重要なログは保護
    if [[ ! "$BASENAME" =~ ^(system\.log|boss\.log|worker[1-3]\.log|communication\.log)$ ]]; then
        rm -f "$oldlog"
        echo -e "  ${GREEN}✓${NC} 削除: $BASENAME"
        ((DELETED_COUNT++))
    fi
done < <(find "$LOG_DIR" \( -name "*.jsonl" -o -name "*.json" \) -mtime +${MAX_AGE} -print0)

if [ $DELETED_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓ 削除が必要な古いログファイルはありません${NC}"
else
    echo -e "${GREEN}✓ $DELETED_COUNT 個の古いログファイルを削除しました${NC}"
fi

echo ""

# ディスク使用率のチェック
echo -e "${YELLOW}ディスク使用率を確認中...${NC}"
if command -v df >/dev/null 2>&1; then
    USAGE=$(df -h "$LOG_DIR" | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [ "$USAGE" -gt "$DISK_WARNING" ]; then
        echo -e "${RED}⚠️  警告: ログディレクトリのディスク使用率が ${USAGE}% に達しています！${NC}"
    else
        echo -e "${GREEN}✓ ディスク使用率: ${USAGE}%${NC}"
    fi
fi

# ログディレクトリの統計情報
echo ""
echo -e "${BLUE}📊 ログディレクトリの統計:${NC}"
echo -e "  現在のログファイル: $(find "$LOG_DIR" -name "*.log" | wc -l) 個"
echo -e "  圧縮されたログ: $(find "$LOG_DIR" -name "*.gz" | wc -l) 個"
echo -e "  合計サイズ: $(du -sh "$LOG_DIR" | awk '{print $1}')"

# 次回の実行についての提案
echo ""
echo -e "${GREEN}💡 ヒント:${NC}"
echo "  このスクリプトをcronで定期実行することを推奨します:"
echo "  0 0 * * * cd $(pwd) && ./scripts/log_rotation.sh"