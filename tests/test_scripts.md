# CCTeam テストスクリプト集

このドキュメントには、CCTeamのテストに使用できる再利用可能なスクリプトが含まれています。

## 📋 目次

1. [クイックヘルスチェック](#クイックヘルスチェック)
2. [詳細システムヘルスチェック](#詳細システムヘルスチェック)
3. [統合テスト](#統合テスト)
4. [構造化ログテスト](#構造化ログテスト)
5. [エラーループ検出テスト](#エラーループ検出テスト)
6. [クリーンアップスクリプト](#クリーンアップスクリプト)

---

## クイックヘルスチェック

基本的な動作確認を素早く実行します。

```bash
#!/bin/bash
# quick_health_check.sh

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
```

---

## 詳細システムヘルスチェック

網羅的なシステムチェックを実行し、詳細レポートを生成します。

```bash
#!/bin/bash
# system_health_check.sh

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

# 各種チェックを実行...
# （詳細は元のスクリプトを参照）

echo "詳細レポート: $REPORT_FILE"
```

---

## 統合テスト

システム全体の統合テストを実行します。

```bash
#!/bin/bash
# integration_test.sh

set -euo pipefail

# カラー定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 CCTeam 統合テスト開始${NC}"
echo "=========================="
echo ""

# テスト結果
TESTS_PASSED=0
TESTS_FAILED=0

# テスト関数
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    
    echo -n "▶ $test_name... "
    
    if eval "$test_cmd" &> /tmp/test_output.log; then
        echo -e "${GREEN}✅ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        echo "  詳細:"
        cat /tmp/test_output.log | sed 's/^/    /'
        ((TESTS_FAILED++))
        return 1
    fi
}

# 各種テストを実行...
# （詳細は元のスクリプトを参照）
```

---

## 構造化ログテスト

構造化ログシステムの動作確認テストです。

```python
#!/usr/bin/env python3
# test_structured_logger.py

import sys
sys.path.append('scripts')
from structured_logger import StructuredLogger, LogAnalyzer

def test_basic_logging():
    """基本的なログ出力テスト"""
    logger = StructuredLogger("test")
    
    logger.info("テストログシステム起動")
    logger.debug("デバッグ情報", {"key": "value"})
    logger.warning("警告メッセージ", {"threshold": 80, "current": 85})
    
    try:
        1 / 0
    except Exception as e:
        logger.error("ゼロ除算エラー", e, {"operation": "division"})
    
    logger.log_task_start("test_task", {"param1": "value1"})
    logger.log_task_complete("test_task", {"result": "success"})
    
    print("✅ 基本ログテスト完了")

def test_log_analysis():
    """ログ分析機能のテスト"""
    analyzer = LogAnalyzer()
    
    # エラー分析
    errors = analyzer.analyze_errors(3600)  # 過去1時間
    print(f"エラー総数: {errors['total']}")
    print(f"エラータイプ: {errors['by_type']}")
    print(f"エージェント別: {errors['by_agent']}")
    
    print("✅ ログ分析テスト完了")

if __name__ == "__main__":
    test_basic_logging()
    test_log_analysis()
```

---

## エラーループ検出テスト

エラーループ検出システムの動作確認テストです。

```python
#!/usr/bin/env python3
# test_error_loop_detector.py

import sys
import time
sys.path.append('scripts')
from error_loop_detector import ErrorLoopDetector

def test_error_loop_detection():
    """エラーループ検出のテスト"""
    detector = ErrorLoopDetector(threshold=3, time_window=60)
    
    # 同じエラーを3回報告
    test_agent = "test_worker"
    test_error = "Module not found: test_module"
    
    print("同じエラーを3回報告...")
    for i in range(3):
        is_loop = detector.check_error(test_agent, test_error)
        print(f"  {i+1}回目: {'ループ検出!' if is_loop else 'OK'}")
        time.sleep(0.1)
    
    # ステータス確認
    status = detector.get_status()
    print(f"\nアクティブなモニター: {len(status['active_monitors'])}")
    print(f"総エラー数: {status['total_errors']}")
    
    # クリア
    detector.error_history = {}
    detector.save_history()
    print("\n✅ エラーループ検出テスト完了")

if __name__ == "__main__":
    test_error_loop_detection()
```

---

## クリーンアップスクリプト

テスト実行後の不要ファイルを削除します。

```bash
#!/bin/bash
# cleanup_test_files.sh

echo "🧹 テストファイルのクリーンアップを開始します..."

# Python キャッシュの削除
echo "Pythonキャッシュを削除中..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true
find . -name "*.pyo" -delete 2>/dev/null || true

# テストログの削除
echo "テストログを削除中..."
rm -f logs/test.log 2>/dev/null || true
rm -f logs/test_structured.jsonl 2>/dev/null || true
rm -f /tmp/test_output.log 2>/dev/null || true

# 一時ファイルの削除
echo "一時ファイルを削除中..."
rm -f /tmp/convert_logs.py 2>/dev/null || true

echo "✅ クリーンアップ完了！"
```

---

## 使用方法

### 1. 個別のテストスクリプトとして保存

```bash
# ディレクトリ構造
tests/
├── quick_health_check.sh
├── system_health_check.sh
├── integration_test.sh
├── test_structured_logger.py
├── test_error_loop_detector.py
└── cleanup_test_files.sh
```

### 2. 実行権限の付与

```bash
chmod +x tests/*.sh
```

### 3. テストの実行

```bash
# クイックチェック
./tests/quick_health_check.sh

# 詳細チェック
./tests/system_health_check.sh

# 統合テスト
./tests/integration_test.sh

# Pythonテスト
python3 tests/test_structured_logger.py
python3 tests/test_error_loop_detector.py

# クリーンアップ
./tests/cleanup_test_files.sh
```

### 4. 全テストの一括実行

```bash
#!/bin/bash
# run_all_tests.sh

echo "🚀 全テスト実行開始"

# 各テストを順番に実行
for test in tests/*.sh; do
    if [[ -x "$test" && "$test" != *"cleanup"* ]]; then
        echo "\n実行中: $test"
        "$test" || echo "⚠️ $test が失敗しました"
    fi
done

# Pythonテスト
for test in tests/*.py; do
    echo "\n実行中: $test"
    python3 "$test" || echo "⚠️ $test が失敗しました"
done

# クリーンアップ
./tests/cleanup_test_files.sh

echo "\n✅ 全テスト完了"
```

---

## 注意事項

1. **実行環境**: CCTeamプロジェクトのルートディレクトリで実行してください
2. **依存関係**: Python 3.x、bash、tmux が必要です
3. **権限**: スクリプトには実行権限が必要です
4. **ログ**: テスト実行時にログファイルが生成されます