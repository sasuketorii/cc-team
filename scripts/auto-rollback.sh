#!/bin/bash
# 自動ロールバックシステム - 品質問題検出時に自動で安全な状態に戻す

set -e

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 設定
HEALTH_CHECK_URL="${HEALTH_CHECK_URL:-http://localhost:3000/health}"
MAX_ERROR_RATE=5  # エラー率5%以上で警告
ROLLBACK_THRESHOLD=10  # エラー率10%以上でロールバック

echo -e "${YELLOW}🔄 Auto-Rollback System Active${NC}"

# 関数: ヘルスチェック
check_health() {
    local response=$(curl -s -o /dev/null -w "%{http_code}" $HEALTH_CHECK_URL 2>/dev/null || echo "000")
    
    if [ "$response" = "200" ]; then
        return 0
    else
        return 1
    fi
}

# 関数: エラー率監視
monitor_error_rate() {
    # 直近100件のログからエラー率を計算
    local total_requests=$(tail -n 100 logs/app.log | wc -l)
    local error_count=$(tail -n 100 logs/app.log | grep -c "ERROR" || echo "0")
    
    if [ "$total_requests" -gt 0 ]; then
        local error_rate=$((error_count * 100 / total_requests))
        echo "$error_rate"
    else
        echo "0"
    fi
}

# 関数: 自動ロールバック実行
perform_rollback() {
    local previous_commit=$(git rev-parse HEAD~1)
    
    echo -e "${RED}🚨 Critical issues detected! Initiating rollback...${NC}"
    
    # 現在の状態を保存
    git stash push -m "auto-rollback-$(date +%Y%m%d-%H%M%S)"
    
    # 前のコミットに戻す
    git checkout $previous_commit
    
    # デプロイ再実行
    if [ -f "deploy.sh" ]; then
        ./deploy.sh
    elif [ -f "package.json" ]; then
        npm run deploy || npm run build
    fi
    
    # 通知
    echo -e "${GREEN}✅ Rollback completed to commit: $previous_commit${NC}"
    
    # Slackやメールへの通知（オプション）
    # notify_team "Automatic rollback performed due to high error rate"
}

# 関数: 段階的ロールアウト
canary_deployment() {
    local percentage=${1:-10}  # デフォルト10%のトラフィック
    
    echo -e "${YELLOW}🐤 Canary deployment: routing ${percentage}% traffic to new version${NC}"
    
    # ロードバランサー設定更新（実装例）
    # update_load_balancer_weights "new_version:$percentage" "old_version:$((100-percentage))"
    
    # 一定時間監視
    sleep 300  # 5分間
    
    local error_rate=$(monitor_error_rate)
    
    if [ "$error_rate" -lt "$MAX_ERROR_RATE" ]; then
        echo -e "${GREEN}✅ Canary healthy. Increasing traffic...${NC}"
        return 0
    else
        echo -e "${RED}❌ Canary unhealthy. Rolling back...${NC}"
        return 1
    fi
}

# メイン監視ループ
monitor_deployment() {
    local check_interval=30  # 30秒ごとにチェック
    local consecutive_failures=0
    
    while true; do
        if ! check_health; then
            consecutive_failures=$((consecutive_failures + 1))
            echo -e "${RED}Health check failed ($consecutive_failures consecutive)${NC}"
            
            if [ "$consecutive_failures" -ge 3 ]; then
                perform_rollback
                break
            fi
        else
            consecutive_failures=0
            local error_rate=$(monitor_error_rate)
            
            if [ "$error_rate" -ge "$ROLLBACK_THRESHOLD" ]; then
                echo -e "${RED}Error rate critical: ${error_rate}%${NC}"
                perform_rollback
                break
            elif [ "$error_rate" -ge "$MAX_ERROR_RATE" ]; then
                echo -e "${YELLOW}⚠️  Error rate warning: ${error_rate}%${NC}"
            else
                echo -e "${GREEN}✓ System healthy (error rate: ${error_rate}%)${NC}"
            fi
        fi
        
        sleep $check_interval
    done
}

# GitHub Actions統合
github_deployment_protection() {
    # デプロイメント作成
    DEPLOYMENT_ID=$(gh api repos/:owner/:repo/deployments \
        --method POST \
        --field ref="$GITHUB_SHA" \
        --field environment="production" \
        --field auto_merge=false \
        --jq '.id')
    
    # デプロイメントステータス更新
    gh api repos/:owner/:repo/deployments/$DEPLOYMENT_ID/statuses \
        --method POST \
        --field state="in_progress"
    
    # 品質チェック実行
    if ./scripts/quality-gate.sh ci; then
        # 段階的デプロイ
        if canary_deployment 10; then
            gh api repos/:owner/:repo/deployments/$DEPLOYMENT_ID/statuses \
                --method POST \
                --field state="success"
        else
            gh api repos/:owner/:repo/deployments/$DEPLOYMENT_ID/statuses \
                --method POST \
                --field state="failure"
            perform_rollback
        fi
    else
        gh api repos/:owner/:repo/deployments/$DEPLOYMENT_ID/statuses \
            --method POST \
            --field state="failure" \
            --field description="Quality gate failed"
    fi
}

# コマンド処理
case "$1" in
    "monitor")
        monitor_deployment
        ;;
    "canary")
        canary_deployment "${2:-10}"
        ;;
    "rollback")
        perform_rollback
        ;;
    "protect")
        github_deployment_protection
        ;;
    *)
        echo "Usage: $0 {monitor|canary|rollback|protect}"
        echo ""
        echo "Commands:"
        echo "  monitor  - Start continuous monitoring"
        echo "  canary   - Deploy with canary strategy"
        echo "  rollback - Manually trigger rollback"
        echo "  protect  - GitHub deployment protection"
        exit 1
        ;;
esac