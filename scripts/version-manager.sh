#!/bin/bash
# セマンティックバージョニング自動管理システム
# 0.0.1刻みで自動的にバージョンアップし、簡単に戻せるようにする

set -e

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 現在のバージョンを取得
get_current_version() {
    # package.jsonから取得を試みる
    if [ -f "package.json" ] && command -v jq &> /dev/null; then
        VERSION=$(jq -r '.version // "0.0.0"' package.json)
    else
        # なければgit tagから最新バージョンを取得
        VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
        VERSION=${VERSION#v}  # v接頭辞を削除
    fi
    echo "$VERSION"
}

# バージョンをインクリメント
increment_version() {
    local version=$1
    local type=${2:-patch}  # デフォルトはパッチ（0.0.1刻み）
    
    # バージョンを分解
    IFS='.' read -r major minor patch <<< "$version"
    
    case "$type" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch|*)
            patch=$((patch + 1))
            ;;
    esac
    
    echo "$major.$minor.$patch"
}

# package.jsonを更新
update_package_json() {
    local new_version=$1
    
    if [ -f "package.json" ] && command -v jq &> /dev/null; then
        tmp=$(mktemp)
        jq --arg version "$new_version" '.version = $version' package.json > "$tmp"
        mv "$tmp" package.json
        echo -e "${GREEN}✓ Updated package.json to v$new_version${NC}"
    fi
}

# 変更をコミットしてタグ付け
commit_and_tag() {
    local version=$1
    local message=$2
    
    # 変更をステージング
    git add -A
    
    # コミットメッセージ生成
    if [ -z "$message" ]; then
        # Geminiで自動生成
        CHANGES=$(git diff --cached --name-only | head -10)
        message=$(gemini "以下のファイル変更に基づいて、簡潔な日本語のコミットメッセージを1行で生成して: $CHANGES" 2>/dev/null || echo "Update: v$version")
    fi
    
    # コミット
    git commit -m "🔖 v$version: $message" || {
        echo -e "${RED}No changes to commit${NC}"
        return 1
    }
    
    # タグ付け
    git tag -a "v$version" -m "Version $version

Changes:
$message

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
    
    echo -e "${GREEN}✓ Tagged as v$version${NC}"
}

# GitHubにプッシュ
push_to_github() {
    local version=$1
    local branch=$(git branch --show-current)
    
    echo -e "${YELLOW}📤 Pushing to GitHub...${NC}"
    
    # コミットとタグをプッシュ
    git push origin "$branch"
    git push origin "v$version"
    
    # GitHub Releasesを作成（ghコマンドが利用可能な場合）
    if command -v gh &> /dev/null; then
        echo -e "${YELLOW}📋 Creating GitHub Release...${NC}"
        
        # リリースノート生成
        RELEASE_NOTES=$(gemini "バージョン$versionのリリースノートを生成して。前回からの変更: $(git log --oneline -10)" 2>/dev/null || echo "Version $version release")
        
        gh release create "v$version" \
            --title "v$version" \
            --notes "$RELEASE_NOTES" \
            --target "$branch"
        
        echo -e "${GREEN}✓ GitHub Release created${NC}"
    fi
}

# バージョンロールバック
rollback_version() {
    local target_version=${1:-}
    
    if [ -z "$target_version" ]; then
        # 利用可能なバージョンを表示
        echo -e "${BLUE}Available versions:${NC}"
        git tag -l "v*" | sort -V | tail -10
        echo ""
        read -p "Enter version to rollback to (e.g., v0.1.2): " target_version
    fi
    
    # バージョンが存在するか確認
    if ! git rev-parse "$target_version" &> /dev/null; then
        echo -e "${RED}❌ エラー: バージョン '$target_version' が見つかりません${NC}"
        echo -e "${YELLOW}   利用可能なバージョンを確認するには以下を実行してください:${NC}"
        echo -e "${YELLOW}   $0 list${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}⏮️  Rolling back to $target_version...${NC}"
    
    # 現在の変更を保存
    if ! git diff --quiet || ! git diff --cached --quiet; then
        git stash push -m "Auto-stash before rollback to $target_version"
    fi
    
    # チェックアウト
    git checkout "$target_version"
    
    echo -e "${GREEN}✓ Rolled back to $target_version${NC}"
    echo "To go back to latest: git checkout main"
}

# バージョン履歴表示
show_version_history() {
    echo -e "${BLUE}📊 Version History:${NC}"
    echo "=================="
    
    git tag -l "v*" | sort -V | tail -20 | while read -r tag; do
        commit=$(git rev-list -n 1 "$tag")
        date=$(git show -s --format=%ci "$commit" | cut -d' ' -f1)
        message=$(git tag -l -n1 "$tag" | sed "s/^$tag\s*//")
        
        echo -e "${GREEN}$tag${NC} ($date) - $message"
    done
}

# 自動バージョンアップとコミット
auto_version_commit() {
    local message=${1:-}
    local type=${2:-patch}
    
    # 現在のバージョン取得
    CURRENT_VERSION=$(get_current_version)
    echo -e "${BLUE}Current version: v$CURRENT_VERSION${NC}"
    
    # 新しいバージョン計算
    NEW_VERSION=$(increment_version "$CURRENT_VERSION" "$type")
    echo -e "${YELLOW}New version: v$NEW_VERSION${NC}"
    
    # package.json更新
    update_package_json "$NEW_VERSION"
    
    # コミットとタグ付け
    if commit_and_tag "$NEW_VERSION" "$message"; then
        # GitHubにプッシュ
        read -p "Push to GitHub? (y/N): " push_confirm
        if [ "$push_confirm" = "y" ]; then
            push_to_github "$NEW_VERSION"
        fi
    fi
}

# メインコマンド処理
case "$1" in
    "bump"|"up")
        auto_version_commit "$2" "${3:-patch}"
        ;;
    "major")
        auto_version_commit "$2" "major"
        ;;
    "minor")
        auto_version_commit "$2" "minor"
        ;;
    "patch")
        auto_version_commit "$2" "patch"
        ;;
    "rollback"|"back")
        rollback_version "$2"
        ;;
    "history"|"list")
        show_version_history
        ;;
    "current")
        echo "v$(get_current_version)"
        ;;
    *)
        echo "🏷️  CCTeam バージョン管理システム"
        echo "================================"
        echo ""
        echo "📋 使用方法: $0 <コマンド> [引数]"
        echo ""
        echo "利用可能なコマンド:"
        echo "  bump [メッセージ]     - パッチバージョンを上げる (0.0.1 → 0.0.2)"
        echo "  major [メッセージ]    - メジャーバージョンを上げる (0.9.0 → 1.0.0)"
        echo "  minor [メッセージ]    - マイナーバージョンを上げる (0.0.9 → 0.1.0)"
        echo "  patch [メッセージ]    - bumpと同じ（パッチ更新）"
        echo "  rollback [バージョン] - 指定バージョンに戻す"
        echo "  history              - バージョン履歴を表示"
        echo "  current              - 現在のバージョンを表示"
        echo ""
        echo "バージョン番号の意味:"
        echo "  メジャー.マイナー.パッチ (例: 1.2.3)"
        echo "  • メジャー: 大きな変更、後方互換性なし"
        echo "  • マイナー: 新機能追加、後方互換性あり"
        echo "  • パッチ: バグ修正、小さな改善"
        echo ""
        echo "使用例:"
        echo "  $0 bump \"ログイン画面のバグ修正\"     # 0.0.1 → 0.0.2"
        echo "  $0 minor \"ユーザー管理機能を追加\"    # 0.0.2 → 0.1.0"
        echo "  $0 rollback v0.0.1               # v0.0.1に戻す"
        echo "  $0 rollback v0.0.1          # Go back to v0.0.1"
        ;;
esac