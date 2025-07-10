#!/bin/bash
# CCTeam インストーラー - グローバルコマンドを設定

set -e

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 CCTeam Installer${NC}"
echo "==================="

# インストール先の確認
INSTALL_DIR="$HOME/CC-Team/CCTeam"
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${RED}Error: CCTeam not found at $INSTALL_DIR${NC}"
    echo "Please clone CCTeam first:"
    echo "  git clone <repository> ~/CC-Team/CCTeam"
    exit 1
fi

# グローバルコマンドの作成
echo -e "\n${YELLOW}Creating global commands...${NC}"

# ccteamコマンド作成
cat > /tmp/ccteam << EOF
#!/bin/bash
# CCTeam launcher command

CCTEAM_HOME="$INSTALL_DIR"

# ディレクトリ移動とセットアップ
cd "\$CCTEAM_HOME" || exit 1

# 初回実行チェック
if [ ! -f "\$CCTEAM_HOME/.initialized" ]; then
    echo "🎉 First time setup..."
    ./scripts/setup.sh
    touch "\$CCTEAM_HOME/.initialized"
fi

# CCTeam起動
./scripts/launch-ccteam.sh
EOF

# ccteam-statusコマンド作成
cat > /tmp/ccteam-status << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/project-status.sh
EOF

# ccteam-sendコマンド作成
cat > /tmp/ccteam-send << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/agent-send.sh "\$@"
EOF

# ccteam-versionコマンド作成
cat > /tmp/ccteam-version << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/version-manager.sh "\$@"
EOF

# ccteam-attachコマンド作成
cat > /tmp/ccteam-attach << EOF
#!/bin/bash
tmux attach -t ccteam-boss || tmux attach -t ccteam-workers
EOF

# ccteam-killコマンド作成
cat > /tmp/ccteam-kill << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/ccteam-kill.sh
EOF

# /usr/local/binにインストール（sudoが必要）
echo -e "\n${YELLOW}Installing commands...${NC}"
echo "This requires sudo permission to install to /usr/local/bin"

# コマンドをインストール
for cmd in ccteam ccteam-status ccteam-send ccteam-version ccteam-attach ccteam-kill; do
    sudo mv /tmp/$cmd /usr/local/bin/
    sudo chmod +x /usr/local/bin/$cmd
    echo -e "${GREEN}✓ Installed: $cmd${NC}"
done

# エイリアス設定ファイル作成
cat > "$HOME/.ccteam-commands" << 'EOF'
# CCTeam Quick Commands
alias cct='ccteam'                    # CCTeam起動
alias cca='ccteam-attach'             # tmuxセッションに接続
alias ccs='ccteam-status'             # ステータス確認
alias ccv='ccteam-version'            # バージョン管理
alias ccsend='ccteam-send'            # エージェントにメッセージ送信
alias cckill='ccteam-kill'            # tmuxセッション終了

# ショートカット
alias ccbump='ccteam-version bump'    # バージョンアップ
alias ccback='ccteam-version rollback' # ロールバック
EOF

echo -e "${GREEN}✓ Command aliases created${NC}"

# シェル設定への追加を提案
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
echo "You can now use:"
echo "  ${BLUE}ccteam${NC}         - Start CCTeam from anywhere"
echo "  ${BLUE}cct${NC}            - Short alias for ccteam"
echo "  ${BLUE}cca${NC}            - Attach to running session"
echo "  ${BLUE}ccs${NC}            - Check status"
echo "  ${BLUE}ccv bump${NC}       - Version up (0.0.1 → 0.0.2)"
echo "  ${BLUE}ccsend boss${NC}    - Send message to agent"
echo ""
echo "No need to cd to the directory anymore! 🎉"