# 🔔 CCTeam Claude Code Hooks 通知実装ガイド

## 概要
Claude Code hooksを使用してCCTeamの通知システムを実装します。

## 実装例

### 1. hooks設定ファイル（~/.claude/settings.json）
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "CCTeam",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.ccteam/notification-handler.sh"
          }
        ]
      }
    ],
    "BeforeCommand": [
      {
        "matcher": "ccteam|worktree",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'CCTeam command detected' >> ~/.ccteam/activity.log"
          }
        ]
      }
    ]
  }
}
```

### 2. 通知ハンドラー（~/.ccteam/notification-handler.sh）
```bash
#!/bin/bash
# CCTeam通知ハンドラー

# 環境変数から情報取得
SESSION_ID=$CLAUDE_CODE_SESSION_ID
MESSAGE=$CLAUDE_CODE_MESSAGE
TITLE=$CLAUDE_CODE_TITLE

# 通知タイプ判定
if [[ "$MESSAGE" =~ "完了" ]]; then
    TYPE="success"
elif [[ "$MESSAGE" =~ "エラー" ]]; then
    TYPE="error"
elif [[ "$MESSAGE" =~ "承認" ]]; then
    TYPE="approval"
else
    TYPE="info"
fi

# OS別通知
case "$OSTYPE" in
    darwin*)
        # macOS
        osascript -e "display notification \"$MESSAGE\" with title \"CCTeam: $TITLE\" sound name \"Glass\""
        ;;
    linux*)
        # Linux/WSL
        notify-send "CCTeam: $TITLE" "$MESSAGE" -i terminal -u critical
        ;;
esac

# ログ記録
echo "[$(date '+%Y-%m-%d %H:%M:%S')] $TYPE: $TITLE - $MESSAGE" >> ~/.ccteam/notifications.log

# Slack/Discord連携（オプション）
if [ -n "$CCTEAM_WEBHOOK_URL" ]; then
    curl -X POST $CCTEAM_WEBHOOK_URL \
        -H 'Content-Type: application/json' \
        -d "{\"text\":\"CCTeam: $TITLE\n$MESSAGE\"}"
fi
```

### 3. CCTeamからの通知送信
```bash
# Boss v2から通知を送信
send_claude_notification() {
    local title=$1
    local message=$2
    
    # Claude Code APIを通じて通知
    echo "🔔 CCTeam: $title - $message"
    
    # hooksがトリガーされる
}
```

## 利用シーン

### タスク完了通知
```bash
send_claude_notification "タスク完了" "Worker1がログイン画面の実装を完了しました"
```

### エラー通知
```bash
send_claude_notification "ビルドエラー" "Worker2でTypeScriptコンパイルエラーが発生"
```

### 承認要求
```bash
send_claude_notification "承認待ち" "mainブランチへのマージ準備が完了。承認してください"
```

## セットアップ手順

1. **ディレクトリ作成**
```bash
mkdir -p ~/.ccteam
```

2. **通知ハンドラー配置**
```bash
cp notification-handler.sh ~/.ccteam/
chmod +x ~/.ccteam/notification-handler.sh
```

3. **Claude Code設定更新**
```bash
# ~/.claude/settings.jsonを編集
```

4. **環境変数設定（オプション）**
```bash
export CCTEAM_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

## 高度な使い方

### 条件付き通知
```json
{
  "matcher": "error|failed|失敗",
  "hooks": [
    {
      "type": "command",
      "command": "~/.ccteam/urgent-notification.sh"
    }
  ]
}
```

### 通知の集約
```bash
# 5分間の通知を集約して送信
~/.ccteam/notification-aggregator.sh
```

## トラブルシューティング

### 通知が届かない
1. hooks設定を確認
2. 通知ハンドラーの実行権限確認
3. ログファイルでエラー確認

### 通知が多すぎる
1. matcherを調整して絞り込み
2. 通知レベルの設定追加
3. 集約機能の実装

---

**Created by SasukeTorii / REV-C Inc.**