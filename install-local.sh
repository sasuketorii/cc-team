#!/bin/bash
# CCTeam ローカルインストーラー（sudoなし版）

set -e

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 CCTeam Local Installer (No sudo)${NC}"
echo "======================================"

# インストール先の確認
INSTALL_DIR="$HOME/CC-Team/CCTeam"
LOCAL_BIN="$HOME/.local/bin"

if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${RED}Error: CCTeam not found at $INSTALL_DIR${NC}"
    exit 1
fi

# ローカルbinディレクトリ作成
mkdir -p "$LOCAL_BIN"

# グローバルコマンドの作成
echo -e "\n${YELLOW}Creating commands in ~/.local/bin...${NC}"

# ccteamコマンド作成（v3起動スクリプトを使用）
cat > "$LOCAL_BIN/ccteam" << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/launch-ccteam-v3.sh
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
tmux attach -t ccteam-boss || tmux attach -t ccteam-workers
EOF

cat > "$LOCAL_BIN/ccteam-kill" << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/ccteam-kill.sh
EOF

cat > "$LOCAL_BIN/ccteam-guided" << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/ccteam-guided.sh
EOF

cat > "$LOCAL_BIN/ccteam-monitor" << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/ccteam-monitor.sh
EOF

cat > "$LOCAL_BIN/ccteam-prompts" << EOF
#!/bin/bash
cd "$INSTALL_DIR" && ./scripts/ccteam-prompts.sh
EOF

# 実行権限を付与
chmod +x "$LOCAL_BIN"/ccteam*

echo -e "${GREEN}✓ Commands created in ~/.local/bin${NC}"

# エイリアス設定ファイル作成
cat > "$HOME/.ccteam-commands" << 'EOF'
# CCTeam Quick Commands
alias cct='ccteam'                    # CCTeam起動
alias cca='ccteam-attach'             # tmuxセッションに接続
alias ccs='ccteam-status'             # ステータス確認
alias ccv='ccteam-version'            # バージョン管理
alias ccsend='ccteam-send'            # エージェントにメッセージ送信
alias cckill='ccteam-kill'            # tmuxセッション終了
alias ccguide='ccteam-guided'         # ガイド付き起動
alias ccmon='ccteam-monitor'          # 状態監視
alias ccprompt='ccteam-prompts'       # プロンプト例

# ショートカット
alias ccbump='ccteam-version bump'    # バージョンアップ
alias ccback='ccteam-version rollback' # ロールバック
EOF

echo -e "${GREEN}✓ Command aliases created${NC}"

# PATH設定の確認
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    echo -e "\n${YELLOW}⚠️  ~/.local/bin is not in your PATH${NC}"
    echo -e "Add this line to your ~/.bashrc or ~/.zshrc:"
    echo -e "${BLUE}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
fi

echo -e "\n${BLUE}📋 Final Steps:${NC}"
echo ""
echo "1. Add to your shell config (~/.bashrc or ~/.zshrc):"
echo -e "${YELLOW}   export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
echo -e "${YELLOW}   source ~/.ccteam-commands${NC}"
echo ""
echo "2. Reload your shell:"
echo -e "${YELLOW}   source ~/.bashrc${NC}  # or ~/.zshrc"
echo ""
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo ""
echo "You can now use:"
echo "  ${BLUE}ccteam${NC}         - Start CCTeam (v3: 手動認証版)"
echo "  ${BLUE}ccguide${NC}        - ガイド付き起動（初心者向け）"
echo "  ${BLUE}ccmon${NC}          - リアルタイム状態監視"
echo "  ${BLUE}ccprompt${NC}       - プロンプトテンプレート表示"
echo ""
echo "No sudo required! 🎉"