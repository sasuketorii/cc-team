#!/bin/bash
# CCTeam クリーンアップスクリプト v0.0.6
# 不要ファイルを安全に削除します

set -e

# カラー定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧹 CCTeam クリーンアップスクリプト v0.0.6${NC}"
echo "========================================"

# 削除対象ファイルのリスト
declare -a FILES_TO_DELETE=(
    # 無効化された旧バージョンファイル
    "scripts/launch-ccteam-v2.sh.disabled"
    "scripts/setup-v2.sh.disabled"
    
    # 機能統合済みスクリプト
    "scripts/launch-ccteam-standby.sh"
    "scripts/launch-ccteam-auto.sh"
    "install-local.sh"
    
    # 未使用ログファイル
    "logs/worker4.log"
    "logs/gemini.log"
    
    # 初期化マーカー
    ".initialized"
)

# 外部の無関係ファイル
EXTERNAL_FILE="/Users/sasuketorii/CC-Team/調査報告書.md"

# 削除対象ファイルの確認
echo -e "${YELLOW}削除対象ファイルを確認しています...${NC}"
echo ""

FOUND_FILES=0
for file in "${FILES_TO_DELETE[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${RED}✗${NC} $file ($(ls -lh "$file" | awk '{print $5}'))"
        ((FOUND_FILES++))
    else
        echo -e "  ${GREEN}✓${NC} $file (既に削除済み)"
    fi
done

# 外部ファイルの確認
if [ -f "$EXTERNAL_FILE" ]; then
    echo -e "  ${RED}✗${NC} $EXTERNAL_FILE (外部ファイル)"
    ((FOUND_FILES++))
fi

# .DS_Storeファイルの検索
DS_STORE_COUNT=$(find . -name ".DS_Store" 2>/dev/null | wc -l | tr -d ' ')
if [ "$DS_STORE_COUNT" -gt 0 ]; then
    echo -e "  ${RED}✗${NC} .DS_Store ファイル: ${DS_STORE_COUNT}個"
    ((FOUND_FILES+=$DS_STORE_COUNT))
fi

echo ""

if [ $FOUND_FILES -eq 0 ]; then
    echo -e "${GREEN}✅ 削除すべきファイルはありません。既にクリーンです！${NC}"
    exit 0
fi

echo -e "${YELLOW}合計 $FOUND_FILES 個のファイルが削除対象です。${NC}"
echo ""

# 確認プロンプト
read -p "これらのファイルを削除しますか？ (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}キャンセルしました。${NC}"
    exit 1
fi

# 削除実行
echo ""
echo -e "${YELLOW}削除を実行しています...${NC}"

# 各ファイルを削除
for file in "${FILES_TO_DELETE[@]}"; do
    if [ -f "$file" ]; then
        rm -f "$file"
        echo -e "  ${GREEN}✓${NC} 削除: $file"
    fi
done

# 外部ファイルを削除
if [ -f "$EXTERNAL_FILE" ]; then
    rm -f "$EXTERNAL_FILE"
    echo -e "  ${GREEN}✓${NC} 削除: $EXTERNAL_FILE"
fi

# .DS_Storeファイルを削除
if [ "$DS_STORE_COUNT" -gt 0 ]; then
    find . -name ".DS_Store" -delete
    echo -e "  ${GREEN}✓${NC} 削除: .DS_Store ファイル ${DS_STORE_COUNT}個"
fi

echo ""
echo -e "${GREEN}✅ クリーンアップ完了！${NC}"
echo ""

# 空ディレクトリの状況を報告
echo -e "${BLUE}📁 空ディレクトリの状況:${NC}"
for dir in reports tmp worktrees; do
    if [ -d "$dir" ] && [ -z "$(ls -A "$dir")" ]; then
        echo -e "  ⚠️  $dir/ (空 - 将来の機能実装用に保持)"
    fi
done

echo ""
echo -e "${GREEN}次のステップ:${NC}"
echo "  1. Claude Code Actions の実装: .claude/claude_desktop_config.json"
echo "  2. ログローテーションの設定: scripts/log_rotation.sh"
echo "  3. .gitignoreの更新"