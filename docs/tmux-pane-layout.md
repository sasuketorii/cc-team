# CCTeam tmuxペインレイアウト

## 各チームのペイン配置

すべてのチーム（Team1, Team2, Team3）で統一されたレイアウト：

```
┌─────────────┬─────────────┐
│    PM       │   Worker1   │
│  (左上)     │   (右上)    │
│  Opus       │   Sonnet    │
│ main.0      │  main.1     │
├─────────────┼─────────────┤
│  Worker2    │   Worker3   │
│  (左下)     │   (右下)    │
│  Sonnet     │   Sonnet    │
│  main.2     │  main.3     │
└─────────────┴─────────────┘
```

## 役割詳細

### Team1 (Frontend) - `tmux attach -t ccteam-1`
- **PM-1** (左上): フロントエンド統括
- **Worker1** (右上): UIコンポーネント開発
- **Worker2** (左下): 状態管理・データフロー
- **Worker3** (右下): テスト・品質保証

### Team2 (Backend) - `tmux attach -t ccteam-2`
- **PM-2** (左上): バックエンド統括
- **Worker1** (右上): API開発
- **Worker2** (左下): データベース・キャッシュ
- **Worker3** (右下): 認証・セキュリティ

### Team3 (DevOps) - `tmux attach -t ccteam-3`
- **PM-3** (左上): DevOps統括
- **Worker1** (右上): CI/CD・自動化
- **Worker2** (左下): インフラ・監視
- **Worker3** (右下): セキュリティ・コンプライアンス

## tmux操作

### ペイン間の移動
```bash
# 矢印キーで移動
Ctrl+b → ↑/↓/←/→

# ペイン番号で直接移動
Ctrl+b → q → [番号]
```

### ペインタイトルの確認
tmux 2.3以降では、各ペインの上部にタイトル（PM-1, Worker1など）が表示されます。

## コミュニケーションフロー

```
ユーザー
  ↓
Boss (ccteam-boss)
  ↓
PM (各チームの左上ペイン)
  ↓
Workers (右上、左下、右下ペイン)
```

**重要**: Bossは必ずPMを経由してWorkerに指示を出します。