# 🚀 CCTeam クイックスタートガイド

## 🎯 5分で始めるCCTeam

### 🔧 セットアップ（1コマンドだけ！）

```bash
# リポジトリをクローン
git clone https://github.com/your-org/CCTeam.git
cd CCTeam

# マジックコマンドを実行🪄
./quick-start.sh
```

これだけです！スクリプトが以下を自動で行います：
- ✅ 依存関係のチェック
- ✅ コマンドのインストール
- ✅ エイリアスの設定
- ✅ tmux環境の準備

---

## 🎆 さあ、使ってみよう！

### 1️⃣ CCTeamを起動

```bash
ccteam  # または cct
```

初回起動時は、Claudeの認証画面が表示されます。
「Bypass Permissions」をクリックして認証してください。

### 2️⃣ ステータスを確認

```bash
ccteam-status  # または ccs
```

### 3️⃣ AIエージェントに指示を出す

```bash
# Bossに指示を送る
ccteam-send boss "要件定義書を読んで開発を開始してください"

# またはショートカットで
ccsend boss "開発を開始してください"
```

---

## 👨‍💻 CCTeamのアーキテクチャ

```
Boss (CEO) 🎯
  ├─ Worker1 (フロントエンド) 🎨
  ├─ Worker2 (バックエンド) ⚙️
  └─ Worker3 (テスト/品質) ✅
```

### 役割分担
- **Boss**: 全体管理、タスク割り当て、進捗管理
- **Worker1**: UI/UX、React、フロントエンド開発
- **Worker2**: API、データベース、バックエンド開発
- **Worker3**: テスト作成、品質保証、ドキュメント

---

## 💡 便利なコマンド一覧

| コマンド | ショートカット | 説明 |
|---------|--------------|------|
| `ccteam` | `cct` | CCTeamを起動 |
| `ccteam-status` | `ccs` | ステータス確認 |
| `ccteam-send` | `ccsend` | エージェントに指示 |
| `ccteam-attach` | `cca` | tmuxセッションに接続 |
| `ccteam-monitor` | `ccmon` | リアルタイム監視 |
| `ccteam-prompts` | `ccprompt` | プロンプト例 |
| `ccteam-kill` | `cckill` | セッション終了 |

---

## 🌟 よく使うプロンプト例

### 開発開始
```bash
ccsend boss "requirements/フォルダの要件定義書を読んで、開発を開始してください"
```

### 進捗確認
```bash
ccsend boss "各Workerの進捗を確認して、ステータスを報告してください"
```

### テスト実行
```bash
ccsend boss "Worker3に全体のテストを実行させてください"
```

---

## 🆘 トラブルシューティング

### Q: 「tmuxがインストールされていません」と表示される

**Macの場合:**
```bash
brew install tmux
```

**Ubuntu/Debianの場合:**
```bash
sudo apt-get install tmux
```

### Q: 「Claude CLIがインストールされていません」と表示される

[Claude公式サイト](https://claude.ai/download)からダウンロードしてインストールしてください。

### Q: コマンドが見つからない

新しいターミナルを開くか、以下を実行：
```bash
source ~/.ccteam-commands
```

### Q: tmuxセッションに接続したい

```bash
cca  # または ccteam-attach
```

### Q: セッションを終了したい

```bash
cckill  # または ccteam-kill
```

---

## 📚 もっと詳しく知りたい方へ

- **コマンド一覧**: `cat COMMANDS.md`
- **詳細ドキュメント**: `cat README.md`
- **技術仕様**: `cat CLAUDE.md`
- **スクリプト説明**: `cat scripts/README.md`

---

## 🎉 おめでとうございます！

CCTeamのセットアップが完了しました。
AIエージェントたちが、あなたの開発を100倍加速させます🚀

問題がある場合は、GitHub Issuesでお知らせください。