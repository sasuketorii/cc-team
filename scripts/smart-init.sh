#!/bin/bash
# CCTeam スマート初期化 - Bossを通じた階層的初期化

set -e

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🧠 CCTeam スマート初期化開始${NC}"
echo "=================================="

# Boss経由の初期化
echo -e "${YELLOW}👑 Boss経由でチーム全体を初期化中...${NC}"

# Bossに要件読み込みとチーム初期化を指示
tmux send-keys -t ccteam-boss:main "以下のタスクを実行してください:
1. @requirements/README.md を読み込んでプロジェクト要件を理解する
2. 各PMを初期化する（重要: 必ず階層構造を守ってください）:
   - ccsend pm1 \"あなたはTeam1(Frontend)のPMです。@instructions/team1-frontend/PM-1.md を確認し、チーム内のWorkerに役割を伝えてください。\"
   - ccsend pm2 \"あなたはTeam2(Backend)のPMです。@instructions/team2-backend/PM-2.md を確認し、チーム内のWorkerに役割を伝えてください。\"
   - ccsend pm3 \"あなたはTeam3(DevOps)のPMです。@instructions/team3-devops/PM-3.md を確認し、チーム内のWorkerに役割を伝えてください。\"
3. 今後、Workerへの指示は必ずPMを経由してください。直接Workerに連絡しないでください。" Enter

echo ""
echo -e "${GREEN}✅ Boss初期化完了！${NC}"
echo ""
echo -e "${BLUE}📋 次のステップ:${NC}"
echo "1. Bossが自動的に全チームを初期化します"
echo "2. 初期化状況確認: ${YELLOW}tmux attach -t ccteam-boss${NC}"
echo "3. 作業開始: ${YELLOW}ccsend boss \"作業を開始してください\"${NC}"
echo ""
echo -e "${YELLOW}💡 ヒント:${NC}"
echo "Bossは階層的にPM→Workerへ指示を伝播させます"
echo "ユーザーはBossとのみやり取りすればOKです"