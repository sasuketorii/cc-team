#!/bin/bash

# CCTeam Kill Script
# tmuxセッションを完全に終了

# カラー定義
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
NC=$'\033[0m'

echo "${RED}🔥 CCTeam セッション終了${NC}"
echo "=========================="
echo ""

# 確認プロンプト
echo "${YELLOW}⚠️  警告: すべてのtmuxセッションが終了します${NC}"
echo "他のtmuxセッションも使用している場合は注意してください"
echo ""
read -p "本当に終了しますか？ (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "キャンセルしました"
    exit 0
fi

echo ""
echo "tmuxセッションを終了しています..."

# tmux kill-server を実行
tmux kill-server 2>/dev/null

if [ $? -eq 0 ]; then
    echo "${GREEN}✅ すべてのtmuxセッションを終了しました${NC}"
else
    echo "${GREEN}✅ tmuxセッションは既に終了しています${NC}"
fi

echo ""
echo "💡 CCTeamを再起動するには:"
echo "   cd ~/CC-Team/CCTeam && ./scripts/setup-v2.sh && ccteam"
echo ""