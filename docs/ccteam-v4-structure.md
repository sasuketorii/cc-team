# CCTeam v4 階層構造

## 概要
CCTeam v4は、より洗練されたシンプルな階層構造を採用しています。1人のBossが3つの専門チームを統括し、各チームは従来の4人構成（PM1人+Worker3人）を維持します。

## 構造図
```
👑 Boss (全体統括) - Opus 4
├── Team1 [Frontend]
│   ├── PM-1 (Opus 4) - チームリーダー
│   ├── Worker1-1 (Sonnet) - UIコンポーネント
│   ├── Worker1-2 (Sonnet) - 状態管理
│   └── Worker1-3 (Sonnet) - テスト・品質
├── Team2 [Backend]
│   ├── PM-2 (Opus 4) - チームリーダー
│   ├── Worker2-1 (Sonnet) - API開発
│   ├── Worker2-2 (Sonnet) - データベース
│   └── Worker2-3 (Sonnet) - セキュリティ
└── Team3 [DevOps]
    ├── PM-3 (Opus 4) - チームリーダー
    ├── Worker3-1 (Sonnet) - CI/CD
    ├── Worker3-2 (Sonnet) - インフラ
    └── Worker3-3 (Sonnet) - 監視・運用
```

## tmuxセッション構成
- **ccteam-boss**: Boss専用セッション（1ペイン）
- **ccteam-1**: Team1セッション（4分割 - Frontend）
- **ccteam-2**: Team2セッション（4分割 - Backend）
- **ccteam-3**: Team3セッション（4分割 - DevOps）

## コマンド一覧

### 起動
```bash
# v4構造でCCTeamを起動
ccteam-v4

# または直接スクリプト実行
./scripts/launch-ccteam-v4.sh
```

### 接続
```bash
# Boss接続
tmux attach -t ccteam-boss

# 各チーム接続
tmux attach -t ccteam-1  # Frontend
tmux attach -t ccteam-2  # Backend
tmux attach -t ccteam-3  # DevOps
```

### 通信
```bash
# Boss宛
ccsend boss "全体の進捗を報告してください"

# PM宛
ccsend pm1 "フロントエンドの状況は？"
ccsend pm2 "API開発の進捗は？"
ccsend pm3 "デプロイ準備はOK？"

# Worker宛
ccsend worker1-1 "コンポーネントの実装状況は？"
ccsend worker2-1 "APIエンドポイントの進捗は？"
ccsend worker3-1 "CI/CDパイプラインの状態は？"
```

### 自動認証
```bash
# v4用自動認証
./scripts/auto-auth-claude-v4.sh
```

## ペインマッピング

### Boss (ccteam-boss)
- main.0: Boss

### Team1 (ccteam-1) - Frontend
- main.0: PM-1 (左上)
- main.1: Worker1-1 (右上)
- main.2: Worker1-2 (左下)
- main.3: Worker1-3 (右下)

### Team2 (ccteam-2) - Backend
- main.0: PM-2 (左上)
- main.1: Worker2-1 (右上)
- main.2: Worker2-2 (左下)
- main.3: Worker2-3 (右下)

### Team3 (ccteam-3) - DevOps
- main.0: PM-3 (左上)
- main.1: Worker3-1 (右上)
- main.2: Worker3-2 (左下)
- main.3: Worker3-3 (右下)

## 特徴
1. **シンプルな構造**: 従来の4人チーム構造を3つ並列で運用
2. **明確な役割分担**: Boss→PM→Workerの階層
3. **専門チーム**: Frontend/Backend/DevOpsの分離
4. **既存機能の活用**: メモリシステム、エラーループ検出を完全統合
5. **柔軟な通信**: 直感的なエージェント名

## ワークフロー例

### 新機能開発
1. Boss: "新しい認証機能を実装してください"
2. PM-1: UIデザインをWorker1-1に指示
3. PM-2: APIをWorker2-1に指示
4. PM-3: デプロイ準備をWorker3-1に指示
5. 各Worker: 並列で実装
6. 各PM: Bossに進捗報告
7. Boss: 全体統合確認

### デイリー運用
```bash
# 朝の点呼
ccsend boss "全チーム、朝の状況報告をお願いします"

# タスク配分
ccsend pm1 "本日のフロントエンドタスクを配分してください"

# 進捗確認
ccsend worker2-1 "APIの実装状況を教えてください"

# 統合確認
ccsend boss "全チームの本日の成果をまとめてください"
```