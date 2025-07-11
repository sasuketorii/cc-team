#!/bin/bash
# CCTeam Quick Start - ワンクリックセットアップ
# このスクリプト1つですべてが始まります！

set -e

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# アスキーアート
clear
echo -e "${BLUE}"
cat << 'EOF'
   _____ _____ _______                  
  / ____/ ____|__   __|                 
 | |   | |       | | ___  __ _ _ __ ___  
 | |   | |       | |/ _ \/ _` | '_ ` _ \ 
 | |___| |____   | |  __/ (_| | | | | | |
  \_____\_____|  |_|\___|\__,_|_| |_| |_|
                                         
  AI駆動開発チーム - 100倍の生産性を実現
EOF
echo -e "${NC}"

echo -e "\n${GREEN}ようこそ CCTeam へ！${NC}"
echo "セットアップを開始します..."
echo ""

# ステップ1: 依存関係チェック
echo -e "${YELLOW}[1/5] 依存関係をチェックしています...${NC}"

# tmuxチェック
if ! command -v tmux &> /dev/null; then
    echo -e "${RED}✗ tmuxがインストールされていません${NC}"
    echo "  以下のコマンドでインストールしてください:"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  brew install tmux"
    else
        echo "  sudo apt-get install tmux  # Ubuntu/Debian"
        echo "  sudo yum install tmux      # CentOS/RHEL"
    fi
    exit 1
else
    echo -e "${GREEN}✓ tmux${NC}"
fi

# Claude CLIチェック
if ! command -v claude &> /dev/null; then
    echo -e "${RED}✗ Claude CLIがインストールされていません${NC}"
    echo "  以下のURLからインストールしてください:"
    echo "  https://claude.ai/download"
    exit 1
else
    echo -e "${GREEN}✓ Claude CLI${NC}"
fi

# Python3チェック
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python3がインストールされていません${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Python3${NC}"
fi

echo ""

# ステップ2: 初回設定
echo -e "${YELLOW}[2/5] 初期設定を行います...${NC}"

# ディレクトリ作成
mkdir -p logs memory reports worktrees .claude/logs backup
echo -e "${GREEN}✓ 必要なディレクトリを作成しました${NC}"

# ステップ3: コマンドインストール
echo -e "\n${YELLOW}[3/5] CCTeamコマンドをインストールします...${NC}"

# インストールスクリプトの存在確認
if [ -f "scripts/install-local.sh" ]; then
    ./scripts/install-local.sh
else
    echo -e "${RED}エラー: scripts/install-local.sh が見つかりません${NC}"
    exit 1
fi

# ステップ4: エイリアス設定
echo -e "\n${YELLOW}[4/5] ショートカットを設定します...${NC}"

# シェルを検出
SHELL_CONFIG=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
fi

if [ -n "$SHELL_CONFIG" ]; then
    if ! grep -q "source ~/.ccteam-commands" "$SHELL_CONFIG" 2>/dev/null; then
        echo "source ~/.ccteam-commands" >> "$SHELL_CONFIG"
        echo -e "${GREEN}✓ $SHELL_CONFIG にエイリアスを追加しました${NC}"
    else
        echo -e "${GREEN}✓ エイリアスは既に設定されています${NC}"
    fi
    
    # 現在のシェルでも読み込む
    source ~/.ccteam-commands 2>/dev/null || true
fi

# ステップ5: 初期セットアップ
echo -e "\n${YELLOW}[5/5] tmux環境を準備します...${NC}"
./scripts/setup.sh

# 完了メッセージ
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ セットアップが完了しました！ ✨${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📚 次のステップ:"
echo ""
echo "1. CCTeamを起動:"
echo -e "   ${BLUE}ccteam${NC}  または  ${BLUE}cct${NC}"
echo ""
echo "2. ステータス確認:"
echo -e "   ${BLUE}ccteam-status${NC}  または  ${BLUE}ccs${NC}"
echo ""
echo "3. エージェントに指示:"
echo -e "   ${BLUE}ccteam-send boss "開発を開始してください"${NC}"
echo ""
echo "4. 詳しい使い方:"
echo -e "   ${BLUE}cat QUICKSTART.md${NC}"
echo ""
echo -e "${YELLOW}注意: 新しいターミナルを開くか、以下を実行してエイリアスを有効化してください:${NC}"
echo -e "${BLUE}source ~/.ccteam-commands${NC}"
echo ""