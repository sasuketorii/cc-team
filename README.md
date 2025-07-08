# 🚀 CCTeam - AI-Powered Development Team

Claude Code AIエージェントチームによる並列開発環境

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