# CCTeam Instructions ディレクトリ

## 概要
このディレクトリには、CCTeamの各AIエージェント向けの指示書が格納されています。

## ファイル構造

```
instructions/
├── README.md               # このファイル
├── agent_instructions.md   # 全エージェント共通の基本指示
├── ai-usage-guide.md      # AI（Claude/Gemini）の使用ガイド
├── boss.md                # BOSS（統括管理者）専用指示書 v2.1
├── worker.md              # 全Worker共通の指示書 v2.1
├── worker1.md             # Worker1（フロントエンド）専用指示書
├── worker2.md             # Worker2（バックエンド）専用指示書
└── worker3.md             # Worker3（インフラ/テスト）専用指示書
```

## 各ファイルの役割

### 📌 agent_instructions.md
- **全エージェント共通**の基本ガイドライン
- エラーループ防止の詳細な手順
- 各エージェントへの役割説明テンプレート

### 🤖 ai-usage-guide.md
- Claude CodeとGemini Flashの使い分け
- CLIコマンドの使用方法
- モデル選択の指針

### 🎯 boss.md (v2.1)
- プロジェクト全体の統括管理
- Git Worktree自動管理
- ログ/メモリシステムの活用
- Claude Code v0.1.6機能の統合

### 👥 worker.md (v2.1)
- 全Worker共通のルール
- 報告フォーマット
- 連携方法
- 新機能（ログ、メモリ、調査報告）の活用

### 👷 worker1.md / worker2.md / worker3.md
- 各分野の専門的な指示
- 技術スタックの参照方法
- 新機能の活用方法

## 重要な変更（v0.1.6）

### 1. パス参照の更新
- `requirements/project-tech-stack/*` → `requirements/`ディレクトリ内のユーザー配置ファイル
- `shared-docs/error-solutions/` → `shared-docs/よくあるエラーと対策.md`

### 2. 新機能の統合
- **ログ管理**: `logs/`ディレクトリへの自動記録
- **メモリシステム**: `memory/ccteam_memory.db`での経験蓄積
- **調査報告**: `investigation_reports/`への詳細記録
- **アーカイブ**: `archive/`への古いファイル移動

### 3. Claude Code v0.1.6機能
- **TodoWrite**: 複雑なタスク管理
- **WebSearch/WebFetch**: 最新情報の調査
- **MultiEdit**: 効率的な一括編集

### 4. エラーループ防止の一元化
- 詳細は`agent_instructions.md`に集約
- 各worker指示書は参照のみ

## 使用方法

1. **新規プロジェクト開始時**
   - ユーザーが`requirements/`に要件定義書を配置
   - BOSSが要件を分析し、各Workerに役割を割り当て

2. **開発中**
   - 各エージェントは自分の指示書に従って作業
   - 共通ルールは`agent_instructions.md`と`worker.md`を参照

3. **エラー発生時**
   - `agent_instructions.md`のエラーループ防止ガイドラインに従う
   - `shared-docs/よくあるエラーと対策.md`を参照

4. **調査・分析時**
   - 詳細な調査結果は`investigation_reports/`に保存
   - 過去の経験は`memory/ccteam_memory.db`から参照

## 注意事項

- 指示書の内容は定期的に更新されます
- 最新のバージョン番号を確認してください
- 大きな変更がある場合は、Version Historyセクションを確認してください

---
最終更新: 2025-01-11 (v0.1.6対応)