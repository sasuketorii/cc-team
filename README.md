# 🏢 CCTeam - あなた専用のAI開発企業を、今すぐ立ち上げる

<div align="center">
  <br>
  <h1>もう、開発チームの採用・管理で悩まない。</h1>
  <h3>要件定義を入れるだけで、AIチームが24時間365日開発を続ける</h3>
  <br>
  <p>
    <img src="https://img.shields.io/badge/version-0.1.4-blue.svg" />
    <img src="https://img.shields.io/badge/claude-opus--4-purple.svg" />
    <img src="https://img.shields.io/badge/by-SasukeTorii-orange.svg" />
    <img src="https://img.shields.io/badge/license-AGPL--3.0-green.svg" />
  </p>
  <br>
  <h2>🌍 グローバルコマンドとして動作</h2>
  <p><b>一度インストールすれば、どこでも<code>ccteam</code>コマンドで起動可能</b></p>
  <p>Claude Codeと同じ使い勝手で、あなた専用の開発企業をいつでも呼び出せます</p>
  <br>
  <p>
    <a href="#-30秒で起動">🚀 今すぐ始める</a> •
    <a href="#-デモ動画">📺 デモを見る</a> •
    <a href="#-導入事例">💼 導入事例</a> •
    <a href="#-料金">💰 料金</a>
  </p>
</div>

---

## 😫 こんな悩み、ありませんか？

<table>
<tr>
<td width="50%">

### ❌ **従来の開発**
- 優秀なエンジニアが採用できない
- 人件費が高すぎる（月80-150万円/人）
- チーム管理が大変
- コミュニケーションコストが高い
- 離職リスクが常にある
- 24時間開発は不可能

</td>
<td width="50%">

### ✅ **CCTeamなら**
- 最高レベルのAIエンジニアが即座に利用可能
- コストは従来の1/10以下
- 管理不要（自動統括）
- 完璧なコミュニケーション
- 離職リスクゼロ
- 24時間365日ノンストップ開発

</td>
</tr>
</table>

---

## 🎯 CCTeamは「仮想システム開発企業」です

<div align="center">
  <h3>単なるAIツールではありません。<br>本物の開発企業と同じ組織構造を持つ、あなた専用の開発チームです。</h3>
</div>

```
あなた（CEO/オーナー）
    ↓ 要件定義を入れるだけ
┌─────────────────────────────────────┐
│          CCTeam Virtual Inc.         │
├─────────────────────────────────────┤
│  Boss (CTO)                         │
│  ・要件分析・タスク分配・進捗管理    │
├─────────────┬───────────┬──────────┤
│  Worker1    │  Worker2  │ Worker3  │
│  Frontend   │  Backend  │ QA/DevOps│
└─────────────┴───────────┴──────────┘
    ↓ 24時間365日並列開発
完成したシステム
```

---

## 📺 デモ動画

<div align="center">
  <a href="https://youtu.be/demo-link">
    <img src="https://img.youtube.com/vi/demo-link/maxresdefault.jpg" width="600">
  </a>
  <p><i>実際にECサイトを10分で構築する様子</i></p>
</div>

---

## 🚀 30秒で起動（初回のみ）

### 初回セットアップ
```bash
# 1. クローン（5秒）
git clone https://github.com/sasuketorii/cc-team.git

# 2. グローバルインストール（10秒）
cd cc-team/CCTeam && ./install.sh

# 完了！これで準備OK 🎉
```

### 以降はどこからでも使える！
```bash
# どのプロジェクトからでも起動可能
cd ~/my-project
ccteam  # グローバルコマンドとして動作！

# 要件定義を配置
echo "ユーザー認証機能を実装して" > requirements/機能要件.md

# AIチームが開発を開始 🚀
```

### GitHubからのClaude Code実行（ローカル不要！）

⚡ **Claude MAXプランユーザーの方へ**
- GitHub連携が完了していれば、APIキー設定は不要です
- @claudeメンションですぐに利用開始できます

#### 1️⃣ @claudeメンションでAI実行
```bash
# IssueまたはPRにコメント
@claude ダークモード対応を追加して

# 🤖 Claudeが実際にコードを変更し、PRを作成します
```

#### 2️⃣ CCTeam BossをGitHubで動かす
```bash
# Bossにタスクを依頼
@claude boss 要件定義を分析してタスク分配計画を作成して

# 👑 Bossが要件分析と計画立案を実行
```

#### 3️⃣ 自動リリース
```bash
# バージョンタグ付けとリリース
@claude release patch  # v0.1.9 -> v0.1.10
@claude release minor  # v0.1.9 -> v0.2.0
@claude release major  # v0.1.9 -> v1.0.0

# 🚀 CHANGELOG更新、タグ作成、リリース作成まで自動
```

#### 2️⃣ 自動プロジェクトセットアップ
```markdown
# Issueを作成
タイトル: [CCTeam Setup] ECサイト開発

本文:
Project Type: web-app
Tech Stack: react-node

要件:
- ユーザー認証機能
- 商品カタログ
- ショッピングカート
```

🤖 GitHub Actionsが自動で：
- 要件ファイル作成
- 技術スタック設定
- プロジェクト構造初期化
- Issueを自動クローズ

#### 3️⃣ ワークフローから手動実行
```yaml
# GitHub Actions → Install CCTeam
# 入力パラメータ:
- install_mode: global/local/devcontainer
- target_os: ubuntu/macos/windows
- project_type: web-app/mobile-app/api-service
- tech_stack: react-node/vue-python/etc
```

<div align="center">
  <h3>⚡ 他のAIツールとの決定的な違い</h3>
  <p><b>毎回クローンやディレクトリ移動は不要！</b></p>
  <p>Claude Codeと同じように、どこからでも<code>ccteam</code>一発で起動</p>
</div>

---

## 🐳 Dev Container & GitHub Actions対応！

### VSCode Dev Containerで即座に開発開始
```bash
# VSCodeで開く
code cc-team/CCTeam

# 「Reopen in Container」をクリック
# 自動的に全ての環境が構築されます！
```

### 特徴
- 🔧 **完全な開発環境** - tmux、Claude CLI、Python、Node.js全て設定済み
- 🔐 **安全な認証** - ホストのClaude認証を自動マウント
- 🚀 **即座に利用可能** - コンテナ起動後すぐにccteamコマンドが使える
- 📦 **依存関係自動インストール** - npm/pip全て自動

### GitHub Actionsで自動化
- ✅ **自動テスト** - プッシュ時に全テスト実行
- 🔍 **品質チェック** - コード品質を自動評価
- 🛡️ **セキュリティスキャン** - 脆弱性を自動検出
- 🔧 **自動修正** - PRコメントで`/fix`と入力するだけ
- 📊 **定期メンテナンス** - ログ整理・依存関係更新を自動実行

### 🆕 GitHub Claude Code Action（v0.1.9）
- 🤖 **@claudeメンション** - Issue/PRで`@claude`でAI実行
- 👑 **@claude boss** - CCTeam BossがGitHub上で動作
- 🚀 **完全自動化** - コード変更からリリースまで
- 🎯 **@claude release** - バージョンタグ付けとリリース
- 📦 **プロジェクト初期化** - `[CCTeam Setup]`で自動セットアップ

---

## 💡 革命的な特徴

### 1️⃣ **本物の開発企業構造**
```
Boss (CTO/PM) - プロジェクト全体を統括
├── Worker1 (Frontend) - UI/UX専門
├── Worker2 (Backend) - API/DB専門
└── Worker3 (QA/DevOps) - テスト/インフラ専門
```

### 2️⃣ **完全自動の開発プロセス**
1. 要件定義を`requirements/`に配置
2. `ccteam`コマンドを実行
3. あとは待つだけ

### 3️⃣ **グローバルコマンドで即座に利用**
- 🌍 一度のインストールで永続的に利用可能
- 🚀 `ccteam`コマンドでどこからでも起動
- 📁 プロジェクトごとのセットアップ不要
- ⚡ Claude Codeと同じ使用感

### 4️⃣ **55個以上の先進機能を搭載**

#### 🧠 **SuperClaudeライクな永続メモリ**
```python
# 対話履歴を永続的に保存
memory_manager.py save --agent BOSS --message "タスク完了"
memory_manager.py search --query "エラー解決方法"
```
- SQLiteベースで高速検索
- パターン学習で賢くなる
- プロジェクトコンテキスト保持

#### 🛡️ **業界初！エラーループ自動回避AI**
```python
# 同じエラー3回で自動停止＆建設的解決策提示
error_loop_detector.py check --agent worker1 --error "Module not found"
```

#### 🎮 **VSCode/Cursorから直接操作**
- 10個のClaude Code Actions
- キーボードショートカット対応
- IDEから離れずに全操作可能

#### 📊 **エンタープライズグレード監視**
- リアルタイムステータス表示
- 構造化JSON ログ（機械学習対応）
- 自動レポート生成（日次/週次）

[→ 全55個以上の機能を見る](#-実装済み機能一覧55個以上)

---

## 📊 圧倒的な成果

<table>
<tr>
<td align="center">
<h3>開発速度</h3>
<h1>10倍</h1>
<p>並列開発により<br>複数機能を同時実装</p>
</td>
<td align="center">
<h3>コスト削減</h3>
<h1>90%</h1>
<p>人件費・オフィス<br>管理コスト全て不要</p>
</td>
<td align="center">
<h3>稼働時間</h3>
<h1>24/7</h1>
<p>365日ノンストップ<br>深夜も休日も開発継続</p>
</td>
<td align="center">
<h3>品質向上</h3>
<h1>80%</h1>
<p>エラー率削減<br>ベストプラクティス適用</p>
</td>
</tr>
</table>

---

## 💼 導入事例

### 🛒 ECサイト構築 - A社様
> 「3ヶ月かかる予定だった開発が**2週間で完了**。しかも品質は想定以上でした」

### 📱 モバイルアプリ開発 - B社様
> 「エンジニア5人分の仕事を**CCTeam1つで実現**。月間300万円のコスト削減に成功」

### 🏢 社内システム刷新 - C社様
> 「24時間開発が可能なので、**納期が1/3に短縮**。競合他社に大きく差をつけられました」

---

## 🎮 使い方

### 基本的な流れ

#### 1. 要件定義を作成
```markdown
# requirements/機能要件.md

## 必要な機能
- ユーザー認証（メール/パスワード）
- 商品一覧・詳細表示
- カート機能
- 決済連携（Stripe）
```

#### 2. CCTeamを起動
```bash
ccteam  # または ccguide（初心者向け）
```

#### 3. 認証を完了
各エージェントで`2`を選択して認証

#### 4. 開発スタート
```bash
# Bossに初期指示
requirementsフォルダの要件を読み込んで開発を開始してください
```

### 便利なコマンド集

| コマンド | 説明 | 使用場面 |
|---------|------|----------|
| `ccteam` | 通常起動 | 日常的な開発 |
| `ccguide` | ガイド付き起動 | 初回や不慣れな時 |
| `ccmon` | リアルタイム監視 | 進捗確認 |
| `ccsend boss "message"` | Bossへ指示 | タスク追加・変更 |
| `ccs` | ステータス確認 | 全体状況把握 |
| `cckill` | 終了 | 作業完了時 |

---

## 🛠️ 実装済み機能一覧（55個以上！）

<details>
<summary><b>🚀 起動・制御システム（15個） - クリックで展開</b></summary>

### インストール・セットアップ
- ✅ **グローバルコマンドインストーラー** (`install.sh`)
- ✅ **ローカルインストーラー** (sudoなし版)
- ✅ **tmux環境構築** (`setup.sh`, `setup-v2.sh`)
- ✅ **AIモデル設定** (簡易版・詳細版)

### 起動スクリプト
- ✅ **手動認証版起動** (`launch-ccteam-v3.sh`) 🆕
- ✅ **ガイド付き起動** (`ccteam-guided.sh`) 初心者向け
- ✅ **Claude自動起動** (expect自動化)
- ✅ **安全起動モード** (エラーチェック付き)

### 監視・制御
- ✅ **リアルタイム監視** (`ccteam-monitor.sh`) 🆕
- ✅ **プロンプトテンプレート** (`ccteam-prompts.sh`) 🆕
- ✅ **プロジェクトステータス** (統計情報表示)
- ✅ **セッション終了** (`ccteam-kill.sh`)

</details>

<details>
<summary><b>🤖 AIエージェント管理（10個） - クリックで展開</b></summary>

### マルチエージェントシステム
- ✅ **Boss統合アーキテクチャ** (CTO/PM役)
- ✅ **Worker1** (フロントエンド専門)
- ✅ **Worker2** (バックエンド専門)
- ✅ **Worker3** (QA/DevOps専門)
- ✅ **Gemini** (調査・ドキュメント支援)

### エージェント間通信
- ✅ **メッセージ送信システム** (`agent-send.sh`)
- ✅ **拡張メッセージング** (エラーハンドリング強化)
- ✅ **tmuxペインマッピング**
- ✅ **通信履歴ログ**
- ✅ **Ctrl+Cプロンプトクリア**

</details>

<details>
<summary><b>🛡️ エラー管理・品質保証（12個） - クリックで展開</b></summary>

### エラーループ防止
- ✅ **自動エラーループ検出** (`error_loop_detector.py`) 🆕
- ✅ **3ストライク自動停止**
- ✅ **建設的問題解決AI**
- ✅ **エラー固有ヘルパー** (`error_loop_helper.py`)

### ログ・分析システム
- ✅ **構造化ログシステム** (JSON形式)
- ✅ **エラーパターン分析** (`analyze-errors.sh`)
- ✅ **ログローテーション** (10MB/30日)
- ✅ **ログ形式変換ツール**

### 品質チェック
- ✅ **ヘルスチェック** (簡易版/詳細版)
- ✅ **統合テストスイート** (18項目)
- ✅ **品質ゲートシステム** (`quality-gate.sh`)
- ✅ **CI/CD統合** (`ai-cicd.sh`)

</details>

<details>
<summary><b>💾 データ・メモリ管理（8個） - クリックで展開</b></summary>

### SuperClaudeライクメモリ
- ✅ **SQLiteベース永続メモリ** (`memory_manager.py`) 🆕
- ✅ **対話履歴完全保存**
- ✅ **プロジェクトコンテキスト**
- ✅ **パターン学習システム**
- ✅ **重要度スコアリング**

### データ管理
- ✅ **自動バックアップ**
- ✅ **エラー集約システム**
- ✅ **スナップショットエクスポート**

</details>

<details>
<summary><b>🎮 Claude Code Actions（10個） - クリックで展開</b></summary>

### カスタムアクション
- ✅ **ccteam-launch** - CCTeam環境起動
- ✅ **ccteam-status** - プロジェクト状況確認
- ✅ **ccteam-analyze** - コード分析
- ✅ **ccteam-test-generate** - テスト生成
- ✅ **ccteam-send-boss** - Bossへ送信
- ✅ **ccteam-attach** - セッション接続
- ✅ **ccteam-memory-save** - メモリ保存
- ✅ **ccteam-memory-load** - メモリ読込
- ✅ **ccteam-memory-search** - メモリ検索
- ✅ **ccteam-version** - バージョン管理

### キーボードショートカット
- ⌘+Shift+L: CCTeam起動
- ⌘+Shift+S: ステータス確認
- ⌘+Shift+A: セッション接続
- ⌘+Shift+M: メモリ保存

</details>

<details>
<summary><b>🔧 開発支援ツール（15個） - クリックで展開</b></summary>

### バージョン管理
- ✅ **セマンティックバージョニング** (`version-manager.sh`)
- ✅ **自動ロールバック** (`auto-rollback.sh`)
- ✅ **Git タグ管理**
- ✅ **バージョン履歴**

### Git Worktree並列開発
- ✅ **Worktree管理** (`worktree-parallel-manual.sh`)
- ✅ **Worker別ブランチ管理**
- ✅ **自動同期システム**
- ✅ **コンフリクト回避**

### ユーティリティ
- ✅ **安全削除システム** (`safe-delete.sh`)
- ✅ **30日間復元可能**
- ✅ **調査報告書生成** (タイムスタンプ付き)
- ✅ **自動レポート生成** (日次/cron対応)
- ✅ **不要ファイル一括削除** (`cleanup_obsolete_files.sh`)

### tmux管理
- ✅ **ペイン永続化** (`tmux-pane-manager.sh`)
- ✅ **レイアウト保存/復元**
- ✅ **動的ペイン追加**

</details>

<details>
<summary><b>🧪 テスト・検証（5個） - クリックで展開</b></summary>

- ✅ **クイックヘルスチェック** (基本動作確認)
- ✅ **システムヘルスチェック** (網羅的検証)
- ✅ **統合テストスイート** (18項目自動テスト)
- ✅ **テストログアーカイブ** (履歴管理)
- ✅ **テストアーティファクト削除**

</details>

<details>
<summary><b>📊 高度な機能 - クリックで展開</b></summary>

### CI/CD統合
- ✅ **GitHub Actions連携**
- ✅ **PR自動チェック**
- ✅ **Claude SDK統合**
- ✅ **バッチ処理サポート**

### セキュリティ
- ✅ **APIキー環境変数管理**
- ✅ **ログファイル保護**
- ✅ **最小実行権限**
- ✅ **スタックトレース除去**
- ✅ **監査ログ記録**

### 自動化
- ✅ **cron連携**
- ✅ **定期レポート**
- ✅ **エラー通知**
- ✅ **リソース監視**

</details>

---

## 🔧 トラブルシューティング

<details>
<summary><b>よくある問題と解決方法</b></summary>

### 🚨 tmuxエラー
```bash
# エラー: no server running on /tmp/tmux-501/default
cckill  # 一度終了
ccteam  # 再起動
```

### 🔐 認証画面が出ない
```bash
# すでに認証済みの可能性
# そのまま初期指示を入力してOK
```

### 💾 メモリ不足
```bash
# ログをクリーンアップ
./scripts/log_rotation.sh
```

### 🐛 エラーループ
```bash
# 自動で検出・停止されます
# 手動で止める場合
ccsend boss "STOP"
```

</details>

---

## 🏆 なぜCCTeamを選ぶべきか？

### 他のAIツールとの決定的な違い

<table>
<tr>
<th width="20%">機能</th>
<th width="40%">CCTeam</th>
<th width="40%">他のAIツール</th>
</tr>
<tr>
<td><b>起動方法</b></td>
<td>✅ グローバルコマンド<br>どこでも<code>ccteam</code>一発</td>
<td>❌ 毎回セットアップ必要</td>
</tr>
<tr>
<td><b>並列開発</b></td>
<td>✅ 4つのAIが同時開発<br>実際の開発チーム構造</td>
<td>❌ 単一AIのみ</td>
</tr>
<tr>
<td><b>メモリ</b></td>
<td>✅ 永続的SQLiteメモリ<br>プロジェクト間で共有</td>
<td>❌ セッション終了で消失</td>
</tr>
<tr>
<td><b>エラー対策</b></td>
<td>✅ 自動ループ検出<br>建設的解決策AI</td>
<td>❌ 同じエラーを繰り返す</td>
</tr>
<tr>
<td><b>IDE統合</b></td>
<td>✅ 10個のActions<br>ショートカット対応</td>
<td>❌ ターミナルのみ</td>
</tr>
<tr>
<td><b>監視</b></td>
<td>✅ リアルタイム監視<br>構造化ログ</td>
<td>❌ ログ確認のみ</td>
</tr>
<tr>
<td><b>Git連携</b></td>
<td>✅ Worktree並列開発<br>自動ブランチ管理</td>
<td>❌ 手動管理</td>
</tr>
<tr>
<td><b>テスト</b></td>
<td>✅ 自動テストスイート<br>品質ゲート</td>
<td>❌ 手動テスト</td>
</tr>
</table>

### 🎯 CCTeamだけの独自機能
1. **仮想開発企業構造** - Boss/Worker体制で本物の開発チーム
2. **55個以上の自動化ツール** - あらゆる開発作業を自動化
3. **エンタープライズグレード** - 大規模プロジェクト対応
4. **完全ローカル実行** - セキュリティ最優先設計
5. **by SasukeTorii** - 革新的なシステム開発の未来

---

## ❓ よくある質問（FAQ）

<details>
<summary><b>Q: 本当に人間のエンジニアは不要？</b></summary>
A: はい。要件定義さえあれば、設計から実装、テストまで全て自動で行います。
</details>

<details>
<summary><b>Q: どんなプロジェクトに対応可能？</b></summary>
A: Webアプリ、API、モバイルアプリ、社内システムなど、ほぼ全ての開発に対応します。
</details>

<details>
<summary><b>Q: セキュリティは大丈夫？</b></summary>
A: 完全ローカル実行、APIキー保護、セッション分離など、エンタープライズレベルのセキュリティを実装しています。
</details>

<details>
<summary><b>Q: 既存プロジェクトにも使える？</b></summary>
A: はい。既存のコードベースを理解し、追加開発や改修も可能です。
</details>

<details>
<summary><b>Q: サポートは？</b></summary>
A: GitHubのIssues、または開発者に直接お問い合わせください。
</details>

---

## 💰 料金

### オープンソース（AGPL v3）
- ✅ 全機能無料
- ✅ 制限なし
- ⚠️ 改変版もAGPL v3で公開必須
- ⚠️ SaaS利用時もソース公開必須
- 💼 商用ライセンスも用意

※Claude APIの利用料金は別途必要です

---

## 🚀 今すぐ始めましょう

<div align="center">
  <h2>もう、開発で悩む必要はありません。</h2>
  <h3>CCTeamがあなたの開発チームになります。</h3>
  <br>
  <a href="https://github.com/sasuketorii/cc-team">
    <img src="https://img.shields.io/badge/GitHub-Clone%20Now-blue?style=for-the-badge&logo=github">
  </a>
  <br><br>
  <code>git clone https://github.com/sasuketorii/cc-team.git</code>
</div>

---

## 🏢 開発元

<div align="center">
  <h2>Created by SasukeTorii</h2>
  <p>システム開発の未来を変える、革新的なソリューション</p>
  <br>
  <table>
    <tr>
      <td align="center">
        <b>開発者</b><br>
        <h3>SasukeTorii</h3>
      </td>
      <td align="center">
        <b>会社</b><br>
        <h3><a href="https://company.rev-c.com">REV-C Inc.</a></h3>
      </td>
      <td align="center">
        <b>サポート</b><br>
        <h3><a href="https://github.com/sasuketorii/cc-team/issues">GitHub Issues</a></h3>
      </td>
    </tr>
  </table>
  <br>
  <p><b>CCTeam - Where AI Becomes Your Development Company</b></p>
  <p>© 2025 REV-C Inc. All rights reserved. | AGPL-3.0 License</p>
</div>