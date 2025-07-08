#!/bin/bash
# CCTeam Setup v2 - 高速起動版
# Boss+Gemini用とWorkers用の2つのtmuxセッションを作成

set -e

# カラー定義
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
YELLOW=$'\033[0;33m'
PURPLE=$'\033[0;35m'
NC=$'\033[0m'

echo "🚀 CCTeam セットアップ v2 を開始します..."

# 必要なディレクトリを作成
echo "📁 ディレクトリを作成しています..."
mkdir -p logs
mkdir -p tmp
mkdir -p worktrees
mkdir -p reports

# 既存のtmuxセッションをクリーンアップ
echo "🧹 既存のセッションをクリーンアップしています..."
tmux kill-session -t ccteam-boss 2>/dev/null || true
tmux kill-session -t ccteam-workers 2>/dev/null || true

# Boss+Geminiセッション作成（横分割）
echo "👔 Boss+Geminiセッションを作成しています..."
tmux new-session -d -s ccteam-boss -n main
tmux split-window -h -t ccteam-boss:main

# プロンプト設定
tmux select-pane -t ccteam-boss:main.0 -T "BOSS"
tmux send-keys -t ccteam-boss:main.0 "export PS1='${PURPLE}[BOSS]${NC} \w $ '" C-m
tmux send-keys -t ccteam-boss:main.0 "clear" C-m
tmux send-keys -t ccteam-boss:main.0 "echo '👔 BOSS - プロジェクト統括'" C-m
tmux send-keys -t ccteam-boss:main.0 "echo '役割: 全体管理、タスク分配、品質管理'" C-m

tmux select-pane -t ccteam-boss:main.1 -T "GEMINI"
tmux send-keys -t ccteam-boss:main.1 "export PS1='${GREEN}[GEMINI]${NC} \w $ '" C-m
tmux send-keys -t ccteam-boss:main.1 "clear" C-m
tmux send-keys -t ccteam-boss:main.1 "echo '🤖 GEMINI - AI補佐'" C-m
tmux send-keys -t ccteam-boss:main.1 "echo '役割: 調査、ドキュメント生成、情報収集'" C-m

# Workersセッション作成（2x2分割）
echo "👷 Workersセッションを作成しています..."
tmux new-session -d -s ccteam-workers -n main

# 2x2の4分割を作成
tmux split-window -h -t ccteam-workers:main
tmux split-window -v -t ccteam-workers:main.0
tmux split-window -v -t ccteam-workers:main.2

# 各Workerのプロンプト設定
# Worker1 (右上)
tmux select-pane -t ccteam-workers:main.0 -T "Worker1"
tmux send-keys -t ccteam-workers:main.0 "export PS1='${BLUE}[Worker1]${NC} \w $ '" C-m
tmux send-keys -t ccteam-workers:main.0 "clear" C-m
tmux send-keys -t ccteam-workers:main.0 "echo '🎨 Worker1 - フロントエンド開発'" C-m
tmux send-keys -t ccteam-workers:main.0 "echo '役割: UI/UX実装、React/Vue開発'" C-m

# Worker2 (左下)
tmux select-pane -t ccteam-workers:main.1 -T "Worker2"
tmux send-keys -t ccteam-workers:main.1 "export PS1='${GREEN}[Worker2]${NC} \w $ '" C-m
tmux send-keys -t ccteam-workers:main.1 "clear" C-m
tmux send-keys -t ccteam-workers:main.1 "echo '⚙️ Worker2 - バックエンド開発'" C-m
tmux send-keys -t ccteam-workers:main.1 "echo '役割: API実装、データベース設計'" C-m

# Worker3 (右上)
tmux select-pane -t ccteam-workers:main.2 -T "Worker3"
tmux send-keys -t ccteam-workers:main.2 "export PS1='${RED}[Worker3]${NC} \w $ '" C-m
tmux send-keys -t ccteam-workers:main.2 "clear" C-m
tmux send-keys -t ccteam-workers:main.2 "echo '🔧 Worker3 - インフラ/DevOps'" C-m
tmux send-keys -t ccteam-workers:main.2 "echo '役割: Docker、CI/CD、デプロイ'" C-m

# Worker4 (右下)
tmux select-pane -t ccteam-workers:main.3 -T "Worker4"
tmux send-keys -t ccteam-workers:main.3 "export PS1='${YELLOW}[Worker4]${NC} \w $ '" C-m
tmux send-keys -t ccteam-workers:main.3 "clear" C-m
tmux send-keys -t ccteam-workers:main.3 "echo '🧪 Worker4 - テスト/品質保証'" C-m
tmux send-keys -t ccteam-workers:main.3 "echo '役割: テスト作成、品質チェック'" C-m

# 作業ディレクトリを設定
WORK_DIR=$(pwd)
for session in ccteam-boss ccteam-workers; do
    for pane in 0 1 2 3; do
        tmux send-keys -t $session:main.$pane "cd $WORK_DIR" C-m 2>/dev/null || true
    done
done

# ログファイルを初期化
echo "📝 ログファイルを初期化しています..."
> logs/system.log
> logs/boss.log
> logs/gemini.log
> logs/worker1.log
> logs/worker2.log
> logs/worker3.log
> logs/worker4.log
> logs/communication.log

# AI設定を実行
if [ -f "./scripts/setup-models-simple.sh" ]; then
    echo "🤖 AIモデルを設定しています..."
    ./scripts/setup-models-simple.sh
fi

# セットアップ完了メッセージ
echo "✅ セットアップが完了しました！"
echo ""
echo "📺 tmuxセッションに接続："
echo "  Boss+Gemini: ${GREEN}tmux attach -t ccteam-boss${NC}"
echo "  Workers:     ${GREEN}tmux attach -t ccteam-workers${NC}"
echo ""
echo "🚀 Claude Codeを起動："
echo "  ${GREEN}./scripts/launch-ccteam-v2.sh${NC}"
echo ""
echo "💡 セッション切り替え："
echo "  Ctrl+b → s でセッション一覧"
echo "  Ctrl+b → d でデタッチ"

# 初期化フラグを作成
touch .initialized

# セットアップログを記録
echo "[$(date '+%Y-%m-%d %H:%M:%S')] CCTeam v2 setup completed" >> logs/system.log