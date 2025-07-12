#!/bin/bash
# 品質ゲートシステム - バグや品質不良を検出してコミットを防ぐ

set -e

# カラー定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 品質基準の設定
MIN_TEST_COVERAGE=80
MAX_COMPLEXITY=10
MAX_DUPLICATION=5
MAX_LINT_ERRORS=0
MAX_SECURITY_ISSUES=0

# 結果格納用
QUALITY_SCORE=100
ISSUES=()

echo -e "${BLUE}🛡️  CCTeam Quality Gate System${NC}"
echo "================================="

# 関数: テストカバレッジチェック
check_test_coverage() {
    echo -e "\n${YELLOW}📊 Checking test coverage...${NC}"
    
    # テスト実行とカバレッジ取得
    if command -v npm &> /dev/null && [ -f "package.json" ] && [ -f "jest.config.js" ]; then
        # Jestテストを実行
        if npm test -- --coverage --silent 2>/dev/null; then
            COVERAGE=$(cat coverage/coverage-summary.json 2>/dev/null | jq '.total.lines.pct' 2>/dev/null || echo "0")
            
            if [ "$COVERAGE" = "0" ] || [ -z "$COVERAGE" ]; then
                echo -e "${YELLOW}⚠️  No test coverage data available${NC}"
                ISSUES+=("⚠️  No test coverage data")
                QUALITY_SCORE=$((QUALITY_SCORE - 10))
            elif (( $(echo "$COVERAGE < $MIN_TEST_COVERAGE" | bc -l) )); then
                ISSUES+=("❌ Test coverage is ${COVERAGE}% (minimum: ${MIN_TEST_COVERAGE}%)")
                QUALITY_SCORE=$((QUALITY_SCORE - 20))
                return 1
            else
                echo -e "${GREEN}✓ Test coverage: ${COVERAGE}%${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  Tests failed or not configured${NC}"
            ISSUES+=("⚠️  Tests not properly configured")
            QUALITY_SCORE=$((QUALITY_SCORE - 15))
        fi
    else
        echo -e "${YELLOW}⚠️  Test infrastructure not found${NC}"
        ISSUES+=("⚠️  Test infrastructure missing")
        QUALITY_SCORE=$((QUALITY_SCORE - 10))
    fi
    return 0
}

# 関数: Lintチェック
check_lint() {
    echo -e "\n${YELLOW}🔍 Running lint checks...${NC}"
    
    # ESLint実行
    if [ -f ".eslintrc.json" ] || [ -f ".eslintrc.js" ]; then
        LINT_ERRORS=$(npm run lint --silent 2>&1 | grep -c "error" || echo "0")
        
        if [ "$LINT_ERRORS" -gt "$MAX_LINT_ERRORS" ]; then
            ISSUES+=("❌ Found ${LINT_ERRORS} lint errors (maximum: ${MAX_LINT_ERRORS})")
            QUALITY_SCORE=$((QUALITY_SCORE - 15))
            return 1
        else
            echo -e "${GREEN}✓ No lint errors found${NC}"
        fi
    fi
    return 0
}

# 関数: TypeScriptエラーチェック
check_typescript() {
    echo -e "\n${YELLOW}📘 Checking TypeScript...${NC}"
    
    if [ -f "tsconfig.json" ]; then
        TS_ERRORS=$(npx tsc --noEmit 2>&1 | grep -c "error" || echo "0")
        
        if [ "$TS_ERRORS" -gt 0 ]; then
            ISSUES+=("❌ Found ${TS_ERRORS} TypeScript errors")
            QUALITY_SCORE=$((QUALITY_SCORE - 25))
            return 1
        else
            echo -e "${GREEN}✓ No TypeScript errors${NC}"
        fi
    fi
    return 0
}

# 関数: セキュリティチェック
check_security() {
    echo -e "\n${YELLOW}🔒 Security scanning...${NC}"
    
    # npm audit
    if [ -f "package-lock.json" ]; then
        VULNERABILITIES=$(npm audit --json 2>/dev/null | jq '.metadata.vulnerabilities.high + .metadata.vulnerabilities.critical' || echo "0")
        
        if [ "$VULNERABILITIES" -gt "$MAX_SECURITY_ISSUES" ]; then
            ISSUES+=("❌ Found ${VULNERABILITIES} high/critical vulnerabilities")
            QUALITY_SCORE=$((QUALITY_SCORE - 30))
            return 1
        else
            echo -e "${GREEN}✓ No security vulnerabilities${NC}"
        fi
    fi
    return 0
}

# 関数: コード複雑度チェック
check_complexity() {
    echo -e "\n${YELLOW}🧩 Checking code complexity...${NC}"
    
    # 簡易的な複雑度チェック（実際はESLintのcomplexityルールで実装）
    COMPLEX_FILES=$(find . -name "*.js" -o -name "*.ts" | xargs grep -l "if.*if.*if" | wc -l || echo "0")
    
    if [ "$COMPLEX_FILES" -gt "$MAX_COMPLEXITY" ]; then
        ISSUES+=("⚠️  Found ${COMPLEX_FILES} files with high complexity")
        QUALITY_SCORE=$((QUALITY_SCORE - 10))
    else
        echo -e "${GREEN}✓ Code complexity is acceptable${NC}"
    fi
}

# 関数: ビルドチェック
check_build() {
    echo -e "\n${YELLOW}🏗️  Checking build...${NC}"
    
    if [ -f "package.json" ] && grep -q '"build"' package.json; then
        if ! npm run build --silent > /dev/null 2>&1; then
            ISSUES+=("❌ Build failed")
            QUALITY_SCORE=$((QUALITY_SCORE - 30))
            return 1
        else
            echo -e "${GREEN}✓ Build successful${NC}"
        fi
    fi
    return 0
}

# 関数: Geminiによる追加チェック
check_with_gemini() {
    echo -e "\n${YELLOW}🤖 AI Quality Review...${NC}"
    
    # 最近の変更を取得
    CHANGES=$(git diff --cached --name-only)
    
    if [ -n "$CHANGES" ]; then
        # Geminiにコード品質をチェックさせる
        GEMINI_CHECK=$(gemini "以下のファイルの変更に潜在的な問題がないか確認: $CHANGES" 2>/dev/null || echo "")
        
        if echo "$GEMINI_CHECK" | grep -qi "問題\|エラー\|警告"; then
            ISSUES+=("⚠️  AI detected potential issues: $GEMINI_CHECK")
            QUALITY_SCORE=$((QUALITY_SCORE - 5))
        fi
    fi
}

# メインの品質チェック実行
run_quality_checks() {
    check_test_coverage
    check_lint
    check_typescript
    check_security
    check_complexity
    check_build
    check_with_gemini
}

# 品質ゲート判定
evaluate_quality() {
    echo -e "\n${BLUE}📋 Quality Gate Results${NC}"
    echo "========================"
    
    if [ ${#ISSUES[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All quality checks passed!${NC}"
        echo -e "Quality Score: ${GREEN}${QUALITY_SCORE}/100${NC}"
        return 0
    else
        echo -e "${RED}❌ 品質チェックが基準を満たしていません${NC}"
        echo -e "品質スコア: ${RED}${QUALITY_SCORE}/100${NC} (必要: 80/100以上)"
        echo -e "\n${RED}改善が必要な項目:${NC}"
        for issue in "${ISSUES[@]}"; do
            echo "  $issue"
        done
        return 1
    fi
}

# Git pre-commitフックとして使用する場合
if [ "$1" = "pre-commit" ]; then
    run_quality_checks
    
    if ! evaluate_quality; then
        echo -e "\n${RED}🚫 品質基準を満たしていないため、コミットをブロックしました${NC}"
        echo "上記の問題を修正してからコミットしてください。"
        
        # 自動修正の提案
        echo -e "\n${YELLOW}💡 修正方法の提案:${NC}"
        echo "1. テストの失敗を確認: npm test"
        echo "2. リントエラーを自動修正: npm run lint --fix"
        echo "3. 脆弱性を修正: npm audit fix"
        echo "4. カバレッジを確認: npm run test:coverage"
        
        exit 1
    fi
    
    echo -e "\n${GREEN}✅ Quality gate passed. Proceeding with commit...${NC}"
    exit 0
fi

# 手動実行の場合
if [ "$1" = "report" ]; then
    run_quality_checks
    evaluate_quality
    
    # レポート生成
    REPORT_FILE="reports/quality/quality-report-$(date +%Y%m%d-%H%M%S).json"
    mkdir -p reports/quality
    
    cat > "$REPORT_FILE" << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "score": $QUALITY_SCORE,
    "passed": $([ ${#ISSUES[@]} -eq 0 ] && echo "true" || echo "false"),
    "issues": [
        $(printf '"%s",' "${ISSUES[@]}" | sed 's/,$//')
    ]
}
EOF
    
    echo -e "\n📄 Report saved to: $REPORT_FILE"
fi

# CI/CD統合モード
if [ "$1" = "ci" ]; then
    run_quality_checks
    
    if ! evaluate_quality; then
        # GitHub Actionsのアノテーション
        for issue in "${ISSUES[@]}"; do
            echo "::error::$issue"
        done
        exit 1
    fi
    
    # 成功時のメトリクス出力
    echo "::notice::Quality Score: ${QUALITY_SCORE}/100"
    exit 0
fi

# ヘルプ
if [ -z "$1" ] || [ "$1" = "help" ]; then
    echo "Usage: $0 {pre-commit|report|ci|help}"
    echo ""
    echo "Modes:"
    echo "  pre-commit  - Run as git pre-commit hook"
    echo "  report      - Generate quality report"
    echo "  ci          - Run in CI/CD pipeline"
    echo "  help        - Show this help"
fi