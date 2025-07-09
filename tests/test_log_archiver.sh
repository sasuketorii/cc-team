#!/bin/bash

# テスト結果をアーカイブするスクリプト

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_DIR="tests/history/$TIMESTAMP"

echo "📦 テスト結果をアーカイブ中..."

# アーカイブディレクトリ作成
mkdir -p "$ARCHIVE_DIR"

# レポートファイルをコピー
if [[ -d "reports" ]]; then
    cp -r reports/*.md "$ARCHIVE_DIR/" 2>/dev/null || true
    cp -r reports/*.txt "$ARCHIVE_DIR/" 2>/dev/null || true
fi

# テストログをコピー
if [[ -f "/tmp/test_output.log" ]]; then
    cp /tmp/test_output.log "$ARCHIVE_DIR/"
fi

# サマリーファイル作成
cat > "$ARCHIVE_DIR/summary.txt" << EOF
テスト実行日時: $(date '+%Y-%m-%d %H:%M:%S')
システムバージョン: $(cat package.json | grep '"version"' | cut -d'"' -f4)
実行ユーザー: $(whoami)
ブランチ: $(git branch --show-current)
最新コミット: $(git log -1 --oneline)
EOF

echo "✅ アーカイブ完了: $ARCHIVE_DIR"