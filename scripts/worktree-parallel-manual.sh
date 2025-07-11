#!/bin/bash

# CCTeam Git Worktree 並列開発マニュアル v0.0.8
# 複数ブランチでの並列開発を支援するスクリプト

set -euo pipefail

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

# worktreeディレクトリ
WORKTREE_DIR="worktrees"
MAIN_BRANCH="main"

# ヘルプメッセージ
show_help() {
    cat << EOF
${BLUE}CCTeam Git Worktree 並列開発マニュアル v0.0.8${NC}

${GREEN}概要:${NC}
Git worktreeを使用して、複数のブランチで並列開発を行うためのツールです。
各Workerが異なるブランチで作業することで、競合を避けながら効率的に開発できます。

${GREEN}使用方法:${NC}
  $0 <command> [options]

${GREEN}コマンド:${NC}
  setup                     - worktree環境の初期設定
  create <branch> <worker>  - 新しいworktreeを作成
  list                      - 既存のworktreeを一覧表示
  switch <worker> <branch>  - Workerを特定のworktreeに切り替え
  sync                      - 全worktreeを最新状態に同期
  remove <branch>           - worktreeを削除
  status                    - 全worktreeの状態を確認
  guide                     - 詳細な使用ガイドを表示
  auto-assign               - Workerに自動でworktreeを割り当て

${GREEN}例:${NC}
  # 初期設定
  $0 setup

  # Worker1用にfeature/uiブランチのworktreeを作成
  $0 create feature/ui worker1

  # 全worktreeの状態確認
  $0 status

  # Worker自動割り当て
  $0 auto-assign

${YELLOW}推奨ワークフロー:${NC}
1. ./scripts/worktree-parallel-manual.sh setup
2. ./scripts/worktree-parallel-manual.sh auto-assign
3. 各Workerが割り当てられたworktreeで作業
4. 定期的に ./scripts/worktree-parallel-manual.sh sync で同期

EOF
}

# worktree環境の初期設定
setup_worktrees() {
    echo -e "${BLUE}🔧 Git Worktree環境を設定中...${NC}"
    
    # worktreeディレクトリ作成
    mkdir -p "$WORKTREE_DIR"
    
    # 現在のブランチを確認
    CURRENT_BRANCH=$(git branch --show-current)
    echo "現在のブランチ: $CURRENT_BRANCH"
    
    # mainブランチが存在しない場合は作成
    if ! git show-ref --verify --quiet refs/heads/"$MAIN_BRANCH"; then
        echo -e "${YELLOW}⚠️  $MAIN_BRANCH ブランチが存在しません。作成しますか？ (y/n)${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git checkout -b "$MAIN_BRANCH"
            git checkout "$CURRENT_BRANCH"
        fi
    fi
    
    # .gitignoreにworktreesを追加
    if ! grep -q "^worktrees/$" .gitignore 2>/dev/null; then
        echo "worktrees/" >> .gitignore
        echo -e "${GREEN}✅ .gitignoreにworktreesを追加しました${NC}"
    fi
    
    # 設定ファイルを作成
    cat > "$WORKTREE_DIR/.config" << EOF
# CCTeam Worktree Configuration
CREATED_AT=$(date)
MAIN_BRANCH=$MAIN_BRANCH
WORKER_ASSIGNMENTS=()
EOF
    
    echo -e "${GREEN}✅ Worktree環境の設定が完了しました${NC}"
}

# 新しいworktreeを作成
create_worktree() {
    local branch=$1
    local worker=${2:-""}
    local worktree_path="$WORKTREE_DIR/$branch"
    
    echo -e "${BLUE}🌳 新しいworktreeを作成中: $branch${NC}"
    
    # ブランチが既に存在するか確認
    if git show-ref --verify --quiet "refs/heads/$branch"; then
        echo -e "${YELLOW}ブランチ '$branch' は既に存在します${NC}"
        git worktree add "$worktree_path" "$branch"
    else
        # 新しいブランチを作成
        git worktree add -b "$branch" "$worktree_path" "$MAIN_BRANCH"
    fi
    
    # Workerへの割り当て
    if [[ -n "$worker" ]]; then
        echo "$worker:$branch:$worktree_path" >> "$WORKTREE_DIR/.assignments"
        echo -e "${GREEN}✅ $worker に $branch を割り当てました${NC}"
    fi
    
    echo -e "${GREEN}✅ Worktree作成完了: $worktree_path${NC}"
}

# worktree一覧表示
list_worktrees() {
    echo -e "${BLUE}📋 現在のWorktree一覧:${NC}"
    echo ""
    
    # git worktree listの出力を整形
    git worktree list | while read -r line; do
        path=$(echo "$line" | awk '{print $1}')
        branch=$(echo "$line" | awk '{print $3}' | tr -d '[]')
        
        # Worker割り当て情報を確認
        if [[ -f "$WORKTREE_DIR/.assignments" ]]; then
            assignment=$(grep ":$branch:" "$WORKTREE_DIR/.assignments" 2>/dev/null | cut -d: -f1)
            if [[ -n "$assignment" ]]; then
                echo -e "  ${GREEN}$branch${NC} → $path ${YELLOW}(担当: $assignment)${NC}"
            else
                echo -e "  ${GREEN}$branch${NC} → $path"
            fi
        else
            echo -e "  ${GREEN}$branch${NC} → $path"
        fi
    done
    
    echo ""
}

# Workerを特定のworktreeに切り替え
switch_worker() {
    local worker=$1
    local branch=$2
    local worktree_path="$WORKTREE_DIR/$branch"
    
    if [[ ! -d "$worktree_path" ]]; then
        echo -e "${RED}❌ Worktree '$worktree_path' が存在しません${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🔄 $worker を $branch ブランチに切り替え中...${NC}"
    
    # tmuxペインでディレクトリを変更
    case $worker in
        worker1) PANE="ccteam:main.1" ;;
        worker2) PANE="ccteam:main.2" ;;
        worker3) PANE="ccteam:main.3" ;;
        *) echo -e "${RED}不明なWorker: $worker${NC}"; return 1 ;;
    esac
    
    # ディレクトリ変更コマンドを送信
    tmux send-keys -t "$PANE" "cd $(pwd)/$worktree_path" C-m
    
    # 割り当て情報を更新
    grep -v "^$worker:" "$WORKTREE_DIR/.assignments" > "$WORKTREE_DIR/.assignments.tmp" 2>/dev/null || true
    echo "$worker:$branch:$worktree_path" >> "$WORKTREE_DIR/.assignments.tmp"
    mv "$WORKTREE_DIR/.assignments.tmp" "$WORKTREE_DIR/.assignments"
    
    echo -e "${GREEN}✅ $worker を $branch に切り替えました${NC}"
}

# 全worktreeを同期
sync_worktrees() {
    echo -e "${BLUE}🔄 全worktreeを同期中...${NC}"
    
    # メインリポジトリでfetch
    git fetch --all
    
    # 各worktreeで更新
    git worktree list | while read -r line; do
        path=$(echo "$line" | awk '{print $1}')
        branch=$(echo "$line" | awk '{print $3}' | tr -d '[]')
        
        if [[ "$path" != "$(pwd)" ]]; then
            echo -e "${YELLOW}同期中: $branch${NC}"
            (
                cd "$path"
                # リモートの変更を取得
                git pull origin "$branch" --rebase || echo "⚠️  $branch の同期に失敗"
            )
        fi
    done
    
    echo -e "${GREEN}✅ 同期完了${NC}"
}

# worktreeを削除
remove_worktree() {
    local branch=$1
    local worktree_path="$WORKTREE_DIR/$branch"
    
    echo -e "${YELLOW}⚠️  worktree '$branch' を削除しますか？ (y/n)${NC}"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        git worktree remove "$worktree_path" --force
        
        # 割り当て情報も削除
        if [[ -f "$WORKTREE_DIR/.assignments" ]]; then
            grep -v ":$branch:" "$WORKTREE_DIR/.assignments" > "$WORKTREE_DIR/.assignments.tmp" || true
            mv "$WORKTREE_DIR/.assignments.tmp" "$WORKTREE_DIR/.assignments"
        fi
        
        echo -e "${GREEN}✅ worktree '$branch' を削除しました${NC}"
    else
        echo "削除をキャンセルしました"
    fi
}

# 全worktreeの状態確認
show_status() {
    echo -e "${BLUE}📊 Worktree状態レポート${NC}"
    echo "========================="
    echo ""
    
    git worktree list | while read -r line; do
        path=$(echo "$line" | awk '{print $1}')
        branch=$(echo "$line" | awk '{print $3}' | tr -d '[]')
        
        echo -e "${GREEN}ブランチ: $branch${NC}"
        echo "パス: $path"
        
        # Worker割り当て確認
        if [[ -f "$WORKTREE_DIR/.assignments" ]]; then
            assignment=$(grep ":$branch:" "$WORKTREE_DIR/.assignments" 2>/dev/null | cut -d: -f1)
            if [[ -n "$assignment" ]]; then
                echo -e "担当: ${YELLOW}$assignment${NC}"
            fi
        fi
        
        # 変更状態を確認
        if [[ -d "$path" ]]; then
            (
                cd "$path"
                STATUS=$(git status --porcelain)
                if [[ -n "$STATUS" ]]; then
                    echo -e "状態: ${YELLOW}変更あり${NC}"
                    echo "$STATUS" | head -5
                else
                    echo -e "状態: ${GREEN}クリーン${NC}"
                fi
                
                # 最新コミット
                LATEST_COMMIT=$(git log -1 --oneline 2>/dev/null || echo "コミットなし")
                echo "最新: $LATEST_COMMIT"
            )
        fi
        
        echo "-------------------------"
    done
}

# 詳細ガイドを表示
show_guide() {
    cat << 'EOF'

================================================================================
                    CCTeam Git Worktree 並列開発ガイド
================================================================================

📚 概念説明
-----------
Git worktreeは、1つのリポジトリから複数の作業ディレクトリを作成する機能です。
各Workerが異なるブランチで同時に作業でき、切り替えのオーバーヘッドがありません。

🏗️ アーキテクチャ
----------------
CCTeam/
├── .git/                    # メインリポジトリ
├── worktrees/              # worktreeディレクトリ
│   ├── feature/ui/         # Worker1の作業ディレクトリ
│   ├── feature/api/        # Worker2の作業ディレクトリ
│   └── feature/tests/      # Worker3の作業ディレクトリ
└── [その他のプロジェクトファイル]

📋 推奨ワークフロー
------------------
1. 初期設定
   $ ./scripts/worktree-parallel-manual.sh setup

2. 機能開発の開始
   $ ./scripts/worktree-parallel-manual.sh create feature/new-feature worker1

3. Workerの切り替え
   $ ./scripts/worktree-parallel-manual.sh switch worker1 feature/new-feature

4. 定期的な同期
   $ ./scripts/worktree-parallel-manual.sh sync

5. 開発完了後のマージ
   - 各worktreeでコミット
   - プルリクエスト作成
   - mainブランチへマージ

6. 不要なworktreeの削除
   $ ./scripts/worktree-parallel-manual.sh remove feature/new-feature

⚡ ベストプラクティス
-------------------
1. ブランチ命名規則
   - feature/xxx  : 新機能開発
   - fix/xxx      : バグ修正
   - refactor/xxx : リファクタリング

2. Worker割り当て
   - Worker1: UI/フロントエンド関連 → feature/ui-xxx
   - Worker2: API/バックエンド関連 → feature/api-xxx
   - Worker3: テスト/インフラ関連 → feature/test-xxx

3. コミット規則
   - 各worktreeで頻繁にコミット
   - わかりやすいコミットメッセージ
   - 1機能1コミットを心がける

4. 同期タイミング
   - 作業開始前に必ず同期
   - 大きな変更の前後で同期
   - 1日の終わりに同期

🚨 注意事項
-----------
- worktree内での破壊的な操作は慎重に
- 他のWorkerのworktreeは直接編集しない
- マージ前に必ずテストを実行
- コンフリクトは早期に解決

💡 トラブルシューティング
-----------------------
Q: worktreeが壊れた場合は？
A: git worktree remove --force <path> で強制削除後、再作成

Q: 同期でコンフリクトが発生した場合は？
A: 該当worktreeで手動解決後、git rebase --continue

Q: worktreeの場所を忘れた場合は？
A: ./scripts/worktree-parallel-manual.sh list で確認

📞 サポート
-----------
問題が発生した場合は、BOSSエージェントに相談してください：
$ ./scripts/agent-send.sh boss "worktreeで問題が発生しました: [詳細]"

================================================================================
EOF
}

# Workerに自動でworktreeを割り当て
auto_assign() {
    echo -e "${BLUE}🤖 Workerに自動でworktreeを割り当て中...${NC}"
    
    # 既存の割り当てをクリア
    > "$WORKTREE_DIR/.assignments"
    
    # 基本的な機能ブランチを作成
    local branches=("feature/frontend" "feature/backend" "feature/testing")
    local workers=("worker1" "worker2" "worker3")
    
    for i in {0..2}; do
        local branch="${branches[$i]}"
        local worker="${workers[$i]}"
        
        # worktreeが存在しない場合は作成
        if [[ ! -d "$WORKTREE_DIR/$branch" ]]; then
            create_worktree "$branch" "$worker"
        else
            echo "$worker:$branch:$WORKTREE_DIR/$branch" >> "$WORKTREE_DIR/.assignments"
            echo -e "${GREEN}✅ $worker に既存の $branch を割り当てました${NC}"
        fi
        
        # Workerを切り替え
        switch_worker "$worker" "$branch"
    done
    
    echo ""
    echo -e "${GREEN}✅ 自動割り当てが完了しました！${NC}"
    list_worktrees
}

# メイン処理
case "${1:-help}" in
    "setup")
        setup_worktrees
        ;;
    "create")
        if [[ -z "${2:-}" ]]; then
            echo -e "${RED}❌ エラー: ブランチ名が指定されていません${NC}"
            echo -e "${YELLOW}   使用例: $0 create feature/new-ui [worker名]${NC}"
            exit 1
        fi
        create_worktree "$2" "${3:-}"
        ;;
    "list")
        list_worktrees
        ;;
    "switch")
        if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]]; then
            echo -e "${RED}❌ エラー: worker名とブランチ名が指定されていません${NC}"
            echo -e "${YELLOW}   使用例: $0 switch worker1 feature/new-ui${NC}"
            exit 1
        fi
        switch_worker "$2" "$3"
        ;;
    "sync")
        sync_worktrees
        ;;
    "remove")
        if [[ -z "${2:-}" ]]; then
            echo -e "${RED}❌ エラー: 削除するブランチ名が指定されていません${NC}"
            echo -e "${YELLOW}   使用例: $0 remove feature/old-ui${NC}"
            exit 1
        fi
        remove_worktree "$2"
        ;;
    "status")
        show_status
        ;;
    "guide")
        show_guide
        ;;
    "auto-assign")
        auto_assign
        ;;
    "help"|*)
        show_help
        ;;
esac