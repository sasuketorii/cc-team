# 🚀 CCTeam - AI-Powered Development Team

Claude Code AIエージェントチームによる並列開発環境

## 🔄 最新アップデート (v0.0.8)

### 新機能
- ✅ **パーミッションモード対応**: 全自動実行とユーザー承認モードを選択可能
- ✅ **Boss暴走防止**: 自動実行機能を無効化し、待機モードを厳守
- ✅ **指示書最適化**: boss.mdとworker.mdを安定版に更新
- ✅ **調査報告書**: investigation_reports/に包括的な分析結果を追加
- ✅ **ccteam-killコマンド**: `ccteam-kill`でtmuxセッションを安全に終了

### 重要な変更点
- **認証フロー修正**: 全自動実行モードで初期プロンプトをBossのみに送信
  - 全エージェントのBypass Permissions認証完了を待機
  - 認証後にBossのみに初期指示を送信（Workerには送信しない）
- `claude-safe-launch.expect`: ユーザー承認モード用の新しい起動スクリプト
- `claude-auto-launch-v2.expect`: 全自動モード用の改良版（手動認証方式）
- `boss-enhanced.md`: 無効化（.disabledに変更）
- 承認モードに応じて異なるexpectスクリプトを使用するように改善
- Bypass Permissions画面での手動認証に対応

## 📦 超簡単！3ステップで開始

### 1️⃣ インストール
```bash
# クローン
git clone https://github.com/yourusername/CCTeam.git ~/CC-Team/CCTeam
cd ~/CC-Team/CCTeam

# グローバルコマンドをインストール
./install.sh
source ~/.bashrc  # または ~/.zshrc
```

### 2️⃣ 起動（どこからでも！）
```bash
ccteam  # これだけ！cdする必要なし！

# 起動時の選択
# 1) 全自動実行モード（デフォルト）
#    - --dangerously-skip-permissions使用
#    - 各エージェントのBypass Permissions画面で手動で'2'を選択
#    - 全エージェント認証後、Enterキーを押すとBossのみに初期指示を送信
#    - Workerには初期プロンプトを送信しない（待機モードを維持）
#
# 2) ユーザー承認モード
#    - 通常のClaude CLI（権限確認あり）
#    - より慎重な運用向け
#    - Boss/Worker全員に初期プロンプトを送信
```

### 3️⃣ 使う
```bash
cca  # セッションに接続（ccteam-attachの短縮形）
```

---

## 🎯 便利なコマンド（どこからでも使える！）

```bash
# 基本コマンド
ccteam         # CCTeam起動
cct            # ccteamの短縮形
cca            # tmuxセッションに接続
ccs            # ステータス確認

# バージョン管理
ccv bump "バグ修正"      # 0.0.1 → 0.0.2
ccv minor "新機能"       # 0.0.2 → 0.1.0  
ccv rollback v0.0.1     # 前のバージョンに戻す

# エージェントと会話
ccsend boss "進捗どう？"
ccsend worker1 "ログイン画面作って"

# tmuxセッション終了
cckill                  # 全tmuxセッションを終了
```

---

## ✨ 特徴

- ✅ **超簡単**: `ccteam`と打つだけ（cdいらない！）
- ✅ **4画面並列**: BOSS + 3 Workers が同時作業
- ✅ **自動バージョン管理**: 0.0.1刻みで簡単ロールバック
- ✅ **品質保証**: コミット前に自動チェック
- ✅ **AI活用**: Claude Opus 4 + Gemini 2.5 Pro

## ディレクトリ構造

```
CCTeam/
  scripts/              # 実行スクリプト
    setup.sh         # 環境構築
    launch-ccteam.sh # CCTeam起動
    agent-send.sh    # エージェント間通信
    project-status.sh # プロジェクト状況
  instructions/        # エージェント指示書
    boss.md         # BOSS用
    worker*.md      # Worker用
  requirements/        # プロジェクト要件
  logs/               # ログファイル
  CLAUDE.md           # プロジェクトメモリ
  README.md          # このファイル
```

## 使用方法

### 基本操作

```bash
# プロジェクト状況確認
./scripts/project-status.sh

# エージェントへの指示送信
./scripts/agent-send.sh boss "タスク分配を実行してください"

# ログ監視
tail -f logs/system.log
```

### tmux操作

- `Ctrl+b` + `矢印キー`: ペイン切り替え
- `Ctrl+b` + `d`: デタッチ
- `tmux attach -t ccteam`: 再接続

## エージェント構成

| エージェント | 役割 | 位置 | ショートカット |
|------------|------|---------|------------|
| BOSS | プロジェクト管理・統括 | 左上 | d |
| Worker1 | フロントエンド開発 | 右上 | R |
| Worker2 | バックエンド開発 | 左下 | L |
| Worker3 | テスト・品質保証 | 右下 | B |

## トラブルシューティング

### tmuxセッションが見つからない場合

```bash
# セッション一覧確認
tmux ls

# 再構築
./scripts/setup.sh
```

### エージェントが応答しない場合

```bash
# ログ確認
tail -f logs/boss.log
tail -f logs/worker1.log

# 再起動
./scripts/launch-ccteam.sh --restart
```

## ライセンス

MIT License

## サポート

Issues: https://github.com/yourusername/ccteam/issues 