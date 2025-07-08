# CCTeam 使用AIモデル仕様

## Claude Code
- **コマンド**: `claude --model opus` または `opus`
- **モデル**: Opus 4 (最新版)
- **用途**: 
  - 複雑な問題解決
  - アーキテクチャ設計
  - 詳細なコードレビュー
  - 戦略的判断

## Gemini CLI
- **コマンド**: `gemini --model gemini-2.5-pro` または `gemini`
- **モデル**: Gemini 2.5 Pro
- **無料枠**: 1日1000リクエスト
- **用途**:
  - 高速な情報検索
  - ドキュメント生成
  - 簡単なコード生成
  - API仕様調査

## 使用例

```bash
# Claude Opus 4
opus "複雑なバグの原因を分析して"
claude --model opus "アーキテクチャを設計して"

# Gemini 2.5 Pro
gemini "React 19の新機能を教えて"
gemini --model gemini-2.5-pro "このエラーの解決方法"
```

## 自動設定
`./scripts/setup.sh` 実行時にエイリアスが自動設定されます。

## 認証方法

### Claude Code
- **認証**: MAXプランアカウント連携
- **APIキー**: 不要（アカウントログイン使用）

### Gemini CLI
- **認証**: APIキー
- **環境変数**: `export GEMINI_API_KEY="your-gemini-api-key"`
- **無料枠**: 1日1000リクエスト
- **取得先**: https://makersuite.google.com/app/apikey