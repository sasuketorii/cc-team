#!/bin/bash

# テストファイルのクリーンアップスクリプト

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