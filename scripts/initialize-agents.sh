#!/bin/bash
# CCTeam エージェント初期化スクリプト

set -e

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🤖 CCTeam エージェント初期化開始${NC}"
echo "=================================="

# Boss初期化
echo -e "${YELLOW}👑 Boss初期化中...${NC}"
tmux send-keys -t ccteam-boss:main "あなたはCCTeam全体のBossです。3つのチームを統括します。指示書: @instructions/boss.md を読んで作業を開始してください。" Enter
sleep 1

# Team1初期化
echo -e "${YELLOW}🏢 Team1 (Frontend) 初期化中...${NC}"
tmux send-keys -t ccteam-1:main.0 "あなたはTeam1のPMです。Frontendチームを管理します。指示書: @instructions/team1-frontend/PM-1.md を読んで作業を開始してください。" Enter
sleep 0.5
tmux send-keys -t ccteam-1:main.1 "あなたはTeam1のWorker1です。UIコンポーネント開発を担当します。指示書: @instructions/team1-frontend/worker1-1.md を読んで作業を開始してください。" Enter
sleep 0.5
tmux send-keys -t ccteam-1:main.2 "あなたはTeam1のWorker2です。状態管理を担当します。指示書: @instructions/team1-frontend/worker1-2.md を読んで作業を開始してください。" Enter
sleep 0.5
tmux send-keys -t ccteam-1:main.3 "あなたはTeam1のWorker3です。テスト・品質保証を担当します。指示書: @instructions/team1-frontend/worker1-3.md を読んで作業を開始してください。" Enter
sleep 1

# Team2初期化
echo -e "${YELLOW}🏢 Team2 (Backend) 初期化中...${NC}"
tmux send-keys -t ccteam-2:main.0 "あなたはTeam2のPMです。Backendチームを管理します。指示書: @instructions/team2-backend/PM-2.md を読んで作業を開始してください。" Enter
sleep 0.5
tmux send-keys -t ccteam-2:main.1 "あなたはTeam2のWorker1です。API開発を担当します。指示書: @instructions/team2-backend/worker2-1.md を読んで作業を開始してください。" Enter
sleep 0.5
tmux send-keys -t ccteam-2:main.2 "あなたはTeam2のWorker2です。データベース・キャッシュを担当します。指示書: @instructions/team2-backend/worker2-2.md を読んで作業を開始してください。" Enter
sleep 0.5
tmux send-keys -t ccteam-2:main.3 "あなたはTeam2のWorker3です。認証・セキュリティを担当します。指示書: @instructions/team2-backend/worker2-3.md を読んで作業を開始してください。" Enter
sleep 1

# Team3初期化
echo -e "${YELLOW}🏢 Team3 (DevOps) 初期化中...${NC}"
tmux send-keys -t ccteam-3:main.0 "あなたはTeam3のPMです。DevOpsチームを管理します。指示書: @instructions/team3-devops/PM-3.md を読んで作業を開始してください。" Enter
sleep 0.5
tmux send-keys -t ccteam-3:main.1 "あなたはTeam3のWorker1です。CI/CD・自動化を担当します。指示書: @instructions/team3-devops/worker3-1.md を読んで作業を開始してください。" Enter
sleep 0.5
tmux send-keys -t ccteam-3:main.2 "あなたはTeam3のWorker2です。インフラ・監視を担当します。指示書: @instructions/team3-devops/worker3-2.md を読んで作業を開始してください。" Enter
sleep 0.5
tmux send-keys -t ccteam-3:main.3 "あなたはTeam3のWorker3です。セキュリティ・コンプライアンスを担当します。指示書: @instructions/team3-devops/worker3-3.md を読んで作業を開始してください。" Enter

echo ""
echo -e "${GREEN}✅ 全エージェントの初期化完了！${NC}"
echo ""
echo "次のステップ:"
echo "1. 各セッションに接続して確認"
echo "2. ccsendコマンドで通信開始"