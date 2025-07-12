# CCTeam 手動Bypass認証ガイド

## 概要
Claude CLIには`--bypass`オプションが存在しないため、起動時に手動で認証モードを選択する必要があります。

## 手順

### 1. CCTeam起動
```bash
ccteam
```

### 2. 各セッションで認証選択

#### Boss認証
```bash
tmux attach -t ccteam-boss
# 認証画面で '1' を入力してEnter
# Ctrl+b → d でデタッチ
```

#### Team1認証
```bash
tmux attach -t ccteam-1
# 4つのペインそれぞれで '1' を入力してEnter
# Ctrl+b → 矢印キーでペイン移動
# Ctrl+b → d でデタッチ
```

#### Team2認証
```bash
tmux attach -t ccteam-2
# 4つのペインそれぞれで '1' を入力してEnter
# Ctrl+b → d でデタッチ
```

#### Team3認証
```bash
tmux attach -t ccteam-3
# 4つのペインそれぞれで '1' を入力してEnter
# Ctrl+b → d でデタッチ
```

## 認証画面の選択肢
```
Do you want to proceed?
1) Yes, enable all permissions (Bypass mode)
2) Yes, but let me review permissions
3) No
```

**必ず '1' を選択してください**

## 効率的な方法

### 一括認証スクリプト（検討中）
将来的には、expectスクリプトなどを使用して自動化を検討します。

## 注意事項
- 各ペインで個別に認証が必要です
- 認証後はモデルが正しく設定されています
  - Boss/PM: opus
  - Worker: sonnet