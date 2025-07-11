#!/bin/bash
# CCTeam ポート管理システム v1.0.0
# Worktree毎に異なるポートを自動割り当て

set -euo pipefail

# ベースポート定義
BASE_FRONTEND_PORT=3000
BASE_BACKEND_PORT=8000
BASE_DB_PORT=5432

# ポート設定ファイル
PORT_CONFIG="$HOME/.ccteam/port-assignments.json"

# Worktreeに基づいてポートオフセットを計算
get_port_offset() {
    local worktree_path=$1
    local worktree_name=$(basename "$worktree_path")
    
    case "$worktree_name" in
        "worker1"|"frontend") echo 0 ;;
        "worker2"|"backend") echo 10 ;;
        "worker3"|"testing") echo 20 ;;
        "integration") echo 30 ;;
        *) echo $(( $(echo "$worktree_name" | cksum | cut -d' ' -f1) % 100 * 10 )) ;;
    esac
}

# ポート割り当て
assign_ports() {
    local worktree_path=${1:-$(pwd)}
    local offset=$(get_port_offset "$worktree_path")
    
    export FRONTEND_PORT=$((BASE_FRONTEND_PORT + offset))
    export BACKEND_PORT=$((BASE_BACKEND_PORT + offset))
    export DB_PORT=$((BASE_DB_PORT + offset))
    
    echo "🔌 ポート割り当て完了:"
    echo "  フロントエンド: http://localhost:$FRONTEND_PORT"
    echo "  バックエンド: http://localhost:$BACKEND_PORT"
    echo "  データベース: localhost:$DB_PORT"
    
    # .envファイルに書き出し
    cat > "$worktree_path/.env.local" << EOF
# CCTeam自動生成ポート設定
PORT=$FRONTEND_PORT
REACT_APP_PORT=$FRONTEND_PORT
NEXT_PUBLIC_PORT=$FRONTEND_PORT
API_PORT=$BACKEND_PORT
DATABASE_PORT=$DB_PORT
EOF
}

# 使用中のポート一覧表示
list_ports() {
    echo "📊 CCTeam ポート使用状況:"
    echo ""
    echo "Worktree          | Frontend | Backend | Database"
    echo "------------------|----------|---------|----------"
    echo "worker1 (base)    | 3000     | 8000    | 5432"
    echo "worker2           | 3010     | 8010    | 5442"
    echo "worker3           | 3020     | 8020    | 5452"
    echo "integration       | 3030     | 8030    | 5462"
}

# プロキシ設定生成（統合表示用）
generate_proxy_config() {
    cat > "$HOME/.ccteam/proxy-config.json" << EOF
{
  "proxies": [
    {
      "name": "Frontend Worker1",
      "source": "/worker1",
      "target": "http://localhost:3000"
    },
    {
      "name": "Frontend Worker2",
      "source": "/worker2",
      "target": "http://localhost:3010"
    },
    {
      "name": "Integration",
      "source": "/integration",
      "target": "http://localhost:3030"
    }
  ]
}
EOF
}

# メイン処理
case "${1:-assign}" in
    assign)
        assign_ports "${2:-}"
        ;;
    list)
        list_ports
        ;;
    proxy)
        generate_proxy_config
        ;;
    *)
        echo "📋 使用方法: $0 <コマンド>"
        echo ""
        echo "利用可能なコマンド:"
        echo "  assign - ワーカーにポートを自動割り当て"
        echo "  list   - 現在のポート割り当てを表示"
        echo "  proxy  - プロキシ設定を生成"
        echo ""
        echo "使用例:"
        echo "  $0 assign   # 各ワーカーに異なるポートを割り当て"
        echo "  $0 list     # 割り当て済みポートの一覧表示"
        ;;
esac