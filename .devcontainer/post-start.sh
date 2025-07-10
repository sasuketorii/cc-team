#!/bin/bash

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 CCTeam Dev Container 起動チェック${NC}"
echo "=================================="

# 1. Claude認証状態確認
echo -e "${YELLOW}🔐 Claude認証状態:${NC}"
if [ -f ~/.claude/.credentials.json ]; then
    if command -v jq &> /dev/null; then
        TOKEN_EXPIRY=$(jq -r '.expires_at // empty' ~/.claude/.credentials.json 2>/dev/null || echo "")
        if [ -n "$TOKEN_EXPIRY" ]; then
            CURRENT_TIME=$(date +%s)
            EXPIRY_DATE=$(date -d "@$TOKEN_EXPIRY" 2>/dev/null || echo "不明")
            
            if [ "$TOKEN_EXPIRY" -lt "$CURRENT_TIME" ]; then
                echo -e "${RED}❌ 認証トークンが期限切れです（期限: $EXPIRY_DATE）${NC}"
                echo "   ホストマシンで 'claude login' を実行してください"
            else
                REMAINING=$((($TOKEN_EXPIRY - $CURRENT_TIME) / 3600))
                echo -e "${GREEN}✅ 認証トークンは有効です（残り約 ${REMAINING} 時間）${NC}"
            fi
        else
            echo -e "${GREEN}✅ Claude認証情報が存在します${NC}"
        fi
    else
        echo -e "${GREEN}✅ Claude認証ファイルが存在します${NC}"
    fi
elif [ -f ~/.claude/claude_config.json ]; then
    echo -e "${GREEN}✅ Claude設定ファイルが存在します${NC}"
else
    echo -e "${YELLOW}⚠️  Claude認証情報が見つかりません${NC}"
    echo "   ホストマシンで認証を完了してください"
fi

# 2. CCTeamインストール状態確認
echo ""
echo -e "${YELLOW}📦 CCTeamインストール状態:${NC}"
if command -v ccteam &> /dev/null; then
    echo -e "${GREEN}✅ ccteam コマンドが利用可能です${NC}"
else
    echo -e "${YELLOW}⚠️  ccteam コマンドが見つかりません${NC}"
    echo "   '/workspaces/CCTeam/install.sh' を実行してください"
fi

# 3. tmuxセッション確認
echo ""
echo -e "${YELLOW}🖥️  tmuxセッション:${NC}"
if tmux has-session -t ccteam 2>/dev/null; then
    echo -e "${GREEN}✅ CCTeamセッションが実行中です${NC}"
    echo "   'ccmon' または 'tmux attach -t ccteam' で接続できます"
else
    echo -e "${BLUE}ℹ️  CCTeamセッションは起動していません${NC}"
    echo "   'ccteam' コマンドで起動できます"
fi

# 4. プロジェクト状態
echo ""
echo -e "${YELLOW}📊 プロジェクト状態:${NC}"
cd /workspaces/CCTeam

# Git状態
if [ -d .git ]; then
    BRANCH=$(git branch --show-current 2>/dev/null || echo "不明")
    CHANGES=$(git status --porcelain 2>/dev/null | wc -l)
    echo -e "   Git ブランチ: ${BLUE}$BRANCH${NC}"
    if [ "$CHANGES" -gt 0 ]; then
        echo -e "   未コミットの変更: ${YELLOW}$CHANGES ファイル${NC}"
    else
        echo -e "   作業ツリー: ${GREEN}クリーン${NC}"
    fi
fi

# ログファイル
if [ -d logs ]; then
    LOG_COUNT=$(find logs -name "*.log" -type f 2>/dev/null | wc -l)
    if [ "$LOG_COUNT" -gt 0 ]; then
        echo -e "   ログファイル: ${BLUE}$LOG_COUNT 個${NC}"
    fi
fi

# メモリデータベース
if [ -f memory/memory.db ]; then
    DB_SIZE=$(du -h memory/memory.db | cut -f1)
    echo -e "   メモリDB: ${BLUE}$DB_SIZE${NC}"
fi

# 5. クイックヘルプ
echo ""
echo -e "${BLUE}📚 クイックヘルプ:${NC}"
echo "  • CCTeam起動: ccteam"
echo "  • ガイド付き起動: ccguide"
echo "  • セッション接続: ccmon"
echo "  • ステータス確認: ccs"
echo "  • ログ監視: cclog"
echo "  • プロジェクトディレクトリ: cct"

echo ""
echo -e "${GREEN}準備完了！${NC}"
echo "=================================="