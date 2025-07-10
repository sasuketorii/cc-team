# 🛡️ DevContainer + Git Worktree による超安全開発ガイド

## なぜこの組み合わせが最強なのか？

### 1. 🔒 完全な環境分離
```
ホストマシン
├── 本番環境（クリーン）
└── DevContainer
    ├── 開発環境（隔離）
    └── Git Worktree
        ├── feature/ui（Worker1）
        ├── feature/api（Worker2）
        └── feature/test（Worker3）
```

### 2. 🎯 具体的なメリット

#### DevContainerのメリット
- **環境汚染ゼロ**: ホストマシンに一切影響しない
- **再現性100%**: チーム全員が同じ環境
- **即座にリセット**: コンテナ削除で完全クリーン
- **依存関係の競合なし**: プロジェクトごとに独立

#### Git Worktreeのメリット
- **並列開発**: 複数機能を同時開発
- **ブランチ切り替え不要**: 各Workerが専用ディレクトリ
- **変更の分離**: 実験的変更も安全
- **高速切り替え**: stash/checkout不要

## 🚀 実践的な使い方

### 1. DevContainer内でWorktree設定
```bash
# DevContainer起動後
cd /workspaces/CCTeam

# Worktree環境構築
./scripts/worktree-parallel-manual.sh setup
./scripts/worktree-parallel-manual.sh auto-assign

# 結果
/workspaces/CCTeam/
├── worktrees/
│   ├── feature/frontend/  # Worker1専用
│   ├── feature/backend/   # Worker2専用
│   └── feature/testing/   # Worker3専用
└── main（メインコード）
```

### 2. CCTeamでの並列開発
```bash
# CCTeam起動
ccteam

# 各Workerが自動的に専用Worktreeで作業
# Boss: メインディレクトリで統括
# Worker1: worktrees/feature/frontend/で作業
# Worker2: worktrees/feature/backend/で作業
# Worker3: worktrees/feature/testing/で作業
```

### 3. 安全な実験
```bash
# 破壊的な変更も安全
cd worktrees/feature/experimental
rm -rf *  # メインコードには影響なし！

# 失敗したら
git worktree remove feature/experimental --force
# 完全に消去、メインは無傷
```

## 🛡️ セキュリティ面での利点

### 1. 認証情報の保護
```yaml
# .devcontainer/devcontainer.json
"mounts": [
  # 読み取り専用でマウント
  "source=${localEnv:HOME}/.claude,target=/home/vscode/.claude,type=bind,readonly"
]
```
- Claude認証はホストで管理
- コンテナからは読み取りのみ
- 誤って認証情報を変更する心配なし

### 2. ネットワーク分離
```yaml
# 必要に応じてネットワーク制限
"runArgs": ["--network", "none"]  # 完全オフライン開発
```

### 3. ファイルシステム保護
- ホストの重要ファイルにアクセス不可
- プロジェクトディレクトリのみマウント
- 誤操作によるシステム破壊を防止

## 📊 開発フロー例

### 新機能開発
```bash
# 1. DevContainerで開始
code .  # VSCodeで開く
# "Reopen in Container"

# 2. 新しいWorktree作成
./scripts/worktree-parallel-manual.sh create feature/new-payment worker1

# 3. CCTeamに指示
ccteam
# Boss: "Worker1は決済機能を実装してください"

# 4. 安全にテスト
cd worktrees/feature/new-payment
npm test  # 他の機能に影響なし

# 5. 問題があれば即座にリセット
git worktree remove feature/new-payment --force
```

### ホットフィックス
```bash
# 本番バグ発生！
# 1. 緊急Worktree作成
./scripts/worktree-parallel-manual.sh create hotfix/critical main

# 2. 修正実施
cd worktrees/hotfix/critical
# 修正...

# 3. 他の開発を止めずに修正完了
git push origin hotfix/critical
```

## 🎯 ベストプラクティス

### 1. DevContainer設定
```json
{
  "name": "CCTeam-${env:USER}",  // ユーザーごとに分離
  "features": {
    "ghcr.io/devcontainers/features/git:1": {
      "version": "latest",
      "ppa": true
    }
  },
  "postCreateCommand": "git config --global --add safe.directory ${containerWorkspaceFolder}"
}
```

### 2. Worktree命名規則
```
feature/[worker番号]-[機能名]
fix/[issue番号]-[修正内容]
experiment/[日付]-[実験名]
```

### 3. 定期的なクリーンアップ
```bash
# 週次でWorktreeを整理
git worktree list
git worktree prune
```

## 💡 トラブルシューティング

### Q: DevContainer内でWorktreeが作成できない
```bash
# 解決策
git config --global --add safe.directory /workspaces/CCTeam
```

### Q: パフォーマンスが遅い
```json
// .devcontainer/devcontainer.json
"mounts": [
  "source=${localWorkspaceFolder},target=/workspaces/CCTeam,type=bind,consistency=cached"
]
```

### Q: 認証が効かない
```bash
# ホストで再認証
claude login
# DevContainerを再起動
```

## 🚀 まとめ

**DevContainer + Git Worktreeは最強の組み合わせ**：
- ✅ 環境の完全分離
- ✅ 並列開発の効率化
- ✅ 実験的変更の安全性
- ✅ チーム開発の標準化
- ✅ 本番環境の保護

この環境でCCTeamを使えば、**安全かつ高速に開発**できること間違いなしです！

---

Created by SasukeTorii / REV-C Inc.