#!/bin/bash

# CCTeam システムヘルスチェックスクリプト
# 網羅的なバグチェックとシステム検証を実行

set -euo pipefail

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# テスト結果カウンタ
PASSED=0
FAILED=0
WARNINGS=0

# ログファイル
REPORT_FILE="reports/health_check_$(date +%Y%m%d_%H%M%S).md"
mkdir -p reports

# レポートヘッダー
cat > "$REPORT_FILE" << EOF
# CCTeam システムヘルスチェックレポート

実行日時: $(date '+%Y-%m-%d %H:%M:%S')
システムバージョン: $(cat package.json | grep '"version"' | cut -d'"' -f4)

---

## 📊 チェック結果サマリー

EOF

# テスト関数
run_test() {
    local test_name="$1"
    local test_command="$2"
    local description="${3:-}"
    
    echo -n "Checking $test_name... "
    
    if eval "$test_command" &> /dev/null; then
        echo -e "${GREEN}✓ PASSED${NC}"
        echo "✅ **$test_name**: $description" >> "$REPORT_FILE"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "❌ **$test_name**: $description" >> "$REPORT_FILE"
        echo "   エラー詳細: \`$test_command\` が失敗しました" >> "$REPORT_FILE"
        ((FAILED++))
    fi
}

# 警告チェック関数
check_warning() {
    local test_name="$1"
    local test_command="$2"
    local description="${3:-}"
    
    echo -n "Checking $test_name... "
    
    if eval "$test_command" &> /dev/null; then
        echo -e "${YELLOW}⚠ WARNING${NC}"
        echo "⚠️ **$test_name**: $description" >> "$REPORT_FILE"
        ((WARNINGS++))
    else
        echo -e "${GREEN}✓ OK${NC}"
        echo "✅ **$test_name**: 問題なし" >> "$REPORT_FILE"
        ((PASSED++))
    fi
}

echo -e "${BLUE}=== CCTeam システムヘルスチェック開始 ===${NC}"
echo ""

# 1. 必須ファイル・ディレクトリの存在確認
echo -e "${BLUE}[1/8] 必須ファイル・ディレクトリチェック${NC}"
echo "" >> "$REPORT_FILE"
echo "### 1. 必須ファイル・ディレクトリ" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

run_test "package.json" "test -f package.json" "プロジェクト設定ファイル"
run_test "scripts directory" "test -d scripts" "スクリプトディレクトリ"
run_test "logs directory" "test -d logs" "ログディレクトリ"
run_test "instructions directory" "test -d instructions" "指示ディレクトリ"
run_test ".claude directory" "test -d .claude" "Claude設定ディレクトリ"
run_test "CLAUDE.md" "test -f CLAUDE.md" "Claudeプロジェクト設定"
run_test ".cursorrules" "test -f .cursorrules" "Cursor設定ファイル"

# 2. スクリプトの実行権限チェック
echo ""
echo -e "${BLUE}[2/8] スクリプト実行権限チェック${NC}"
echo "" >> "$REPORT_FILE"
echo "### 2. スクリプト実行権限" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

for script in scripts/*.sh; do
    if [[ -f "$script" ]]; then
        script_name=$(basename "$script")
        run_test "$script_name permissions" "test -x $script" "実行権限"
    fi
done

# 3. 必須コマンドの存在確認
echo ""
echo -e "${BLUE}[3/8] 必須コマンドチェック${NC}"
echo "" >> "$REPORT_FILE"
echo "### 3. 必須コマンド" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

run_test "tmux" "command -v tmux" "ターミナルマルチプレクサ"
run_test "git" "command -v git" "バージョン管理システム"
run_test "python3" "command -v python3" "Python実行環境"
run_test "npm" "command -v npm" "Node.jsパッケージマネージャ"
run_test "code/cursor" "command -v code || command -v cursor" "エディタ"

# 4. tmuxセッションチェック
echo ""
echo -e "${BLUE}[4/8] tmuxセッション状態チェック${NC}"
echo "" >> "$REPORT_FILE"
echo "### 4. tmuxセッション状態" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if tmux has-session -t ccteam 2>/dev/null; then
    echo "✅ **ccteamセッション**: 実行中" >> "$REPORT_FILE"
    
    # ペイン数チェック
    pane_count=$(tmux list-panes -t ccteam:main | wc -l)
    if [[ $pane_count -eq 4 ]]; then
        echo "✅ **ペイン構成**: 正常（4ペイン）" >> "$REPORT_FILE"
        ((PASSED++))
    else
        echo "❌ **ペイン構成**: 異常（期待: 4、実際: $pane_count）" >> "$REPORT_FILE"
        ((FAILED++))
    fi
else
    echo "⚠️ **ccteamセッション**: 未起動" >> "$REPORT_FILE"
    ((WARNINGS++))
fi

# 5. ログファイルのサイズチェック
echo ""
echo -e "${BLUE}[5/8] ログファイルサイズチェック${NC}"
echo "" >> "$REPORT_FILE"
echo "### 5. ログファイルサイズ" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

for log in logs/*.log; do
    if [[ -f "$log" ]]; then
        size=$(du -h "$log" | cut -f1)
        size_bytes=$(stat -f%z "$log" 2>/dev/null || stat -c%s "$log" 2>/dev/null || echo 0)
        log_name=$(basename "$log")
        
        if [[ $size_bytes -gt 10485760 ]]; then  # 10MB
            echo "⚠️ **$log_name**: $size（10MB超過）" >> "$REPORT_FILE"
            ((WARNINGS++))
        else
            echo "✅ **$log_name**: $size" >> "$REPORT_FILE"
            ((PASSED++))
        fi
    fi
done

# 6. エラーループ検出システムチェック
echo ""
echo -e "${BLUE}[6/8] エラーループ検出システムチェック${NC}"
echo "" >> "$REPORT_FILE"
echo "### 6. エラーループ検出システム" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

run_test "error_loop_detector.py" "python3 scripts/error_loop_detector.py status" "エラーループ検出システム"
run_test "error_loop_helper.py" "python3 -m py_compile scripts/error_loop_helper.py" "エラーループヘルパー"

# 7. メモリシステムチェック
echo ""
echo -e "${BLUE}[7/8] メモリシステムチェック${NC}"
echo "" >> "$REPORT_FILE"
echo "### 7. メモリシステム" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

run_test "memory directory" "test -d memory" "メモリディレクトリ"
if [[ -f "memory/ccteam_memory.db" ]]; then
    db_size=$(du -h "memory/ccteam_memory.db" | cut -f1)
    echo "✅ **メモリDB**: 存在（サイズ: $db_size）" >> "$REPORT_FILE"
    ((PASSED++))
else
    echo "⚠️ **メモリDB**: 未作成" >> "$REPORT_FILE"
    ((WARNINGS++))
fi

# 8. Git状態チェック
echo ""
echo -e "${BLUE}[8/8] Git状態チェック${NC}"
echo "" >> "$REPORT_FILE"
echo "### 8. Git状態" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 未コミットの変更確認
if git diff --quiet && git diff --cached --quiet; then
    echo "✅ **Git状態**: クリーン" >> "$REPORT_FILE"
    ((PASSED++))
else
    echo "⚠️ **Git状態**: 未コミットの変更あり" >> "$REPORT_FILE"
    ((WARNINGS++))
fi

# 最新のタグ確認
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "なし")
echo "ℹ️ **最新タグ**: $latest_tag" >> "$REPORT_FILE"

# エラーパターン分析
echo "" >> "$REPORT_FILE"
echo "## 🔍 最近のエラーパターン分析" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [[ -f "logs/system.log" ]]; then
    error_count=$(grep -i "error" logs/system.log 2>/dev/null | wc -l || echo 0)
    warning_count=$(grep -i "warning" logs/system.log 2>/dev/null | wc -l || echo 0)
    
    echo "- エラー発生回数: $error_count" >> "$REPORT_FILE"
    echo "- 警告発生回数: $warning_count" >> "$REPORT_FILE"
    
    # 最新のエラー5件
    echo "" >> "$REPORT_FILE"
    echo "### 最新のエラー（最大5件）" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
    grep -i "error" logs/system.log 2>/dev/null | tail -5 >> "$REPORT_FILE" || echo "エラーなし" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
fi

# サマリー
echo "" >> "$REPORT_FILE"
echo "## 📈 総合評価" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "- ✅ 成功: $PASSED" >> "$REPORT_FILE"
echo "- ❌ 失敗: $FAILED" >> "$REPORT_FILE"
echo "- ⚠️ 警告: $WARNINGS" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 総合判定
if [[ $FAILED -eq 0 ]]; then
    if [[ $WARNINGS -eq 0 ]]; then
        echo "### 🎉 システム状態: 完璧" >> "$REPORT_FILE"
        overall="${GREEN}完璧${NC}"
    else
        echo "### ✅ システム状態: 良好（警告あり）" >> "$REPORT_FILE"
        overall="${YELLOW}良好（警告あり）${NC}"
    fi
else
    echo "### ❌ システム状態: 要修正" >> "$REPORT_FILE"
    overall="${RED}要修正${NC}"
fi

# 推奨アクション
echo "" >> "$REPORT_FILE"
echo "## 🔧 推奨アクション" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [[ $FAILED -gt 0 ]]; then
    echo "1. 失敗したチェック項目を修正してください" >> "$REPORT_FILE"
fi

if [[ $WARNINGS -gt 0 ]]; then
    echo "1. ログファイルのサイズが大きい場合は `./scripts/log_rotation.sh` を実行" >> "$REPORT_FILE"
    echo "2. tmuxセッションが未起動の場合は `ccteam` コマンドで起動" >> "$REPORT_FILE"
fi

# コンソール出力
echo ""
echo -e "${BLUE}=== チェック完了 ===${NC}"
echo ""
echo -e "総合評価: $overall"
echo -e "✅ 成功: ${GREEN}$PASSED${NC}"
echo -e "❌ 失敗: ${RED}$FAILED${NC}"
echo -e "⚠️ 警告: ${YELLOW}$WARNINGS${NC}"
echo ""
echo "詳細レポート: $REPORT_FILE"

# 終了コード
if [[ $FAILED -gt 0 ]]; then
    exit 1
else
    exit 0
fi