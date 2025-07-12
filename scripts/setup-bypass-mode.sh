#!/bin/bash
# CCTeam Bypassモード永続設定スクリプト

set -e

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 CCTeam Bypassモード永続設定${NC}"
echo "=================================="

# ~/.claude/settings.jsonに設定を追加
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

# ディレクトリ作成
mkdir -p "$CLAUDE_DIR"

# 既存の設定をバックアップ
if [ -f "$SETTINGS_FILE" ]; then
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak"
    echo -e "${YELLOW}既存の設定をバックアップしました: $SETTINGS_FILE.bak${NC}"
fi

# Bypassモード設定を書き込み
cat > "$SETTINGS_FILE" << 'EOF'
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  }
}
EOF

echo -e "${GREEN}✅ Bypassモードを永続設定しました！${NC}"
echo ""
echo "設定内容:"
cat "$SETTINGS_FILE"
echo ""
echo -e "${BLUE}今後は以下のコマンドだけでBypassモードで起動します:${NC}"
echo "  claude"
echo "  claude --model opus"
echo "  claude --model sonnet"
echo ""
echo -e "${YELLOW}元に戻す場合:${NC}"
echo "  rm ~/.claude/settings.json"