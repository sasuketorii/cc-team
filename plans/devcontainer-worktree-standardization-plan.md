# 🚀 CCTeam DevContainer + Worktree 標準化実装計画

## 📋 エグゼクティブサマリー

CCTeamの開発プロセスを**完全自動化**し、DevContainerとGit Worktreeを標準開発環境として確立する包括的な実装計画です。

### 主要目標
1. **開発環境の完全自動化**: DevContainer起動と同時にCCTeam環境を構築
2. **Git Worktree自動管理**: Bossが自動的にWorktreeを作成・管理・統合
3. **通知システム**: Claude Code hooksを使用した進捗通知
4. **組織構造の最適化**: 必要に応じてPM層の追加を検討

---

## 🏗️ 組織構造の再設計

### 現在の構造
```
ユーザー
  └── Boss（CTO/PM役）
       ├── Worker1（Frontend）
       ├── Worker2（Backend）
       └── Worker3（QA/DevOps）
```

### 提案1: Boss機能拡張（推奨）
```
ユーザー
  └── Boss v2（CTO/PM + Worktree Manager）
       ├── Worker1（Frontend）- worktrees/feature/frontend
       ├── Worker2（Backend） - worktrees/feature/backend
       └── Worker3（QA/DevOps）- worktrees/feature/testing
```

**メリット**:
- 既存の構造を維持
- 実装が簡単
- Bossの権限が明確

### 提案2: PM層追加（将来的な拡張）
```
ユーザー
  └── PM（Project Manager）
       └── Boss（Technical Lead）
            ├── Worker1
            ├── Worker2
            └── Worker3
```

**メリット**:
- 役割分離が明確
- スケーラビリティ向上
- より複雑なプロジェクトに対応

**推奨**: まず提案1で実装し、必要に応じて提案2に移行

---

## 📝 実装計画詳細

### Phase 1: Boss v2への機能追加（1週間）

#### 1.1 Boss指示書の更新

**instructions/boss-v2.md**（新規作成）
```markdown
# Boss v2.0 - Worktree自動管理対応版

## 新機能: Git Worktree自動管理

### 自動実行タスク（ユーザー承認後）
1. **プロジェクト開始時**:
   - `requirements/`フォルダの内容を分析
   - 必要なWorktreeを自動作成
   ```bash
   ./scripts/worktree-auto-manager.sh create-project-worktrees
   ```

2. **タスク割り当て時**:
   - 各Workerに適切なWorktreeを自動割り当て
   - Worker移動コマンドを自動送信
   ```bash
   ./scripts/enhanced_agent_send.sh worker1 "cd /workspace/CCTeam/worktrees/feature/frontend"
   ```

3. **統合時**:
   - 各Worktreeの変更を確認
   - マージ準備とコンフリクト検出
   - 統合レポート生成

### 通知機能
- 重要なイベント時にClaude Code hooksで通知
- 完了、エラー、承認待ちなど

## 制約事項（継承）
- ユーザーの明示的な承認なしに破壊的操作は実行しない
- 自動マージは行わない（提案のみ）
```

#### 1.2 Worktree自動管理スクリプト

**scripts/worktree-auto-manager.sh**
```bash
#!/bin/bash
# Worktree自動管理システム v1.0.0

set -euo pipefail

# カラー定義
source "$(dirname "$0")/colors.sh"

# ログ設定
LOG_FILE="logs/worktree-manager.log"

# Worktree設定
WORKTREE_CONFIG="worktrees/.auto-config.json"

# 関数: プロジェクト用Worktree作成
create_project_worktrees() {
    echo -e "${BLUE}🌳 プロジェクトWorktree自動作成開始${NC}"
    
    # requirements分析
    local requirements=$(analyze_requirements)
    
    # 必要なWorktree決定
    local worktrees=(
        "feature/frontend:worker1"
        "feature/backend:worker2"
        "feature/testing:worker3"
    )
    
    # 追加Worktree（要件に応じて）
    if echo "$requirements" | grep -q "mobile"; then
        worktrees+=("feature/mobile:worker1")
    fi
    
    if echo "$requirements" | grep -q "database"; then
        worktrees+=("feature/database:worker2")
    fi
    
    # Worktree作成
    for worktree in "${worktrees[@]}"; do
        IFS=':' read -r branch worker <<< "$worktree"
        create_worktree "$branch" "$worker"
    done
    
    # 設定保存
    save_worktree_config "${worktrees[@]}"
    
    echo -e "${GREEN}✅ Worktree作成完了${NC}"
    notify_boss "Worktree準備完了: ${#worktrees[@]}個のブランチを作成しました"
}

# 関数: requirements分析
analyze_requirements() {
    local req_dir="../requirements"
    local analysis=""
    
    if [ -d "$req_dir" ]; then
        for file in "$req_dir"/*.md; do
            if [ -f "$file" ]; then
                analysis+=$(cat "$file")
            fi
        done
    fi
    
    echo "$analysis"
}

# 関数: Worktree作成
create_worktree() {
    local branch=$1
    local worker=$2
    local worktree_path="worktrees/$branch"
    
    # 既存チェック
    if [ -d "$worktree_path" ]; then
        echo "既存: $branch"
        return
    fi
    
    # 作成
    echo "作成中: $branch (担当: $worker)"
    git worktree add -b "$branch" "$worktree_path" main || \
    git worktree add "$worktree_path" "$branch"
    
    # Worker割り当て
    assign_worker_to_worktree "$worker" "$branch" "$worktree_path"
}

# 関数: Worker割り当て
assign_worker_to_worktree() {
    local worker=$1
    local branch=$2
    local path=$3
    
    # Workerに通知
    ../scripts/enhanced_agent_send.sh "$worker" \
        "Worktree割り当て: $branch ($path) - 'cd $PWD/$path'で移動してください"
    
    # ログ記録
    log_action "ASSIGN" "$worker -> $branch"
}

# 関数: 統合準備
prepare_integration() {
    echo -e "${BLUE}🔄 統合準備開始${NC}"
    
    local report="# Worktree統合レポート\n\n"
    report+="生成時刻: $(date)\n\n"
    
    # 各Worktreeの状態確認
    git worktree list | while read -r line; do
        local path=$(echo "$line" | awk '{print $1}')
        local branch=$(echo "$line" | awk '{print $3}' | tr -d '[]')
        
        if [[ "$path" != "$(pwd)" ]]; then
            report+="## $branch\n"
            report+="パス: $path\n"
            
            # 変更確認
            cd "$path"
            local changes=$(git status --porcelain | wc -l)
            local commits=$(git log main.."$branch" --oneline | wc -l)
            
            report+="- 未コミット変更: $changes ファイル\n"
            report+="- 新規コミット: $commits 個\n"
            
            # マージ可能性チェック
            if git merge-base --is-ancestor main "$branch"; then
                report+="- マージ状態: ✅ Fast-forward可能\n"
            else
                # コンフリクトチェック
                local conflicts=$(git merge-tree $(git merge-base main "$branch") main "$branch" | grep -c "<<<<<<" || true)
                if [ "$conflicts" -gt 0 ]; then
                    report+="- マージ状態: ⚠️ コンフリクトあり ($conflicts 箇所)\n"
                else
                    report+="- マージ状態: ✅ マージ可能\n"
                fi
            fi
            
            report+="\n"
            cd - > /dev/null
        fi
    done
    
    # レポート保存
    echo -e "$report" > "reports/worktree-integration-$(date +%Y%m%d-%H%M%S).md"
    
    # Boss通知
    notify_boss "統合レポート生成完了。確認してください。"
    
    echo -e "${GREEN}✅ 統合準備完了${NC}"
}

# 関数: Claude Code hooks通知
notify_boss() {
    local message=$1
    
    # hooks経由で通知（将来実装）
    # claude-code-hook notify "CCTeam: $message"
    
    # 現在はログに記録
    log_action "NOTIFY" "$message"
}

# 関数: ログ記録
log_action() {
    local action=$1
    local details=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] $action: $details" >> "$LOG_FILE"
}

# 関数: 設定保存
save_worktree_config() {
    local worktrees=("$@")
    local config="{\n  \"created\": \"$(date)\",\n  \"worktrees\": [\n"
    
    for worktree in "${worktrees[@]}"; do
        IFS=':' read -r branch worker <<< "$worktree"
        config+="    {\"branch\": \"$branch\", \"worker\": \"$worker\"},\n"
    done
    
    config="${config%,*}\n  ]\n}"
    echo -e "$config" > "$WORKTREE_CONFIG"
}

# メイン処理
case "${1:-help}" in
    "create-project-worktrees")
        create_project_worktrees
        ;;
    "prepare-integration")
        prepare_integration
        ;;
    "status")
        git worktree list
        ;;
    "clean")
        echo "古いWorktreeをクリーンアップしますか？ (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git worktree prune
        fi
        ;;
    *)
        echo "Usage: $0 {create-project-worktrees|prepare-integration|status|clean}"
        ;;
esac
```

### Phase 2: DevContainer完全自動化（3日）

#### 2.1 DevContainer起動時の自動セットアップ

**.devcontainer/auto-setup.sh**
```bash
#!/bin/bash
# DevContainer自動セットアップ v1.0.0

set -e

echo "🚀 CCTeam DevContainer 完全自動セットアップ開始"

# 1. 基本セットアップ（既存のpost-create.sh実行）
/workspaces/CCTeam/.devcontainer/post-create.sh

# 2. CCTeam自動起動設定
cat >> ~/.bashrc << 'EOF'

# CCTeam自動起動オプション
if [ -z "$CCTEAM_AUTO_STARTED" ]; then
    echo "🤖 CCTeamを自動起動しますか？ (y/n/always)"
    read -r response
    
    case "$response" in
        y|Y)
            export CCTEAM_AUTO_STARTED=1
            cd /workspaces/CCTeam && ccteam
            ;;
        always)
            echo "export CCTEAM_AUTO_START=always" >> ~/.bashrc
            export CCTEAM_AUTO_STARTED=1
            cd /workspaces/CCTeam && ccteam
            ;;
        *)
            echo "手動起動: ccteam"
            ;;
    esac
fi

# 自動起動設定確認
if [ "$CCTEAM_AUTO_START" = "always" ] && [ -z "$CCTEAM_AUTO_STARTED" ]; then
    export CCTEAM_AUTO_STARTED=1
    cd /workspaces/CCTeam && ccteam
fi
EOF

# 3. Git Worktree初期設定
cd /workspaces/CCTeam
if [ ! -d "worktrees" ]; then
    echo "📁 Worktree環境を初期化中..."
    ./scripts/worktree-parallel-manual.sh setup
fi

# 4. requirements確認
if [ -d "requirements" ] && [ "$(ls -A requirements/*.md 2>/dev/null)" ]; then
    echo "📋 要件定義を検出しました"
    echo "CCTeam起動後、以下のコマンドでプロジェクトを開始できます："
    echo "  ./scripts/agent-send.sh boss \"requirementsフォルダの要件を読み込んで、プロジェクトを開始してください\""
fi

# 5. 通知設定
setup_notifications() {
    # Claude Code hooks設定
    mkdir -p ~/.claude/hooks
    cat > ~/.claude/hooks/ccteam-notify.sh << 'HOOK'
#!/bin/bash
# CCTeam通知フック

EVENT=$1
MESSAGE=$2

case "$EVENT" in
    "task_complete")
        notify-send "CCTeam" "$MESSAGE" -i terminal
        ;;
    "error")
        notify-send "CCTeam Error" "$MESSAGE" -i error -u critical
        ;;
    "approval_needed")
        notify-send "CCTeam 承認待ち" "$MESSAGE" -i info -u critical
        ;;
esac
HOOK
    chmod +x ~/.claude/hooks/ccteam-notify.sh
}

setup_notifications

echo "✅ 自動セットアップ完了！"
```

#### 2.2 DevContainer設定の更新

**.devcontainer/devcontainer.json** (更新)
```json
{
  "name": "CCTeam Development - Auto",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  
  // 既存の設定...
  
  "postCreateCommand": "bash .devcontainer/auto-setup.sh",
  
  "customizations": {
    "vscode": {
      "settings": {
        // 既存の設定...
        "terminal.integrated.shellIntegration.enabled": true,
        "terminal.integrated.automationShell.linux": "/bin/bash"
      }
    }
  },
  
  // Worktree用の追加マウント
  "mounts": [
    "source=${localEnv:HOME}/.claude,target=/home/vscode/.claude,type=bind,consistency=cached,readonly",
    // Worktreeパフォーマンス最適化
    "source=ccteam-worktrees,target=/workspaces/CCTeam/worktrees,type=volume"
  ],
  
  // 環境変数
  "containerEnv": {
    "CCTEAM_DEV_CONTAINER": "true",
    "CCTEAM_AUTO_WORKTREE": "true"
  }
}
```

### Phase 3: 通知システム実装（3日）

#### 3.1 Claude Code Hooks統合

**scripts/notification-manager.sh**
```bash
#!/bin/bash
# CCTeam通知マネージャー v1.0.0

# 通知タイプ
NOTIFY_SUCCESS="task_complete"
NOTIFY_ERROR="error"
NOTIFY_APPROVAL="approval_needed"
NOTIFY_INFO="info"

# 通知送信関数
send_notification() {
    local type=$1
    local title=$2
    local message=$3
    local priority=${4:-normal}
    
    # Claude Code hooks確認
    if [ -f ~/.claude/hooks/notify ]; then
        ~/.claude/hooks/notify "$type" "$title" "$message" "$priority"
    fi
    
    # 代替通知（WSL/Linux）
    if command -v notify-send &> /dev/null; then
        case "$type" in
            "$NOTIFY_ERROR")
                notify-send "$title" "$message" -i error -u critical
                ;;
            "$NOTIFY_APPROVAL")
                notify-send "$title" "$message" -i info -u critical
                ;;
            *)
                notify-send "$title" "$message" -i terminal
                ;;
        esac
    fi
    
    # macOS通知
    if command -v osascript &> /dev/null; then
        osascript -e "display notification \"$message\" with title \"$title\""
    fi
    
    # ログ記録
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $type: $title - $message" >> logs/notifications.log
}

# Boss完了通知
notify_task_complete() {
    local task=$1
    send_notification "$NOTIFY_SUCCESS" "CCTeam タスク完了" "$task"
}

# エラー通知
notify_error() {
    local error=$1
    send_notification "$NOTIFY_ERROR" "CCTeam エラー" "$error" "critical"
}

# 承認要求通知
notify_approval_needed() {
    local request=$1
    send_notification "$NOTIFY_APPROVAL" "CCTeam 承認待ち" "$request" "critical"
}

# エクスポート
export -f send_notification
export -f notify_task_complete
export -f notify_error
export -f notify_approval_needed
```

### Phase 4: 統合と最適化（1週間）

#### 4.1 launch-ccteam-v4.sh（DevContainer対応版）

```bash
#!/bin/bash
# CCTeam起動スクリプト v4.0.0 - DevContainer & Worktree自動化対応

VERSION="4.0.0"

# DevContainer環境チェック
if [ "$CCTEAM_DEV_CONTAINER" = "true" ]; then
    echo "🐳 DevContainer環境を検出"
    
    # Worktree自動セットアップ
    if [ "$CCTEAM_AUTO_WORKTREE" = "true" ] && [ ! -f worktrees/.auto-setup-done ]; then
        echo "🌳 Worktree自動セットアップ中..."
        ./scripts/worktree-auto-manager.sh create-project-worktrees
        touch worktrees/.auto-setup-done
    fi
fi

# 既存の起動処理...
# (launch-ccteam-v3.shの内容を継承)

# Boss v2モード有効化
export BOSS_VERSION="2.0"
export BOSS_AUTO_WORKTREE="true"
export BOSS_NOTIFICATION="true"

# 起動完了通知
source ./scripts/notification-manager.sh
notify_info "CCTeam起動完了" "開発環境の準備ができました"
```

---

## 📊 実装スケジュール

### Week 1
- [ ] Boss v2指示書作成
- [ ] worktree-auto-manager.sh実装
- [ ] 既存スクリプトとの統合テスト

### Week 2
- [ ] DevContainer自動セットアップ実装
- [ ] 通知システム実装
- [ ] launch-ccteam-v4.sh作成

### Week 3
- [ ] 統合テスト
- [ ] ドキュメント更新
- [ ] ユーザーガイド作成

---

## 🎯 成功指標

1. **完全自動化率**: 90%以上
2. **セットアップ時間**: 3分以内
3. **エラー率**: 5%以下
4. **ユーザー満足度**: 承認フロー明確化

---

## ⚠️ リスクと対策

### リスク1: 自動化による予期しない動作
**対策**: 
- すべての破壊的操作に承認ステップ
- ドライラン機能の実装
- ロールバック機能

### リスク2: 既存ワークフローとの互換性
**対策**:
- v3モードの維持オプション
- 段階的移行サポート
- 設定による動作切り替え

---

## 📝 移行ガイド

### 既存ユーザー向け
1. `git pull`で最新版取得
2. `./migrate-to-v4.sh`実行
3. DevContainerで再起動

### 新規ユーザー向け
1. リポジトリクローン
2. VSCodeで開く
3. "Reopen in Container"
4. 自動セットアップ完了！

---

**Created by SasukeTorii / REV-C Inc.**