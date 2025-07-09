#!/bin/bash

# Agent Send Script v2.0.0
# 幹部・ワーカー分離アーキテクチャ対応版

set -e

# 引数チェック
if [ $# -lt 2 ]; then
    echo "使用方法: $0 <agent_name> <message>"
    echo "例: $0 boss \"プロジェクトを開始してください\""
    echo ""
    echo "利用可能なエージェント:"
    echo "  【幹部】"
    echo "  - boss    : 統括管理者"
    echo "  - gemini  : AI戦略相談役"
    echo "  【ワーカー】"
    echo "  - worker1 : フロントエンド担当"
    echo "  - worker2 : バックエンド担当" 
    echo "  - worker3 : インフラ/テスト担当"
    exit 1
fi

AGENT=$1
MESSAGE=$2

# エージェント名をtmuxペイン番号にマッピング
case $AGENT in
    "boss")
        PANE="ccteam-boss:main.0"
        LOG_FILE="logs/boss.log"
        SESSION="ccteam-boss"
        ;;
    "gemini")
        PANE="ccteam-boss:main.1"
        LOG_FILE="logs/gemini.log"
        SESSION="ccteam-boss"
        ;;
    "worker1")
        PANE="ccteam-workers:main.0"
        LOG_FILE="logs/worker1.log"
        SESSION="ccteam-workers"
        ;;
    "worker2")
        PANE="ccteam-workers:main.1"
        LOG_FILE="logs/worker2.log"
        SESSION="ccteam-workers"
        ;;
    "worker3")
        PANE="ccteam-workers:main.2"
        LOG_FILE="logs/worker3.log"
        SESSION="ccteam-workers"
        ;;
    *)
        echo "❌ 不明なエージェント: $AGENT"
        echo "利用可能: boss, gemini, worker1, worker2, worker3"
        exit 1
        ;;
esac

# tmuxセッションの存在確認
if ! tmux has-session -t $SESSION 2>/dev/null; then
    echo "❌ $SESSION セッションが見つかりません"
    echo "先に ./scripts/setup-v2.sh を実行してください"
    exit 1
fi

# タイムスタンプ
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# ログディレクトリ確認
mkdir -p logs

# ログに記録
echo "[$TIMESTAMP] 送信: $MESSAGE" >> $LOG_FILE
echo "[$TIMESTAMP] $AGENT <- $MESSAGE" >> logs/system.log

# メッセージ送信の表示
echo "📤 $AGENT にメッセージを送信しています..."

# Ctrl+C でプロンプトをクリア
tmux send-keys -t $PANE C-c

# 少し待機（延長して確実にプロンプトをクリア）
sleep 1.5

# メッセージを送信
tmux send-keys -t $PANE "$MESSAGE" 

# Enterキーを送信
tmux send-keys -t $PANE Enter

echo "✅ メッセージを送信しました"

# 送信履歴を保存
echo "[$TIMESTAMP] $AGENT: $MESSAGE" >> logs/communication.log

# Bossへの送信時の特別処理（ワーカー管理のヒント）
if [[ "$AGENT" == "boss" ]]; then
    echo ""
    echo "💡 ヒント: Bossは以下のワーカーを管理できます:"
    echo "  - worker1: フロントエンド開発"
    echo "  - worker2: バックエンド開発"
    echo "  - worker3: インフラ/テスト"
    echo ""
    echo "例: 「worker1にUIコンポーネントの実装を指示してください」"
fi