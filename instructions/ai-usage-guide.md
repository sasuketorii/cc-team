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
