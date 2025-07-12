# カスタムモデルの削除手順

## 問題
誤って作成されたカスタムモデル（"/model"コマンドで作成）を削除する必要があります。

## 削除手順

### 1. Claude Codeの設定ファイルを確認
```bash
# 設定ファイルの場所を確認
ls -la ~/.config/claude/
```

### 2. カスタムモデルのリストを確認
```bash
# Claude CLIでモデルリストを表示（可能な場合）
claude --list-models
```

### 3. 手動でカスタムモデルを削除

#### macOSの場合
```bash
# Claude Codeの設定ディレクトリ
cd ~/.config/claude/

# カスタムモデル設定を削除
rm -f custom_models.json
rm -f models.json
```

#### または、Claude Code内で
```
/models reset
```

## 今後の対策

### 正しいモデル指定方法
```bash
# Boss/PM用（Opus）
claude --model opus

# Worker用（Sonnet）
claude --model sonnet
```

### 誤った方法（使用禁止）
```
/model opus    # ❌ カスタムモデル作成
/model sonnet  # ❌ カスタムモデル作成
```

## CCTeam v0.1.16の新仕様
- 起動時にモデルを直接指定
- 初期プロンプトは送信しない
- Bypassモードがデフォルト