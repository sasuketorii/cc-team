#!/bin/bash
# CCTeam Claude自動認証スクリプト v1.0.0
# Bypassing Permissions画面で自動的に認証を実行

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 共通カラー定義を読み込み
source "$SCRIPT_DIR/common/colors.sh"

echo -e "${BLUE}🔐 CCTeam Claude自動認証開始${NC}"
echo "=================================="

# 認証関数
authenticate_claude() {
    local pane=$1
    local agent_name=$2
    
    echo -e "${YELLOW}🔄 $agent_name の認証処理を開始...${NC}"
    
    # 現在の画面内容を確認
    local screen_content=$(tmux capture-pane -t "$pane" -p 2>/dev/null || echo "")
    
    # Bypassing Permissions画面の確認
    if echo "$screen_content" | grep -q "Bypassing Permissions\|Do you want to proceed"; then
        echo "  📋 認証画面を検出しました"
        echo "  🔢 '2' (Yes, enable all) を送信..."
        
        # 2を送信
        tmux send-keys -t "$pane" "2"
        sleep 0.1
        
        # Enterを送信
        tmux send-keys -t "$pane" Enter
        sleep 2
        
        # プロンプトが表示されるまで待機（最大30秒）
        local max_wait=30
        local count=0
        while [ $count -lt $max_wait ]; do
            screen_content=$(tmux capture-pane -t "$pane" -p 2>/dev/null || echo "")
            
            # Claude Codeのプロンプト（╭─ または claude>）を確認
            if echo "$screen_content" | grep -q "╭─\|claude>"; then
                echo -e "  ${GREEN}✅ $agent_name 認証完了！${NC}"
                return 0
            fi
            
            # エラーチェック
            if echo "$screen_content" | grep -q "Error\|Failed"; then
                echo -e "  ${RED}❌ $agent_name 認証エラー${NC}"
                return 1
            fi
            
            sleep 1
            ((count++))
            echo -ne "\r  ⏳ 待機中... ($count/$max_wait秒)"
        done
        
        echo ""
        echo -e "  ${YELLOW}⚠️  $agent_name 認証タイムアウト${NC}"
        return 1
    else
        # 既に認証済みか確認
        if echo "$screen_content" | grep -q "╭─\|claude>"; then
            echo -e "  ${GREEN}✅ $agent_name は既に認証済み${NC}"
            return 0
        else
            echo -e "  ${YELLOW}⚠️  $agent_name の状態が不明です${NC}"
            echo "  現在の画面:"
            echo "$screen_content" | head -5
            return 1
        fi
    fi
}

# エラーカウンター
error_count=0

# Boss認証
echo ""
echo -e "${BLUE}1. Boss認証${NC}"
if ! authenticate_claude "ccteam-boss:main.0" "Boss"; then
    ((error_count++))
fi

# Workers認証
echo ""
echo -e "${BLUE}2. Workers認証${NC}"

# Worker1
if ! authenticate_claude "ccteam-workers:main.0" "Worker1 (Frontend)"; then
    ((error_count++))
fi

# Worker2
if ! authenticate_claude "ccteam-workers:main.1" "Worker2 (Backend)"; then
    ((error_count++))
fi

# Worker3
if ! authenticate_claude "ccteam-workers:main.2" "Worker3 (QA/Test)"; then
    ((error_count++))
fi

# 結果表示
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $error_count -eq 0 ]; then
    echo -e "${GREEN}✅ 全エージェントの認証が完了しました！${NC}"
    echo ""
    echo "次のステップ："
    echo "1. エージェントの初期化："
    echo -e "   ${CYAN}./scripts/auto-init-agents.sh${NC}"
    echo ""
    echo "2. 動作確認："
    echo -e "   ${CYAN}./scripts/agent-send.sh boss \"動作確認メッセージ\"${NC}"
else
    echo -e "${RED}❌ $error_count 個のエージェントで認証に失敗しました${NC}"
    echo ""
    echo "手動で認証を完了させてください："
    echo "1. tmux attach -t ccteam-boss"
    echo "2. 各ペインで '2' を入力してEnter"
    echo "3. Ctrl+b → d でデタッチ"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ログ記録
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] Auto authentication completed (errors: $error_count)" >> "$PROJECT_ROOT/logs/system.log"