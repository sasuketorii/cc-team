#!/bin/bash

# 全エージェントを別々のターミナルタブで開くスクリプト

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🚀 全エージェントを新規ターミナルタブで開きます..."

# tmuxセッションの存在確認
if ! tmux has-session -t ccteam 2>/dev/null; then
    echo "⚠️  CCTeamセッションが見つかりません"
    echo "先に ./scripts/launch-ccteam.sh を実行してください"
    exit 1
fi

# 各エージェントを順番に開く
echo "📋 BOSS (左上) を開いています..."
./scripts/open-boss.sh

echo "🎨 Worker1 (右上) を開いています..."
./scripts/open-worker1.sh

echo "⚙️  Worker2 (左下) を開いています..."
./scripts/open-worker2.sh

echo "🔧 Worker3 (右下) を開いています..."
./scripts/open-worker3.sh

echo ""
echo "✅ 全エージェントを新規タブで開きました！"
echo ""
echo "💡 各タブの説明:"
echo "- ${BLUE}BOSS${NC}: プロジェクト管理・統括"
echo "- ${BLUE}Worker1${NC}: フロントエンド開発"
echo "- ${BLUE}Worker2${NC}: バックエンド開発"
echo "- ${BLUE}Worker3${NC}: インフラ・テスト"