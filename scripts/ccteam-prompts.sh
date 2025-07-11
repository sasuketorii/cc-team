#!/bin/bash

# CCTeam Prompt Templates
# よく使うプロンプトのテンプレート集

# 共通カラー定義を読み込み
source "$(dirname "${BASH_SOURCE[0]}")/common/colors.sh"

echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "${CYAN}📝 CCTeam プロンプトテンプレート${NC}"
echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "${GREEN}【開発系プロンプト】${NC}"
echo ""

echo "${BLUE}1. 開発開始（推奨）${NC}"
echo "${YELLOW}\"requirementsフォルダの要件を読み込み、役割分担して開発を開始してください\"${NC}"
echo ""

echo "${BLUE}2. 機能開発${NC}"
echo "${YELLOW}\"requirements/[機能名].mdを読み込んで、[機能名]を実装してください\"${NC}"
echo ""

echo "${BLUE}3. バグ修正${NC}"
echo "${YELLOW}\"[エラー内容]が発生しています。原因を調査して修正してください\"${NC}"
echo ""

echo "${GREEN}【管理系プロンプト】${NC}"
echo ""

echo "${BLUE}4. 点呼確認${NC}"
echo "${YELLOW}\"全Worker点呼: 各自の役割と準備状況を報告してください\"${NC}"
echo ""

echo "${BLUE}5. 進捗確認${NC}"
echo "${YELLOW}\"全Workerの現在の進捗を報告してください\"${NC}"
echo ""

echo "${BLUE}6. タスク再分配${NC}"
echo "${YELLOW}\"現在のタスク進捗を確認し、必要に応じてタスクを再分配してください\"${NC}"
echo ""

echo "${GREEN}【品質系プロンプト】${NC}"
echo ""

echo "${BLUE}7. コードレビュー${NC}"
echo "${YELLOW}\"全Workerが実装したコードをレビューし、改善点を指摘してください\"${NC}"
echo ""

echo "${BLUE}8. テスト実行${NC}"
echo "${YELLOW}\"実装した機能の単体テストと統合テストを実行してください\"${NC}"
echo ""

echo "${BLUE}9. 品質チェック${NC}"
echo "${YELLOW}\"リンター、型チェック、テストカバレッジを確認してください\"${NC}"
echo ""

echo "${GREEN}【統合系プロンプト】${NC}"
echo ""

echo "${BLUE}10. 統合確認${NC}"
echo "${YELLOW}\"全Workerの成果物を統合して動作確認してください\"${NC}"
echo ""

echo "${BLUE}11. デプロイ準備${NC}"
echo "${YELLOW}\"本番環境へのデプロイ準備を行ってください（ビルド、環境変数、Docker）\"${NC}"
echo ""

echo "${BLUE}12. リリース作業${NC}"
echo "${YELLOW}\"v[バージョン]のリリース作業を実施してください（タグ付け、リリースノート作成）\"${NC}"
echo ""

echo "${GREEN}【トラブルシューティング】${NC}"
echo ""

echo "${BLUE}13. エラー調査${NC}"
echo "${YELLOW}\"[エラーログ]を分析し、原因と解決策を提示してください\"${NC}"
echo ""

echo "${BLUE}14. パフォーマンス改善${NC}"
echo "${YELLOW}\"アプリケーションのパフォーマンスを分析し、改善案を実装してください\"${NC}"
echo ""

echo "${BLUE}15. セキュリティ確認${NC}"
echo "${YELLOW}\"セキュリティ脆弱性をチェックし、必要な対策を実施してください\"${NC}"
echo ""

echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "💡 使い方: コピーしてBossペインに貼り付けてください"
echo "   必要に応じて[括弧]内を実際の値に置き換えてください"
echo ""