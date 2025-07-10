#!/bin/bash
set -e

echo "🚀 CCTeam Dev Container セットアップ開始..."
echo "================================================"

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. システムパッケージインストール
echo -e "${YELLOW}📦 システムパッケージをインストール中...${NC}"
sudo apt-get update
sudo apt-get install -y \
    tmux \
    expect \
    jq \
    sqlite3 \
    curl \
    wget \
    vim \
    htop \
    tree \
    ripgrep \
    fd-find

# 2. Claude CLIインストール（通常版）
echo -e "${YELLOW}📦 Claude CLI インストール中...${NC}"
if ! command -v claude &> /dev/null; then
    # 公式のClaude CLIをインストール
    npm install -g @anthropic-ai/claude-cli || {
        echo -e "${RED}⚠️  公式Claude CLIのインストールに失敗しました${NC}"
        echo "代替方法を使用します..."
    }
else
    echo -e "${GREEN}✅ Claude CLI は既にインストールされています${NC}"
fi

# 3. CCTeam依存関係インストール
echo -e "${YELLOW}📦 CCTeam依存関係をインストール中...${NC}"
cd /workspaces/CCTeam

# package.jsonが存在する場合
if [ -f package.json ]; then
    npm install
fi

# requirements.txtが存在する場合
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
fi

# 4. グローバルコマンド設定（Dev Container用）
echo -e "${YELLOW}🔧 グローバルコマンドを設定中...${NC}"
if [ -f install.sh ]; then
    # Dev Container内では/usr/local/binにインストール
    sudo ./install.sh --prefix /usr/local
else
    echo -e "${RED}⚠️  install.sh が見つかりません${NC}"
fi

# 5. ディレクトリ構造確認
echo -e "${YELLOW}📁 ディレクトリ構造を確認中...${NC}"
mkdir -p logs
mkdir -p memory
mkdir -p reports
mkdir -p investigation_reports
mkdir -p worktrees
mkdir -p tests/history

# 6. Claude認証確認
echo -e "${YELLOW}🔐 Claude認証情報を確認中...${NC}"
if [ -f ~/.claude/.credentials.json ]; then
    echo -e "${GREEN}✅ Claude認証情報を検出しました${NC}"
    # トークンの有効期限確認
    if command -v jq &> /dev/null; then
        EXPIRY=$(jq -r '.expires_at // empty' ~/.claude/.credentials.json 2>/dev/null || echo "")
        if [ -n "$EXPIRY" ]; then
            CURRENT=$(date +%s)
            if [ "$EXPIRY" -lt "$CURRENT" ]; then
                echo -e "${YELLOW}⚠️  認証トークンが期限切れの可能性があります${NC}"
            fi
        fi
    fi
elif [ -f ~/.claude/claude_config.json ]; then
    echo -e "${GREEN}✅ Claude設定ファイルを検出しました${NC}"
else
    echo -e "${YELLOW}⚠️  Claude認証情報が見つかりません${NC}"
    echo "ホストマシンで以下のコマンドを実行して認証を完了してください："
    echo "  claude login"
fi

# 7. Git設定
echo -e "${YELLOW}🔧 Git設定中...${NC}"
git config --global --add safe.directory /workspaces/CCTeam

# 8. エイリアス設定
echo -e "${YELLOW}🔧 便利なエイリアスを設定中...${NC}"
cat >> ~/.bashrc << 'EOF'

# CCTeam aliases
alias cct='cd /workspaces/CCTeam'
alias ccmon='tmux attach -t ccteam || echo "CCTeamセッションが見つかりません"'
alias cclog='tail -f /workspaces/CCTeam/logs/*.log'
alias ccs='ccstatus'

# 便利なエイリアス
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# プロンプトをカスタマイズ
export PS1='\[\033[01;32m\]🚀 CCTeam Dev\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

EOF

# 9. 完了メッセージ
echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}✅ CCTeam Dev Container セットアップ完了！${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "利用可能なコマンド:"
echo "  ccteam    - CCTeamを起動"
echo "  ccguide   - ガイド付きでCCTeamを起動"
echo "  ccmon     - CCTeamセッションに接続"
echo "  ccs       - CCTeamステータス確認"
echo "  cclog     - ログをリアルタイム表示"
echo ""
echo "次のステップ:"
echo "1. ターミナルを再読み込み: source ~/.bashrc"
echo "2. CCTeamを起動: ccteam"
echo ""