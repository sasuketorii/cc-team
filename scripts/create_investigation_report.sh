#!/bin/bash

# 調査報告書作成スクリプト
# 日本時間でファイル名を生成

set -euo pipefail

# 引数チェック
if [ $# -lt 1 ]; then
    echo "Usage: $0 <title> [description]"
    echo "Example: $0 'エラーループ調査' 'エラーループ検出システムの動作調査'"
    exit 1
fi

TITLE="$1"
DESCRIPTION="${2:-}"

# 日本時間でタイムスタンプ生成（UTC+9）
TIMESTAMP=$(TZ=Asia/Tokyo date '+%Y%m%d_%H%M%S')
DATE_JP=$(TZ=Asia/Tokyo date '+%Y年%m月%d日 %H時%M分%S秒')

# ファイル名生成（スペースをアンダースコアに置換）
FILENAME="investigation_reports/${TIMESTAMP}_${TITLE// /_}調査報告.md"

# 報告書テンプレート作成
cat > "$FILENAME" << EOF
# ${TITLE}調査報告書

作成日時: ${DATE_JP} (JST)
作成者: CCTeam
バージョン: $(cat package.json | grep '"version"' | cut -d'"' -f4)

---

## 📋 概要

${DESCRIPTION}

## 🔍 調査目的

- [ ] 目的1
- [ ] 目的2
- [ ] 目的3

## 📊 調査結果

### 1. 現状分析

### 2. 問題点の特定

### 3. 技術的詳細

## 💡 提案・改善策

### 短期的対策

### 長期的対策

## 📈 実装計画

| フェーズ | 内容 | 期間 | 優先度 |
|---------|------|------|--------|
| Phase 1 | | 1週間 | 高 |
| Phase 2 | | 2週間 | 中 |
| Phase 3 | | 1ヶ月 | 低 |

## 🚀 次のアクション

1. 
2. 
3. 

## 📎 参考資料

- 
- 
- 

---

## 更新履歴

- ${DATE_JP}: 初版作成
EOF

echo "✅ 調査報告書を作成しました: $FILENAME"
echo ""
echo "ファイルを編集してください:"
echo "  code $FILENAME"
echo "  または"
echo "  cursor $FILENAME"