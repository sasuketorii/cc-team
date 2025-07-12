#!/bin/bash
# セキュリティユーティリティ関数
# worktree-auto-manager.sh等から利用される

set -euo pipefail

# セキュアなgit clone実行
secure_clone() {
    local repo_url=$1
    local target_dir=$2
    
    # URLの検証
    if [[ ! "$repo_url" =~ ^(https://|git@|ssh://) ]]; then
        echo "エラー: 無効なリポジトリURL: $repo_url" >&2
        return 1
    fi
    
    # ディレクトリの検証
    if [[ -e "$target_dir" ]]; then
        echo "エラー: ターゲットディレクトリが既に存在します: $target_dir" >&2
        return 1
    fi
    
    # クローン実行
    git clone "$repo_url" "$target_dir"
}

# worktreeパスの検証
validate_worktree_path() {
    local path=$1
    
    # パス内に危険な文字が含まれていないか確認
    if [[ "$path" =~ \.\. ]] || [[ "$path" =~ ^/ ]]; then
        echo "エラー: 無効なworktreeパス: $path" >&2
        return 1
    fi
    
    # プロジェクトディレクトリ内かチェック
    local abs_path=$(cd "$(dirname "$path")" 2>/dev/null && pwd)/$(basename "$path")
    local project_root=$(git rev-parse --show-toplevel 2>/dev/null)
    
    if [[ ! "$abs_path" =~ ^"$project_root" ]]; then
        echo "エラー: worktreeパスがプロジェクト外です: $path" >&2
        return 1
    fi
    
    return 0
}

# Git権限チェック
check_git_permissions() {
    local repo_path=${1:-.}
    
    # .gitディレクトリの存在確認
    if [[ ! -d "$repo_path/.git" ]] && ! git -C "$repo_path" rev-parse --git-dir >/dev/null 2>&1; then
        echo "エラー: Gitリポジトリが見つかりません: $repo_path" >&2
        return 1
    fi
    
    # 書き込み権限確認
    if [[ ! -w "$repo_path" ]]; then
        echo "エラー: リポジトリへの書き込み権限がありません: $repo_path" >&2
        return 1
    fi
    
    # Git設定の確認
    if ! git -C "$repo_path" config user.name >/dev/null 2>&1; then
        echo "警告: Git user.nameが設定されていません" >&2
    fi
    
    if ! git -C "$repo_path" config user.email >/dev/null 2>&1; then
        echo "警告: Git user.emailが設定されていません" >&2
    fi
    
    return 0
}

# エクスポート可能にする
export -f secure_clone
export -f validate_worktree_path
export -f check_git_permissions