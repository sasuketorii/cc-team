#!/bin/bash
# CCTeam ローカルインストーラー（sudo不要版）

set -e

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 CCTeam Local Installer (No sudo required)${NC}"
echo "============================================"

# インストール先の確認
INSTALL_DIR="$HOME/CC-Team/CCTeam"
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${RED}Error: CCTeam not found at $INSTALL_DIR${NC}"
    exit 1
fi

# ローカルbinディレクトリ作成
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

echo -e "\n${YELLOW}Creating local commands in $LOCAL_BIN...${NC}"

# ccteamコマンド作成
cat > "$LOCAL_BIN/ccteam" << EOF
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

# その他のコマンド作成
cat > "$LOCAL_BIN/ccteam-status" << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/project-status.sh
EOF

cat > "$LOCAL_BIN/ccteam-send" << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/agent-send.sh "\$@"
EOF

cat > "$LOCAL_BIN/ccteam-version" << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/version-manager.sh "\$@"
EOF

cat > "$LOCAL_BIN/ccteam-attach" << EOF
#!/bin/bash
tmux attach -t ccteam
EOF

# 実行権限付与
chmod +x "$LOCAL_BIN/ccteam"*

echo -e "${GREEN}✓ Commands installed in $LOCAL_BIN${NC}"

# PATHの設定確認
if ! echo "$PATH" | grep -q "$LOCAL_BIN"; then
    echo -e "\n${YELLOW}Adding $LOCAL_BIN to PATH...${NC}"
    
    # .bashrcに追加
    if [ -f "$HOME/.bashrc" ]; then
        echo "" >> "$HOME/.bashrc"
        echo "# CCTeam local bin" >> "$HOME/.bashrc"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
    fi
    
    # .zshrcに追加
    if [ -f "$HOME/.zshrc" ]; then
        echo "" >> "$HOME/.zshrc"
        echo "# CCTeam local bin" >> "$HOME/.zshrc"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
    fi
fi

# エイリアス設定ファイル作成
cat > "$HOME/.ccteam-commands" << 'EOF'
# CCTeam Quick Commands
alias cct='ccteam'                    # CCTeam起動
alias cca='ccteam-attach'             # tmuxセッションに接続
alias ccs='ccteam-status'             # ステータス確認
alias ccv='ccteam-version'            # バージョン管理
alias ccsend='ccteam-send'            # エージェントにメッセージ送信

# ショートカット
alias ccbump='ccteam-version bump'    # バージョンアップ
alias ccback='ccteam-version rollback' # ロールバック
EOF

echo -e "${GREEN}✓ Command aliases created${NC}"

# 現在のシェルにPATHを追加
export PATH="$HOME/.local/bin:$PATH"

echo -e "\n${BLUE}📋 Installation Complete!${NC}"
echo ""
echo "To use the commands right now, run:"
echo -e "${YELLOW}   source ~/.ccteam-commands${NC}"
echo -e "${YELLOW}   export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
echo ""
echo "Or restart your terminal."
echo ""
echo -e "${GREEN}✅ You can now use:${NC}"
echo "  ${BLUE}ccteam${NC}         - Start CCTeam from anywhere"
echo "  ${BLUE}cct${NC}            - Short alias for ccteam"
echo "  ${BLUE}cca${NC}            - Attach to running session"
echo "  ${BLUE}ccs${NC}            - Check status"
echo ""
echo "Try it now: ${BLUE}ccteam${NC}"