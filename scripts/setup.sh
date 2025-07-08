#!/bin/bash

# CCTeam Setup Script
# tmuxセッションの初期設定を行います

set -e

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "🚀 CCTeam セットアップを開始します..."

# tmuxがインストールされているか確認
if ! command -v tmux &> /dev/null; then
    echo "❌ tmuxがインストールされていません。インストールしてください。"
    echo "   macOS: brew install tmux"
    echo "   Ubuntu: sudo apt-get install tmux"
    exit 1
fi

# Claude Codeがインストールされているか確認
if ! command -v claude &> /dev/null; then
    echo "❌ Claude Codeがインストールされていません。"
    echo "   https://docs.anthropic.com/claude-code をご確認ください。"
    exit 1
fi

# 必要なディレクトリを作成
echo "📁 ディレクトリを作成しています..."
mkdir -p logs
mkdir -p tmp
mkdir -p worktrees

# tmuxセッションが既に存在する場合は削除
if tmux has-session -t ccteam 2>/dev/null; then
    echo "⚠️  既存のccteamセッションを削除します..."
    tmux kill-session -t ccteam
fi

# 新しいtmuxセッションを作成（2x2レイアウト）
echo "🖥️  tmuxセッションを作成しています..."
tmux new-session -d -s ccteam -n main

# 2x2のペインを作成
tmux split-window -h -t ccteam:main
tmux split-window -v -t ccteam:main.0
tmux split-window -v -t ccteam:main.2

# 各ペインに名前を設定（tmux 3.1以降）
if tmux -V | grep -q "3\.[1-9]"; then
    tmux select-pane -t ccteam:main.0 -T "BOSS"
    tmux select-pane -t ccteam:main.1 -T "Worker1"
    tmux select-pane -t ccteam:main.2 -T "Worker2"
    tmux select-pane -t ccteam:main.3 -T "Worker3"
fi

# 各ペインでプロンプトカラーを設定
echo "🎨 プロンプトカラーを設定しています..."

# BOSS (赤)
tmux send-keys -t ccteam:main.0 "export PS1='${RED}[BOSS]${NC} \w $ '" C-m
tmux send-keys -t ccteam:main.0 "clear" C-m

# Worker1 (青)
tmux send-keys -t ccteam:main.1 "export PS1='${BLUE}[Worker1]${NC} \w $ '" C-m
tmux send-keys -t ccteam:main.1 "clear" C-m

# Worker2 (緑)
tmux send-keys -t ccteam:main.2 "export PS1='${GREEN}[Worker2]${NC} \w $ '" C-m
tmux send-keys -t ccteam:main.2 "clear" C-m

# Worker3 (黄)
tmux send-keys -t ccteam:main.3 "export PS1='${YELLOW}[Worker3]${NC} \w $ '" C-m
tmux send-keys -t ccteam:main.3 "clear" C-m

# 作業ディレクトリを設定
WORK_DIR=$(pwd)
for pane in 0 1 2 3; do
    tmux send-keys -t ccteam:main.$pane "cd $WORK_DIR" C-m
done

# ログファイルを初期化
echo "📝 ログファイルを初期化しています..."
> logs/system.log
> logs/boss.log
> logs/worker1.log
> logs/worker2.log
> logs/worker3.log

# AIモデル設定
echo -e "\n🤖 Setting up AI models..."
./scripts/setup-models-simple.sh

# セットアップ完了メッセージ
echo "✅ セットアップが完了しました！"
echo ""
echo "次のステップ:"
echo "1. 要件定義を requirements/ フォルダに配置してください"
echo "2. ./scripts/launch-ccteam.sh を実行してCCTeamを起動してください"
echo "3. tmux attach -t ccteam でセッションに接続してください"
echo ""
echo "tmux基本操作:"
echo "- Ctrl+b → 矢印キー: ペイン間移動"
echo "- Ctrl+b → d: デタッチ"
echo "- Ctrl+b → [: スクロールモード（qで終了）"

# セットアップログを記録
echo "[$(date '+%Y-%m-%d %H:%M:%S')] CCTeam setup completed" >> logs/system.log