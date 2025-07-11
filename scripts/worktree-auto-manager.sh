#!/bin/bash
# CCTeam Worktree自動管理システム v1.0.0
# Boss v2が使用する自動Worktree管理スクリプト

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# セキュリティユーティリティを読み込み
source "$SCRIPT_DIR/security-utils.sh"

# カラー定義を共通ファイルから読み込み
source "$SCRIPT_DIR/common/colors.sh"

# ログ設定
LOG_DIR="$PROJECT_ROOT/logs"
LOG_FILE="$LOG_DIR/worktree-manager.log"
mkdir -p "$LOG_DIR"

# Worktree設定
WORKTREE_BASE="$PROJECT_ROOT/worktrees"
WORKTREE_CONFIG="$WORKTREE_BASE/.auto-config.json"
mkdir -p "$WORKTREE_BASE"

# ログ関数
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case $level in
        "INFO")  echo -e "${BLUE}[INFO]${NC} $message" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
    esac
}

# 通知送信関数
send_notification() {
    local type=$1
    local message=$2
    
    # notification-manager.shが存在する場合は使用
    if [ -f "$SCRIPT_DIR/notification-manager.sh" ]; then
        source "$SCRIPT_DIR/notification-manager.sh"
        case $type in
            "success") notify_task_complete "$message" ;;
            "error") notify_error "$message" ;;
            "approval") notify_approval_needed "$message" ;;
            *) send_notification "$type" "CCTeam Worktree" "$message" ;;
        esac
    else
        log "INFO" "通知: $message"
    fi
}

# requirements分析関数
analyze_requirements() {
    local req_dir="$PROJECT_ROOT/requirements"
    local analysis=""
    
    log "INFO" "requirements/フォルダを分析中..."
    
    if [ ! -d "$req_dir" ]; then
        log "WARN" "requirements/フォルダが見つかりません"
        echo ""
        return
    fi
    
    # すべての.mdファイルを読み込み
    for file in "$req_dir"/*.md; do
        if [ -f "$file" ]; then
            log "INFO" "分析中: $(basename "$file")"
            analysis+=$(cat "$file" 2>/dev/null || true)
            analysis+="\n"
        fi
    done
    
    echo "$analysis"
}

# プロジェクトタイプ判定関数
determine_project_type() {
    local requirements=$1
    local project_type="standard"
    
    # キーワードベースの判定
    if echo "$requirements" | grep -qi "mobile\|react native\|flutter"; then
        project_type="mobile"
    elif echo "$requirements" | grep -qi "database\|migration\|sql"; then
        project_type="database"
    elif echo "$requirements" | grep -qi "api\|microservice\|backend only"; then
        project_type="api"
    elif echo "$requirements" | grep -qi "frontend only\|spa\|static site"; then
        project_type="frontend"
    fi
    
    log "INFO" "プロジェクトタイプ: $project_type"
    echo "$project_type"
}

# Worktree作成関数
create_worktree() {
    local branch=$1
    local worker=$2
    
    # パス検証
    if ! validate_path "$branch" "$WORKTREE_BASE"; then
        log "ERROR" "無効なブランチ名: $branch"
        return 1
    fi
    
    local worktree_path="$WORKTREE_BASE/$branch"
    
    # 既存チェック
    if [ -d "$worktree_path" ]; then
        log "WARN" "Worktree '$branch' は既に存在します"
        return 0
    fi
    
    log "INFO" "Worktree作成中: $branch (担当: $worker)"
    
    # ブランチが存在するか確認
    if git show-ref --verify --quiet "refs/heads/$branch"; then
        # 既存ブランチを使用
        git worktree add "$worktree_path" "$branch" 2>&1 | tee -a "$LOG_FILE"
    else
        # 新規ブランチを作成
        git worktree add -b "$branch" "$worktree_path" main 2>&1 | tee -a "$LOG_FILE"
    fi
    
    if [ $? -eq 0 ]; then
        log "SUCCESS" "Worktree作成完了: $branch"
        
        # Worker割り当て記録
        echo "$worker:$branch:$worktree_path" >> "$WORKTREE_BASE/.assignments"
        
        return 0
    else
        log "ERROR" "Worktree作成失敗: $branch"
        return 1
    fi
}

# プロジェクト用Worktree自動作成
create_project_worktrees() {
    echo -e "${BLUE}🌳 プロジェクトWorktree自動作成開始${NC}"
    log "INFO" "=== プロジェクトWorktree作成開始 ==="
    
    # requirements分析
    local requirements=$(analyze_requirements)
    local project_type=$(determine_project_type "$requirements")
    
    # 基本Worktreeの定義
    local -a worktrees=(
        "feature/frontend:worker1"
        "feature/backend:worker2"
        "feature/testing:worker3"
    )
    
    # プロジェクトタイプに応じて追加
    case $project_type in
        "mobile")
            log "INFO" "モバイルプロジェクト検出: 追加Worktree作成"
            worktrees+=("feature/mobile:worker1")
            ;;
        "database")
            log "INFO" "データベースプロジェクト検出: 追加Worktree作成"
            worktrees+=("feature/database:worker2")
            ;;
        "api")
            log "INFO" "APIプロジェクト検出: バックエンド重視構成"
            worktrees+=("feature/api-v2:worker2")
            ;;
    esac
    
    # Worktree作成
    local created_count=0
    local failed_count=0
    
    for worktree_info in "${worktrees[@]}"; do
        IFS=':' read -r branch worker <<< "$worktree_info"
        if create_worktree "$branch" "$worker"; then
            ((created_count++))
        else
            ((failed_count++))
        fi
    done
    
    # 設定保存
    save_worktree_config "${worktrees[@]}"
    
    # 結果通知
    local message="Worktree作成完了: 成功 $created_count 個"
    if [ $failed_count -gt 0 ]; then
        message+=" / 失敗 $failed_count 個"
    fi
    
    log "SUCCESS" "$message"
    send_notification "success" "$message"
    
    # Workerへの通知メッセージ生成
    echo ""
    echo -e "${GREEN}✅ Worktree準備完了！${NC}"
    echo ""
    echo "各Workerへの指示:"
    for worktree_info in "${worktrees[@]}"; do
        IFS=':' read -r branch worker <<< "$worktree_info"
        echo "- $worker: cd $WORKTREE_BASE/$branch"
    done
}

# Worker割り当て通知
notify_worker_assignment() {
    local worker=$1
    local branch=$2
    local path=$3
    
    # enhanced_agent_send.shを使用してWorkerに通知
    if [ -f "$SCRIPT_DIR/enhanced_agent_send.sh" ]; then
        local message="Worktree割り当て通知

あなたに新しい作業ブランチが割り当てられました。
ブランチ: $branch
パス: $path

以下のコマンドで移動してください:
cd $path

このブランチで作業を進めてください。"

        "$SCRIPT_DIR/enhanced_agent_send.sh" "$worker" "$message" 2>&1 | tee -a "$LOG_FILE"
    else
        log "WARN" "enhanced_agent_send.shが見つかりません。手動でWorkerに通知してください。"
    fi
}

# 統合レポート生成
prepare_integration() {
    echo -e "${BLUE}🔄 統合レポート生成中...${NC}"
    log "INFO" "=== 統合レポート生成開始 ==="
    
    local report_file="$PROJECT_ROOT/reports/worktree-integration-$(date +%Y%m%d-%H%M%S).md"
    mkdir -p "$PROJECT_ROOT/reports"
    
    # レポートヘッダー
    cat > "$report_file" << EOF
# Worktree統合レポート

生成日時: $(date '+%Y-%m-%d %H:%M:%S')
プロジェクトルート: $PROJECT_ROOT

## 概要

EOF
    
    # 各Worktreeの状態確認
    local total_changes=0
    local total_commits=0
    local has_conflicts=false
    
    git worktree list | while read -r line; do
        local path=$(echo "$line" | awk '{print $1}')
        local branch=$(echo "$line" | awk '{print $3}' | tr -d '[]')
        
        # メインブランチはスキップ
        if [[ "$path" == "$PROJECT_ROOT" ]]; then
            continue
        fi
        
        # worktreesディレクトリ内のみ処理
        if [[ "$path" == *"/worktrees/"* ]]; then
            echo "## $branch" >> "$report_file"
            echo "" >> "$report_file"
            echo "**パス**: \`$path\`" >> "$report_file"
            echo "" >> "$report_file"
            
            # Workerの割り当て確認
            if [ -f "$WORKTREE_BASE/.assignments" ]; then
                local assignment=$(grep ":$branch:" "$WORKTREE_BASE/.assignments" 2>/dev/null | cut -d: -f1)
                if [ -n "$assignment" ]; then
                    echo "**担当**: $assignment" >> "$report_file"
                    echo "" >> "$report_file"
                fi
            fi
            
            # ディレクトリが存在する場合のみ処理
            if [ -d "$path" ]; then
                cd "$path"
                
                # 変更状況
                local changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
                local staged=$(git status --porcelain 2>/dev/null | grep '^[AM]' | wc -l | tr -d ' ')
                local unstaged=$(git status --porcelain 2>/dev/null | grep '^.[MD]' | wc -l | tr -d ' ')
                
                echo "### 変更状況" >> "$report_file"
                echo "- 変更ファイル数: $changes" >> "$report_file"
                echo "- ステージ済み: $staged" >> "$report_file"
                echo "- 未ステージ: $unstaged" >> "$report_file"
                echo "" >> "$report_file"
                
                total_changes=$((total_changes + changes))
                
                # コミット履歴
                local commits=$(git log main.."$branch" --oneline 2>/dev/null | wc -l | tr -d ' ')
                if [ "$commits" -gt 0 ]; then
                    echo "### 新規コミット ($commits 件)" >> "$report_file"
                    echo "\`\`\`" >> "$report_file"
                    git log main.."$branch" --oneline --max-count=5 2>/dev/null >> "$report_file"
                    if [ "$commits" -gt 5 ]; then
                        echo "... 他 $((commits - 5)) 件" >> "$report_file"
                    fi
                    echo "\`\`\`" >> "$report_file"
                    echo "" >> "$report_file"
                fi
                
                total_commits=$((total_commits + commits))
                
                # マージ可能性チェック
                echo "### マージ状態" >> "$report_file"
                
                # Fast-forward可能か確認
                if git merge-base --is-ancestor main "$branch" 2>/dev/null; then
                    echo "✅ **Fast-forward可能**" >> "$report_file"
                else
                    # マージコンフリクトチェック（簡易版）
                    local merge_base=$(git merge-base main "$branch" 2>/dev/null)
                    if [ -n "$merge_base" ]; then
                        # マージツリーでコンフリクト検出
                        local conflicts=$(git merge-tree "$merge_base" main "$branch" 2>/dev/null | grep -c '<<<<<<' || true)
                        if [ "$conflicts" -gt 0 ]; then
                            echo "⚠️ **コンフリクトの可能性あり** ($conflicts 箇所)" >> "$report_file"
                            has_conflicts=true
                        else
                            echo "✅ **マージ可能（コンフリクトなし）**" >> "$report_file"
                        fi
                    else
                        echo "❓ **マージ状態不明**" >> "$report_file"
                    fi
                fi
                echo "" >> "$report_file"
                
                cd - > /dev/null
            else
                echo "⚠️ **Worktreeディレクトリが存在しません**" >> "$report_file"
                echo "" >> "$report_file"
            fi
            
            echo "---" >> "$report_file"
            echo "" >> "$report_file"
        fi
    done
    
    # サマリー追加
    {
        echo "## サマリー"
        echo ""
        echo "- 総変更ファイル数: $total_changes"
        echo "- 総コミット数: $total_commits"
        echo "- コンフリクトリスク: $([ "$has_conflicts" = true ] && echo "あり ⚠️" || echo "なし ✅")"
        echo ""
        echo "## 推奨アクション"
        echo ""
        
        if [ "$has_conflicts" = true ]; then
            echo "1. コンフリクトが予想されるブランチの確認"
            echo "2. 影響範囲の特定"
            echo "3. マージ戦略の決定"
        else
            echo "1. 各ブランチのテスト実行"
            echo "2. コードレビュー"
            echo "3. 順次マージ"
        fi
    } >> "$report_file"
    
    log "SUCCESS" "統合レポート生成完了: $report_file"
    
    # 通知
    if [ "$has_conflicts" = true ]; then
        send_notification "approval" "統合レポート生成完了。コンフリクトの可能性があります。"
    else
        send_notification "success" "統合レポート生成完了。マージ可能です。"
    fi
    
    echo -e "${GREEN}✅ レポート生成完了${NC}"
    echo "レポート: $report_file"
}

# Worktree設定保存
save_worktree_config() {
    local worktrees=("$@")
    
    cat > "$WORKTREE_CONFIG" << EOF
{
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "project_root": "$PROJECT_ROOT",
  "worktrees": [
EOF
    
    local first=true
    for worktree in "${worktrees[@]}"; do
        IFS=':' read -r branch worker <<< "$worktree"
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> "$WORKTREE_CONFIG"
        fi
        cat >> "$WORKTREE_CONFIG" << EOF
    {
      "branch": "$branch",
      "worker": "$worker",
      "path": "$WORKTREE_BASE/$branch",
      "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    }
EOF
    done
    
    cat >> "$WORKTREE_CONFIG" << EOF

  ]
}
EOF
    
    log "INFO" "Worktree設定を保存しました: $WORKTREE_CONFIG"
}

# 全Worktreeの状態表示
show_status() {
    echo -e "${BLUE}📊 Worktree状態${NC}"
    echo "=================="
    
    # git worktree listの出力を整形
    git worktree list | while read -r line; do
        local path=$(echo "$line" | awk '{print $1}')
        local commit=$(echo "$line" | awk '{print $2}')
        local branch=$(echo "$line" | awk '{print $3}' | tr -d '[]')
        
        # worktreesディレクトリ内のみ表示
        if [[ "$path" == *"/worktrees/"* ]]; then
            echo ""
            echo -e "${GREEN}ブランチ:${NC} $branch"
            echo -e "${BLUE}パス:${NC} $path"
            echo -e "${PURPLE}コミット:${NC} $commit"
            
            # Worker割り当て確認
            if [ -f "$WORKTREE_BASE/.assignments" ]; then
                local assignment=$(grep ":$branch:" "$WORKTREE_BASE/.assignments" 2>/dev/null | cut -d: -f1)
                if [ -n "$assignment" ]; then
                    echo -e "${YELLOW}担当:${NC} $assignment"
                fi
            fi
            
            # 変更状況確認
            if [ -d "$path" ]; then
                cd "$path"
                local changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
                if [ "$changes" -gt 0 ]; then
                    echo -e "${YELLOW}変更:${NC} $changes ファイル"
                else
                    echo -e "${GREEN}状態:${NC} クリーン"
                fi
                cd - > /dev/null
            fi
        fi
    done
    echo ""
}

# クリーンアップ
cleanup_worktrees() {
    echo -e "${YELLOW}⚠️  古いWorktreeをクリーンアップしますか？${NC}"
    echo "30日以上更新のないWorktreeを削除します。"
    echo -n "続行しますか？ (y/N): "
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "キャンセルしました。"
        return
    fi
    
    log "INFO" "Worktreeクリーンアップ開始"
    
    # まずpruneを実行
    git worktree prune
    
    # 30日以上古いWorktreeを検出して削除
    local removed_count=0
    git worktree list --porcelain | grep "^worktree " | while read -r _ path; do
        if [[ "$path" == *"/worktrees/"* ]] && [ -d "$path" ]; then
            # 最終更新日時を確認
            local last_modified=$(find "$path" -type f -name "*.md" -o -name "*.sh" -o -name "*.js" -o -name "*.py" | 
                xargs ls -t 2>/dev/null | head -1 | xargs stat -f "%m" 2>/dev/null || echo "0")
            
            local current_time=$(date +%s)
            local age_days=$(( (current_time - last_modified) / 86400 ))
            
            if [ "$age_days" -gt 30 ]; then
                local branch=$(git -C "$path" branch --show-current 2>/dev/null)
                echo "削除対象: $branch ($age_days 日間更新なし)"
                git worktree remove "$path" --force
                ((removed_count++))
                log "INFO" "Worktree削除: $branch"
            fi
        fi
    done
    
    log "SUCCESS" "クリーンアップ完了: $removed_count 個のWorktreeを削除"
    echo -e "${GREEN}✅ クリーンアップ完了${NC}"
}

# ヘルプ表示
show_help() {
    cat << EOF
${BLUE}CCTeam Worktree自動管理システム v1.0.0${NC}

${GREEN}使用方法:${NC}
  $(basename "$0") <command> [options]

${GREEN}コマンド:${NC}
  create-project-worktrees  - プロジェクト用Worktreeを自動作成
  prepare-integration       - 統合レポートを生成
  status                   - 全Worktreeの状態を表示
  cleanup                  - 古いWorktreeをクリーンアップ
  help                     - このヘルプを表示

${GREEN}例:${NC}
  # プロジェクト開始時
  $(basename "$0") create-project-worktrees

  # 統合前の確認
  $(basename "$0") prepare-integration

  # 状態確認
  $(basename "$0") status

${YELLOW}注意事項:${NC}
  - このスクリプトはBoss v2から自動的に呼び出されます
  - 手動実行も可能です
  - ログは logs/worktree-manager.log に記録されます

EOF
}

# メイン処理
main() {
    case "${1:-help}" in
        "create-project-worktrees")
            create_project_worktrees
            ;;
        "prepare-integration")
            prepare_integration
            ;;
        "status")
            show_status
            ;;
        "cleanup")
            cleanup_worktrees
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo -e "${RED}エラー: 不明なコマンド '$1'${NC}"
            show_help
            exit 1
            ;;
    esac
}

# スクリプト実行
main "$@"