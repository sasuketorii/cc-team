#!/bin/bash

# Error Analysis Script
# エラーログを分析し、パターンを検出します

# 共通カラー定義を読み込み
source "$(dirname "${BASH_SOURCE[0]}")/common/colors.sh"

echo "🔍 CCTeam エラー分析を実行しています..."
echo ""

# エラーループ検出機能の有効化
ENABLE_LOOP_DETECTION=true

# オプション解析
TIME_RANGE="all"
if [ "$1" == "--last-hour" ]; then
    TIME_RANGE="hour"
elif [ "$1" == "--today" ]; then
    TIME_RANGE="today"
fi

# ログディレクトリの確認
if [ ! -d "logs" ]; then
    echo "❌ logsディレクトリが見つかりません"
    exit 1
fi

# エラー統計を初期化
declare -A ERROR_COUNTS
declare -A ERROR_TYPES
TOTAL_ERRORS=0

# 各ログファイルからエラーを抽出
echo -e "${CYAN}【エラー検出】${NC}"
for logfile in logs/*.log; do
    if [ -f "$logfile" ]; then
        filename=$(basename "$logfile")
        
        # 時間範囲に基づいてフィルタリング
        case $TIME_RANGE in
            "hour")
                ERRORS=$(grep -i "error\|failed\|exception" "$logfile" | grep "$(date -d '1 hour ago' '+%Y-%m-%d %H')" 2>/dev/null || true)
                ;;
            "today")
                ERRORS=$(grep -i "error\|failed\|exception" "$logfile" | grep "$(date '+%Y-%m-%d')" 2>/dev/null || true)
                ;;
            *)
                ERRORS=$(grep -i "error\|failed\|exception" "$logfile" 2>/dev/null || true)
                ;;
        esac
        
        ERROR_COUNT=$(echo "$ERRORS" | grep -c . || true)
        
        if [ $ERROR_COUNT -gt 0 ]; then
            echo -e "${RED}$filename${NC}: $ERROR_COUNT エラー"
            ERROR_COUNTS[$filename]=$ERROR_COUNT
            TOTAL_ERRORS=$((TOTAL_ERRORS + ERROR_COUNT))
            
            # エラータイプの分類
            while IFS= read -r error_line; do
                if echo "$error_line" | grep -qi "timeout"; then
                    ((ERROR_TYPES[timeout]++))
                elif echo "$error_line" | grep -qi "connection\|network"; then
                    ((ERROR_TYPES[network]++))
                elif echo "$error_line" | grep -qi "permission\|denied"; then
                    ((ERROR_TYPES[permission]++))
                elif echo "$error_line" | grep -qi "not found\|missing"; then
                    ((ERROR_TYPES[notfound]++))
                elif echo "$error_line" | grep -qi "syntax\|parse"; then
                    ((ERROR_TYPES[syntax]++))
                else
                    ((ERROR_TYPES[other]++))
                fi
            done <<< "$ERRORS"
        fi
    fi
done

if [ $TOTAL_ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ エラーは検出されませんでした${NC}"
else
    # エラータイプ別統計
    echo ""
    echo -e "${CYAN}【エラータイプ分析】${NC}"
    for error_type in "${!ERROR_TYPES[@]}"; do
        count=${ERROR_TYPES[$error_type]}
        percentage=$((count * 100 / TOTAL_ERRORS))
        case $error_type in
            "timeout")
                echo "⏱️  タイムアウト: $count件 ($percentage%)"
                ;;
            "network")
                echo "🌐 ネットワーク: $count件 ($percentage%)"
                ;;
            "permission")
                echo "🔒 権限エラー: $count件 ($percentage%)"
                ;;
            "notfound")
                echo "❓ 未検出: $count件 ($percentage%)"
                ;;
            "syntax")
                echo "📝 構文エラー: $count件 ($percentage%)"
                ;;
            "other")
                echo "❔ その他: $count件 ($percentage%)"
                ;;
        esac
    done
fi

# 最も問題のあるエージェントを特定
echo ""
echo -e "${CYAN}【エージェント別分析】${NC}"
if [ ${#ERROR_COUNTS[@]} -gt 0 ]; then
    MAX_ERRORS=0
    PROBLEMATIC_AGENT=""
    
    for agent in "${!ERROR_COUNTS[@]}"; do
        if [ ${ERROR_COUNTS[$agent]} -gt $MAX_ERRORS ]; then
            MAX_ERRORS=${ERROR_COUNTS[$agent]}
            PROBLEMATIC_AGENT=$agent
        fi
    done
    
    echo -e "${YELLOW}⚠️  最も問題のあるログ: $PROBLEMATIC_AGENT ($MAX_ERRORS エラー)${NC}"
fi

# 推奨アクション
echo ""
echo -e "${CYAN}【推奨アクション】${NC}"

if [ $TOTAL_ERRORS -eq 0 ]; then
    echo "👍 システムは正常に動作しています"
else
    # エラータイプに基づいた推奨事項
    if [ ${ERROR_TYPES[timeout]:-0} -gt 0 ]; then
        echo "1. タイムアウト値の調整を検討してください"
    fi
    
    if [ ${ERROR_TYPES[network]:-0} -gt 0 ]; then
        echo "2. ネットワーク接続を確認してください"
    fi
    
    if [ ${ERROR_TYPES[permission]:-0} -gt 0 ]; then
        echo "3. ファイルとディレクトリの権限を確認してください"
    fi
    
    if [ ${ERROR_TYPES[notfound]:-0} -gt 0 ]; then
        echo "4. 必要なファイルや依存関係を確認してください"
    fi
    
    if [ ${ERROR_TYPES[syntax]:-0} -gt 0 ]; then
        echo "5. コードの構文エラーを修正してください"
    fi
    
    echo ""
    echo "詳細なエラー内容を確認するには:"
    echo -e "${GREEN}grep -i 'error' logs/*.log | less${NC}"
fi

# エラーパターンをJSONファイルに保存
if [ $TOTAL_ERRORS -gt 0 ]; then
    mkdir -p logs/analysis
    TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
    cat > "logs/analysis/error_report_$TIMESTAMP.json" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "total_errors": $TOTAL_ERRORS,
  "time_range": "$TIME_RANGE",
  "error_types": {
$(for error_type in "${!ERROR_TYPES[@]}"; do
    echo "    \"$error_type\": ${ERROR_TYPES[$error_type]},"
done | sed '$ s/,$//')
  },
  "agent_errors": {
$(for agent in "${!ERROR_COUNTS[@]}"; do
    echo "    \"$agent\": ${ERROR_COUNTS[$agent]},"
done | sed '$ s/,$//')
  }
}
EOF
    echo ""
    echo "📊 分析レポートを保存しました: logs/analysis/error_report_$TIMESTAMP.json"
fi