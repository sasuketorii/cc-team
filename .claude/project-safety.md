# Claude Code プロジェクト安全対策

## Git操作の安全ルール

### 🚫 絶対にやらないこと
- ホームディレクトリで `git add -A` を実行しない
- プロジェクトルート以外で `git add .` を実行しない
- 親ディレクトリに `.git` がないか確認せずに操作しない

### ✅ 必ず行うこと
1. **作業前の確認**
   ```bash
   # 現在のリポジトリルートを確認
   git rev-parse --show-toplevel
   
   # 現在のディレクトリと一致するか確認
   pwd
   ```

2. **安全なgit add**
   ```bash
   # プロジェクトルートに移動してから実行
   cd $(git rev-parse --show-toplevel)
   git add .
   ```

3. **特定ファイルのみ追加**
   ```bash
   # ワイルドカードを使わず、明示的にファイルを指定
   git add README.md
   git add .github/workflows/*.yml
   ```

## DevContainer使用時の利点

DevContainerを使用すると以下の問題が自動的に回避されます：

1. **隔離された環境** - ホストのファイルシステムに影響しない
2. **プロジェクト専用の.git** - 他のリポジトリと混在しない
3. **権限の明確化** - コンテナ内でのみ操作可能

## 推奨設定

### Claude Code実行時の確認事項
```bash
# プロジェクトディレクトリで実行していることを確認
if [[ $(pwd) != *"/CC-Team/CCTeam"* ]]; then
    echo "警告: CCTeamプロジェクトディレクトリ外で実行しています"
    exit 1
fi
```

### git設定の推奨
```bash
# グローバル設定で安全性を高める
git config --global core.safecrlf true
git config --global push.default current
```