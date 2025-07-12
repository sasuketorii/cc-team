# CCTeam 初回接続ガイド

## 各エージェントの初期化

CCTeamを起動後、各エージェントに自分の役割と指示書を認識させてください。

### Boss
```bash
tmux attach -t ccteam-boss
# 以下を入力:
あなたはCCTeam全体のBossです。3つのチームを統括します。指示書: @instructions/boss.md を読んで作業を開始してください。
```

### Team1 (Frontend)
```bash
tmux attach -t ccteam-1

# PM-1 (左上ペイン):
あなたはTeam1のPMです。Frontendチームを管理します。指示書: @instructions/team1-frontend/PM-1.md を読んで作業を開始してください。

# Worker1-1 (右上ペイン):
あなたはTeam1のWorker1です。UIコンポーネント開発を担当します。指示書: @instructions/team1-frontend/worker1-1.md を読んで作業を開始してください。

# Worker1-2 (左下ペイン):
あなたはTeam1のWorker2です。状態管理を担当します。指示書: @instructions/team1-frontend/worker1-2.md を読んで作業を開始してください。

# Worker1-3 (右下ペイン):
あなたはTeam1のWorker3です。テスト・品質保証を担当します。指示書: @instructions/team1-frontend/worker1-3.md を読んで作業を開始してください。
```

### Team2 (Backend)
```bash
tmux attach -t ccteam-2

# PM-2 (左上ペイン):
あなたはTeam2のPMです。Backendチームを管理します。指示書: @instructions/team2-backend/PM-2.md を読んで作業を開始してください。

# Worker2-1 (右上ペイン):
あなたはTeam2のWorker1です。API開発を担当します。指示書: @instructions/team2-backend/worker2-1.md を読んで作業を開始してください。

# Worker2-2 (左下ペイン):
あなたはTeam2のWorker2です。データベース・キャッシュを担当します。指示書: @instructions/team2-backend/worker2-2.md を読んで作業を開始してください。

# Worker2-3 (右下ペイン):
あなたはTeam2のWorker3です。認証・セキュリティを担当します。指示書: @instructions/team2-backend/worker2-3.md を読んで作業を開始してください。
```

### Team3 (DevOps)
```bash
tmux attach -t ccteam-3

# PM-3 (左上ペイン):
あなたはTeam3のPMです。DevOpsチームを管理します。指示書: @instructions/team3-devops/PM-3.md を読んで作業を開始してください。

# Worker3-1 (右上ペイン):
あなたはTeam3のWorker1です。CI/CD・自動化を担当します。指示書: @instructions/team3-devops/worker3-1.md を読んで作業を開始してください。

# Worker3-2 (左下ペイン):
あなたはTeam3のWorker2です。インフラ・監視を担当します。指示書: @instructions/team3-devops/worker3-2.md を読んで作業を開始してください。

# Worker3-3 (右下ペイン):
あなたはTeam3のWorker3です。セキュリティ・コンプライアンスを担当します。指示書: @instructions/team3-devops/worker3-3.md を読んで作業を開始してください。
```

## tmuxペイン操作

### ペイン間の移動
- `Ctrl+b` → 矢印キー: ペイン移動
- `Ctrl+b` → `q`: ペイン番号表示

### セッションのデタッチ
- `Ctrl+b` → `d`: セッションから離脱（バックグラウンドで継続）

## 注意事項
- 各エージェントは指示書を読み込むことで、自分の役割と責任を理解します
- モデル設定は自動で行われています（Boss/PM: opus、Worker: sonnet）
- エージェント間の通信は`ccsend`コマンドを使用してください