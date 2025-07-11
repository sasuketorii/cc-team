#!/bin/bash
# CCTeam 共通カラー定義 v0.1.5
# 全スクリプトで統一されたカラーを使用するための定義ファイル

# 基本カラー
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export YELLOW='\033[1;33m'  # 太字で視認性向上
export CYAN='\033[0;36m'
export PURPLE='\033[0;35m'
export NC='\033[0m'         # No Color (リセット)

# 拡張カラー（必要に応じて使用）
export BOLD='\033[1m'
export DIM='\033[2m'
export UNDERLINE='\033[4m'

# 背景色（特殊な強調用）
export BG_RED='\033[41m'
export BG_GREEN='\033[42m'
export BG_YELLOW='\033[43m'
export BG_BLUE='\033[44m'

# 使用例:
# source "$(dirname "${BASH_SOURCE[0]}")/common/colors.sh"
# echo -e "${GREEN}✅ 成功${NC}"
# echo -e "${RED}❌ エラー${NC}"
# echo -e "${YELLOW}⚠️  警告${NC}"
# echo -e "${BLUE}ℹ️  情報${NC}"