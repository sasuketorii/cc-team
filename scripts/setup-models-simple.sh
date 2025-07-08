#!/bin/bash
# AIモデル設定 - シンプル版
# Claude: --model opus
# Gemini: --model gemini-2.5-pro (常にProシリーズ)

set -e

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🤖 CCTeam AI Model Setup (Simple)${NC}"
echo "=================================="

# エイリアス設定ファイル作成
cat > "$HOME/.ccteam-ai-aliases" << 'EOF'
# CCTeam AI Model Aliases

# Claude Opus 4 (MAXプラン使用)
alias opus='claude --model opus'
alias claude-opus='claude --model opus'

# Gemini 2.5 Pro (無料で1日1000リクエスト)
alias gemini='gemini --model gemini-2.5-pro'
alias gemini-pro='gemini --model gemini-2.5-pro'
alias gemini-flash='gemini --model gemini-2.5-flash'  # 高速版も2.5シリーズ

# 使い分けガイド
# opus: 複雑な問題解決、アーキテクチャ設計、詳細なコードレビュー
# gemini: 高速検索、ドキュメント生成、簡単なコード生成
EOF

echo -e "${GREEN}✓ AI aliases created${NC}"

# 起動スクリプトに追加
if ! grep -q "ccteam-ai-aliases" "$HOME/.bashrc" 2>/dev/null && ! grep -q "ccteam-ai-aliases" "$HOME/.zshrc" 2>/dev/null; then
    echo -e "\n${YELLOW}Add this to your shell config:${NC}"
    echo "source ~/.ccteam-ai-aliases"
fi

# エージェント用の簡易ガイド作成
cat > instructions/ai-usage-guide.md << 'EOF'
# AI使用ガイド (CCTeam)

## Claude (Opus 4)
```bash
# 常にOpusモデルを使用
opus "複雑な問題を解決して"
claude --model opus "アーキテクチャを設計して"
```

## Gemini (2.5 Pro)
```bash
# 2.5 Proモデルを使用（無料で1日1000リクエスト）
gemini "React 19の新機能を教えて"
gemini --model gemini-2.5-pro "このエラーの解決方法"

# 高速レスポンスが必要な場合
gemini --model gemini-2.5-flash "簡単な質問"
```

## 使い分け
- **Opus**: 戦略的判断、複雑な実装、品質レビュー
- **Gemini**: 調査、ドキュメント検索、簡単なコード生成
EOF

echo -e "${GREEN}✓ AI usage guide created${NC}"

echo -e "\n${BLUE}📋 Setup Complete!${NC}"
echo ""
echo "Claude: Always uses Opus 4 (--model opus)"
echo "Gemini: Always uses 2.5 Pro (--model gemini-2.5-pro)"
echo ""
echo "Usage examples:"
echo "  opus \"solve complex problem\""
echo "  gemini \"quick research task\""