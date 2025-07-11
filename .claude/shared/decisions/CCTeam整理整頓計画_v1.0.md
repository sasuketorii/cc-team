# CCTeam整理整頓計画 v1.0
## Claude Code公式ベストプラクティス準拠版

### 📋 エグゼクティブサマリー

CCTeamプロジェクトの現状分析により、Claude Code公式推奨構造との乖離が確認されました。本計画書は、基礎基本に忠実でありながら、無限の拡張性を持つ新しい組織構造を提案します。

**キーコンセプト：**
- 🎯 **基礎基本の徹底**: Claude Code公式構造への完全準拠
- 🚀 **無限の扉**: Opus/Sonnet混成チームによる効率的な開発
- 📊 **整理整頓**: 明確なディレクトリ構造とファイル配置

---

## 🔍 現状分析

### 1. 構造的問題点

#### .claude ディレクトリの散在
- 3つの.claudeディレクトリが無秩序に存在
- 公式推奨のサブディレクトリ構造が欠如
- カスタムコマンド、共有知識、ログの管理が不統一

#### CLAUDE.md の不完全性
- 公式推奨セクションの欠如（Tech Stack、Commands等）
- 階層的なCLAUDE.md構造の未実装
- ローカル作業用CLAUDE.local.mdの不在

#### MCPとの統合不足
- .mcp.jsonファイルの欠如
- ツール統合の機会損失
- 自動化の可能性が未活用

### 2. 組織的課題

#### リソース配分の非効率性
- すべてのタスクでOpusを使用（コスト高）
- 単純作業とアーキテクチャ決定の区別なし
- レート制限への頻繁な到達

#### 知識管理の分散
- investigation_reportsが独立して存在
- 成功パターンの体系的な蓄積なし
- レビュー履歴の散逸

---

## 🏗️ 新しい組織構造

### 1. ディレクトリ構造の再編成

```bash
CCTeam/
├── CLAUDE.md                    # プロジェクト全体の指示（改訂版）
├── CLAUDE.local.md             # ローカル作業メモ（.gitignore対象）
├── .claude/                    # Claude Code専用ディレクトリ（統一）
│   ├── commands/               # カスタムスラッシュコマンド
│   │   ├── ccteam-status.md
│   │   ├── ccteam-sync.md
│   │   ├── code-review.md
│   │   ├── run-tests.md
│   │   └── deploy.md
│   ├── shared/                 # CCTeam共有ナレッジ
│   │   ├── decisions/          # アーキテクチャ決定（旧investigation_reports）
│   │   ├── implementations/    # 実装成果物
│   │   ├── reviews/           # レビュー記録
│   │   ├── patterns/          # 成功パターン
│   │   └── metrics/           # パフォーマンスメトリクス
│   ├── logs/                  # 実行ログ（移動）
│   └── settings.json          # Claude設定
├── .mcp.json                  # MCP設定（新規）
├── scripts/                   # 実行スクリプト（保持）
│   ├── common/               # 共通ユーティリティ
│   └── ...                   # 既存スクリプト
├── worktrees/                # Git worktree（保持）
│   ├── frontend/
│   │   └── CLAUDE.md         # Frontend固有の指示
│   ├── backend/
│   │   └── CLAUDE.md         # Backend固有の指示
│   └── database/
│       └── CLAUDE.md         # Database固有の指示
└── requirements/             # 要件定義（保持）
```

### 2. Opus/Sonnet混成チーム構成

#### 新しいチーム編成
```yaml
CCTeam v2.0 Structure:
  
決定層（Opus使用）:
  Boss:
    - モデル: claude-opus-4
    - 責任: アーキテクチャ決定、品質基準設定
    - 使用頻度: 必要時のみ（コスト最適化）
  
  PM層:
    - Frontend PM: claude-opus-4（複雑なUI/UX決定時）
    - Backend PM: claude-opus-4（API設計、データフロー決定時）
    - DB/Security PM: claude-opus-4（スキーマ設計、セキュリティ監査時）
    - 使用方針: 設計・レビュー時のみ使用

実装層（Sonnet使用）:
  Workers (1-6):
    - モデル: claude-sonnet-4
    - 責任: コード実装、ユニットテスト作成
    - 使用頻度: 日常的な実装作業
    - 利点: レート制限回避、コスト削減
```

#### 役割分担の明確化
```markdown
## Opus担当タスク（高度な判断が必要）
- アーキテクチャ設計
- 技術選定の決定
- 複雑な問題の解決
- コードレビューと品質評価
- セキュリティ監査

## Sonnet担当タスク（実装中心）
- コンポーネント実装
- ユニットテスト作成
- ドキュメント作成
- リファクタリング
- バグ修正
```

### 3. カスタムコマンドシステム

#### 基本コマンド（.claude/commands/）
```markdown
# ccteam-status.md
Show comprehensive CCTeam status:
1. Active Opus sessions and their current tasks
2. Active Sonnet workers and progress
3. Cost usage for current day
4. Rate limit status for both models
5. Pending architectural decisions

# ccteam-assign.md
Intelligently assign tasks based on complexity:
1. Analyze task requirements
2. Determine if Opus-level decision is needed
3. Assign to appropriate model/role
4. Create task file in shared/queue/
5. Notify assigned agent

# ccteam-handoff.md
Handle Opus to Sonnet handoff:
1. Opus creates detailed implementation plan
2. Save plan to shared/implementations/
3. Assign Sonnet workers
4. Monitor implementation progress
```

### 4. 知識管理システム

#### 決定記録の体系化
```bash
.claude/shared/decisions/
├── DECISION-001-architecture.md     # 全体アーキテクチャ
├── DECISION-002-tech-stack.md       # 技術スタック選定
├── DECISION-003-api-design.md       # API設計方針
└── TEMPLATE-decision.md             # 決定テンプレート
```

#### パターンライブラリ
```bash
.claude/shared/patterns/
├── frontend/
│   ├── component-structure.md
│   ├── state-management.md
│   └── testing-strategy.md
├── backend/
│   ├── api-patterns.md
│   ├── error-handling.md
│   └── validation-rules.md
└── common/
    ├── naming-conventions.md
    └── git-workflow.md
```

### 5. 自動化とモニタリング

#### コスト追跡システム
```python
# .claude/commands/cost-monitor.md
Track Claude API usage and costs:
1. Count Opus API calls from logs
2. Count Sonnet API calls from logs
3. Calculate daily/weekly/monthly costs
4. Alert if approaching budget limits
5. Suggest optimization opportunities
```

#### 品質保証の自動化
```bash
# .claude/commands/quality-gate.md
Automated quality checks before merge:
1. Run all unit tests
2. Check test coverage (min 80%)
3. Validate documentation completeness
4. Verify no Opus decisions are pending
5. Ensure Sonnet implementations match Opus designs
```

---

## 📋 実装計画

### Phase 1: 基礎構造の確立（Day 1-2）

1. **ディレクトリ再構成**
   ```bash
   # 新しい.claude構造を作成
   mkdir -p .claude/{commands,shared/{decisions,implementations,reviews,patterns,metrics},logs}
   
   # 既存ファイルの移動
   mv logs/* .claude/logs/
   mv investigation_reports/* .claude/shared/decisions/
   ```

2. **CLAUDE.md の標準化**
   ```markdown
   # 各CLAUDE.mdに公式セクションを追加
   - Tech Stack
   - Project Structure
   - Commands
   - Code Style
   - Repository Etiquette
   - CCTeam Specific Rules
   ```

3. **MCP設定の作成**
   ```json
   {
     "mcpServers": {
       "github": {...},
       "filesystem": {...},
       "memory": {...}
     }
   }
   ```

### Phase 2: チーム再編成（Day 3-4）

1. **役割定義の更新**
   - Opus/Sonnet使い分けガイドライン作成
   - タスク複雑度の判定基準策定
   - ハンドオフプロセスの定義

2. **カスタムコマンド実装**
   - 基本コマンドセットの作成
   - チーム管理コマンドの実装
   - コスト監視システムの構築

### Phase 3: 運用開始（Day 5+）

1. **段階的移行**
   - 新規タスクから新体制を適用
   - 既存ワークフローの段階的更新
   - チームメンバーへのトレーニング

2. **継続的改善**
   - メトリクス収集と分析
   - プロセスの最適化
   - 成功パターンの文書化

---

## 🎯 期待される成果

### 定量的効果
- **コスト削減**: Opus使用量を50%削減
- **開発速度**: レート制限の影響を70%軽減
- **品質向上**: 標準化により一貫性が30%向上

### 定性的効果
- **知識の体系化**: 決定事項と実装の明確な分離
- **スケーラビリティ**: 無限のSonnetワーカー追加が可能
- **保守性**: Claude Code標準への準拠による将来性

---

## 🚀 無限の扉を開く

この新しい構造により、CCTeamは以下を実現します：

1. **基礎基本の徹底**
   - Claude Code公式構造への完全準拠
   - 明確な役割分担とプロセス
   - 体系的な知識管理

2. **スケーラブルな成長**
   - Sonnetワーカーの無制限追加
   - コスト効率的な開発体制
   - レート制限からの解放

3. **継続的な進化**
   - パターンライブラリの自動成長
   - メトリクスベースの改善
   - AIエージェント協調の新境地

CCTeamは単なるツールから、真の「AI開発組織」へと進化します。