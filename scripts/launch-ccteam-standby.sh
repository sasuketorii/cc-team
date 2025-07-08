#!/bin/bash

# CCTeam Launch Script (Standby Mode)
# 全エージェントを起動し、ユーザーの指示を待機します

set -e

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "🚀 CCTeam を待機モードで起動します..."

# セットアップが完了しているか確認
if ! tmux has-session -t ccteam 2>/dev/null; then
    echo "⚠️  tmuxセッションが見つかりません"
    echo "まず ./scripts/setup.sh を実行してください"
    exit 1
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

# 初期指示を送信（待機モード）
echo "📋 待機モードの初期指示を送信しています..."

# BOSSへの待機指示
BOSS_STANDBY="あなたはBOSSエージェントです。現在は待機モードです。

⚠️ 重要: まだ作業を開始しないでください。ユーザーから明確な指示があるまで待機してください。

役割:
- プロジェクト全体の管理と進捗追跡
- タスクの分解と各Workerへの適切な割り当て
- 品質管理とリスク管理

利用可能なWorker:
- Worker1: フロントエンド開発担当
- Worker2: バックエンド開発担当  
- Worker3: インフラ・テスト担当

通信方法:
./scripts/agent-send.sh worker1 \"タスク内容\"

現在は待機モードです。ユーザーから「開始してください」や具体的なタスクの指示があるまで、何もアクションを起こさないでください。"

# Worker1への待機指示
WORKER1_STANDBY="あなたはWorker1エージェントです。フロントエンド開発を担当します。

⚠️ 重要: 現在は待機モードです。BOSSから明確な指示があるまで、何も作業を開始しないでください。

役割:
- UI/UXの実装
- フロントエンドフレームワークの構築
- ユーザーインターフェースの最適化

通信方法:
./scripts/agent-send.sh boss \"進捗報告内容\"

BOSSからの指示を待ってください。勝手に作業を開始しないでください。"

# Worker2への待機指示  
WORKER2_STANDBY="あなたはWorker2エージェントです。バックエンド開発を担当します。

⚠️ 重要: 現在は待機モードです。BOSSから明確な指示があるまで、何も作業を開始しないでください。

役割:
- API設計と実装
- データベース設計
- ビジネスロジックの実装

通信方法:
./scripts/agent-send.sh boss \"進捗報告内容\"

BOSSからの指示を待ってください。勝手に作業を開始しないでください。"

# Worker3への待機指示
WORKER3_STANDBY="あなたはWorker3エージェントです。インフラストラクチャとテストを担当します。

⚠️ 重要: 現在は待機モードです。BOSSから明確な指示があるまで、何も作業を開始しないでください。

役割:
- インフラ構築（Docker、CI/CD）
- テストコードの作成と実行
- デプロイメント設定

通信方法:
./scripts/agent-send.sh boss \"進捗報告内容\"

BOSSからの指示を待ってください。勝手に作業を開始しないでください。"

# 各エージェントに待機指示を送信
./scripts/agent-send.sh boss "$BOSS_STANDBY"
sleep 3
./scripts/agent-send.sh worker1 "$WORKER1_STANDBY"
sleep 2
./scripts/agent-send.sh worker2 "$WORKER2_STANDBY"
sleep 2
./scripts/agent-send.sh worker3 "$WORKER3_STANDBY"

# 起動ログ
echo "[$TIMESTAMP] CCTeam launched in standby mode" >> logs/system.log

echo "✅ CCTeamが待機モードで起動しました！"
echo ""
echo "⏸️  ${YELLOW}全エージェントは待機状態です${NC}"
echo ""
echo "📺 tmuxセッションに接続するには:"
echo "   ${GREEN}tmux attach -t ccteam${NC}"
echo ""
echo "🚀 作業を開始するには、BOSSに指示を送信してください:"
echo "   ${GREEN}./scripts/agent-send.sh boss \"requirementsを読み込んで作業を開始してください\"${NC}"
echo ""
echo "📊 ステータスを確認するには:"
echo "   ${GREEN}./scripts/project-status.sh${NC}"
echo ""
echo "💡 ヒント:"
echo "- Ctrl+b → 矢印キー でペイン間を移動"
echo "- Ctrl+b → d でデタッチ"
echo "- エージェントはあなたの指示を待っています"