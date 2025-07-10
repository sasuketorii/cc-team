# 🚀 CCTeam - AI-Powered Development Team

Claude Code AIエージェントチームによる並列開発環境

## 🔄 最新アップデート (v0.1.1)

### 🎯 v0.1.1の更新内容

#### 📚 ドキュメント整備
- 全ドキュメントのバージョン情報を統一
- 古いバージョン参照を修正
- 使用方法ガイドの充実化

### 🚀 v0.1.0の主要機能

#### 1️⃣ **完全手動認証システム**
- 初期プロンプトを一切送信しない
- ユーザーが各エージェントで手動認証
- 認証後、ユーザーが初期指示を入力

#### 2️⃣ **ガイド付き起動モード**
```bash
ccguide  # 初心者向けステップバイステップガイド
```

#### 3️⃣ **リアルタイム監視ツール**
```bash
ccmon    # エージェント状態をリアルタイム表示
```

#### 4️⃣ **プロンプトテンプレート**
```bash
ccprompt # よく使うプロンプトの例を表示
```

#### 5️⃣ **Boss/Worker連携強化**
- 新しい指示書（boss-v2.md, worker-v2.md）
- 10分ごとの進捗確認
- 標準化された報告フォーマット

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

### 2️⃣ 起動方法を選択

#### 🚀 通常起動（推奨）
```bash
ccteam  # v3: 完全手動認証版
```

#### 🎯 初心者向け
```bash
ccguide # ステップバイステップガイド付き
```

#### 📊 起動後の監視
```bash
ccmon   # 別ターミナルで状態監視
```

### 3️⃣ 認証と初期プロンプト

1. **Bossセッションに接続**
   ```bash
   tmux attach -t ccteam-boss
   ```
   - Bypass Permissions画面で `2` を選択

2. **Workerセッションに接続**
   ```bash
   tmux attach -t ccteam-workers
   ```
   - 各ペインで `2` を選択（Ctrl+b → 矢印キーで切替）

3. **Bossに初期指示を入力**
   ```
   requirementsフォルダの要件を読み込み、役割分担して開発を開始してください
   ```

---

## 🎯 便利なコマンド一覧

```bash
### 🚀 起動・管理
ccteam         # CCTeam起動（v3: 手動認証版）
ccguide        # ガイド付き起動（初心者向け）
ccmon          # リアルタイム状態監視
cckill         # 全tmuxセッション終了

### 💬 コミュニケーション
ccsend boss "進捗どう？"        # Bossにメッセージ
ccsend worker1 "UI実装して"     # Worker1にメッセージ
ccprompt                       # プロンプトテンプレート表示

### 📊 情報確認
ccs            # プロジェクトステータス
cca            # tmuxセッションに接続

### 🔄 バージョン管理
ccv bump "バグ修正"      # 0.0.1 → 0.0.2
ccv minor "新機能"       # 0.0.2 → 0.1.0  
ccv rollback v0.0.1     # 前のバージョンに戻す

### ⚡ ショートカット
cct            # ccteamの短縮形
ccbump         # バージョンアップ
ccback         # ロールバック
```

---

## ✨ 特徴

- ✅ **完全手動認証**: 初期プロンプトを送信せず、ユーザー主導
- ✅ **ガイド付き起動**: 初心者でも簡単セットアップ
- ✅ **リアルタイム監視**: エージェントの状態を可視化
- ✅ **4画面並列**: BOSS + 3 Workers が同時作業
- ✅ **強化された連携**: 標準化された報告フォーマット
- ✅ **豊富なツール**: プロンプトテンプレート、状態監視など

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