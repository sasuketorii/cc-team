#!/bin/bash
# CCTeam インストールスクリプト v1.0.0
# グローバルコマンドのインストールと環境設定

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 CCTeam インストーラー v1.0.0${NC}"
echo "=================================="
echo ""

# インストール先の確認
BIN_DIR="$HOME/.local/bin"
echo -e "${YELLOW}📁 インストール先: $BIN_DIR${NC}"

# ディレクトリ作成
mkdir -p "$BIN_DIR"

# グローバルコマンドのインストール
echo ""
echo -e "${GREEN}📦 グローバルコマンドをインストール中...${NC}"

# ccteamコマンド
cat > "$BIN_DIR/ccteam" << 'EOF'
#!/bin/bash
# CCTeam グローバル起動コマンド

# プロジェクトルートを検出
find_ccteam_root() {
    local current_dir="$PWD"
    
    # 現在のディレクトリから上に向かって探索
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/scripts/launch-ccteam-v3.sh" ] && \
           [ -d "$current_dir/instructions" ] && \
           [ -d "$current_dir/requirements" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    
    # 見つからない場合はホームディレクトリのCCTeam関連を探す
    for dir in "$HOME/CCTeam-Dev1/cc-team" "$HOME/cc-team" "$HOME/CCTeam"; do
        if [ -f "$dir/scripts/launch-ccteam-v3.sh" ]; then
            echo "$dir"
            return 0
        fi
    done
    
    return 1
}

# CCTeamプロジェクトルートを検出
if CCTEAM_ROOT=$(find_ccteam_root); then
    cd "$CCTEAM_ROOT"
    exec ./scripts/launch-ccteam-v3.sh "$@"
else
    echo "❌ エラー: CCTeamプロジェクトが見つかりません"
    echo "現在のディレクトリまたは親ディレクトリにCCTeamプロジェクトが存在することを確認してください"
    exit 1
fi
EOF

chmod +x "$BIN_DIR/ccteam"
echo "  ✅ ccteam"

# ccsendコマンド
cat > "$BIN_DIR/ccsend" << 'EOF'
#!/bin/bash
# エージェントへのメッセージ送信

find_ccteam_root() {
    local current_dir="$PWD"
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/scripts/agent-send.sh" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    return 1
}

if CCTEAM_ROOT=$(find_ccteam_root); then
    exec "$CCTEAM_ROOT/scripts/agent-send.sh" "$@"
else
    echo "❌ エラー: CCTeamプロジェクトが見つかりません"
    exit 1
fi
EOF

chmod +x "$BIN_DIR/ccsend"
echo "  ✅ ccsend"

# ccstatusコマンド
cat > "$BIN_DIR/ccstatus" << 'EOF'
#!/bin/bash
# CCTeamステータス確認

find_ccteam_root() {
    local current_dir="$PWD"
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/scripts/project-status.sh" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    return 1
}

if CCTEAM_ROOT=$(find_ccteam_root); then
    exec "$CCTEAM_ROOT/scripts/project-status.sh" "$@"
else
    echo "❌ エラー: CCTeamプロジェクトが見つかりません"
    exit 1
fi
EOF

chmod +x "$BIN_DIR/ccstatus"
echo "  ✅ ccstatus"

# ccmonコマンド
cat > "$BIN_DIR/ccmon" << 'EOF'
#!/bin/bash
# CCTeamモニタリング

find_ccteam_root() {
    local current_dir="$PWD"
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/scripts/ccteam-monitor.sh" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    return 1
}

if CCTEAM_ROOT=$(find_ccteam_root); then
    exec "$CCTEAM_ROOT/scripts/ccteam-monitor.sh" "$@"
else
    echo "❌ エラー: CCTeamプロジェクトが見つかりません"
    exit 1
fi
EOF

chmod +x "$BIN_DIR/ccmon"
echo "  ✅ ccmon"

# cckillコマンド
cat > "$BIN_DIR/cckill" << 'EOF'
#!/bin/bash
# CCTeamセッション終了

find_ccteam_root() {
    local current_dir="$PWD"
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/scripts/ccteam-kill.sh" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    return 1
}

if CCTEAM_ROOT=$(find_ccteam_root); then
    exec "$CCTEAM_ROOT/scripts/ccteam-kill.sh" "$@"
else
    echo "❌ エラー: CCTeamプロジェクトが見つかりません"
    exit 1
fi
EOF

chmod +x "$BIN_DIR/cckill"
echo "  ✅ cckill"

# ccrollcallコマンド
cat > "$BIN_DIR/ccrollcall" << 'EOF'
#!/bin/bash
# CCTeam自動点呼

find_ccteam_root() {
    local current_dir="$PWD"
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/scripts/auto-rollcall.sh" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    return 1
}

if CCTEAM_ROOT=$(find_ccteam_root); then
    exec "$CCTEAM_ROOT/scripts/auto-rollcall.sh" "$@"
else
    echo "❌ エラー: CCTeamプロジェクトが見つかりません"
    exit 1
fi
EOF

chmod +x "$BIN_DIR/ccrollcall"
echo "  ✅ ccrollcall"

# PATH設定の確認と追加
echo ""
echo -e "${YELLOW}🔧 PATH設定を確認中...${NC}"

add_to_path() {
    local shell_rc=$1
    local shell_name=$2
    
    if [ -f "$HOME/$shell_rc" ]; then
        if ! grep -q "$BIN_DIR" "$HOME/$shell_rc"; then
            echo "" >> "$HOME/$shell_rc"
            echo "# CCTeam PATH" >> "$HOME/$shell_rc"
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/$shell_rc"
            echo -e "  ✅ $shell_name: PATH追加完了"
        else
            echo -e "  ℹ️  $shell_name: 既にPATHに追加済み"
        fi
    fi
}

# bash設定
add_to_path ".bashrc" "bash"

# zsh設定
add_to_path ".zshrc" "zsh"

# 現在のシェルにも反映
export PATH="$HOME/.local/bin:$PATH"

# インストール完了
echo ""
echo -e "${GREEN}✅ インストール完了！${NC}"
echo ""
echo "以下のコマンドが利用可能になりました："
echo "  • ccteam      - CCTeamを起動"
echo "  • ccsend      - エージェントにメッセージ送信"
echo "  • ccstatus    - プロジェクトステータス確認"
echo "  • ccmon       - リアルタイムモニタリング"
echo "  • cckill      - CCTeamセッション終了"
echo "  • ccrollcall  - 全エージェントの点呼"
echo ""
echo -e "${YELLOW}💡 新しいターミナルを開くか、以下を実行してPATHを反映してください：${NC}"
echo "   source ~/.bashrc  # bashの場合"
echo "   source ~/.zshrc   # zshの場合"
echo ""
echo -e "${BLUE}🚀 CCTeamを起動するには: ccteam${NC}"