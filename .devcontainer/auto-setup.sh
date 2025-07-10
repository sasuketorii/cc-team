#!/bin/bash
# CCTeam DevContainer 自動セットアップスクリプト v1.0.0
# 完全自動化されたDevContainer環境構築

set -e

echo "🚀 CCTeam DevContainer 完全自動セットアップ開始"
echo "================================================"
echo "Version: 1.0.0"
echo "Date: $(date)"
echo ""

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# プロジェクトルート
PROJECT_ROOT="/workspaces/CCTeam"

# エラーハンドリング
error_exit() {
    echo -e "${RED}❌ エラー: $1${NC}" >&2
    exit 1
}

# 成功メッセージ
success_msg() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 警告メッセージ
warning_msg() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 情報メッセージ
info_msg() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 1. 基本的なセットアップ（既存のpost-create.sh実行）
echo -e "${YELLOW}📦 基本セットアップを実行中...${NC}"
if [ -f "$PROJECT_ROOT/.devcontainer/post-create.sh" ]; then
    bash "$PROJECT_ROOT/.devcontainer/post-create.sh"
else
    warning_msg "post-create.shが見つかりません。スキップします。"
fi

# 2. Git Worktree環境の自動初期化
echo ""
echo -e "${YELLOW}🌳 Git Worktree環境を初期化中...${NC}"

cd "$PROJECT_ROOT"

# Worktreeディレクトリの準備
if [ ! -d "worktrees" ]; then
    mkdir -p worktrees
    success_msg "worktreesディレクトリを作成しました"
fi

# worktree-parallel-manual.shの存在確認と実行
if [ -f "./scripts/worktree-parallel-manual.sh" ]; then
    info_msg "既存のWorktree設定スクリプトを実行します"
    ./scripts/worktree-parallel-manual.sh setup || warning_msg "Worktree設定で警告が発生しました"
else
    warning_msg "worktree-parallel-manual.shが見つかりません"
fi

# 3. CCTeam自動起動オプションの設定
echo ""
echo -e "${YELLOW}🤖 CCTeam自動起動オプションを設定中...${NC}"

# .bashrcへの追加（重複チェック付き）
if ! grep -q "CCTEAM_AUTO_START" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'EOF'

# ========================================
# CCTeam DevContainer Auto-Start Settings
# ========================================

# CCTeamプロジェクトディレクトリ
export CCTEAM_PROJECT_ROOT="/workspaces/CCTeam"

# CCTeam自動起動関数
ccteam_auto_start() {
    if [ -z "$CCTEAM_AUTO_STARTED" ] && [ "$PWD" = "$CCTEAM_PROJECT_ROOT" ]; then
        echo ""
        echo "🤖 CCTeam DevContainer環境へようこそ！"
        echo ""
        echo "オプションを選択してください："
        echo "  1) CCTeamを起動する"
        echo "  2) 手動で起動する（後で 'ccteam' コマンドで起動）"
        echo "  3) 常に自動起動する（次回から自動）"
        echo ""
        echo -n "選択 (1-3): "
        read -r response
        
        case "$response" in
            1)
                export CCTEAM_AUTO_STARTED=1
                echo "CCTeamを起動します..."
                cd "$CCTEAM_PROJECT_ROOT" && ccteam
                ;;
            3)
                echo "export CCTEAM_AUTO_START=always" >> ~/.bashrc_local
                echo "設定を保存しました。次回から自動起動します。"
                export CCTEAM_AUTO_STARTED=1
                cd "$CCTEAM_PROJECT_ROOT" && ccteam
                ;;
            *)
                echo "手動起動モードです。'ccteam' コマンドでいつでも起動できます。"
                export CCTEAM_AUTO_STARTED=1
                ;;
        esac
    fi
}

# 自動起動設定の読み込み
if [ -f ~/.bashrc_local ]; then
    source ~/.bashrc_local
fi

# 常に自動起動が設定されている場合
if [ "$CCTEAM_AUTO_START" = "always" ] && [ -z "$CCTEAM_AUTO_STARTED" ] && [ "$PWD" = "$CCTEAM_PROJECT_ROOT" ]; then
    export CCTEAM_AUTO_STARTED=1
    echo "🚀 CCTeamを自動起動します..."
    cd "$CCTEAM_PROJECT_ROOT" && ccteam
else
    # 初回はプロンプトを表示
    ccteam_auto_start
fi

# 便利なエイリアス（CCTeam専用）
alias cct='cd $CCTEAM_PROJECT_ROOT'
alias ccmon='tmux attach -t ccteam || echo "CCTeamセッションが見つかりません"'
alias cclog='tail -f $CCTEAM_PROJECT_ROOT/logs/*.log'
alias ccs='ccstatus'
alias ccwork='cd $CCTEAM_PROJECT_ROOT/worktrees'

# Worktree用エイリアス
alias wt='git worktree'
alias wtl='git worktree list'
alias wts='$CCTEAM_PROJECT_ROOT/scripts/worktree-auto-manager.sh status'

# プロンプトカスタマイズ（DevContainer表示）
export PS1='\[\033[01;32m\]🐳 CCTeam-Dev\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

EOF
    success_msg "起動オプションを設定しました"
else
    info_msg "起動オプションは既に設定されています"
fi

# 4. requirements確認と初期メッセージ
echo ""
echo -e "${YELLOW}📋 プロジェクト要件を確認中...${NC}"

if [ -d "$PROJECT_ROOT/requirements" ] && [ "$(ls -A $PROJECT_ROOT/requirements/*.md 2>/dev/null)" ]; then
    success_msg "要件定義ファイルを検出しました："
    echo ""
    ls -la $PROJECT_ROOT/requirements/*.md | awk '{print "  📄 " $9}'
    echo ""
    info_msg "CCTeam起動後、以下のコマンドでプロジェクトを開始できます："
    echo "    ./scripts/agent-send.sh boss \"requirementsフォルダの要件を読み込んで、プロジェクトを開始してください\""
else
    warning_msg "requirements/フォルダに要件定義ファイルがありません"
    info_msg "要件定義ファイルを配置してからプロジェクトを開始してください"
fi

# 5. 通知システムのセットアップ
echo ""
echo -e "${YELLOW}🔔 通知システムをセットアップ中...${NC}"

setup_notifications() {
    # Claude Code hooks用ディレクトリ
    mkdir -p ~/.claude/hooks
    
    # CCTeam通知ディレクトリ
    mkdir -p ~/.ccteam
    
    # 通知ハンドラー作成
    if [ ! -f ~/.ccteam/ccteam-notify.sh ]; then
        cat > ~/.ccteam/ccteam-notify.sh << 'HOOK'
#!/bin/bash
# CCTeam DevContainer通知ハンドラー

EVENT=$1
MESSAGE=$2

# ログ記録
echo "[$(date '+%Y-%m-%d %H:%M:%S')] $EVENT: $MESSAGE" >> ~/.ccteam/notifications.log

# DevContainer内では視覚的な通知は限定的
# 代わりにログとターミナル出力を使用
case "$EVENT" in
    "task_complete")
        echo -e "\033[0;32m✅ [完了] $MESSAGE\033[0m"
        ;;
    "error")
        echo -e "\033[0;31m❌ [エラー] $MESSAGE\033[0m"
        ;;
    "approval_needed")
        echo -e "\033[1;33m🔔 [承認待ち] $MESSAGE\033[0m"
        ;;
    *)
        echo -e "\033[0;34mℹ️  [情報] $MESSAGE\033[0m"
        ;;
esac

# VS Code通知（拡張機能経由）
# TODO: VS Code拡張機能との連携実装
HOOK
        chmod +x ~/.ccteam/ccteam-notify.sh
        success_msg "通知ハンドラーを作成しました"
    else
        info_msg "通知ハンドラーは既に存在します"
    fi
}

setup_notifications

# 6. VS Code設定の最適化
echo ""
echo -e "${YELLOW}⚙️  VS Code設定を最適化中...${NC}"

# ワークスペース設定
if [ ! -f "$PROJECT_ROOT/.vscode/settings.json" ]; then
    mkdir -p "$PROJECT_ROOT/.vscode"
    cat > "$PROJECT_ROOT/.vscode/settings.json" << 'EOF'
{
    "terminal.integrated.defaultProfile.linux": "bash",
    "terminal.integrated.profiles.linux": {
        "bash": {
            "path": "/bin/bash",
            "args": ["-l"]
        }
    },
    "files.watcherExclude": {
        "**/worktrees/**": true,
        "**/logs/**": true,
        "**/node_modules/**": true
    },
    "search.exclude": {
        "**/worktrees/**": true,
        "**/logs/**": true
    },
    "git.ignoreLimitWarning": true,
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "[shellscript]": {
        "editor.defaultFormatter": "foxundermoon.shell-format"
    }
}
EOF
    success_msg "VS Code設定を作成しました"
fi

# 7. 環境変数の設定
echo ""
echo -e "${YELLOW}🔧 環境変数を設定中...${NC}"

# DevContainer専用環境変数
export CCTEAM_DEV_CONTAINER="true"
export CCTEAM_AUTO_WORKTREE="true"
export BOSS_VERSION="2.0"
export BOSS_AUTO_WORKTREE="true"
export BOSS_NOTIFICATION="true"

# 環境変数をファイルに保存（永続化）
cat > ~/.ccteam/env << EOF
# CCTeam DevContainer環境変数
export CCTEAM_DEV_CONTAINER="true"
export CCTEAM_AUTO_WORKTREE="true"
export BOSS_VERSION="2.0"
export BOSS_AUTO_WORKTREE="true"
export BOSS_NOTIFICATION="true"
export CCTEAM_PROJECT_ROOT="$PROJECT_ROOT"
EOF

# .bashrcから読み込み
if ! grep -q "source ~/.ccteam/env" ~/.bashrc 2>/dev/null; then
    echo "source ~/.ccteam/env" >> ~/.bashrc
fi

# 8. 最終チェックとレポート
echo ""
echo -e "${BLUE}📊 セットアップ完了レポート${NC}"
echo "=================================="

# Git状態
echo -e "${YELLOW}Git状態:${NC}"
cd "$PROJECT_ROOT"
BRANCH=$(git branch --show-current 2>/dev/null || echo "不明")
echo "  現在のブランチ: $BRANCH"

# Worktree状態
if command -v git &> /dev/null; then
    WORKTREE_COUNT=$(git worktree list 2>/dev/null | wc -l)
    echo "  Worktree数: $WORKTREE_COUNT"
fi

# CCTeamコマンド
echo ""
echo -e "${YELLOW}利用可能なコマンド:${NC}"
if command -v ccteam &> /dev/null; then
    echo "  ✅ ccteam    - CCTeamを起動"
else
    echo "  ❌ ccteam    - 未インストール"
fi

if command -v ccguide &> /dev/null; then
    echo "  ✅ ccguide   - ガイド付き起動"
else
    echo "  ❌ ccguide   - 未インストール"
fi

# ディレクトリ状態
echo ""
echo -e "${YELLOW}ディレクトリ状態:${NC}"
[ -d "$PROJECT_ROOT/worktrees" ] && echo "  ✅ worktrees/" || echo "  ❌ worktrees/"
[ -d "$PROJECT_ROOT/logs" ] && echo "  ✅ logs/" || echo "  ❌ logs/"
[ -d "$PROJECT_ROOT/requirements" ] && echo "  ✅ requirements/" || echo "  ❌ requirements/"
[ -d "$PROJECT_ROOT/memory" ] && echo "  ✅ memory/" || echo "  ❌ memory/"

# 9. ウェルカムメッセージ
echo ""
echo "================================================"
echo -e "${GREEN}✅ CCTeam DevContainer セットアップ完了！${NC}"
echo "================================================"
echo ""
echo "🎉 開発環境の準備が整いました！"
echo ""
echo "📚 クイックスタート:"
echo "  1. ターミナルを再読み込み: source ~/.bashrc"
echo "  2. CCTeamを起動: ccteam"
echo "  3. プロジェクト開始: Bossに指示を送る"
echo ""
echo "💡 便利なエイリアス:"
echo "  cct     - プロジェクトルートへ移動"
echo "  ccwork  - worktreesディレクトリへ移動"
echo "  ccmon   - CCTeamセッションに接続"
echo "  ccs     - ステータス確認"
echo "  cclog   - ログをリアルタイム表示"
echo "  wtl     - Worktree一覧表示"
echo ""
echo "📖 ドキュメント:"
echo "  - /workspaces/CCTeam/README.md"
echo "  - /workspaces/CCTeam/docs/"
echo ""
echo "Happy Coding with CCTeam! 🚀"
echo ""

# スクリプト終了
exit 0