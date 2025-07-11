#!/bin/bash

# Worker3ペインに接続するスクリプト
# 新規ターミナルタブで開きます

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "🎯 Worker3（インフラ・テスト）ペインに接続します..."

# tmuxセッションの存在確認
if ! tmux has-session -t ccteam 2>/dev/null; then
    echo "❌ エラー: CCTeamが起動していません"
    echo ""
    echo "📝 CCTeamを起動するには以下のコマンドを実行してください:"
    echo "   ccteam"
    echo "   または"
    echo "   ./scripts/launch-ccteam.sh"
    exit 1
fi

# macOSの場合、新規ターミナルタブで開く
if [[ "$OSTYPE" == "darwin"* ]]; then
    osascript -e 'tell application "Terminal" to do script "cd '"$(pwd)"' && tmux attach-session -t ccteam:main.3"'
    echo "✅ 新規ターミナルタブでWorker3ペインを開きました"
else
    # Linux/その他の場合は直接接続
    tmux attach-session -t ccteam:main.3
fi

echo ""
echo "💡 ヒント:"
echo "- このペインはWorker3（インフラ・テスト）専用です"
echo "- Ctrl+b → d でデタッチ"
echo "- 他のエージェントに切り替えたい場合は、対応するスクリプトを使用してください"