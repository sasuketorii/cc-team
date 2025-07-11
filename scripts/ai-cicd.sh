#!/bin/bash
# AI-CICD: GitHub ActionsとClaudeCodeの統合

set -e

# 共通カラー定義を読み込み
source "$(dirname "${BASH_SOURCE[0]}")/common/colors.sh"

# 関数: ワークフロー実行と監視
run_workflow() {
    local workflow=$1
    local ref=${2:-main}
    
    echo -e "${YELLOW}Running workflow: $workflow on $ref${NC}"
    
    # ワークフロー実行
    RUN_ID=$(gh workflow run $workflow --ref $ref --json | jq -r '.id')
    
    # 実行監視
    gh run watch $RUN_ID
    
    # 結果取得
    STATUS=$(gh run view $RUN_ID --json status -q '.status')
    
    if [ "$STATUS" = "completed" ]; then
        echo -e "${GREEN}✓ Workflow completed successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ Workflow failed${NC}"
        return 1
    fi
}

# 関数: PR自動チェック
check_pr() {
    local pr_number=$1
    
    echo -e "${YELLOW}Checking PR #$pr_number${NC}"
    
    # チェック状態確認
    CHECKS=$(gh pr checks $pr_number --json state -q '.[] | select(.state != "SUCCESS")')
    
    if [ -z "$CHECKS" ]; then
        echo -e "${GREEN}✓ All checks passed${NC}"
        return 0
    else
        echo -e "${RED}✗ Some checks failed${NC}"
        echo "$CHECKS"
        return 1
    fi
}

# 関数: 自動マージ
auto_merge() {
    local pr_number=$1
    
    if check_pr $pr_number; then
        echo -e "${YELLOW}Auto-merging PR #$pr_number${NC}"
        gh pr merge $pr_number --auto --squash
        echo -e "${GREEN}✓ PR set to auto-merge${NC}"
    else
        echo -e "${RED}Cannot auto-merge: checks failed${NC}"
    fi
}

# 関数: Gemini調査結果を記録
gemini_research() {
    local query=$1
    local output_file=${2:-"shared-docs/gemini-research-$(date +%Y%m%d-%H%M%S).md"}
    
    echo "# Gemini Research: $query" > $output_file
    echo "Date: $(date)" >> $output_file
    echo "---" >> $output_file
    echo "" >> $output_file
    
    gemini "$query" >> $output_file
    
    echo -e "${GREEN}✓ Research saved to: $output_file${NC}"
}

# メインコマンド処理
case "$1" in
    "test")
        run_workflow "test.yml" "${2:-main}"
        ;;
    "build")
        run_workflow "build.yml" "${2:-main}"
        ;;
    "deploy")
        run_workflow "deploy.yml" "${2:-main}"
        ;;
    "check")
        check_pr "$2"
        ;;
    "merge")
        auto_merge "$2"
        ;;
    "research")
        gemini_research "$2" "$3"
        ;;
    *)
        echo "📋 使用方法: $0 <コマンド> [引数]"
        echo ""
        echo "利用可能なコマンド:"
        echo "  test     - ブランチのテストを実行"
        echo "  build    - プロジェクトをビルド"
        echo "  deploy   - デプロイを実行"
        echo "  check    - プルリクエストの品質チェック"
        echo "  merge    - プルリクエストをマージ"
        echo "  research - AIによる調査を実行"
        echo ""
        echo "使用例:"
        echo "  $0 test feature/new-feature    # 指定ブランチでテスト実行"
        echo "  $0 check 123                   # PR #123 の品質チェック"
        echo "  $0 research \"エラー対処法\" \"このエラーの解決方法を調査\""
        echo "  $0 merge 123                   # Auto-merge PR #123"
        echo "  $0 research 'React best practices'"
        exit 1
        ;;
esac