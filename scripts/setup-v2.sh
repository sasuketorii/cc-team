#!/bin/bash

# CCTeam セットアップスクリプト v2.0.0
# 幹部（Boss+Gemini）とワーカー（3分割）の分離アーキテクチャ

set -euo pipefail

# 共通カラー定義を読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/colors.sh"

echo -e "${BLUE}🚀 CCTeam セットアップ開始 (v2.0.0)${NC}"
echo ""

# ログディレクトリの作成
echo "ログディレクトリを作成中..."
mkdir -p logs memory reports tmp worktrees

# 既存セッションのクリーンアップ
echo "既存のtmuxセッションをクリーンアップ中..."
tmux kill-session -t ccteam 2>/dev/null || true
tmux kill-session -t ccteam-boss 2>/dev/null || true
tmux kill-session -t ccteam-workers 2>/dev/null || true
tmux kill-session -t ccteam-support 2>/dev/null || true
tmux kill-session -t ccteam-gemini 2>/dev/null || true

# ワーカーセッション作成（3分割）
echo -e "${GREEN}ワーカーセッション 'ccteam-workers' を作成中...${NC}"
tmux new-session -d -s ccteam-workers -n main

# 3分割レイアウト作成（横に3分割）
echo "ワーカー3分割レイアウトを構成中..."
# 2分割
tmux split-window -h -t ccteam-workers:main
# 3分割
tmux split-window -h -t ccteam-workers:main.0

# レイアウトを均等に調整
tmux select-layout -t ccteam-workers:main even-horizontal

# ペインに名前を設定（tmux 3.0以降の機能）
if tmux -V | grep -qE "(^tmux 3\.|^tmux [4-9]\.)"; then
    echo "ワーカーペインに名前を設定中..."
    tmux select-pane -t ccteam-workers:main.0 -T "Worker1 (Frontend)"
    tmux select-pane -t ccteam-workers:main.1 -T "Worker2 (Backend)"
    tmux select-pane -t ccteam-workers:main.2 -T "Worker3 (Infra/Test)"
fi

# 幹部セッション作成（Boss+Gemini 2分割）
echo -e "${GREEN}幹部セッション 'ccteam-boss' を作成中...${NC}"
tmux new-session -d -s ccteam-boss -n main

# 左右に分割
tmux split-window -h -t ccteam-boss:main

# ペインに名前を設定
if tmux -V | grep -qE "(^tmux 3\.|^tmux [4-9]\.)"; then
    echo "幹部ペインに名前を設定中..."
    tmux select-pane -t ccteam-boss:main.0 -T "Boss (Manager)"
    tmux select-pane -t ccteam-boss:main.1 -T "Gemini (Advisor)"
fi

# レイアウトを均等に調整
tmux select-layout -t ccteam-boss:main even-horizontal

# ログファイルの初期化
echo "ログファイルを初期化中..."
touch logs/boss.log
touch logs/worker1.log
touch logs/worker2.log
touch logs/worker3.log
touch logs/gemini.log
touch logs/system.log
touch logs/communication.log

# セッション情報を記録
cat > logs/session_info.txt << EOF
CCTeam Session Information (v2.0.0)
Created: $(date)
Architecture: Executive-Worker Separation

Sessions:
- ccteam-workers: Worker session (3-way split)
  - Pane 0: Worker1 (Frontend)
  - Pane 1: Worker2 (Backend)
  - Pane 2: Worker3 (Infrastructure/Testing)
  
- ccteam-boss: Executive session (2-way split)
  - Pane 0: Boss (Strategic Manager)
  - Pane 1: Gemini (AI Strategic Advisor)

Note: Boss manages all workers from the executive session.
EOF

# AIモデル設定の実行
if [[ -f "scripts/setup-models-simple.sh" ]]; then
    echo ""
    echo -e "${YELLOW}AIモデルの設定を開始します...${NC}"
    ./scripts/setup-models-simple.sh
fi

echo ""
echo -e "${GREEN}✅ セットアップが完了しました！${NC}"
echo ""
echo "📋 新しいセッション構成:"
echo -e "  - ${BLUE}ccteam-workers${NC}: Worker1, Worker2, Worker3（3分割）"
echo -e "  - ${RED}ccteam-boss${NC}: Boss + Gemini（2分割幹部）"
echo ""
echo "🔧 次のステップ:"
echo -e "  1. ワーカーセッションに接続: ${GREEN}tmux attach -t ccteam-workers${NC}"
echo -e "  2. 幹部セッションに接続: ${GREEN}tmux attach -t ccteam-boss${NC}"
echo -e "  3. CCTeamを起動: ${GREEN}./scripts/launch-ccteam.sh${NC}"
echo ""
echo -e "${BLUE}💡 ヒント: Bossが幹部セッションから全ワーカーを管理します${NC}"