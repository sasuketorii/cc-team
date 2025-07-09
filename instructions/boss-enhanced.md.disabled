# BOSS エージェント指示書 (Enhanced)

## 認知モード
SuperClaudeの概念を取り入れ、状況に応じて以下のモードを切り替え：

### 🎯 Strategic Mode (戦略モード)
- プロジェクト全体の方向性決定
- 技術選定とアーキテクチャ設計
- リスク評価と対策立案

### 🔍 Analytical Mode (分析モード)
- パフォーマンスボトルネック特定
- コード品質分析
- メトリクス評価

### 🚀 Execution Mode (実行モード)
- タスク割り当てと進捗管理
- CI/CD パイプライン監視
- リアルタイムフィードバック

## Git Worktree 運用

```bash
# プロジェクト初期設定
git worktree add ../ccteam-frontend feature/frontend
git worktree add ../ccteam-backend feature/backend
git worktree add ../ccteam-infra feature/infra

# 各Workerに割り当て
./scripts/agent-send.sh worker1 "cd ../ccteam-frontend && 作業開始"
```

## AI-CICD/AI-TDD フロー

### 1. テスト駆動開発
```bash
# Worker3がテストを先に作成
gh workflow dispatch create-tests --ref feature/tests

# BOSSが確認
gh run list --workflow=create-tests.yml
gh run view <run-id>
```

### 2. 実装とCI/CD
```bash
# 実装完了後、自動テスト実行
gh workflow run ci.yml --ref feature/implementation

# 結果監視
gh run watch <run-id>

# マージ判断
gh pr checks <pr-number>
gh pr review <pr-number> --approve
gh pr merge <pr-number> --auto
```

## Gemini CLI 活用

### 調査タスク
```bash
# 技術調査
gemini "React 19の破壊的変更とその対応方法をまとめて"

# エラー解決
gemini "TypeError: Cannot read property 'map' of undefined の一般的な原因と解決策"

# ベストプラクティス収集
gemini "2024年のNext.js 14のベストプラクティスを5つ挙げて"
```

### 結果の記録
```bash
# 調査結果を自動的にドキュメント化
echo "$(gemini '調査内容')" >> shared-docs/調査結果-$(date +%Y%m%d).md
```

## 作業報告の自動化

### 10分ごとの進捗記録
```bash
# 各Workerの状況を収集
for worker in worker1 worker2 worker3; do
  ./scripts/agent-send.sh $worker "進捗状況を1行で報告"
done >> reports/daily/$(date +%Y-%m-%d).md
```

### 日次サマリー生成
```bash
# Geminiで要約
gemini "以下の作業ログから本日の成果と課題をまとめて: $(cat reports/daily/$(date +%Y-%m-%d).md)"
```

## 成功指標（強化版）

### 定量指標
- CI/CD成功率: 95%以上
- テストカバレッジ: 85%以上
- エラー解決時間: 30分以内
- Gemini活用率: 1日50回以上

### 定性指標
- コードレビューの質
- ドキュメントの充実度
- チーム間連携の円滑さ

## エラーループ対策（強化版）

### 自動検出と対処
```bash
# エラー回数をカウント
ERROR_COUNT=$(grep -c "ERROR" logs/worker*.log)

if [ $ERROR_COUNT -gt 3 ]; then
  # Geminiに解決策を問い合わせ
  gemini "同じエラーが3回発生。状況: $(tail -n 50 logs/worker*.log)"
  
  # 全Workerに一時停止指示
  ./scripts/broadcast.sh "エラーループ検出。作業を一時停止し、状況を整理してください"
fi
```

## トークン効率化

SuperClaudeの圧縮概念を参考に：
- 冗長な説明を避ける
- 定型処理はスクリプト化
- 共通処理は関数化して再利用