#!/bin/bash
# ログローテーションをcronに自動登録するスクリプト

set -e

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 ログローテーションの自動化設定${NC}"
echo "===================================="

# スクリプトのフルパスを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_ROTATION_SCRIPT="$SCRIPT_DIR/log_rotation.sh"

# スクリプトの存在確認
if [ ! -f "$LOG_ROTATION_SCRIPT" ]; then
    echo -e "${RED}エラー: log_rotation.sh が見つかりません${NC}"
    exit 1
fi

# 現在のcrontabを取得
echo -e "${YELLOW}現在のcrontab設定を確認中...${NC}"
CURRENT_CRON=$(crontab -l 2>/dev/null || echo "")

# 既に登録されているか確認
if echo "$CURRENT_CRON" | grep -q "log_rotation.sh"; then
    echo -e "${GREEN}✓ ログローテーションは既に設定されています${NC}"
    echo ""
    echo "現在の設定:"
    echo "$CURRENT_CRON" | grep "log_rotation.sh"
    exit 0
fi

# cron設定の選択
echo ""
echo "ログローテーションのスケジュールを選択してください:"
echo "  1) 毎日午前0時（推奨）"
echo "  2) 毎週日曜日午前0時"
echo "  3) 毎時0分"
echo "  4) カスタム設定"
echo ""

read -p "選択 (1-4): " -n 1 -r
echo ""

case $REPLY in
    1)
        CRON_SCHEDULE="0 0 * * *"
        SCHEDULE_DESC="毎日午前0時"
        ;;
    2)
        CRON_SCHEDULE="0 0 * * 0"
        SCHEDULE_DESC="毎週日曜日午前0時"
        ;;
    3)
        CRON_SCHEDULE="0 * * * *"
        SCHEDULE_DESC="毎時0分"
        ;;
    4)
        echo "cron形式でスケジュールを入力してください"
        echo "例: 0 2 * * * (毎日午前2時)"
        read -p "スケジュール: " CRON_SCHEDULE
        SCHEDULE_DESC="カスタム: $CRON_SCHEDULE"
        ;;
    *)
        echo -e "${YELLOW}キャンセルしました${NC}"
        exit 0
        ;;
esac

# cron行の作成
CRON_LINE="$CRON_SCHEDULE cd $SCRIPT_DIR/.. && $LOG_ROTATION_SCRIPT >> logs/log_rotation.log 2>&1"

echo ""
echo -e "${YELLOW}以下の設定を追加します:${NC}"
echo "$CRON_LINE"
echo ""
echo "スケジュール: $SCHEDULE_DESC"
echo ""

read -p "続行しますか？ (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}キャンセルしました${NC}"
    exit 0
fi

# crontabに追加
echo -e "${YELLOW}crontabに追加しています...${NC}"
(crontab -l 2>/dev/null || echo ""; echo "$CRON_LINE") | crontab -

echo -e "${GREEN}✅ ログローテーションの自動化が設定されました！${NC}"
echo ""
echo "設定内容:"
echo "  スケジュール: $SCHEDULE_DESC"
echo "  ログ出力: logs/log_rotation.log"
echo ""
echo "確認するには: crontab -l"
echo "削除するには: crontab -e で該当行を削除"