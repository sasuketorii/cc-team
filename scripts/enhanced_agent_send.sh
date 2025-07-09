#!/bin/bash

# Enhanced agent-send.sh with structured logging
# 構造化ログ機能を追加したエージェント送信スクリプト

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# 引数チェック
if [ $# -lt 2 ]; then
    echo "Usage: $0 <agent> <message>"
    echo "Agents: boss, worker1, worker2, worker3"
    exit 1
fi

AGENT=$1
MESSAGE=$2

# エージェント名の検証
case $AGENT in
    boss|worker1|worker2|worker3)
        ;;
    *)
        echo "Error: Invalid agent name. Use: boss, worker1, worker2, worker3"
        exit 1
        ;;
esac

# tmuxペインのマッピング
case $AGENT in
    boss)
        PANE="ccteam-boss:main.0"
        ;;
    worker1)
        PANE="ccteam:main.0"
        ;;
    worker2)
        PANE="ccteam:main.1"
        ;;
    worker3)
        PANE="ccteam:main.2"
        ;;
esac

# タイムスタンプ
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 構造化ログを記録（Pythonロガーを使用）
python3 << EOF
import sys
sys.path.append('$SCRIPT_DIR')
from structured_logger import StructuredLogger

logger = StructuredLogger("agent_send")
logger.log_communication(
    from_agent="user",
    to_agent="$AGENT",
    message="""$MESSAGE""",
    success=True
)
EOF

# メッセージ送信
echo "[$TIMESTAMP] Sending to $AGENT: $MESSAGE" >> logs/communication.log

# Ctrl+C を送信してプロンプトをクリア
tmux send-keys -t "$PANE" C-c

# 少し待機
sleep 0.5

# メッセージを送信
tmux send-keys -t "$PANE" "$MESSAGE" C-m

echo "✅ Message sent to $AGENT"

# エラーループチェック（エラーキーワードが含まれる場合）
if echo "$MESSAGE" | grep -iE "(error|exception|failed|失敗)" > /dev/null; then
    python3 scripts/error_loop_detector.py check --agent "$AGENT" --error "$MESSAGE" || true
fi