#!/bin/bash
# CCTeam セキュリティユーティリティ v1.0.0
# 共通のセキュリティ関数

set -euo pipefail

# パス検証関数
validate_path() {
    local path=$1
    local base_dir=${2:-""}
    
    # 空のパスチェック
    if [ -z "$path" ]; then
        echo "ERROR: 空のパスが指定されました" >&2
        return 1
    fi
    
    # パストラバーサル攻撃の検出
    if [[ "$path" =~ \.\. ]] || [[ "$path" =~ ^/ && -n "$base_dir" ]]; then
        echo "ERROR: 無効なパス: $path" >&2
        return 1
    fi
    
    # スペースや特殊文字のチェック
    if [[ "$path" =~ [[:space:]\$\`\'\"\\\<\>\|] ]]; then
        echo "ERROR: パスに無効な文字が含まれています: $path" >&2
        return 1
    fi
    
    # ベースディレクトリ内かチェック
    if [ -n "$base_dir" ]; then
        local real_path=$(realpath -m "$base_dir/$path" 2>/dev/null || echo "")
        local real_base=$(realpath "$base_dir" 2>/dev/null || echo "")
        
        if [ -z "$real_path" ] || [ -z "$real_base" ] || [[ ! "$real_path" =~ ^"$real_base" ]]; then
            echo "ERROR: パスがベースディレクトリ外です: $path" >&2
            return 1
        fi
    fi
    
    return 0
}

# 環境変数検証関数
validate_env_var() {
    local var_name=$1
    local pattern=${2:-".*"}
    local required=${3:-false}
    
    local value="${!var_name:-}"
    
    # 必須チェック
    if [ "$required" = "true" ] && [ -z "$value" ]; then
        echo "ERROR: 必須環境変数が設定されていません: $var_name" >&2
        return 1
    fi
    
    # パターンマッチ
    if [ -n "$value" ] && ! [[ "$value" =~ $pattern ]]; then
        echo "ERROR: 環境変数の値が無効です: $var_name" >&2
        return 1
    fi
    
    return 0
}

# URL検証関数
validate_url() {
    local url=$1
    local allowed_protocols=${2:-"https"}
    
    if [ -z "$url" ]; then
        return 0  # 空のURLは許可
    fi
    
    # プロトコルチェック
    local protocol_pattern="^($allowed_protocols)://"
    if ! [[ "$url" =~ $protocol_pattern ]]; then
        echo "ERROR: 無効なURLプロトコル: $url" >&2
        return 1
    fi
    
    # 基本的なURL構造チェック
    if ! [[ "$url" =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,} ]]; then
        echo "ERROR: 無効なURL形式: $url" >&2
        return 1
    fi
    
    return 0
}

# ファイル権限チェック関数
check_file_permissions() {
    local file=$1
    local expected_perms=${2:-"600"}
    
    if [ ! -f "$file" ]; then
        echo "ERROR: ファイルが存在しません: $file" >&2
        return 1
    fi
    
    local actual_perms=$(stat -c %a "$file" 2>/dev/null || stat -f %Lp "$file" 2>/dev/null)
    
    if [ "$actual_perms" != "$expected_perms" ]; then
        echo "WARNING: ファイル権限が推奨値と異なります: $file (現在: $actual_perms, 推奨: $expected_perms)" >&2
        return 1
    fi
    
    return 0
}