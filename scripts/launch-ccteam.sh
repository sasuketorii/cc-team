#!/bin/bash

# CCTeam Launch Script
# 全エージェントを起動し、初期指示を送信します

set -e

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "🚀 CCTeam を起動します..."

# セットアップが完了しているか確認
if ! tmux has-session -t ccteam 2>/dev/null; then
    echo "⚠️  tmuxセッションが見つかりません"
    echo "まず ./scripts/setup.sh を実行してください"
    exit 1
fi

# 要件定義の存在確認
if [ ! -d "requirements" ] || [ -z "$(ls -A requirements 2>/dev/null)" ]; then
    echo "⚠️  requirements/ フォルダに要件定義ファイルが見つかりません"
    echo "プロジェクトの要件定義を配置してから再実行してください"
    
    # サンプルの作成を提案
    read -p "サンプル要件定義を作成しますか？ (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./scripts/create-sample-requirements.sh
        echo "✅ サンプル要件定義を作成しました"
    else
        exit 1
    fi
fi

# ログディレクトリの確認
mkdir -p logs

# タイムスタンプ
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "🤖 各エージェントでClaude Codeを起動しています..."

# 各ペインでClaude Codeを起動
for pane in 0 1 2 3; do
    tmux send-keys -t ccteam:main.$pane "claude --dangerously-skip-permissions" C-m
    sleep 2
done

echo "⏳ Claude Codeの起動を待機しています..."
sleep 5

# 初期指示を送信
echo "📋 初期指示を送信しています..."

# BOSSへの初期指示
BOSS_INSTRUCTION="あなたはBOSSエージェントです。プロジェクトマネージャーとして、3人のWorkerエージェントを統括してください。

役割:
- プロジェクト全体の管理と進捗追跡
- タスクの分解と各Workerへの適切な割り当て
- 品質管理とリスク管理
- 定期的な進捗確認（10分ごと）

利用可能なWorker:
- Worker1: フロントエンド開発担当
- Worker2: バックエンド開発担当  
- Worker3: インフラ・テスト担当

通信方法:
./scripts/agent-send.sh worker1 \"タスク内容\"

まず、requirements/ フォルダ内の要件定義を全て読み込んで、プロジェクトの全体像を把握してください。その後、適切なタスクに分解してWorkerに割り当ててください。"

# Worker1への初期指示
WORKER1_INSTRUCTION="あなたはWorker1エージェントです。フロントエンド開発を担当します。

役割:
- UI/UXの実装
- フロントエンドフレームワークの構築
- ユーザーインターフェースの最適化
- レスポンシブデザインの実装

BOSSからの指示を待って、タスクを実行してください。完了したら必ず報告してください。

通信方法:
./scripts/agent-send.sh boss \"進捗報告内容\""

# Worker2への初期指示  
WORKER2_INSTRUCTION="あなたはWorker2エージェントです。バックエンド開発を担当します。

役割:
- API設計と実装
- データベース設計
- ビジネスロジックの実装
- セキュリティ対策

BOSSからの指示を待って、タスクを実行してください。完了したら必ず報告してください。

通信方法:
./scripts/agent-send.sh boss \"進捗報告内容\""

# Worker3への初期指示
WORKER3_INSTRUCTION="あなたはWorker3エージェントです。インフラストラクチャとテストを担当します。

役割:
- インフラ構築（Docker、CI/CD）
- テストコードの作成と実行
- デプロイメント設定
- パフォーマンス最適化

BOSSからの指示を待って、タスクを実行してください。完了したら必ず報告してください。

通信方法:
./scripts/agent-send.sh boss \"進捗報告内容\""

# 各エージェントに指示を送信
./scripts/agent-send.sh boss "$BOSS_INSTRUCTION"
sleep 3
./scripts/agent-send.sh worker1 "$WORKER1_INSTRUCTION"
sleep 2
./scripts/agent-send.sh worker2 "$WORKER2_INSTRUCTION"
sleep 2
./scripts/agent-send.sh worker3 "$WORKER3_INSTRUCTION"

# 起動ログ
echo "[$TIMESTAMP] CCTeam launched successfully" >> logs/system.log

echo "✅ CCTeamが正常に起動しました！"
echo ""
echo "📺 tmuxセッションに接続するには:"
echo "   ${GREEN}tmux attach -t ccteam${NC}"
echo ""
echo "📊 ステータスを確認するには:"
echo "   ${GREEN}./scripts/project-status.sh${NC}"
echo ""
echo "💡 ヒント:"
echo "- Ctrl+b → 矢印キー でペイン間を移動"
echo "- Ctrl+b → d でデタッチ"
echo "- 各エージェントが自律的に作業を開始します"