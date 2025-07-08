#!/bin/bash
# 自動作業報告書生成システム

set -e

# 設定
REPORT_DIR="reports/daily"
TODAY=$(date +%Y-%m-%d)
REPORT_FILE="$REPORT_DIR/$TODAY.md"

# ディレクトリ作成
mkdir -p $REPORT_DIR

# 関数: 進捗収集
collect_progress() {
    echo "## 進捗報告 - $(date +%H:%M:%S)"
    echo ""
    
    for worker in worker1 worker2 worker3; do
        echo "### $worker"
        # 実際の進捗取得（シミュレーション）
        echo "- [ ] タスク実行中..."
        echo ""
    done
}

# 関数: メトリクス収集
collect_metrics() {
    echo "## メトリクス"
    echo ""
    echo "- コミット数: $(git rev-list --count HEAD --since=midnight)"
    echo "- テスト実行: $(grep -c "test" logs/*.log 2>/dev/null || echo 0)"
    echo "- エラー発生: $(grep -c "ERROR" logs/*.log 2>/dev/null || echo 0)"
    echo "- CI/CD実行: $(gh run list --limit 10 --json status | jq '[.[] | select(.createdAt > "'$TODAY'")] | length')"
    echo ""
}

# 関数: Gemini要約
generate_summary() {
    echo "## 日次サマリー"
    echo ""
    
    # Geminiで要約生成
    CONTENT=$(cat $REPORT_FILE)
    gemini "以下の作業ログから本日の成果と課題を3行でまとめて: $CONTENT" 2>/dev/null || echo "要約生成エラー"
}

# レポート生成
{
    echo "# CCTeam 日次レポート - $TODAY"
    echo ""
    collect_progress
    collect_metrics
} > $REPORT_FILE

# 10分ごとの定期実行用
if [ "$1" = "cron" ]; then
    collect_progress >> $REPORT_FILE
fi

# 日次サマリー生成（22時に実行想定）
if [ "$1" = "summary" ] || [ $(date +%H) -eq 22 ]; then
    generate_summary >> $REPORT_FILE
    
    # Slackやメールへの通知（オプション）
    # notify_slack "$(cat $REPORT_FILE)"
fi

echo "Report saved to: $REPORT_FILE"