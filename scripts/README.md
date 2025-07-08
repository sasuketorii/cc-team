# 📚 CCTeam Scripts ユーザーガイド

## 🚀 まず最初に！グローバルコマンドをインストール

```bash
cd ~/CC-Team/CCTeam
./install.sh
source ~/.bashrc  # または ~/.zshrc
```

これで**どこからでも**CCTeamが使えるようになります！

---

## 🎯 よく使うコマンド（覚えるのはこれだけ！）

### 起動・接続
```bash
ccteam    # CCTeam起動（どこからでも！）
cct       # ccteamの短縮形
cca       # 実行中のセッションに接続
```

### 開発中の操作
```bash
ccs                         # 状況確認
ccsend boss "タスク完了"     # BOSSに報告
ccsend worker1 "ヘルプ"      # Worker1に依頼
```

### バージョン管理
```bash
ccv bump "バグ修正"          # 0.0.1 → 0.0.2
ccv rollback                # 前のバージョンに戻す
```

---

## 📋 全スクリプト一覧（上級者向け）

### 🏠 基本スクリプト（直接実行する場合）

#### setup.sh - 初期セットアップ
```bash
cd ~/CC-Team/CCTeam
./scripts/setup.sh
```
- tmux環境構築
- ディレクトリ作成
- AI設定

#### launch-ccteam.sh - CCTeam起動
```bash
cd ~/CC-Team/CCTeam
./scripts/launch-ccteam.sh [--restart]
```
- 4エージェント起動
- `--restart`: 再起動オプション

### 💬 コミュニケーション

#### agent-send.sh - エージェント間通信
```bash
cd ~/CC-Team/CCTeam
./scripts/agent-send.sh <エージェント名> "<メッセージ>"

# 例
./scripts/agent-send.sh boss "進捗報告: ログイン機能完成"
./scripts/agent-send.sh worker1 "UIの修正お願い"
```

### 📊 管理・分析

#### project-status.sh - プロジェクト状況
```bash
cd ~/CC-Team/CCTeam
./scripts/project-status.sh
```

#### analyze-errors.sh - エラー分析
```bash
cd ~/CC-Team/CCTeam
./scripts/analyze-errors.sh
```

#### auto-report.sh - レポート生成
```bash
cd ~/CC-Team/CCTeam
./scripts/auto-report.sh [cron|summary]
```

### 🔖 バージョン管理

#### version-manager.sh - セマンティックバージョニング
```bash
cd ~/CC-Team/CCTeam
# パッチ更新 (0.0.1 → 0.0.2)
./scripts/version-manager.sh bump "修正内容"

# マイナー更新 (0.0.2 → 0.1.0)
./scripts/version-manager.sh minor "新機能"

# ロールバック
./scripts/version-manager.sh rollback v0.0.1

# 履歴表示
./scripts/version-manager.sh history
```

### 🛡️ 品質管理

#### quality-gate.sh - 品質チェック
```bash
cd ~/CC-Team/CCTeam
./scripts/quality-gate.sh report    # レポート生成
./scripts/quality-gate.sh ci        # CI用
```

#### auto-rollback.sh - 自動ロールバック
```bash
cd ~/CC-Team/CCTeam
./scripts/auto-rollback.sh monitor  # 監視開始
./scripts/auto-rollback.sh canary   # カナリーデプロイ
```

### 🤖 AI設定

#### setup-models-simple.sh - AIモデル設定
```bash
cd ~/CC-Team/CCTeam
./scripts/setup-models-simple.sh
```
- Claude → Opus 4
- Gemini → 2.5 Pro

### 🔧 その他ツール

#### safe-delete.sh - 安全な削除
```bash
cd ~/CC-Team/CCTeam
./scripts/safe-delete.sh delete file.txt   # ゴミ箱へ
./scripts/safe-delete.sh restore file.txt  # 復元
./scripts/safe-delete.sh list              # 一覧
```

#### ai-cicd.sh - CI/CD連携
```bash
cd ~/CC-Team/CCTeam
./scripts/ai-cicd.sh test              # テスト実行
./scripts/ai-cicd.sh check 123         # PR確認
./scripts/ai-cicd.sh research "調査"    # Gemini調査
```

---

## 🚨 トラブルシューティング

### ccteamコマンドが見つからない
```bash
# 再インストール
cd ~/CC-Team/CCTeam
./install.sh
source ~/.bashrc
```

### tmuxセッションエラー
```bash
# 既存セッション確認
tmux ls

# セッション削除
tmux kill-session -t ccteam

# 再起動
ccteam
```

### 権限エラー
```bash
cd ~/CC-Team/CCTeam
chmod +x scripts/*.sh
```

---

## 💡 Tips

### tmux操作
- `Ctrl+b` + 矢印: ペイン移動
- `Ctrl+b` + `d`: デタッチ
- `Ctrl+b` + `[`: スクロール（qで終了）

### 効率的な使い方
1. `ccteam`で起動
2. `cca`で接続
3. `ccs`で状況確認
4. `ccv bump`でバージョン管理

---

## 📝 メモ

- グローバルコマンドは`/usr/local/bin`にインストールされます
- エイリアスは`~/.ccteam-commands`に保存されます
- ログは`~/CC-Team/CCTeam/logs/`に出力されます