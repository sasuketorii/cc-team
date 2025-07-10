#!/bin/bash
# CCTeam インストーラー v4.0.0
# グローバルコマンドとしてCCTeamをインストール
# DevContainer & Worktree自動化対応

set -e

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

VERSION="4.0.0"

echo -e "${BLUE}🚀 CCTeam Installer v$VERSION${NC}"
echo "================================"
echo "DevContainer & Worktree対応版"
echo ""

# インストール先の確認
INSTALL_DIR="$HOME/CC-Team/CCTeam"
if [ ! -d "$INSTALL_DIR" ]; then
    # 現在のディレクトリがCCTeamプロジェクトルートの場合
    if [ -f "./scripts/launch-ccteam-v4.sh" ] || [ -f "./scripts/launch-ccteam-v3.sh" ]; then
        INSTALL_DIR="$(pwd)"
        echo -e "${GREEN}現在のディレクトリをCCTeamとして使用: $INSTALL_DIR${NC}"
    else
        echo -e "${RED}Error: CCTeam not found${NC}"
        echo "Please clone CCTeam first:"
        echo "  git clone https://github.com/sasuketorii/cc-team.git ~/CC-Team"
        exit 1
    fi
fi

# インストールモード判定
INSTALL_MODE="global"
if [ "$1" = "--local" ]; then
    INSTALL_MODE="local"
    echo -e "${YELLOW}ローカルモードでインストールします${NC}"
elif [ "$1" = "--dev-container" ] || [ "$CCTEAM_DEV_CONTAINER" = "true" ]; then
    INSTALL_MODE="devcontainer"
    echo -e "${YELLOW}DevContainerモードでインストールします${NC}"
fi

# インストール先ディレクトリ
if [ "$INSTALL_MODE" = "local" ]; then
    BIN_DIR="$HOME/.local/bin"
    mkdir -p "$BIN_DIR"
elif [ "$INSTALL_MODE" = "devcontainer" ]; then
    BIN_DIR="/usr/local/bin"
else
    BIN_DIR="/usr/local/bin"
fi

# グローバルコマンドの作成
echo -e "\n${YELLOW}Creating global commands...${NC}"

# ccteamコマンド作成（v4対応）
cat > /tmp/ccteam << EOF
#!/bin/bash
# CCTeam launcher command v$VERSION

CCTEAM_HOME="$INSTALL_DIR"
export CCTEAM_HOME

# ディレクトリ移動
cd "\$CCTEAM_HOME" || exit 1

# v4起動スクリプトが存在する場合は使用
if [ -f "./scripts/launch-ccteam-v4.sh" ]; then
    exec ./scripts/launch-ccteam-v4.sh "\$@"
# v3にフォールバック
elif [ -f "./scripts/launch-ccteam-v3.sh" ]; then
    exec ./scripts/launch-ccteam-v3.sh "\$@"
else
    echo "Error: CCTeam launch script not found"
    exit 1
fi
EOF

# ccguideコマンド（ccteamのエイリアス）
cat > /tmp/ccguide << EOF
#!/bin/bash
# CCTeam guided launcher
exec ccteam --guided "\$@"
EOF

# ccstatusコマンド
cat > /tmp/ccstatus << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/project-status.sh "\$@"
EOF

# ccsendコマンド
cat > /tmp/ccsend << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/enhanced_agent_send.sh "\$@"
EOF

# ccmonコマンド
cat > /tmp/ccmon << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/ccteam-monitor.sh "\$@"
EOF

# cckillコマンド
cat > /tmp/cckill << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/ccteam-kill.sh "\$@"
EOF

# ccworktreeコマンド（新規）
cat > /tmp/ccworktree << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/worktree-auto-manager.sh "\$@"
EOF

# ccnotifyコマンド（新規）
cat > /tmp/ccnotify << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/notification-manager.sh "\$@"
EOF

# インストール実行
echo -e "\n${YELLOW}Installing commands to $BIN_DIR...${NC}"

# sudoが必要か判定
SUDO_CMD=""
if [ "$INSTALL_MODE" = "global" ] && [ ! -w "$BIN_DIR" ]; then
    SUDO_CMD="sudo"
    echo "This requires sudo permission to install to $BIN_DIR"
fi

# コマンドをインストール
for cmd in ccteam ccguide ccstatus ccsend ccmon cckill ccworktree ccnotify; do
    $SUDO_CMD mv /tmp/$cmd "$BIN_DIR/" 2>/dev/null || {
        echo -e "${RED}Failed to install $cmd${NC}"
        continue
    }
    $SUDO_CMD chmod +x "$BIN_DIR/$cmd"
    echo -e "${GREEN}✓ Installed: $cmd${NC}"
done

# エイリアス設定ファイル作成
cat > "$HOME/.ccteam-commands" << 'EOF'
# CCTeam Quick Commands v4.0.0
alias cct='ccteam'                    # CCTeam起動
alias cca='tmux attach -t ccteam'     # tmuxセッションに接続
alias ccs='ccstatus'                  # ステータス確認
alias ccm='ccmon'                     # リアルタイム監視
alias cck='cckill'                    # セッション終了

# v4新機能
alias ccw='ccworktree'                # Worktree管理
alias ccn='ccnotify'                  # 通知テスト
alias ccwt='ccworktree status'        # Worktree状態確認
alias ccwc='ccworktree create-project-worktrees'  # Worktree作成
alias ccwi='ccworktree prepare-integration'       # 統合レポート

# ショートカット（Boss v2対応）
alias ccstart='ccsend boss "requirementsを読み込んでプロジェクトを開始してください"'
alias ccprogress='ccsend boss "進捗を確認してください"'
alias ccintegrate='ccsend boss "統合準備をしてください"'
EOF

echo -e "${GREEN}✓ Command aliases created${NC}"

# PATH確認（ローカルモードの場合）
if [ "$INSTALL_MODE" = "local" ] && [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "\n${YELLOW}⚠️  $BIN_DIR is not in PATH${NC}"
    echo "Add the following to your ~/.bashrc or ~/.zshrc:"
    echo 'export PATH="$HOME/.local/bin:$PATH"'
fi

# 最終手順
echo -e "\n${BLUE}📋 Final Steps:${NC}"
echo ""
echo "1. Add to your shell config (~/.bashrc or ~/.zshrc):"
echo -e "${YELLOW}   source ~/.ccteam-commands${NC}"
echo ""
echo "2. Reload your shell:"
echo -e "${YELLOW}   source ~/.bashrc${NC}  # or ~/.zshrc"
echo ""
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo ""
echo "CCTeam v$VERSION Commands:"
echo "  ${BLUE}ccteam${NC}         - Start CCTeam (v4: DevContainer対応)"
echo "  ${BLUE}ccguide${NC}        - ガイド付き起動"
echo "  ${BLUE}ccmon${NC}          - リアルタイム監視"
echo "  ${BLUE}ccworktree${NC}     - Worktree管理 🆕"
echo "  ${BLUE}ccnotify${NC}       - 通知テスト 🆕"
echo ""
echo "Quick aliases:"
echo "  ${BLUE}cct${NC}            - ccteamの短縮"
echo "  ${BLUE}cca${NC}            - セッション接続"
echo "  ${BLUE}ccs${NC}            - ステータス確認"
echo "  ${BLUE}ccw${NC}            - Worktree管理"
echo "  ${BLUE}ccstart${NC}        - プロジェクト開始（Boss v2）🆕"
echo ""
echo "No need to cd anymore! Run from anywhere! 🎉"
echo ""
if [ "$INSTALL_MODE" = "devcontainer" ]; then
    echo -e "${GREEN}DevContainer環境でのインストールが完了しました！${NC}"
fi