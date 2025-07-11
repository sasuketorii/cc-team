#!/bin/bash
# Claude Code用の安全なGitコマンド

# 安全なgit add（プロジェクトルート確認付き）
safe_git_add() {
    local current_dir=$(pwd)
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    
    # CCTeamプロジェクト内かチェック
    if [[ "$current_dir" == *"/CC-Team/CCTeam"* ]]; then
        echo "✅ CCTeamプロジェクト内で実行中"
        git add "$@"
    else
        echo "❌ エラー: CCTeamプロジェクト外での実行を検出"
        echo "現在のディレクトリ: $current_dir"
        echo "Gitルート: $git_root"
        return 1
    fi
}

# プロジェクト専用のgit add
ccteam_add() {
    cd /Users/sasuketorii/CC-Team/CCTeam
    git add "$@"
}

# 使用例
echo "安全なGitコマンドの使い方:"
echo "  safe_git_add .           # 現在のディレクトリで安全にadd"
echo "  ccteam_add README.md     # CCTeamプロジェクトで確実にadd"