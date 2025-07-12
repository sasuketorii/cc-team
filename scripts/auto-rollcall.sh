#!/bin/bash
# CCTeam 自動点呼システム v1.0.0
# 全Workerの状態を自動確認し、レポートを生成

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 共通カラー定義を読み込み
source "$SCRIPT_DIR/common/colors.sh"

# タイムスタンプ
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="$PROJECT_ROOT/logs/rollcall.log"

echo -e "${BLUE}🔔 CCTeam 自動点呼開始${NC}"
echo "[$TIMESTAMP] 自動点呼開始" >> "$LOG_FILE"

# 点呼メッセージ
ROLLCALL_MESSAGE="点呼確認: 現在の役割と準備状況を報告してください。フォーマット: [役割] 準備完了/作業中/問題あり - 詳細"

# Bossへの指示
echo -e "${YELLOW}📢 Bossに点呼指示を送信中...${NC}"
tmux send-keys -t ccteam-boss:main.0 C-c
sleep 0.5
tmux send-keys -t ccteam-boss:main.0 "全Worker点呼を実施します。各自の状態を報告してください。" Enter
echo "[$TIMESTAMP] Boss: 点呼指示送信" >> "$LOG_FILE"

sleep 2

# 各Workerへ点呼送信
for i in 0 1 2; do
    WORKER_NUM=$((i + 1))
    echo -e "${GREEN}👷 Worker${WORKER_NUM}に点呼送信中...${NC}"
    
    # Ctrl+Cでプロンプトクリア
    tmux send-keys -t ccteam-workers:main.$i C-c
    sleep 0.5
    
    # 点呼メッセージ送信
    tmux send-keys -t ccteam-workers:main.$i "$ROLLCALL_MESSAGE" Enter
    
    echo "[$TIMESTAMP] Worker${WORKER_NUM}: 点呼送信完了" >> "$LOG_FILE"
    sleep 1
done

echo ""
echo -e "${GREEN}✅ 点呼送信完了！${NC}"
echo ""
echo "結果を確認するには："
echo -e "  ${CYAN}tmux attach -t ccteam-boss${NC}     # Boss応答確認"
echo -e "  ${CYAN}tmux attach -t ccteam-workers${NC}  # Worker応答確認"
echo ""
echo -e "${YELLOW}💡 ヒント: 各Workerは数秒後に応答します${NC}"

# 統計情報
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "送信統計:"
echo "  - Boss: 1件"
echo "  - Workers: 3件"
echo "  - 合計: 4件"
echo "  - ログ: $LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# エイリアス情報
if ! grep -q "alias ccrollcall" ~/.bashrc 2>/dev/null && ! grep -q "alias ccrollcall" ~/.zshrc 2>/dev/null; then
    echo ""
    echo -e "${YELLOW}💡 便利なエイリアスを設定できます:${NC}"
    echo -e "   echo \"alias ccrollcall='$SCRIPT_DIR/auto-rollcall.sh'\" >> ~/.bashrc"
fi