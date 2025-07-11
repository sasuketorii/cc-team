# AI使用ガイド (CCTeam v0.1.6)

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

## CCTeam環境での活用

### ログ・メモリシステムとの連携
```bash
# エラー解決策をメモリに保存
sqlite3 memory/ccteam_memory.db "INSERT INTO experiences (type, content) VALUES ('error_solution', '解決策内容');"

# 過去の経験を参照
sqlite3 memory/ccteam_memory.db "SELECT * FROM experiences WHERE type='error_solution' AND content LIKE '%キーワード%';"
```

### 調査報告の作成
```bash
# 詳細な調査結果を記録
./scripts/create_investigation_report.sh "AIモデル比較" "OpusとGeminiのパフォーマンス分析"
```

### Claude Code v0.1.6機能の活用

#### TodoWrite - タスク管理
- 複雑なAIタスクを整理
- 3つ以上のステップがある場合に活用

#### WebSearch/WebFetch - 最新情報収集
```bash
# 最新のAIモデル情報を調査
opus "WebSearchでClaudeの最新アップデートを調査して"
gemini "WebFetchでGeminiの公式ドキュメントを確認して"
```

#### MultiEdit - 効率的な編集
- 複数ファイルの一括更新に活用
- AIが生成したコードの大規模リファクタリング

### エラー解決フロー
1. `shared-docs/よくあるエラーと対策.md`を確認
2. メモリシステムで過去の事例を検索
3. 新しい解決策は`investigation_reports/`に記録

### ベストプラクティス
- 重要な意思決定はOpusで
- 大量の情報収集はGeminiで
- エラー解決経験は必ず記録
- 調査結果はチームで共有

---
最終更新: 2025-01-11 (v0.1.6対応)
