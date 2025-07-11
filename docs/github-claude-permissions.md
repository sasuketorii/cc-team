# GitHub @claude 権限について

---

## 📌 クイックリファレンス

### 問題に直面したら
```
I don't have Bash execution permissions...
```
→ **解決策**: `/roll-call`コマンドを使用

### CCTeamをGitHubから操作したい
1. シミュレーション: `/roll-call`
2. 完全な制御: ローカルで`ccteam`実行

### ファイルを編集したい
→ `@claude`でOK！（これは制限なし）

---

## 問題
GitHub Issueから`@claude`メンションで実行される際、Claude Code Actionは**Bashスクリプトを実行できません**。

## 理由
- **セキュリティ制限**: GitHub Actions環境でのシェル実行は制限されています
- **Claude Code Action仕様**: ファイル操作は可能だが、任意のコマンド実行は不可

## 解決策

### 1. 専用ワークフローの使用
```bash
# Issueでコメント
/roll-call
```
これにより`ccteam-roll-call.yml`ワークフローが実行されます。

### 2. ローカル実行
```bash
# ローカルでCCTeamを起動
ccteam

# roll callを実行
./scripts/enhanced_agent_send.sh boss "Hello, World!! I'm BOSS"
./scripts/enhanced_agent_send.sh worker1 "Hello, World!! I'm Worker1"
./scripts/enhanced_agent_send.sh worker2 "Hello, World!! I'm Worker2"
./scripts/enhanced_agent_send.sh worker3 "Hello, World!! I'm Worker3"
```

### 3. Dev Container使用
DevContainer内では完全な権限で実行可能：
```bash
# VSCodeで開く
code /path/to/CCTeam

# "Reopen in Container"を選択
# コンテナ内でroll callを実行
```

## 利用可能なコマンド（GitHub Issue）

| コマンド | 説明 | 実行可能 |
|---------|------|----------|
| `/install-github-app` | GitHub App インストール | ✅ |
| `/roll-call` | CCTeam roll call | ✅ |
| `@claude` | コード変更・ファイル操作 | ✅ |
| `@claude boss` | Boss機能（ファイル操作のみ） | ⚠️ |
| `@claude [bashコマンド]` | Bash実行 | ❌ |

## 推奨事項

1. **ファイル操作のみ必要な場合**: `@claude`を使用
2. **スクリプト実行が必要な場合**: 専用ワークフローを作成
3. **完全な制御が必要な場合**: ローカルまたはDevContainerで実行

## 技術的詳細

Claude Code Actionは以下の権限を持ちます：
- ✅ ファイルの読み書き
- ✅ Git操作（コミット、プッシュ）
- ✅ Issue/PRへのコメント
- ❌ 任意のシェルコマンド実行
- ❌ システムコマンド実行

これはGitHub上でのセキュリティを保つための意図的な制限です。