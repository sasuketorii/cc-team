#!/bin/bash

# CCTeam Launch Script v2.0.0
# 幹部・ワーカー分離アーキテクチャ版

set -e

# カラー定義
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
YELLOW=$'\033[0;33m'
PURPLE=$'\033[0;35m'
NC=$'\033[0m'

echo "🚀 CCTeam 起動準備 (v2.0.0)"
echo "=========================="

# 安全確認プロンプト
echo ""
echo "⚠️  注意事項:"
echo "  - 全エージェントは待機モードで起動します"
echo "  - Bossが全ワーカーを管理します"
echo "  - デフォルトは全自動実行モードです"
echo ""

# 起動確認
read -p "CCTeamを起動しますか？ (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "キャンセルしました"
    exit 0
fi

# 承認モードの選択（デフォルトは自動）
echo ""
echo "🤔 Bossの承認モードを選択してください:"
echo "  1) ${YELLOW}全自動実行モード${NC} - Bossが自律的に判断して実行します（デフォルト）"
echo "  2) ${GREEN}ユーザー承認モード${NC} - Bossが重要な決定時にユーザーの承認を求めます"
echo ""
read -p "モードを選択 (1 or 2) [デフォルト: 1]: " -n 1 -r APPROVAL_MODE
echo ""

# デフォルトは全自動実行モード
if [[ -z "$APPROVAL_MODE" ]] || [[ "$APPROVAL_MODE" == "1" ]]; then
    APPROVAL_MODE="auto"
    echo -e "${YELLOW}⚡ 全自動実行モードを選択しました${NC}"
else
    APPROVAL_MODE="user"
    echo -e "${GREEN}✅ ユーザー承認モードを選択しました${NC}"
fi

echo ""
echo "🚀 CCTeam を起動します..."

# セットアップが完了しているか確認
if ! tmux has-session -t ccteam-workers 2>/dev/null || ! tmux has-session -t ccteam-boss 2>/dev/null; then
    echo "⚠️  tmuxセッションが見つかりません"
    echo "まず ./scripts/setup-v2.sh を実行してください"
    exit 1
fi

# 要件定義の存在確認
if [ ! -d "requirements" ] || [ -z "$(ls -A requirements 2>/dev/null)" ]; then
    echo "⚠️  requirements/ フォルダに要件定義ファイルが見つかりません"
    echo "プロジェクトの要件定義を配置してから再実行してください"
    # サンプル作成を提案
    echo ""
    echo "💡 サンプル要件定義を作成するには:"
    echo "   ./scripts/create-sample-requirements.sh"
    exit 1
fi

# ログディレクトリの確認
mkdir -p logs

# タイムスタンプ
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "👋 CCTeamメンバーを起こしています..."
echo ""
echo "🎯 幹部陣を起こしています..."

# Boss（幹部セッション）の起動
tmux send-keys -t ccteam-boss:main.0 "./scripts/claude-auto-launch.expect" C-m
sleep 5  # 起動待機時間を延長
echo "  💼 BOSSが目覚めました！"

# Gemini（幹部セッション）の起動 - 一時的に無効化
# tmux send-keys -t ccteam-boss:main.1 "cd $(pwd) && gemini" C-m
# sleep 7  # Node.js起動のため長めに設定
echo "  🤖 GEMINI（相談役）は一時的に無効化中..."

echo ""
echo "👷 ワーカーたちを起こしています..."

# Worker1 (ペイン0)
tmux send-keys -t ccteam-workers:main.0 "./scripts/claude-auto-launch.expect" C-m
sleep 5  # 起動待機時間を延長
echo "  🎨 Worker1（フロントエンド）が起きました！"

# Worker2 (ペイン1)
tmux send-keys -t ccteam-workers:main.1 "./scripts/claude-auto-launch.expect" C-m
sleep 5  # 起動待機時間を延長
echo "  ⚙️  Worker2（バックエンド）が起きました！"

# Worker3 (ペイン2)
tmux send-keys -t ccteam-workers:main.2 "./scripts/claude-auto-launch.expect" C-m
sleep 5  # 起動待機時間を延長
echo "  🔧 Worker3（インフラ/テスト）が起きました！"

echo ""
echo "🎊 CCTeam全員が目覚めました！"
echo ""

# 待機モードの指示を送信
echo "⏸️  待機モードの指示を送信しています..."

# BOSSへの初期指示（承認モードを含む）
if [[ "$APPROVAL_MODE" == "auto" ]]; then
    BOSS_INSTRUCTION="🎯 Boss統括管理者として起動しました。

⚡ 承認モード: 全自動実行モード - 自律的に判断して実行してください。
👥 役割: あなたはWorker1-3を管理し、彼らの作業を承認/否認します。
🤖 Gemini: あなたの右隣にいるGeminiはAI戦略相談役です。技術的な相談や調査を依頼できます。
📋 管理対象:
  - Worker1: フロントエンド開発
  - Worker2: バックエンド開発  
  - Worker3: インフラ/テスト

⏸️ 現在は待機モードです。ユーザーからの指示を待ってください。"
else
    BOSS_INSTRUCTION="🎯 Boss統括管理者として起動しました。

🔐 承認モード: ユーザー承認モード - 重要な決定はユーザーに確認を求めてください。
👥 役割: あなたはWorker1-3を管理し、彼らの作業を承認/否認します。
🤖 Gemini: あなたの右隣にいるGeminiはAI戦略相談役です。技術的な相談や調査を依頼できます。
📋 管理対象:
  - Worker1: フロントエンド開発
  - Worker2: バックエンド開発
  - Worker3: インフラ/テスト

⏸️ 現在は待機モードです。ユーザーからの指示を待ってください。"
fi

# 各Workerへの初期指示（役割を明確に）
WORKER1_INSTRUCTION="🎨 Worker1（フロントエンド担当）として起動しました。

📋 担当領域: UI/UX、フロントエンド開発、ユーザーインターフェース
🎯 上司: Boss（幹部セッション）からの指示に従ってください
⏸️ 現在は待機モードです。Bossからの指示を待ってください。"

WORKER2_INSTRUCTION="⚙️ Worker2（バックエンド担当）として起動しました。

📋 担当領域: API開発、データベース設計、サーバーサイドロジック
🎯 上司: Boss（幹部セッション）からの指示に従ってください
⏸️ 現在は待機モードです。Bossからの指示を待ってください。"

WORKER3_INSTRUCTION="🔧 Worker3（インフラ/テスト担当）として起動しました。

📋 担当領域: インフラ構築、CI/CD、テスト自動化、品質保証
🎯 上司: Boss（幹部セッション）からの指示に従ってください
⏸️ 現在は待機モードです。Bossからの指示を待ってください。"

# Geminiへの初期指示
GEMINI_INSTRUCTION="🤖 Gemini戦略相談役として起動しました。

📋 役割: Bossの戦略的アドバイザー
🎯 支援内容: 技術調査、意思決定支援、リスク分析、アーキテクチャ提案
💡 左隣のBossからの相談に対して、迅速かつ的確なアドバイスを提供してください。
⏸️ 現在は待機モードです。Bossからの相談を待ってください。"

# 各エージェントに指示を送信
echo ""
echo "📤 初期指示を送信中..."

# 全エージェントの起動完了を待つ
echo ""
echo "⏳ エージェントの起動完了を待っています..."
sleep 5

# Boss
echo -n "  Boss への指示送信... "
./scripts/agent-send.sh boss "$BOSS_INSTRUCTION" > /dev/null 2>&1
echo "✅"
sleep 3

# Workers
echo -n "  Worker1 への指示送信... "
./scripts/agent-send.sh worker1 "$WORKER1_INSTRUCTION" > /dev/null 2>&1
echo "✅"
sleep 3

echo -n "  Worker2 への指示送信... "
./scripts/agent-send.sh worker2 "$WORKER2_INSTRUCTION" > /dev/null 2>&1
echo "✅"
sleep 3

echo -n "  Worker3 への指示送信... "
./scripts/agent-send.sh worker3 "$WORKER3_INSTRUCTION" > /dev/null 2>&1
echo "✅"
sleep 3

# Gemini（一時的に無効化）
# echo -n "  Gemini への指示送信... "
# sleep 3  # Gemini用に追加の待機
# ./scripts/agent-send.sh gemini "$GEMINI_INSTRUCTION" > /dev/null 2>&1
# echo "✅"
echo "  Gemini への指示送信... スキップ（一時無効化）"

# 起動ログ
echo "[$TIMESTAMP] CCTeam launched successfully (v2.0.0 - Executive-Worker Architecture)" >> logs/system.log

echo ""
echo "✅ CCTeamが待機モードで起動しました！"
echo ""
echo "⏸️  ${YELLOW}全エージェントは待機状態です${NC}"
echo ""
echo "📝 エージェント構成："
echo ""
echo "  【幹部セッション】"
echo "  ${RED}BOSS${NC}    - 統括管理、タスク分配、承認/否認"
echo "  ${PURPLE}GEMINI${NC}  - AI戦略相談役、技術調査、意思決定支援"
echo ""
echo "  【ワーカーセッション】"
echo "  ${BLUE}Worker1${NC} - フロントエンド開発（UI/UX）"
echo "  ${GREEN}Worker2${NC} - バックエンド開発（API/DB）"
echo "  ${YELLOW}Worker3${NC} - インフラ・テスト（Docker/CI/CD）"
echo ""
echo "📺 セッションに接続するには:"
echo ""
echo "  ${GREEN}tmux attach -t ccteam-boss${NC}     # 幹部セッション（Boss + Gemini）"
echo "  ${GREEN}tmux attach -t ccteam-workers${NC}  # ワーカーセッション（Worker×3）"
echo ""
echo "  【セッション切り替え】"
echo "  tmux内で ${GREEN}Ctrl+b → s${NC} でセッション一覧を表示"
echo ""
echo "🚀 作業を開始するには、BOSSに指示を送信してください:"
echo "   ${GREEN}./scripts/agent-send.sh boss \"requirementsを読み込んで作業を開始してください\"${NC}"
echo ""
echo "📊 ステータスを確認するには:"
echo "   ${GREEN}./scripts/project-status.sh${NC}"
echo ""
echo "💡 tmux操作方法:"
echo "  セッション一覧: ${GREEN}Ctrl+b → s${NC}"
echo "  セッション切替: ${GREEN}Ctrl+b → (${NC} または ${GREEN}Ctrl+b → )${NC}"
echo "  ペイン切り替え: ${GREEN}Ctrl+b → 矢印キー${NC}"
echo "  デタッチ: ${GREEN}Ctrl+b → d${NC}"
echo "  スクロール: ${GREEN}Ctrl+b → [${NC} (qで終了)"
echo "  ペイン最大化: ${GREEN}Ctrl+b → z${NC} (もう一度で解除)"
echo ""
if [[ "$APPROVAL_MODE" == "auto" ]]; then
    echo "⚡ ${YELLOW}全自動実行モード${NC}で動作中 - Bossが自律的に判断します"
else
    echo "🔐 ${GREEN}ユーザー承認モード${NC}で動作中 - 重要な決定時に確認を求めます"
fi
echo ""
echo "⚡ エージェントはあなたの指示を待っています！"