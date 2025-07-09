#!/bin/bash

# CCTeam クイックヘルスチェック
# 基本的な動作確認を素早く実行

set -euo pipefail

echo "🔍 CCTeam クイックヘルスチェック"
echo "================================"
echo ""

# 結果カウンタ
PASSED=0
FAILED=0

# シンプルなチェック関数
check() {
    local name="$1"
    local cmd="$2"
    
    printf "%-40s" "$name"
    if eval "$cmd" &> /dev/null; then
        echo "✅ OK"
        ((PASSED++))
    else
        echo "❌ FAILED"
        ((FAILED++))
    fi
}

# 1. 必須ファイル
echo "📁 必須ファイル:"
check "package.json" "test -f package.json"
check "CLAUDE.md" "test -f CLAUDE.md"
check ".cursorrules" "test -f .cursorrules"
echo ""

# 2. 必須ディレクトリ
echo "📂 必須ディレクトリ:"
check "scripts/" "test -d scripts"
check "logs/" "test -d logs"
check "instructions/" "test -d instructions"
check ".claude/" "test -d .claude"
echo ""

# 3. 実行可能スクリプト
echo "🔧 スクリプト実行権限:"
check "install.sh" "test -x install.sh"
check "scripts/setup.sh" "test -x scripts/setup.sh"
check "scripts/launch-ccteam.sh" "test -x scripts/launch-ccteam.sh"
check "scripts/agent-send.sh" "test -x scripts/agent-send.sh"
echo ""

# 4. Python依存関係
echo "🐍 Python環境:"
check "Python3" "command -v python3"
check "error_loop_detector.py" "python3 -m py_compile scripts/error_loop_detector.py"
check "memory_manager.py" "python3 -m py_compile scripts/memory_manager.py"
echo ""

# 5. tmuxセッション
echo "💻 tmuxセッション:"
check "tmuxインストール済み" "command -v tmux"
if tmux has-session -t ccteam 2>/dev/null; then
    check "ccteamセッション" "true"
    panes=$(tmux list-panes -t ccteam:main 2>/dev/null | wc -l | tr -d ' ')
    check "ペイン数(4個必要)" "[ $panes -eq 4 ]"
else
    check "ccteamセッション" "false"
fi
echo ""

# 6. ログファイルサイズ
echo "📊 ログファイル状態:"
for log in logs/*.log; do
    if [[ -f "$log" ]]; then
        size=$(du -h "$log" 2>/dev/null | cut -f1)
        name=$(basename "$log")
        printf "%-40s %s\n" "$name" "$size"
    fi
done
echo ""

# 7. Git状態
echo "🔀 Git状態:"
if git diff --quiet && git diff --cached --quiet; then
    check "作業ディレクトリ" "true"
else
    check "作業ディレクトリ（未コミット変更あり）" "false"
fi
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "タグなし")
echo "   最新タグ: $latest_tag"
echo ""

# サマリー
echo "================================"
echo "📈 結果サマリー"
echo "  ✅ 成功: $PASSED"
echo "  ❌ 失敗: $FAILED"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo "🎉 システム状態: 良好"
    exit 0
else
    echo "⚠️  システム状態: 要確認"
    exit 1
fi