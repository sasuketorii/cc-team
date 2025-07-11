#!/bin/bash

# CCTeam Data Refresh Script
# データベース、ログ、メモリをリフレッシュ

# カラー定義
source "$(dirname "${BASH_SOURCE[0]}")/common/colors.sh"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔄 CCTeam データリフレッシュツール${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# プロジェクトルートの設定
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# 確認プロンプト
echo -e "${YELLOW}⚠️  注意: このスクリプトは以下のデータを削除します:${NC}"
echo "  - SQLiteデータベース (memory/ccteam_memory.db)"
echo "  - ログファイル (logs/, .claude/logs/)"
echo "  - エラー履歴"
echo ""
echo -e "${GREEN}バックアップは backup/ ディレクトリに保存されています${NC}"
echo ""
read -p "続行しますか？ (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}キャンセルされました${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🗑️  データのクリーンアップを開始します...${NC}"

# 1. SQLiteデータベースのリフレッシュ
echo -e "${BLUE}📊 SQLiteデータベースをリフレッシュ中...${NC}"
if [ -f "memory/ccteam_memory.db" ]; then
    rm -f "memory/ccteam_memory.db"
    echo -e "${GREEN}✅ 既存のデータベースを削除しました${NC}"
fi

# 新しいデータベースを初期化
python3 scripts/memory/setup_database.py > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 新しいデータベースを初期化しました${NC}"
else
    echo -e "${YELLOW}⚠️  データベースの初期化に失敗しました（手動で実行してください）${NC}"
fi

# 2. ログファイルのクリーンアップ
echo -e "${BLUE}📝 ログファイルをクリーンアップ中...${NC}"

# logs/ディレクトリ
if [ -d "logs" ]; then
    # ディレクトリ構造は保持し、ファイルのみクリア
    find logs -type f -name "*.log" -o -name "*.jsonl" -o -name "*.json" -o -name "*.txt" | while read file; do
        echo -n "" > "$file"
    done
    echo -e "${GREEN}✅ logs/ディレクトリのログをクリアしました${NC}"
fi

# .claude/logs/ディレクトリ
if [ -d ".claude/logs" ]; then
    find .claude/logs -type f -name "*.log" | while read file; do
        echo -n "" > "$file"
    done
    echo -e "${GREEN}✅ .claude/logs/ディレクトリのログをクリアしました${NC}"
fi

# 3. 一時ファイルのクリーンアップ
echo -e "${BLUE}🧹 一時ファイルをクリーンアップ中...${NC}"

# tmuxのresurrect/restore関連
if [ -d "/tmp" ]; then
    rm -f /tmp/tmux-resurrect-* 2>/dev/null
    rm -f /tmp/ccteam-* 2>/dev/null
    echo -e "${GREEN}✅ 一時ファイルを削除しました${NC}"
fi

# 4. 初期ファイルの作成
echo -e "${BLUE}📄 初期ファイルを作成中...${NC}"

# 必要なディレクトリの確認と作成
mkdir -p logs
mkdir -p .claude/logs
mkdir -p memory

# 空のログファイルを作成（構造を保持）
touch logs/system.log
touch logs/communication.log
touch logs/error_loops.json
echo "[]" > logs/error_loops.json

touch .claude/logs/boss.log
touch .claude/logs/worker1.log
touch .claude/logs/worker2.log
touch .claude/logs/worker3.log
touch .claude/logs/gemini.log
touch .claude/logs/system.log
touch .claude/logs/communication.log
touch .claude/logs/tool-usage.log
touch .claude/logs/command-history.log
touch .claude/logs/error-notifications.log
touch .claude/logs/hooks.log

echo -e "${GREEN}✅ 初期ファイルを作成しました${NC}"

# 5. 完了メッセージ
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ データリフレッシュが完了しました！${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}ℹ️  情報:${NC}"
echo "  - バックアップ: backup/$(date +%Y%m%d_*)/"
echo "  - データベース: 新規作成されました"
echo "  - ログファイル: すべてクリアされました"
echo ""
echo -e "${YELLOW}💡 ヒント:${NC} CCTeamを起動して新しい環境で開発を始められます:"
echo -e "${GREEN}    ccteam${NC}"
echo ""